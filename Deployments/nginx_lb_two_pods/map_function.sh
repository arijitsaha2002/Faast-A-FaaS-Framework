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

---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /\$1
spec:
  ingressClassName: nginx
  rules:
  - http:
      paths:
      - path: /$URL/(.*)
        pathType: ImplementationSpecific
        backend:
          service:
            name: $APP_NAME-nginx-service
            port:
              number: 80 

" > "$APP_NAME-$APP_TYPE".yaml
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
