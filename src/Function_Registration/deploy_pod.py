from kubernetes import config, client
import yaml
import sys
from kubernetes.client.rest import ApiException
import time

config.load_kube_config()
v1_client_api = client.CoreV1Api()
yaml_file_name = sys.argv[1]

with open(f"{yaml_file_name}.yaml") as f:
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

