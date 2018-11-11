FROM python:2.7.15-alpine3.8

RUN mkdir -p /usr/src/app  && mkdir -p /var/log/gunicorn

COPY . /usr/src/app

WORKDIR /usr/src/app

RUN pip install --no-cache-dir gunicorn && \
    pip install --no-cache-dir -r /usr/src/app/requirements.txt
