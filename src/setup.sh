#starting our kubernetes cluster
minikube start

# enabling metrics-server
minicube addons enable metrics-server

#enbling a nginx-ingres-load-balancer
kubectl apply -f AppConfig/ingres_nginx_config/deploy.yaml



