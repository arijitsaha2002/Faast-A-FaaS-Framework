#!/bin/bash
# --image-name --single-file --requirements.txt --port
if [ $# -ne 4 ]; then
	echo "usage: ./build_image.sh image-name single-file requirements port"
	exit 1;
fi;
mkdir -p /tmp/build_docker_image
rm -rf /tmp/build_docker_image/*
cp "$3" "$2" /tmp/build_docker_image

cd /tmp/build_docker_image
REQUIREMENTS="$(basename $3)"
APP_IMAGE_NAME="$1"
FILE_NAME="$(basename $2)"
PORT_NUMBER="$4"

echo "FROM python:3-alpine
RUN mkdir /flask_app
WORKDIR /flask_app
COPY . /flask_app
RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt
EXPOSE $PORT_NUMBER
CMD [\"python\", \"$FILE_NAME\"]" > Dockerfile

minikube image build -t "$APP_IMAGE_NAME" .
