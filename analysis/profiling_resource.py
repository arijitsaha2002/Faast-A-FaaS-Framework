#!/bin/python3
import time
import argparse
import requests
import numpy as np
import matplotlib.pyplot as plt


def get_cpu(cpu):
    if(cpu[-1] == "n"):
        cpu = int(cpu[:-1])/(10**9)
    elif cpu[-1] == "m":
        cpu = int(cpu[:-1])/(1000)

    return int(cpu)

def get_mem(mem):
    if(mem[-2:] == "Ki"):
        mem = int(mem[:-2])
    elif(mem[-2:] == "Mi"):
        mem = int(mem[:-2])*(2**10)
    else:
        mem = -1
    return mem

parser = argparse.ArgumentParser("use this file to get response time of a server")
parser.add_argument("--single-pod", action="store_true", help='single pod analysis')
parser.add_argument("--two-pod-same-node", action="store_true", help='two pod on the same node analysis')
parser.add_argument("--two-pod-diff-node", action="store_true", help='two pod on the diff node analysis')
parser.add_argument("--hpa", action="store_true", help='horizontal pod autoscaler analysis')
parser.add_argument("--two-container", action="store_true", help='two container on the same pod analysis')
parser.add_argument("--vpa", action="store_true", help='vertical pod autoscaler analysis')
parser.add_argument("--app-name", type=str, required=True, help='name of the app')
parser.add_argument("--logs-dir", type=str, required=True, help='directory to store logs')
args = parser.parse_args()

# num requests
port = 20000
url_pref = f"http://localhost:{port}/apis"

app_name = args.app_name
logs_dir = args.logs_dir

if args.single_pod:
    mem_utilz = []
    cpu_utilz = []

    pod_name = app_name + "-pod"
    url = url_pref + "/metrics.k8s.io/v1beta1/namespaces/default/pods/" + pod_name
    try:
        start_time = time.time()
        while True:
            if (time.time() - start_time) >= 0.1:
                resp = requests.get(url=url).json()
                mem_utilz.append(get_mem(resp["containers"][0]["usage"]["memory"]))
                cpu_utilz.append(get_cpu(resp["containers"][0]["usage"]["cpu"]))
                
                start_time = time.time()
    except KeyboardInterrupt:

        with open(f"{logs_dir}/single-pod-{app_name}-resource_usage.csv", "w") as f:
            f.write("mem,cpu\n")
            for i, j in zip(mem_utilz, cpu_utilz):
                f.write(f"{i},{j}\n")    
    
if args.two_pod_same_node:
    pod1_name = app_name + "-single-pod-1"
    pod2_name = app_name + "-single-pod-2"

    url1 = url_pref + "/metrics.k8s.io/v1beta1/namespaces/default/pods/" + pod1_name
    url2 = url_pref + "/metrics.k8s.io/v1beta1/namespaces/default/pods/" + pod2_name

    pod1_mem_utilz = []
    pod1_cpu_utilz = []

    pod2_mem_utilz = []
    pod2_cpu_utilz = []


    try:
        start_time = time.time()
        while True:
            if (time.time() - start_time) >= 0.1:
                resp = requests.get(url=url1).json()
                mem1 = resp["containers"][0]["usage"]["memory"]
                cpu1 = resp["containers"][0]["usage"]["cpu"]

                pod1_mem_utilz.append(get_mem(mem1))
                pod1_cpu_utilz.append(get_cpu(cpu1))

                resp = requests.get(url=url2).json() 
                mem2 = resp["containers"][0]["usage"]["memory"]
                cpu2 = resp["containers"][0]["usage"]["cpu"]

                pod2_mem_utilz.append(get_mem(mem2))
                pod2_cpu_utilz.append(get_cpu(cpu2))

                start_time = time.time()
    except KeyboardInterrupt:

        with open(f"{logs_dir}/two-pod-same-node-{app_name}-resource_usage.csv", "w") as f:
            f.write("pod1_mem,pod1_cpu,pod2_mem,pod2_cpu\n")
            for i1, j1, i2, j2 in zip(pod1_mem_utilz, pod1_cpu_utilz, pod2_mem_utilz, pod2_cpu_utilz): 
                f.write(f"{i1},{j1},{i2},{j2}\n")

if args.two_container:
    pod_name = app_name + "-app-1"
    url = url_pref + "/metrics.k8s.io/v1beta1/namespaces/default/pods/" + pod_name
    
    cont1_mem_utilz = []
    cont1_cpu_utilz = []

    cont2_mem_utilz = []
    cont2_cpu_utilz = []

    try:
        start_time = time.time()
        while True:
            if (time.time() - start_time) >= 0.1:
                resp = requests.get(url=url).json()
                mem1 = resp["containers"][0]["usage"]["memory"]
                cpu1 = resp["containers"][0]["usage"]["cpu"]
                mem2 = resp["containers"][1]["usage"]["memory"]
                cpu2 = resp["containers"][1]["usage"]["cpu"]

                cont1_mem_utilz.append(get_mem(mem1))            
                cont1_cpu_utilz.append(get_cpu(cpu1))
                cont2_mem_utilz.append(get_mem(mem2))
                cont2_cpu_utilz.append(get_cpu(cpu2))

                start_time = time.time()
    except KeyboardInterrupt:
        
        with open(f"{logs_dir}/two-container-{app_name}-resource_usage.csv", "w") as f:
            f.write("cont1_mem,cont1_cpu,cont2_mem,cont2_cpu\n")
            for i1, j1, i2, j2 in zip(cont1_mem_utilz, cont1_cpu_utilz, cont2_mem_utilz, cont2_cpu_utilz): 
                f.write(f"{i1},{j1},{i2},{j2}\n")
    
    
