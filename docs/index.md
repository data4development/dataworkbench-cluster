---
title: Cluster
order: 1
---

The DataWorkbench consists of applications running as services in containers on a Kubernetes cluster.

The current version uses the Google Kubernetes Engine to host and manage the cluster, and Google Cloud products to provide storage, access and management.

## Cluster configuration and upgrades

Each component in the system has its own git repository. The component code is built into a Docker container image, which is tagged with a version number and stored in a container registry.

Two separate cluster repositories contain the configuration details, including the version numbers of components. The cluster setup is specified using Kubernetes' declarative configuration in YAML files. We use [kustomize with a branches layout](https://kubectl.docs.kubernetes.io/pages/app_composition_and_deployment/structure_branches.html), but with some branches stores in a different, private repository.

* The public repository contains the base configuration details.
* A private repository contains deployment-specific branches for `testing`, `staging` and `production`. These add tuning of cluster parameters such as replica counts, memory limits, namespaces, etc.

In the public cluster configuration repository, the `develop` branch is used for changes in the testing or staging phases. Once promoted to production, the base changes will be merged into the `master` branch.

At the moment, we still perform several steps by hand (red lines). These will become automated steps in a CI/CD pipeline.

![](gitops-current.svg)

## Cluster architecture

The cluster consists of two types of nodes.

1. A `default-pool` of nodes that are permanently available, to run the API, the web front-end, as well as both a Mongo and a Postgres database.

    * The API service provides the point of contact for other services within the cluster, as well as for the outside world.
    * The Mongo database holds information about the datasets in the system, and about IATI publishers (updated from the IATI Registry).
    * The Postgres database currently holds the logs of Pentaho jobs.

2. A `pre-emptible-pool` of nodes to mainly run batch operations. These nodes can be terminated at any point. This pool is configured with auto-scaling to grow as needed (within limits), to offer a trade-off between processing speed and time.

In addition, there still is a separate server running the IATI Data Refresher to update the IATI snapshot. The data is then pushed to a Source Repository on the Google Cloud Platform.

![](./deployment-overview.drawio.svg)

