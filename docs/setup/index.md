---
title: Setup
suborder: 1
---

Steps needed to deploy the DataWorkbench components. Most of these are specific for the Google Kubernetes Engine environment and may not work in another context.

The setup has two main parts:

1. We first need to set up the [basic infrastructure of project and cluster](cluster)
   * Create a Google Cloud project
   * Create a Kubernetes cluster
   * Create the backend services like the Cloud SQL and MongoDB servers
2. We then need to set up a [specific deployment environment](environment) on that infrastructure
   * Configure the deployment for a specific namespace
   * Create specific resources in the backend services for this deployment
     * Storage buckets for files
     * Cloud SQL database
     * Mongo database

## Multi-tenant and deployment pipeline setup

Kubernetes makes it possible to deploy the same configuration in multiple namespaces. This creates good isolation between running environments, whether used for multi-tenant hosting or for deployment pipeline environments (testing, staging, production).

We can use a top-level deployment pipeline using namespaces for `testing`, `staging` and `production`; and additionally, tenant-specific environments like `minbuza-staging`, `iati-production`.

A challenge is using front-end and back-end services to connect the Kubernetes environment to persistent front-end and back-end services.

* Google Storage works with globally unique container/bucket names: we need to connect each Kubernetes environment to its own set of buckets.
* Google Ingress connects a public IP address to a load balancer and back-end services, but does not (yet) allow to connect a single Ingress to services from multiple namespaces: we need an Ingress per environment.
* Our Loopback API implements (major) version-specific API end points (`.../api/v1/...`), which is good for public APIs but also requires internal API users to specify the major version.

### Branch name conventions

Deployments in the cluster are named in the `deploy/...` space: `deploy/staging`, `deploy/minbuza-production`.

(though: name tenant-specific versions in `tenant/minbuza` etc. to distinguish general differences.)

### Deployment helpers

We use a `kubectl` wrapper script that checks for the currently checked out branch of the `cluster` repository, and helpers to switch the default namespace and context (cluster). This makes it easier to deploy a specific version to a specific environment.