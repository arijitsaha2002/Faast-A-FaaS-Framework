#!/bin/bash

if [ $# -ne 4 ]; then
	echo "usage:./map_function.sh app-name image url port"
	exit 1
fi;

APP_NAME="$1"
URL="$3"
APP_TYPE="hpa-deployment"
IMAGE_NAME="$2"
PORT_NUMBER="$4"

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
      targetPort: 5000 
  selector:
    app: $APP_NAME-app 
  type: LoadBalancer
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
 name: hpa-deployment-$APP_NAME
spec:
 scaleTargetRef:
   apiVersion: apps/v1
   kind: Deployment
   name: $APP_NAME-app
 minReplicas: 1
 maxReplicas: 10
 metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
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
            name: $APP_NAME-service
            port:
              number: 8080 
" > "$APP_NAME-$APP_TYPE".yaml
kubectl apply -f "$APP_NAME-$APP_TYPE".yaml

