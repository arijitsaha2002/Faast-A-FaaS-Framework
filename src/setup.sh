#starting our kubernetes cluster
minikube start

# enabling metrics-server
minikube addons enable metrics-server
minikube addons enable ingress

#enbling a nginx-ingres-load-balancer
kubectl apply -f Configs/ingres_nginx_config/deploy.yaml

#enbling vpa autoscaller
kubectl apply -f ./Configs/vpa_config/vpa-v1-crd-gen.yaml
kubectl apply -f ./Configs/vpa_config/vpa-rbac.yaml 



