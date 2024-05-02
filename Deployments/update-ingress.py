#!/bin/python3
import pandas as pd
import numpy as np

csv = pd.read_csv("./ingress.csv")
csv = csv.values
file = """
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /$1
spec:
  ingressClassName: nginx
  rules:
  - http:
      paths:"""

for line in csv:
    url = line[0]
    service = line[1]
    port = line[2]

    file += f"""
      - path: /{url}/(.*)
        pathType: ImplementationSpecific
        backend:
          service:
            name: {service}
            port:
              number: {port} 
    """

ingress_yaml = open("ingress.yaml", "+w")
print(file, file=ingress_yaml)
