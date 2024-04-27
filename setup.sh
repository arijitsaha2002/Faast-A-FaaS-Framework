#starting our kubernetes cluster
minikube start

# enabling metrics-server
minikube addons enable metrics-server

# enabling ingress
minikube addons enable ingress

# enabling vpa
helm repo add cowboysysop https://cowboysysop.github.io/charts/
helm -n kube-system upgrade --install vertical-pod-autoscaler cowboysysop/vertical-pod-autoscaler

#run tunnel
minikube dashboard --port=20000 &
minikube tunnel
