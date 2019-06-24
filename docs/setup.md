---
title: Setup
---

Steps needed to deploy the DataWorkbench components. Most of these are specific for the Google Kubernetes Engine environment and may not work in another context.

## Create a Google project

The project will hold all configuration, billing, billing, service accounts, access control and more.

Components used:

### Container Registry

Tag container images with the appropriate location name. Push the images to the registry to make them available in the cluster(s) in the project.

### Storage

Create the Google Storage buckets for each environment.

{:.warning}

TODO: Bucket names have to be globally unique, which poses problems working with different environments: the service(s) using the Storage backend will need to be configured to use the appropriate buckets.

### Postgresql

Create a Postgresql instance, and add a Private IP as a connection. The IP address and the username and password of a Postgres user are required in the configuration of the cluster.

It's possible to use [the proxy application](https://cloud.google.com/sql/docs/postgres/connect-external-app#proxy) to connect with the Postgresql instance from a developer machine. Start the proxy and use for instance psql to connect via the proxy. Java applications (such as Eclipse or DBeaver) work with the TCP-based version of the proxy.

```bash
./cloud_sql_proxy -instances=d4d-dataworkbench:europe-west4:d4d-dataworkbench-1=tcp:19432 &
```

The setup folder has the DDL to set up the Pentaho logs database in a database of choice.

### VPC network

Under "External IP addresses", reserve a global static IP address to be used by the ingress later on. Give it a name like `stage-ip4-dataworkbench-io`:

```bash
gcloud compute addresses create stage-ip4-dataworkbench-io` --global
```

{:.warning}

Make sure to use the `--global` flag, otherwise the ingress will not bind to it.

The address can now be used in the Ingress specification:

```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: dwb-ingress
  annotations:
    kubernetes.io/ingress.global-static-ip-name: stage-ip4-dataworkbench-io
```

Once the IP address is available, add it to the DNS of the domain of choice.

## Create a Kubernetes cluster

Google organises its resources in regions, each with multiple zones. Typically, the cluster and its persistent disks and so on run in a single zone.

* Set up a standard cluster
* Add a default-pool with 3 n1-standard-1 nodes. Select "Advanced edit".
  * Change the access scopes to "Allow full access to all Cloud APIs" (or configure access to each API).
  * Add a label `node = core`
* Add a second pool with 1 n1-standard-2 node.
  * Enable auto-scaling, from 1 to a suitable maximum number of nodes.
  * Enable pre-emptible nodes to make these nodes only live up to 24 hours, and suitable for termination. Such nodes are a lot cheaper, but only work for stateless containers or batch jobs that can be restarted without a problem.
  * Also change the access scopes to "Allow full access to all Cloud APIs".
  * Add a label `node = preemptible`
* Open the "Availability, networking, ..." settings.
  * Enable VPC-native
  * Make sure HTTP load balancing is enabled, to be able to use the Ingress component.

{:.warning}

The **access scopes setting** of a node pool cannot be changed after the pool is created.

Once the cluster is created, it is possible to connect to it with the gcloud shell.

### IAM & admin

There is one component in the Mongo configuration to add a cluster role binding authorization. For this, the person deploying the configuration needs to have sufficient privileges in the project, for instance by being the owner of the project.

TODO for API: for local testing with remote storage buckets, you need a key file in JSON to access them. This key file can be obtained via Service Accounts.

### Namespaces

The respective testing, staging and production branches specify their namespace via kustomize.

In `namespace.yaml`:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: testing
```

In `kustomize.yaml`:

```yaml
# ...
resources:
- namespace.yaml

namespace: testing
```

{:.warning}

Nodes and persistentVolumes are not in a namespace. For storage in persistentVolumes, this requires some additional configuration to make sure applications don't interfere across namespaces.

### MongoDB

Once the Mongo stateful set is up and running, it still needs to be configured as a replicaset in Mongo.

TODO: write out better instructions

{:.warning}

Most examples of running Mongo on Kubernetes will use a sidecar container that reconfigures Mongo on the fly. This has some risks for larger Mongo replicasets (citation needed). Instead, since we work with a static cluster size, we configure the replicaset by hand for now.

To reconfigure the replicaset in case the host specifications are wrong, this is how it can be done, using the pod addresses as provided by the Kubernetes DNS.

```javascript
cfg = rs.conf()
cfg.members=[{_id:0, host:"mongo-0.mongo"}, {_id:1, host:"mongo-1.mongo"}, {_id:2, host: "mongo-2.mongo"}]
printjson(cfg)
rs.reconfig(cfg, {force : true})
```