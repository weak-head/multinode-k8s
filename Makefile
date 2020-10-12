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


.PHONY: get-auth-token
get-auth-token:
	@kubectl describe secret \
			$(shell kubectl get secrets \
				| grep ${ACCOUNT} \
				| cut -d' ' -f1) \
		| grep 'token:' \
		| cut -d':' -f2 \
		| xargs