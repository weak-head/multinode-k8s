CONFIG ?= kind-config.yaml
CLUSTER_NAME ?= kind
ACCOUNT ?= dashboard-admin-sa

DASHBOARD_URL = https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml
KUBELESS_RELEASE = $(shell curl -s https://api.github.com/repos/kubeless/kubeless/releases/latest \
	| grep tag_name \
	| cut -d '"' -f 4)
KUBELESS_URL = https://github.com/kubeless/kubeless/releases/download/${KUBELESS_RELEASE}/kubeless-${KUBELESS_RELEASE}.yaml


.PHONY: clean
clean:
	kind delete cluster \
		--name ${CLUSTER_NAME}


.PHONY: deploy
deploy:
	# Create cluster of 3 nodes
	kind create cluster \
		--name ${CLUSTER_NAME} \
		--config ${CONFIG} 

	# Enable dashboard
	kubectl apply -f ${DASHBOARD_URL}

	# Forward k8s dashboard to the host machine
	kubectl apply -f dashboard.yaml

	# Create service account to access dashboard
	kubectl create serviceaccount ${ACCOUNT}

	# Bind dashboard service account to cluster admin role
	kubectl create clusterrolebinding ${ACCOUNT} \
		--clusterrole=cluster-admin \
		--serviceaccount=default:${ACCOUNT}

	# Allow to schedule pods on the control-plane nodes 
	kubectl taint nodes --all node-role.kubernetes.io/master- || true

	# Deploy and enable kubeless
	kubectl create ns kubeless
	kubectl create -f ${KUBELESS_URL} 


.PHONY: get-dashboard-auth-token
get-dashboard-auth-token:
	@kubectl describe secret \
			$(shell kubectl get secrets \
				| grep ${ACCOUNT} \
				| cut -d' ' -f1) \
		| grep 'token:' \
		| cut -d':' -f2 \
		| xargs


.PHONY: enable-prometheus
enable-prometheus:
	# Add stable and community repos
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	helm repo add stable https://charts.helm.sh/stable
	helm repo update

	# Dedicated namespace for prometheus
	kubectl create namespace prometheus

	# Enable prometheus and grafana
	helm install prometheus prometheus-community/kube-prometheus-stack \
		--namespace prometheus


.PHONY: enable-keda
enable-keda:
	# Add stable keda repo
	helm repo add kedacore https://kedacore.github.io/charts
	helm repo update

	# Dedicated namespace for keda
	kubectl create namespace keda

	# Enable keda
	helm install keda kedacore/keda \
		--namespace keda


.PHONY: enable-minio
enable-minio:
	# Add minio repo
	helm repo add minio https://helm.min.io/

	# Dedicated namespace for minio
	kubectl create namespace minio

	# Enable minio
	helm install --namespace minio \
		--set accessKey=myaccesskey,secretKey=mysecretkey \
		--generate-name minio/minio


.PHONY: enable-istio
enable-istio:

	# Install istio
	istioctl install --set profile=demo -y

	# Enable istio injection
	kubectl label namespace default istio-injection=enabled

	# Enable kiali (need to apply twice)
	kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.8/samples/addons/kiali.yaml | true
	kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.8/samples/addons/kiali.yaml

	# Enable prometheus
	kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.8/samples/addons/prometheus.yaml

	# Enable grafana
	kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.8/samples/addons/grafana.yaml

	# Enable jaeger 
	kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.8/samples/addons/jaeger.yaml

	# Enable zipkin
	kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.8/samples/addons/extras/zipkin.yaml

	# Enable cert-manager 
	# kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.1.0/cert-manager.yaml


.PHONY: enable-spark
enable-spark:

	# Bitnami charts
	helm repo add bitnami https://charts.bitnami.com/bitnami
	helm repo update

	# Dedicated namespace for spark
	kubectl create namespace spark

	helm install \
		--namespace spark \
		spark bitnami/spark


.PHONY: enable-kafka
enable-kafka:

	# Bitnami charts
	helm repo add bitnami https://charts.bitnami.com/bitnami
	helm repo update

	# Dedicated namespace for kafka
	kubectl create namespace kafka

	helm install \
		--namespace kafka \
		--set replicaCount=3 \
		kafka bitnami/kafka


.PHONY: enable-rabbitmq
enable-rabbitmq:

	# Bitnami charts
	helm repo add bitnami https://charts.bitnami.com/bitnami

	# Dedicated namespace for rabbitmq
	kubectl create namespace rabbitmq

	helm install \
		--namespace rabbitmq \
		--set replicaCount=3 \
		rabbitmq bitnami/rabbitmq
	
	# echo "Username      : user"
	# echo "Password      : $(kubectl get secret --namespace rabbitmq rabbitmq -o jsonpath="{.data.rabbitmq-password}" | base64 --decode)"
	# echo "ErLang Cookie : $(kubectl get secret --namespace rabbitmq rabbitmq -o jsonpath="{.data.rabbitmq-erlang-cookie}" | base64 --decode)"


.PHONY: get-grafana-auth
get-grafana-auth:
	@ kubectl get secret --namespace prometheus prometheus-grafana -o yaml \
		| grep ' admin-user: ' \
		| cut -d':' -f2 \
		| openssl base64 -d \
		| xargs

	@ kubectl get secret --namespace prometheus prometheus-grafana -o yaml \
		| grep ' admin-password: ' \
		| cut -d':' -f2 \
		| openssl base64 -d \
		| xargs
