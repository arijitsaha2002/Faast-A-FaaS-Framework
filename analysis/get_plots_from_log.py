#!/bin/python3
import pandas as pd
import numpy as np
import argparse
import os
from matplotlib import pyplot as plt


parser = argparse.ArgumentParser("script to generate plot from log files")
parser.add_argument("--app-type", type=str, required=True, 
                    help="single-pod/two-pod-same-node/two-pod-diff-node/hpa/vpa/two-pod-diff-node")
parser.add_argument("--response-log", type=str, default="")
parser.add_argument("--resources-log", type=str, default="")
parser.add_argument("--output-folder", type=str, required=True)

args = parser.parse_args()

if args.response_log:
    response_data = pd.read_csv(args.response_log) 
    plt.plot(response_data.avg, label="avg response time")
    plt.plot(response_data.max, label="max response time")
    plt.legend()
    if not os.path.exists(args.output_folder):
        print("output folder path not exists")
        exit(1)

    os.makedirs(f"{args.output_folder}/{args.app_type}", exist_ok=True)
    plt.savefig(f"{args.output_folder}/{args.app_type}/response-time-{args.app_type}-{args.app_name}.png")
    plt.close()


if args.resources_log:
    resource_data = pd.read_csv(args.resources_log) 
    if args.app_type == "single-pod"
    if not os.path.exists(args.output_folder):
        print("output folder path not exists")
        exit(1)
