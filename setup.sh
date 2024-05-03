#starting our kubernetes cluster
minikube start
echo "url,service,port" > ./Deployments/ingress.csv
# enabling metrics-server
minikube addons enable metrics-server

# enabling ingress
minikube addons enable ingress

# enabling vpa
helm repo add cowboysysop https://cowboysysop.github.io/charts/
helm -n kube-system upgrade --install vertical-pod-autoscaler cowboysysop/vertical-pod-autoscaler

minikube dashboard --port=20000 &
minikube tunnel
