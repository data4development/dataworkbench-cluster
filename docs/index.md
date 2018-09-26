---
title: Cluster
order: 1
---

The DataWorkbench consists of applications running as services in containers on a Kubernetes cluster.

The current version uses the Google Kubernetes Engine to host and manage the cluster, and Google Cloud products to provide storage services and access.

## Towards a GitOps workflow

Each component in the system has its own git repository. The component code can be built into a Docker container image, which is tagged with a version number and stored in a container registry.

In addition, this `cluster` repository contains the configuration details of the deployments, including the version numbers of the images to be used.

![](gitops-current.svg)

## Cluster architecture

The cluster consists of two types of nodes.

1. A `default-pool` of nodes to run the API, the web front-end, and the ad-hoc validation service, as well as both a Mongo and a Postgres database.

    * The API service provides the point of contact for other services within the cluster, as well as for the outside world.
    * The Mongo database holds information about the datasets in the system, and about IATI publishers (updated from the IATI Registry).
    * The Postgres database currently holds the logs of Pentaho jobs.

2. A `validator-pool` of one node to run batch operations on a snapshot of IATI data. All cron jobs run on this validator node, and have access to the local disk of that node to share files.

In addition, there still is a separate server running the IATI Data Refresher to update the IATI snapshot. The data is then pushed to a Source Repository on the Google Cloud Platform.

![](./deployment-overview.drawio.svg)
