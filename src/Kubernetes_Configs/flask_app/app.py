# import flask
from flask import Flask
# create an app instance
app = Flask(__name__)

counter = 0;

# create a route /
@app.route("/")     
# define the function hello 
def hello():
   # return "hello world" when
   return "Hello World!"

@app.route("/counter")
def counter_func():
    global counter
    ret_counter = counter;
    counter+=1
    return f"Current counter {ret_counter}"

# on running python app.py
if __name__ == "__main__":
   # run the flask app
   app.run()
