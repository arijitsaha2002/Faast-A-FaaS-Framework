#starting our kubernetes cluster
minikube start

# enabling metrics-server
minikube addons enable metrics-server
minikube addons enable ingress

#enbling a nginx-ingres-load-balancer
kubectl apply -f AppConfigs/ingres_nginx_config/deploy.yaml



