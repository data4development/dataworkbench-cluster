---
title: Environment setup
suborder: 3
---

Once a Google project and of the key cluster infrastructure and backend services are set up, it's time to add a specific deployment environment.

### Storage

Create the Google Storage buckets for each environment.

{:.warning}

TODO: Bucket names have to be globally unique, which poses problems working with different environments: the service(s) using the Storage backend will need to be configured to use the appropriate buckets.

### Postgresql

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

Connect to the first Mongo instance, open a Mongo shell, and run

```javascript
rs.initiate( {
   _id : "rs0",
   members: [
      { _id: 0, host: "mongo-0.mongo:27017" },
      { _id: 1, host: "mongo-1.mongo:27017" },
      { _id: 2, host: "mongo-2.mongo:27017" }
   ]
})
```

{:.warning}

Most examples of running Mongo on Kubernetes will use a sidecar container that reconfigures Mongo on the fly. This has some risks for larger Mongo replicasets (citation needed). Instead, since we work with a static cluster size, we configure the replicaset by hand for now.

To reconfigure the replicaset in case the host specifications are wrong, this is how it can be done, using the pod addresses as provided by the Kubernetes DNS.

```javascript
cfg = rs.conf()
cfg.members=[{_id:0, host:"mongo-0.mongo"}, {_id:1, host:"mongo-1.mongo"}, {_id:2, host: "mongo-2.mongo"}]
printjson(cfg)
rs.reconfig(cfg, {force : true})
```

