#!/bin/bash

if [ $# -ne 6 ]; then
	echo "usage:./map_function.sh app-name image1 image2 url port1 port2"
	exit 1
fi;

APP_NAME="$1"
URL="$4"
APP_TYPE="two-pod"
IMAGE_NAME1="$2"
IMAGE_NAME2="$3"
PORT_NUMBER1="$5"
PORT_NUMBER2="$6"

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
  name: $APP_NAME-app-1
  labels:
    app: $APP_NAME-app-1
spec:
  containers:
  - name: $APP_NAME-container-1
    image: $IMAGE_NAME1
    imagePullPolicy: IfNotPresent
    ports:
    - containerPort: $PORT_NUMBER1 
    resources:
      limits:
        memory: 50Mi
      requests:
        cpu: 20m
  - name: $APP_NAME-container-2
    image: $IMAGE_NAME2 
    imagePullPolicy: IfNotPresent
    ports:
    - containerPort: $PORT_NUMBER2
    resources:
      limits:
        memory: 50Mi
      requests:
        cpu: 20m
---
apiVersion: v1
kind: Pod
metadata:
  name: nginx-loadbalancer-$APP_NAME
  labels:
    app: nginx-loadbalancer-$APP_NAME
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
  name: nginx-loadbalancer-service-$APP_NAME
spec:
  selector:
    app: nginx-loadbalancer-$APP_NAME
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

echo "$URL,nginx-loadbalancer-service-$APP_NAME,80" >> ../ingress.csv
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

./setup_nginx.sh $APP_NAME $PORT_NUMBER1 $PORT_NUMBER2

echo "Deployment of $APP_NAME is successful."
cd ../
./update-ingress.py
kubectl apply -f "./ingress.yaml"
