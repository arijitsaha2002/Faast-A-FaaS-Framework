#!/bin/bash

if [ $# -ne 4 ]; then
	echo "usage:./map_function.sh app-name image url port"
	exit 1
fi;

APP_NAME="$1"
URL="$3"
APP_TYPE="vpa-deployment"
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
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $APP_NAME-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: $APP_NAME-app
  template:
    metadata:
      labels:
        app: $APP_NAME-app 
    spec:
      containers:
      - name: $APP_NAME-app 
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
  name: $APP_NAME-service
  labels:
    app: $APP_NAME-app
spec:
  ports:
    - protocol: TCP
      port: 8080
      targetPort: $PORT_NUMBER 
  selector:
    app: $APP_NAME-app 
  type: LoadBalancer
---
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: vpa-development-$APP_NAME
spec:
  targetRef:
    apiVersion: \"apps/v1\"
    kind: Deployment
    name: $APP_NAME-app
  resourcePolicy:
    containerPolicies:
      - containerName: '*'
        minAllowed:
          cpu: 20m
          memory: 50Mi
        maxAllowed:
          cpu: 1
          memory: 100Mi 
        controlledResources: [\"cpu\", \"memory\"]
" > "$APP_NAME-$APP_TYPE".yaml
if [[ ! -f ../ingress.csv ]];
then
    echo "url,service,port" >> ../ingress.csv
fi;

echo "$URL,$APP_NAME-service,8080" >> ../ingress.csv
kubectl apply -f "$APP_NAME-$APP_TYPE".yaml
cd ../
./update-ingress.py
kubectl apply -f "./ingress.yaml"


