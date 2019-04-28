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

TODO: create buckets

### VPC network

Under "External IP addresses", reserve a static IP address to be used by the ingress later on.Give it a name like `stage-ip4-dataworkbench-io` that is used in the Ingress specification using:

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
  * Make sure HTTP load balancing is enabled, to be able to use the Ingress component.

{:.warning}

The **access scopes setting** of a node pool cannot be changed after the pool is created.

Once the cluster is created, it is possible to connect to it with the gcloud shell.

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
