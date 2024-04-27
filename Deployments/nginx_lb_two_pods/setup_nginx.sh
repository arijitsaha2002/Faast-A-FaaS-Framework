#!/bin/bash

if [ "$#" -ne 2 ]; then
	echo "Usage: $0 <APP_NAME> <PORT>"
	exit 1
fi

APP_NAME=$1
IP1=$(kubectl get pods -o wide | grep $APP_NAME-single-pod-1 | awk '{print $6}')
IP2=$(kubectl get pods -o wide | grep $APP_NAME-single-pod-2 | awk '{print $6}')
NGINX_CONT_NAME=$APP_NAME-nginx-loadbalancer
PORT=$2


DEFAULT_CONF_FILE=$(echo "
upstream backend {
        server $IP1:$PORT; 
        server $IP2:$PORT; 
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

