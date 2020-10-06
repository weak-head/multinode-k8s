clean:
	kind delete cluster

deploy:
	# Create cluster of 3 nodes
	kind create cluster --config kind-config.yaml

	# Enable dashboard
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta4/aio/deploy/recommended.yaml

	# Forward k8s dashboard to the host machine
	kubectl apply -f dashboard.yaml

get-auth-token:
	# Get Auth Token for k8s dashboard
	# http://localhost:7070
	kubectl -n kube-system describe secret \
			$(kubectl -n kube-system get secret \
				| grep deployment-controller-token \
				| awk '{print $1}')