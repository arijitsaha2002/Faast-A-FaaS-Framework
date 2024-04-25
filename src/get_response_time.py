#!/bin/python3
import time
import argparse
import requests
import numpy as np


parser = argparse.ArgumentParser("use this file to get response time of a server")
parser.add_argument("--port", default="8080", type=str)
parser.add_argument("--url", default="", type=str)
parser.add_argument("--host", default="localhost", type=str)
args = parser.parse_args()

total_iteration=500
time_taken = []

for i in range(total_iteration):
    start_time = time.time()
    requests.get(url=f"{args.host}:{args.port}/{args.url}")
    end_time = time.time()
    time_taken.append(end_time - start_time)
avg_responce_time = np.mean(np.array(time_taken))
print(avg_responce_time)


