#!/bin/bash

if [ $# -neq 4 ]; then
	echo "usage:./map_function.sh app-name image url port"
	exit 1
fi;

APP_NAME="$1"
URL="$3"
APP_TYPE="single-pod-deployment"
IMAGE_NAME="$2"
PORT_NUMBER="$4"




echo "
apiVersion: v1
kind: Pod
metadata:
  name: $APP_NAME-pod
  labels:
    app: $APP_NAME-pod 
spec:
  containers:
  - name: $APP_NAME-container
    image: $IMAGE_NAME 
    ports:
    - containerPort: $PORT_NUMBER 
---
apiVersion: v1
kind: Service
metadata:
  name: $APP_NAME-pod-service
spec:
  selector:
    app: $APP_NAME-pod  
  ports:
  - protocol: TCP
    port: 8080  
    targetPort: $PORT_NUMBER  
  type: LoadBalancer
" > "$APP_NAME-$APP_TYPE".yaml

