#!/bin/bash

if [ $# -ne 4 ]; then
	echo "usage:./map_function.sh app-name image url port"
	exit 1
fi;

APP_NAME="$1"
URL="$3"
APP_TYPE="nginx-single-pod-deployment"
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
  name: $APP_NAME-single-pod-1
  labels:
    app: $APP_NAME-single-pod-1
spec:
  containers:
  - name: $APP_NAME-single-container
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
kind: Pod
metadata:
  name: $APP_NAME-single-pod-2
  labels:
    app: $APP_NAME-single-pod-2
spec:
  containers:
  - name: $APP_NAME-single-container
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
kind: Pod
metadata:
  name: $APP_NAME-nginx-loadbalancer 
  labels:
    app: $APP_NAME-nginx-loadbalancer 
spec:
  containers:
  - name: nginx-loadbalancer-container
    image: nginx
    ports:
    - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: $APP_NAME-nginx-service
spec:
  selector:
    app: $APP_NAME-nginx-loadbalancer 
  ports:
  - protocol: TCP
    port: 80  
    targetPort: 80  
  type: LoadBalancer
" > "$APP_NAME-$APP_TYPE".yaml
if ! [[ -f ../ingress.csv ]];
then
    echo "url,service,port" >> ../ingress.csv
fi;

echo "$URL,$APP_NAME-nginx-service,80" >> ../ingress.csv
kubectl apply -f "$APP_NAME-$APP_TYPE".yaml


container_status=0

while [ $container_status -ne 1 ]; do
	echo "Deploying $app_name ..."
	container_status=1
	for i in $(kubectl get pods | sed '1d' | awk '{print $3}'); do
		if [ "$i" != "Running" ]; then
			container_status=0
		fi
	done
	sleep 1
done

./setup_nginx.sh $APP_NAME $PORT_NUMBER

echo "Deployment of $APP_NAME is successful."
cd ../
./update-ingress.py
kubectl apply -f "./ingress.yaml"
