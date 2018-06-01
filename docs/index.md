---
title: Overview
order: 1
---

The DataWorkbench consists of applications running as services in containers on a Kubernetes cluster. Applications are grouped in pods that run on the same machine, and can share for instance a local disk.

The current version uses the Google Kubernetes Engine (GKE) to host and manage the cluster, and Google Cloud products to provide storage services and load balancing.

```mermaid
graph TB

subgraph DataWorkbench Services
  API
  FE(Front end)
  DV(IATI Validator)
  DR(IATI Data Refresher)
end

subgraph Cluster

  subgraph Service Nodes
    App(Web Application Pods)
    Mongo(MongoDB Pods)
  end

  subgraph Data Processing Node
    IE(IATI Processing Pods)
  end
end

subgraph Google Cloud
  GKE(Kubernetes Engine)
  GS(File Storage)
  PD(Persistent Disks)
  GR(Repositories)
  PS(Message Queues)
  GKE -.-> GS
  GKE -.-> PD
  GKE -.-> GR
  GKE -.-> PS
end

API --- App
API -.- Mongo
API -.- GS
API -.- PS

FE --- App
FE -.-> API

DR -.-> API
DR --- IE
DR -.- PS

DV --- IE

IE -.- GR

App --- GKE
IE --- GKE
Mongo --- GKE

```
