FROM python:3-alpine
RUN mkdir /flask_app
WORKDIR /flask_app
COPY flask_app/requirements.txt /flask_app
RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt
COPY ./flask_app/app.py /flask_app/app.py
EXPOSE 5000
CMD [ "python", "app.py" ]
