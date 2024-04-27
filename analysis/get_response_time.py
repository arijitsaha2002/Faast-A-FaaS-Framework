#!/bin/python3
import time
import argparse
import numpy as np
import matplotlib.pyplot as plt
import threading
import subprocess
import os

parser = argparse.ArgumentParser("use this file to get response time of a server")
parser.add_argument("--host", type=str, help='host of the server', required=True)
parser.add_argument("--url", type=str, help='port of the server', required=True)

# this is the cluster configuration
parser.add_argument("--app-type", type=str, help='type of the app', required=True)
parser.add_argument("--app-name", type=str, help='name of the app', required=True)
parser.add_argument("--logs-dir", type=str, help='logs directory', required=True)
args = parser.parse_args()

response_time_avg = []
response_time_max = []
response_time_array = []

def fetch_url(url, index):
    global response_time_array
    start_time = time.time()
    subprocess.run(['curl', '-s', f'{url}'], capture_output=True)
    end_time = time.time()
    response_time_array[index] = end_time - start_time
    exit(0)


num_req_parallel = [1, 10, 50]
num_iter = 500

for num_req in num_req_parallel:
    print(f"Sending request with {num_req} parallel requests for {num_iter} iterations ...")
    for j in range(num_iter):
        threads = []
        response_time_array = [0.0]*num_req
        for i in range(num_req):
          thread = threading.Thread(target=fetch_url, args=(f"http://{args.host}/{args.url}",i))
          thread.start()
          threads.append(thread)

        for thread in threads:
          thread.join()
        
        response_time_avg.append(sum(response_time_array) / num_req)
        response_time_max.append(max(response_time_array))
        time.sleep(0.01)

    print("Sleeping for 5 seconds ...")
    time.sleep(5)

with open(os.path.join(args.logs_dir, f"{args.app_type}-{args.app_name}-response-time.csv"), "w") as f:
    f.write("avg,max\n")
    for i in range(len(response_time_avg)):
        f.write(f"{response_time_avg[i]},{response_time_max[i]}\n")
