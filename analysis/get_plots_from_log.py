#!/bin/python3
import pandas as pd
import argparse
import os
from matplotlib import pyplot as plt


parser = argparse.ArgumentParser("script to generate plot from log files")
parser.add_argument("--app-type", type=str, required=True, 
                    help="single-pod/two-pod-same-node/two-pod-diff-node/hpa/vpa/two-container")
parser.add_argument("--response-log", type=str, default="")
parser.add_argument("--resources-log", type=str, default="")
parser.add_argument("--output-folder", type=str, required=True)
parser.add_argument("--app-name", type=str, required=True)

args = parser.parse_args()
if not os.path.exists(args.output_folder):
    print("output folder path not exists")
    exit(1)
os.makedirs(f"{args.output_folder}/{args.app_type}", exist_ok=True)

if args.response_log:
    response_data = pd.read_csv(args.response_log) 
    plt.plot(response_data.avg, label="avg response time")
    plt.plot(response_data.max, label="max response time")
    plt.legend()
    plt.savefig(f"{args.output_folder}/{args.app_type}/response-time-{args.app_type}-{args.app_name}.png")
    plt.close()


if args.resources_log:
    resource_data = pd.read_csv(args.resources_log) 

    if args.app_type == "single-pod":
        plt.plot(resource_data.mem, label="memory utilization")
        plt.xlabel("time")
        plt.ylabel("memory utilization")
        plt.title("Memory Utilization")
        plt.savefig(os.path.join(args.output_folder,args.app_type, f"mem-utilization-{args.app_name}.png"))
        plt.close()
    
        plt.plot(resource_data.cpu, label="cpu utilization")
        plt.xlabel("time")
        plt.ylabel("cpu utilization")
        plt.title("CPU Utilization")
        plt.savefig(os.path.join(args.output_folder,args.app_type, f"cpu-utilization-{args.app_name}.png"))
        plt.close()

    elif args.app_type == "two-pod-same-node":
        plt.plot(resource_data.pod1_mem, label="memory utilization pod1")
        plt.plot(resource_data.pod2_mem, label="memory utilization pod2")
        plt.xlabel("time")
        plt.ylabel("memory utilization")
        plt.title("Memory Utilization")
        plt.savefig(os.path.join(args.output_folder,args.app_type, f"mem-utilization-{args.app_name}.png"))
        plt.close()

        plt.plot(resource_data.pod1_cpu, label="cpu utilization pod1")
        plt.plot(resource_data.pod2_cpu, label="cpu utilization pod2")
        plt.xlabel("time")
        plt.ylabel("cpu utilization")
        plt.title("CPU Utilization")
        plt.savefig(os.path.join(args.output_folder,args.app_type, f"cpu-utilization-{args.app_name}.png"))
        plt.close()

    elif args.app_type == "two-pod-diff-node":
            # f.write("pod1_mem, pod1_cpu, pod2_mem, pod2_cpu\n")
        plt.plot(resource_data.pod1_mem, label="memory utilization pod1")
        plt.plot(resource_data.pod2_mem, label="memory utilization pod2")
        plt.xlabel("time")
        plt.ylabel("memory utilization")
        plt.title("Memory Utilization")
        plt.savefig(os.path.join(args.output_folder,args.app_type, f"mem-utilization-{args.app_name}.png"))
        plt.close()

        plt.plot(resource_data.pod1_cpu, label="cpu utilization pod1")
        plt.plot(resource_data.pod2_cpu, label="cpu utilization pod2")
        plt.xlabel("time")
        plt.ylabel("cpu utilization")
        plt.title("CPU Utilization")
        plt.savefig(os.path.join(args.output_folder,args.app_type, f"cpu-utilization-{args.app_name}.png"))
        plt.close()

    elif args.app_type == "hpa":

        plt.plot(resource_data.replicas_count, label="replicas count")
        plt.xlabel("time")
        plt.ylabel("replicas count")
        plt.title("Replicas Count")
        plt.savefig(os.path.join(args.output_folder,args.app_type, f"replicas-count-{args.app_name}.png"))
        plt.close()

        plt.plot(resource_data.current_cpu_utilz, label="current cpu utilization")
        plt.plot(resource_data.hpa_target, label="hpa target cpu utilization")
        plt.xlabel("time")
        plt.ylabel("cpu utilization")
        plt.title("CPU Utilization")
        plt.savefig(os.path.join(args.output_folder,args.app_type, f"cpu-utilization-{args.app_name}.png"))
        plt.close()        

    elif args.app_type == "vpa":

            # f.write("lb_cpu, lb_mem, up_cpu, up_mem, target_cpu, target_mem\n")
        plt.plot(resource_data.lb_cpu, label="lower bound cpu")
        plt.plot(resource_data.up_cpu, label="upper bound cpu")
        plt.plot(resource_data.target_cpu, label="target cpu")
        plt.xlabel("time")
        plt.ylabel("cpu")
        plt.title("CPU")
        plt.savefig(os.path.join(args.output_folder,args.app_type, f"cpu-utilization-{args.app_name}.png"))

        plt.plot(resource_data.lb_mem, label="lower bound memory")
        plt.plot(resource_data.up_mem, label="upper bound memory")
        plt.plot(resource_data.target_mem, label="target memory")
        plt.xlabel("time")
        plt.ylabel("memory")
        plt.title("Memory")
        plt.savefig(os.path.join(args.output_folder,args.app_type, f"mem-utilization-{args.app_name}.png"))
        plt.close()        

    elif args.app_type == "two-container":

            # f.write("cont1_mem, cont1_cpu, cont2_mem, cont2_cpu\n")
        plt.plot(resource_data.cont1_mem, label="memory utilization cont1") 
        plt.plot(resource_data.cont2_mem, label="memory utilization cont2")
        plt.plot([i + j for i,j in zip(resource_data.cont1_mem, resource_data.cont2_mem)], label="pod memory utilization")
        plt.xlabel("time")
        plt.ylabel("memory utilization")
        plt.title("Memory Utilization")
        plt.savefig(os.path.join(args.output_folder,args.app_type, f"mem-utilization-{args.app_name}.png"))
        plt.close()
        
        plt.plot(resource_data.cont1_cpu, label="cpu utilization cont1")
        plt.plot(resource_data.cont2_cpu, label="cpu utilization cont2")
        plt.plot([i + j for i,j in zip(resource_data.cont1_cpu, resource_data.cont2_cpu)], label="pod cpu utilization")
        plt.xlabel("time")
        plt.ylabel("cpu utilization")
        plt.title("CPU Utilization")
        plt.savefig(os.path.join(args.output_folder,args.app_type, f"cpu-utilization-{args.app_name}.png"))
        plt.close()     

