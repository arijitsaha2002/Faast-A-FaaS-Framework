#!/bin/python3
import time
import argparse
import requests
import numpy as np
import matplotlib.pyplot as plt

parser = argparse.ArgumentParser("use this file to get response time of a server")
parser.add_argument("--host", type=str, help='host of the server', required=True)
parser.add_argument("--url", type=str, help='port of the server', required=True)

# this is the cluster configuration
parser.add_argument("--app-type", type=str, help='type of the app', required=True)
parser.add_argument("--app-name", type=str, help='name of the app', required=True)
args = parser.parse_args()

# num requests
response_time = []
curr_time = time.time()
while time.time() - curr_time < 60:
    time.sleep(0.1)
    start_time = time.time()
    requests.get(url=f"http://{args.host}/{args.url}")
    end_time = time.time()
    response_time.append(end_time - start_time)

while time.time() - curr_time < 60:
    time.sleep(0.01)
    start_time = time.time()
    requests.get(url=f"http://{args.host}/{args.url}")
    end_time = time.time()
    response_time.append(end_time - start_time)


while time.time() - curr_time < 60:
    time.sleep(0.001)
    start_time = time.time()
    requests.get(url=f"http://{args.host}/{args.url}")
    end_time = time.time()
    response_time.append(end_time - start_time)

plt.plot(response_time)
plt.savefig(f"response-time-{args.app_type}-{args.app_name}.png")
plt.close()

