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

echo "
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $APP_NAME-deployment-app 
spec:
  selector:
    matchLabels:
      app: $APP_NAME-app
  replicas: 2
  template:
    metadata:
      labels:
        app: $APP_NAME-app
    spec:
      containers:
        - name: $APP_NAME-cotainer
          image: $IMAGE_NAME
          imagePullPolicy: IfNotPresent
          resources:
            requests:
              cpu: 5m
              memory: 50Mi
            limits:
              cpu: 50m
          ports:
            - containerPort: $PORT_NUMBER 

---
apiVersion: v1
kind: Service
metadata:
  name: $APP_NAME-vpa-service
spec:
  selector:
    app: $APP_NAME-deployment-app 
  type: LoadBalancer
  ports:
    - protocol: TCP
      port: 8080 
      targetPort: $PORT_NUMBER 

---
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: vpa-development-$APP_NAME
spec:
  targetRef:
    apiVersion: \"apps/v1\"
    kind: Deployment
    name: $APP_NAME-deployment-app
  resourcePolicy:
    containerPolicies:
      - containerName: $APP_NAME-cotainer
        minAllowed:
          cpu: 10m
          memory: 10Mi
        maxAllowed:
          cpu: 50m
          memory: 50Mi
        controlledResources: [\"cpu\", \"memory\"]

---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: $APP_NAME-vpa-ingress
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
            name: $APP_NAME-vpa-service
            port:
              number: 8080 
" > "$APP_NAME-$APP_TYPE".yaml
kubectl apply -f "$APP_NAME-$APP_TYPE".yaml

