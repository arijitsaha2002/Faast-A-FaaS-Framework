import time 
from lorem_text import lorem
from flask import Flask
# create an app instance
app = Flask(__name__)
init_time = time.time_ns()

@app.route("/")
def get_hello():
    return "hello world!"

@app.route("/lorem")
def get_lorem():
    return lorem.words(2000)


@app.route("/time")
def get_init_time():
    return str(init_time)

@app.route("/loop")
def loop_func():
    for i in range(100000):
        a = i
        a = a*a
    return f"loop done"

if __name__ == "__main__":
   app.run(host='0.0.0.0', threaded=False, port=5001)

