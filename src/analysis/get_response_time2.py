#!/bin/python3
import time
import argparse
import requests
import numpy as np
import matplotlib.pyplot as plt
import threading

parser = argparse.ArgumentParser("use this file to get response time of a server")
parser.add_argument("--host", type=str, help='host of the server', required=True)
parser.add_argument("--url", type=str, help='port of the server', required=True)

# this is the cluster configuration
parser.add_argument("--app-type", type=str, help='type of the app', required=True)
parser.add_argument("--app-name", type=str, help='name of the app', required=True)
args = parser.parse_args()

response_time = []

def fetch_url(url):
  requests.get(url=url)


num_req_parallel = [1, 10, 100]

for num_req in num_req_parallel:
    print(f"Sending request with {num_req} parallel requests for around 120 seconds ...")
    curr_time = time.time()
    while time.time() - curr_time < 120:
        start_time = time.time()
        threads = []
        for i in range(num_req):
          thread = threading.Thread(target=fetch_url, args=(f"http://{args.host}/{args.url}",))
          thread.start()
          threads.append(thread)

        for thread in threads:
          thread.join()

        end_time = time.time()
        response_time.append((end_time - start_time) / 10)

    print("Sleeping for 5 seconds ...")
    time.sleep(5)


plt.plot(response_time)
plt.savefig(f"response-time-{args.app_type}-{args.app_name}.png")
plt.close()

