#!/bin/python3
import time
import argparse
import requests
import numpy as np
import matplotlib.pyplot as plt

parser = argparse.ArgumentParser("use this file to get response time of a server")
parser.add_argument("--host", type=str, help='host of the server')
parser.add_argument("--port", type=str, help='port of the server')
args = parser.parse_args()

# num requests
N = 2000
avg_response_time = []
for i in range(N):
    curr_avg = 0
    for j in range(10):
        start_time = time.time()
        requests.get(url=f"http://{args.host}:{args.port}")
        end_time = time.time()
        curr_avg += end_time - start_time
    print(f"iteration {i} avg response time: {curr_avg/10}")
    avg_response_time.append(curr_avg/10)

plt.plot(np.arange(N), avg_response_time)
plt.show()
