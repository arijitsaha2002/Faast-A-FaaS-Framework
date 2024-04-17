#!/bin/bash

if [ "$#" -ne 4 ]; then
	echo "Usage: $0 <IP1> <PORT1> <PORT2> <NGINX_CONT_NAME>"
	exit 1
fi

IP1=$1
PORT1=$2
PORT2=$3
NGINX_CONT_NAME=$4

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

