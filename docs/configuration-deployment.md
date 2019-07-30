---
title: Configuration and deployment
order: 2
---

## Cluster configuration and upgrades

Each component in the system has its own git repository. The component code is built into a Docker container image, which is tagged with a version number and stored in a container registry.

Two separate cluster repositories contain the configuration details, including the version numbers of components. The cluster setup is specified using Kubernetes' declarative configuration in YAML files. We use [kustomize with a branches layout](https://kubectl.docs.kubernetes.io/pages/app_composition_and_deployment/structure_branches.html), but with some branches stores in a different, private repository.

* The public repository contains the base configuration details.
* A private repository contains deployment-specific branches for `testing`, `staging` and `production` (branch names start with `deploy/`). These add tuning of cluster parameters such as replica counts, memory limits, namespaces, etc.

In the public cluster configuration repository, the `develop` branch is used for changes in the testing or staging phases. Once promoted to production, the base changes will be merged into the `master` branch.

At the moment, we still perform several steps by hand (red lines). These should become automated steps in a CI/CD pipeline.

![](gitops-current.drawio.svg)

## Container configuration in Docker and Kubernetes

Services and tasks will connect to resources outside the container image. We pass information about the location of these resources to running containers using ConfigMaps and Secrets in Kubernetes.

### Component configuration part (Docker)

In the Dockerfile for a component, we include a section with information about environment variables and configuration files used by the container. These can be adapted using Kubernetes ConfigMaps and Secrets.

```dockerfile
# To be adapted in the cluster or runtime config
#...
# ----------
```

Example portion from the API Dockerfile:

```dockerfile
FROM gcr.io/google_appengine/nodejs

# ...label...

# To be adapted in the cluster or runtime config
ENV \
    # run the API in public mode: \
    # API_TYPE=public \
    \
    CONTAINER_PUBLIC_SOURCE=dataworkbench-iati \
    CONTAINER_PUBLIC_FEEDBACK=dataworkbench-iatifeedback \
    CONTAINER_PUBLIC_JSON=dataworkbench-json \
    CONTAINER_PUBLIC_SVRL=dataworkbench-svrl \
    \
    CONTAINER_UPLOAD_SOURCE=dataworkbench-testfile \
    CONTAINER_UPLOAD_FEEDBACK=dataworkbench-testiatifeedback \
    CONTAINER_UPLOAD_JSON=dataworkbench-testjson \
    CONTAINER_UPLOAD_SVRL=dataworkbench-testsvrl
# ----------

# ... etcetera
```

### Cluster configuration part (Kubernetes)

In the cluster configuration, we use a copy of the environment variables and configuration files to adapt them to a specific deployment.

Step 1: use kustomize to generate a Kubernetes ConfigMap or Secret from the variables.

In `deploy/env/api.env`:

```bash
# run the API in public mode:
# API_TYPE=public

CONTAINER_PUBLIC_SOURCE=my-bucket-iati
CONTAINER_PUBLIC_FEEDBACK=my-bucket-iatifeedback
CONTAINER_PUBLIC_JSON=my-bucket-json
CONTAINER_PUBLIC_SVRL=my-bucket-svrl

CONTAINER_UPLOAD_SOURCE=my-bucket-testfile
CONTAINER_UPLOAD_FEEDBACK=my-bucket-testiatifeedback
CONTAINER_UPLOAD_JSON=my-bucket-testjson
CONTAINER_UPLOAD_SVRL=my-bucket-testsvrl
```

In `deploy/kustomization.`yaml:

```yaml
# ...
configMapGenerator:
- name: iati-kitchen-config
  files:
  - env/project.env
  - env/iati-kitchen.env

# ...
```

Step 2: use the ConfigMap to add the environment variables to a deployment.

In `base/validator-api-public.yaml` we use the general API configuration and add an extra variable to run the public version of the API.

```yaml
# ...
    spec:
      containers:
      - name: validator-api-public-app
        image: gcr.io/dataworkbench-io/validator-api:0.5.7-public
        imagePullPolicy: Always
        ports:
        - name: api-public
          containerPort: 8080
        envFrom:
        - configMapRef:
          name: validator-api-public-config
        env:
        - name: API_TYPE
          value: "public"
# ...
```

When deploying with `kubectl apply -k`, kustomize will create and deploy a ConfigMap with a suffix added to make the name of the configmap unique, and also update the deployment to use that unique configmap name.

Use `kubectl kustomize deploy | less` to inspect the complete configuration that will be deployed in an `apply` command.

## Cluster architecture

The cluster consists of two types of nodes.

1. A `default-pool` of nodes that are permanently available, to run the API, the web front-end, as well as both a Mongo and a Postgres database.

    * The API service provides the point of contact for other services within the cluster, as well as for the outside world.
    * The Mongo database holds information about the datasets in the system, and about IATI publishers (updated from the IATI Registry).
    * The Postgres database currently holds the logs of Pentaho jobs.

2. A `pre-emptible-pool` of nodes to mainly run batch operations. These nodes can be terminated at any point. This pool is configured with auto-scaling to grow as needed (within limits), to offer a trade-off between processing speed and time.

In addition, there still is a separate server running the IATI Data Refresher to update the IATI snapshot. The data is then pushed to a Source Repository on the Google Cloud Platform.

![](./deployment-overview.drawio.svg)

