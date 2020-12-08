# Multi-node Kubernetes cluster

This repo provides a simple setup for multi-node Kubernetes cluster.  
The K8s cluster is based on [kind](https://kind.sigs.k8s.io/) and comes with enabled [dashboard](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/) and [kubeless](https://kubeless.io/).

You should have [kind](https://kind.sigs.k8s.io/docs/user/quick-start/) and [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) installed and available in your PATH.  
To enable optional features you should also have [helm](https://helm.sh/docs/intro/install/).

## Deploy Kubernetes cluster

```sh
make deploy
```

This will deploy k8s cluster of 3 nodes: 1 control plane and 2 worker nodes.  
The dashboard could be accessed via: https://localhost:7070

## Get Dashboard Auth token

To access the dashboard auth token is required.  
Auth token could be obtained using the following command:

```sh
make get-dashboard-auth-token
```

## Delete cluster

```sh
make clean
```

## Optional Features

* [istio](#istio)
* [keda](#keda)
* [minio](#minio)
* [kafka](#kafka)
* [prometheus & grafana](#prometheus-and-grafana)

### Istio

Download and install [istio release](https://istio.io/latest/docs/setup/getting-started/#download).
After `istioctl` is in the PATH, run the following to install istio to the local cluster:
```sh
make enable-istio

# Access dashboards:
istioctl dashboard [ kiali | jaeger | grafana | zipkin | prometheus ]
```

### Keda

Enable [keda](https://keda.sh/) for event driven autoscaling:
```sh
make enable-keda
```

### Minio

Enable [minio](https://min.io/) object storage:
```sh
make enable-minio
```

### Kafka

Enable [kafka](http://kafka.apache.org/) distributed event streaming platform:
```sh
make enable-kafka

# Forward kafka to local host
kubectl port-forward \
    --namespace kafka \
    service/kafka \
    9092:9092
```

### Prometheus and Grafana

Enable [Prometheus](https://prometheus.io/) and [Grafana](https://grafana.com/) to monitor the Kubernetes cluster:
```sh
make enable-prometheus

# Get grafana username and password
make get-grafana-auth

# Forward grafana to local host
kubectl port-forward \
    --namespace prometheus \
    service/prometheus-grafana \
    3000:80
```
