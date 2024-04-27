#!/bin/bash

if [ "$#" -ne 3 ]; then
	echo "Usage: $0 <APP_NAME> <PORT1> <PORT2>"
	exit 1
fi
APP_NAME=$1
IP1=$(kubectl get pods -o wide | grep "$APP_NAME-app-1" | awk '{print $6}')
PORT1=$2
PORT2=$3
NGINX_CONT_NAME="nginx-loadbalancer-$APP_NAME"

DEFAULT_CONF_FILE=$(echo "
upstream backend {
        server $IP1:$PORT1; 
        server $IP1:$PORT2; 
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

