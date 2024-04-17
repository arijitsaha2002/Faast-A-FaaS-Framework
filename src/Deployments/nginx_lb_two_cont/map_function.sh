#!/bin/bash

if [ $# -neq 4 ]; then
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
    ports:
    - containerPort: $PORT_NUMBER1 
  - name: $APP_NAME-container-2
    image: $IMAGE_NAME2 
    ports:
    - containerPort: $PORT_NUMBER2
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

---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: hpa-flask-ingress-$APP_NAME
spec:
  ingressClassName: nginx
  rules:
  - host: localhost 
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nginx-loadbalancer-service-$APP_NAME
            port:
              number: 8080 


" > "$APP_NAME-$APP_TYPE".yaml
#kubectl apply -f /tmp/map_function_ingress_config

