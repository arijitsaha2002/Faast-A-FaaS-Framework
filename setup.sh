#starting our kubernetes cluster
minikube start

# enabling metrics-server
minikube addons enable metrics-server

# enabling ingress
minikube addons enable ingress

# enabling vpa
#sudo helm repo add cowboysysop https://cowboysysop.github.io/charts/
#sudo helm -n kube-system upgrade --install vertical-pod-autoscaler cowboysysop/vertical-pod-autoscaler

#run tunnel
echo "Visit this URL: $(minikube dashboard --port=20000 --url) to access the kubernetes dashboard"
minikube tunnel
