from kubernetes import config, client
import yaml
import sys
from kubernetes.client.rest import ApiException
import time

config.load_kube_config()
v1_client_api = client.CoreV1Api()
pod_file = sys.argv[1]
pod_service_file = sys.argv[2]

with open(pod_file) as f:
    python_dict_config = yaml.safe_load(f)

app_namespace = python_dict_config['metadata']['namespace']
v1_client_api.create_namespace(body={"metadata": {"name": app_namespace}})
v1_k8_app = client.AppsV1Api()

num_app_replicas = python_dict_config['spec']['replicas']
deployment_name = python_dict_config['metadata']['name']
v1_k8_app.create_namespaced_deployment(
        body=python_dict_config,
        namespace=app_namespace
)

while True:
    try:
        response = v1_k8_app.read_namespaced_deployment_status(name=deployment_name, namespace=app_namespace)
        if response.status.available_replicas != num_app_replicas:
            print("Waiting for Deployment to become ready...")
            time.sleep(5)
        else:
            print("Deployment Completed")
            break
    except ApiException as e:
            print(f"Exception when calling AppsV1Api -> read_namespaced_deployment_status: {e}\n")


with open(pod_service_file) as f:
    python_dict_config = yaml.safe_load(f)

app_namespace = python_dict_config['metadata']['namespace']
service_name = python_dict_config['metadata']['name']

v1_client_api.create_namespaced_service(namespace=app_namespace, body=python_dict_config)
v1_client_api.read_namespaced_service_status

while True:
    try:
        response = v1_client_api.read_namespaced_service_status(name=service_name, namespace=app_namespace)
        if response.status.load_balancer.ingress: 
            print("Waiting for Service to become ready...")
            time.sleep(2)
        else:
            print("Service Creation Completed")
            break
    except ApiException as e:
            print(f"Exception when calling AppsV1Api -> read_namespaced_service_status: {e}\n")
