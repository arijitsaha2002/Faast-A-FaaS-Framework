#!/bin/bash

if [[ "$#" -ne 1 ]];
then
    echo "usage: ./delete_url.sh <url>"
    exit 1;
fi;

delete_url="$1"

line=$(awk -F',' -v url=$delete_url '{if ($1 == url) {print NR}}' ./Deployments/ingress.csv)
if [[ $line == "" ]];
then 
    echo "url not exists";
    exit 1;
fi;

eval "sed '$line""d' -i ./Deployments/ingress.csv"
cd ./Deployments
./update-ingress.py
kubectl apply -f ./ingress.yaml
