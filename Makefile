clean:
	kind delete cluster

deploy:
	# Create cluster of 3 nodes
	kind create cluster --config kind-config.yaml

	# Enable dashboard
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml

	# Forward k8s dashboard to the host machine
	kubectl apply -f dashboard.yaml

	# Create dashboard service account
	kubectl create serviceaccount dashboard-admin-sa

	# Bind dashboard service account to cluster admin role
	kubectl create clusterrolebinding dashboard-admin-sa \
		--clusterrole=cluster-admin \
		--serviceaccount=default:dashboard-admin-sa

get-auth-token:
	# Get Auth Token for k8s dashboard
	# https://localhost:7070

	@kubectl describe secret \
		$(shell kubectl get secrets \
			| grep dashboard-admin-sa \
			| cut -d' ' -f1)