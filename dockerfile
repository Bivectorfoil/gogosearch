FROM python:2.7.15-alpine3.8

RUN mkdir -p /usr/src/app  && mkdir -p /var/log/gunicorn

COPY . /usr/src/app

WORKDIR /usr/src/app

RUN pip install --no-cache-dir gunicorn && \
    pip install --no-cache-dir -r /usr/src/app/requirements.txt


ENV PORT 8000
EXPOSE 8000 5000

CMD ["/usr/local/bin/gunicorn", "-w", "2", "-b", "0.0.0.0:8000", "gogo:app"]
