# Multi-node Kubernetes cluster

This repo provides a simple setup for multi-node Kubernetes cluster.  
The K8s cluster is based on [kind](https://kind.sigs.k8s.io/) and comes with enabled [dashboard](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/) and [kubeless](https://kubeless.io/).

## Deploy Kubernetes cluster

```sh
make deploy
```

This will deploy k8s cluster of 3 nodes: 1 control plane and 2 worker nodes.  
The dashboard could be accessed via: https://localhost:7070

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

## Optional Features

Enable [Prometheus](https://prometheus.io/) and [Grafana](https://grafana.com/) to monitor the Kubernetes cluster:
```sh
# Deploy and enable prometheus & grafana
make enable-prometheus

# Get grafana username and password
make get-grafana-auth

# Forward grafana to local host
kubectl port-forward --namespace prometheus service/prometheus-grafana 3000:80
```
