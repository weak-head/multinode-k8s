# Multi-node Kubernetes cluster

This repo provides a simple setup for multi-node Kubernetes cluster.  
The K8s cluster is based on [kind](https://kind.sigs.k8s.io/) and comes with enabled [Dashboard](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/).

## Deploy Kubernetes cluster

```sh
make deploy
```

This will deploy k8s cluster of 3 nodes: 1 control plane and 2 worker nodes.  
The dashboard is available here: https://localhost:7070

## Get Auth token

To access the dashboard auth token is required.  
Auth token could be obtained using the following command:

```sh
make get-auth-token
```

## Delete cluster

```sh
make clean
```
