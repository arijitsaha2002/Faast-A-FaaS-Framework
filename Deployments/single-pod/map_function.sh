#!/bin/bash

if [ $# -ne 4 ]; then
	echo "usage:./map_function.sh app-name image url port"
	exit 1
fi;

APP_NAME="$1"
URL="$3"
APP_TYPE="single-pod-deployment"
IMAGE_NAME="$2"
PORT_NUMBER="$4"

if [[ -f ../ingress.csv ]]; 
then
    same_url=$(awk -F',' '{print $1}' ../ingress.csv | grep -oE "$URL" | head -1)
    if [[ $same_url != "" ]];
    then
        echo "url already used retry something else"
        exit 1;
    fi;
fi;



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
    imagePullPolicy: IfNotPresent
    ports:
    - containerPort: $PORT_NUMBER 
    resources:
      limits:
        memory: 50Mi
      requests:
        cpu: 20m
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

if ! [[ -f ../ingress.csv ]];
then
    echo "url,service,port" >> ../ingress.csv
fi;

echo "$URL,$APP_NAME-pod-service,8080" >> ../ingress.csv
kubectl apply -f "$APP_NAME-$APP_TYPE".yaml
cd ../
./update-ingress.py
kubectl apply -f "./ingress.yaml"

