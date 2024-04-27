#!/bin/bash

if [ "$#" -ne 1 ]; then
	echo "Usage: $0 <APP_NAME>" 
	exit 1
fi

APP_NAME=$1
IP1=$(kubectl get svc | grep "$APP_NAME-node1-pod-service" | awk '{print $4}')
IP2=$(kubectl get svc | grep "$APP_NAME-node2-pod-service" | awk '{print $4}')
NGINX_CONT_NAME=$APP_NAME-nginx-loadbalancer 

DEFAULT_CONF_FILE=$(echo "
upstream backend {
        server $IP1:8080; 
        server $IP2:8080; 
    }

server {
    listen       80;
    listen  [::]:80;
    server_name  localhost;

    access_log  /var/log/nginx/host.access.log  main;

    location / {
		proxy_pass http://backend; 
    }
}
")

echo $DEFAULT_CONF_FILE > default.conf
kubectl cp default.conf $NGINX_CONT_NAME:/etc/nginx/conf.d/default.conf
kubectl exec -it $NGINX_CONT_NAME -- /bin/bash -c "nginx -s reload"
rm default.conf

