#!/bin/bash

if [ $# -ne 7 ]; then
  echo "Usage: $0 <app_name> <app_type> <docker_image_name> <python-app-file> <requirements-file> <port> <map_url>"
  exit 1
fi

app_name=$1
app_type=$2
docker_image_name=$3
python_app_file=$4
requirements_file=$5
port=$6
map_url=$7


if [ "$app_type" == "two-container" ]; then

	port1=$(($port+1))
	port2=$(($port+2))

	echo "Building two container app with application running on two ports $port1 and $port2"

	./build_image.sh "$docker_image_name-1" $python_app_file $requirements_file $port1
	
	if [ $? -ne 0 ]; then
	  echo "Failed to build docker image-1"
	  exit 1
	fi

	./build_image.sh "$docker_image_name-2" $python_app_file $requirements_file $port2

	if [ $? -ne 0 ]; then
	  echo "Failed to build docker image-2"
	  exit 1
	fi

	cd Deployments/$app_type
	bash map_function.sh $app_name "$docker_image_name-1" "$docker_image_name-2" $map_url $port1 $port2


else
	./build_image.sh $docker_image_name $python_app_file $requirements_file $port

	if [ $? -ne 0 ]; then
	  echo "Failed to build docker image"
	  exit 1
	fi

	cd Deployments/$app_type 
	bash map_function.sh $app_name $docker_image_name $map_url $port
fi


