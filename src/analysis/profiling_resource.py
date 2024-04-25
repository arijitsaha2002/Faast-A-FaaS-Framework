#!/bin/python3
import time
import argparse
import requests
import numpy as np
import matplotlib.pyplot as plt


def get_cpu(cpu):
    if(cpu[-1] == "n"):
        cpu = int(cpu[:-1])/1000000000
    elif cpu[-1] == "m":
        cpu[-1] = int(cpu)/1000
    else:
        cpu = -1
    return cpu

def get_mem(mem):
    if(mem[-2:] == "Ki"):
        mem = int(mem[:-2])
    elif(mem[-2:] == "Mi"):
        mem = int(mem[:-2])*1000
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
args = parser.parse_args()

# num requests
N = 2000

port = 20000
url_pref = f"http://localhost:{port}/apis"

if args.single_pod:
    mem_utilz = []
    cpu_utilz = []

    pod_name = "single-pod-pod"
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
        plt.plot(list(range(len(mem_utilz))), mem_utilz)
        plt.savefig("mem_utilz.png")
        plt.close()
        plt.plot(list(range(len(cpu_utilz))), cpu_utilz)
        plt.savefig("cpu_utilz.png")
        plt.close()
    
    

if args.two_pod_same_node:
    app_name = "aryan-tp"
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
        print(pod1_mem_utilz)
        print(pod1_cpu_utilz)
        print(pod2_mem_utilz)
        print(pod2_cpu_utilz)
        print("plotting remaining")

if args.two_container:
    app_name = "aryan-tc"
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
        print(cont1_mem_utilz)
        print(cont1_cpu_utilz)
        print(cont2_mem_utilz)
        print(cont2_cpu_utilz)
        print("plotting remaining")
    
if args.hpa:
    app_name = "aryan-hpa"
    hpa_name = "hpa-deployment-" + app_name
    url = url_pref + "/autoscaling/v1/namespaces/default/horizontalpodautoscalers/" + hpa_name
    
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
        print(replicas_count)
        print(current_cpu_utilz)
        print(hpa_target)
        print("plotting remaining")


if args.two_pod_diff_node:
    app_name = "aryan-td"
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
        print(pod1_mem_utilz)
        print(pod1_cpu_utilz)
        print(pod2_mem_utilz)
        print(pod2_cpu_utilz)
        print("plotting remaining")



if args.vpa:
    print("vpa analysis not implemented")

