FROM python:2.7.15-alpine3.8

RUN mkdir -p /usr/src/app  && mkdir -p /var/log/gunicorn

COPY ./requirements.txt /usr/src/app/requirements.txt
COPY .env /usr/src/app/.env
COPY .flaskenv /usr/src/app/.flaskenv

WORKDIR /usr/src/app

RUN pip install --no-cache-dir -r /usr/src/app/requirements.txt