if args.hpa:
    hpa_name = "hpa-deployment-" + app_name
    url = url_pref + "/autoscaling/v1/namespaces/default/horizontalpodautoscalers/" + hpa_name
    print(url) 
    replicas_count = []
    hpa_target = []
    current_cpu_utilz = []

    try:
        start_time = time.time()
        while True:
            if (time.time() - start_time) >= 0.1:
                resp = requests.get(url=url).json()
                replicas_count.append(resp["status"]["currentReplicas"])
                current_cpu_utilz.append(resp["status"]["currentCPUUtilizationPercentage"])
                hpa_target.append(resp["spec"]["targetCPUUtilizationPercentage"])

                start_time = time.time()
    except KeyboardInterrupt:

        with open(f"{logs_dir}/hpa-{app_name}-resource_usage.csv", "w") as f:
            f.write("replicas_count,current_cpu_utilz,hpa_target\n")
            for i, j, k in zip(replicas_count, current_cpu_utilz, hpa_target):
                f.write(f"{i},{j},{k}\n") 


if args.two_pod_diff_node:
    pod1_name = app_name + "-node1-pod"
    pod2_name = app_name + "-node2-pod"

    url1 = url_pref + "/metrics.k8s.io/v1beta1/namespaces/default/pods/" + pod1_name
    url2 = url_pref + "/metrics.k8s.io/v1beta1/namespaces/default/pods/" + pod2_name
    
    pod1_mem_utilz = []
    pod1_cpu_utilz = []

    pod2_mem_utilz = []
    pod2_cpu_utilz = []

    try:
        start_time = time.time()
        while True:
            if (time.time() - start_time) >= 0.1:
                resp = requests.get(url=url1).json()
                mem1 = resp["containers"][0]["usage"]["memory"]
                cpu1 = resp["containers"][0]["usage"]["cpu"]

                pod1_mem_utilz.append(get_mem(mem1))
                pod1_cpu_utilz.append(get_cpu(cpu1))

                resp = requests.get(url=url2).json() 
                mem2 = resp["containers"][0]["usage"]["memory"]
                cpu2 = resp["containers"][0]["usage"]["cpu"]

                pod2_mem_utilz.append(get_mem(mem2))
                pod2_cpu_utilz.append(get_cpu(cpu2))

                start_time = time.time()

    except KeyboardInterrupt:
        with open(f"{logs_dir}/two-pod-diff-node-{app_name}-resource_usage.csv", "w") as f:
            f.write("pod1_mem,pod1_cpu,pod2_mem,pod2_cpu\n")
            for i1, j1, i2, j2 in zip(pod1_mem_utilz, pod1_cpu_utilz, pod2_mem_utilz, pod2_cpu_utilz): 
                f.write(f"{i1},{j1},{i2},{j2}\n")



if args.vpa:
    vpa_name = "vpa-development-" + app_name 
    url = url_pref + "/autoscaling.k8s.io/v1/namespaces/default/verticalpodautoscalers/" + vpa_name
    
    lb_cpu = []
    lb_mem = []

    up_cpu = []
    up_mem = []

    target_cpu = []
    target_mem = []
    


    try:
        start_time = time.time()
        while True:
            if (time.time() - start_time) >= 0.1:
                resp = requests.get(url=url).json()
                lb_cpu.append(get_cpu(resp["status"]["recommendation"]["containerRecommendations"][0]["lowerBound"]["cpu"]))
                lb_mem.append(get_mem(resp["status"]["recommendation"]["containerRecommendations"][0]["lowerBound"]["memory"]))
                up_cpu.append(get_cpu(resp["status"]["recommendation"]["containerRecommendations"][0]["upperBound"]["cpu"]))
                up_mem.append(get_mem(resp["status"]["recommendation"]["containerRecommendations"][0]["upperBound"]["memory"]))
                target_cpu.append(get_cpu(resp["status"]["recommendation"]["containerRecommendations"][0]["target"]["cpu"]))
                target_mem.append(get_mem(resp["status"]["recommendation"]["containerRecommendations"][0]["target"]["memory"]))

                start_time = time.time()
    
    except KeyboardInterrupt:
        with open(f"{logs_dir}/vpa-{app_name}-resource_usage.csv", "w") as f:
            f.write("lb_cpu,lb_mem,up_cpu,up_mem,target_cpu,target_mem\n")
            for i, j, k, l, m, n in zip(lb_cpu, lb_mem, up_cpu, up_mem, target_cpu, target_mem):
                f.write(f"{i},{j},{k},{l},{m},{n}\n")
    
