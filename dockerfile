# deploy for Flask App, run with nginx and gunicorn

FROM python:2.7.15

RUN apt update && apt install -y nginx supervisor

RUN mkdir -p /usr/src/app && mkdir -p /var/log/gunicorn

WORKDIR /usr/src/app

RUN git clone https://github.com/Bivectorfoil/gogosearch.git /usr/src/app

# load private env file
COPY .env /usr/src/app/.env

RUN pip install --no-cache-dir gunicorn && pip install --no-cache-dir -r /usr/src/app/requirements.txt

# setup nginx
RUN rm /etc/nginx/sites-enabled/default
RUN rm /etc/nginx/sites-available/default
# COPY nginx.conf /etc/nginx/sites-available/
RUN ln -s /usr/src/app/nginx.conf /etc/nginx/sites-enabled/nginx.conf
# RUN ln -s /etc/nginx/sites-available/nginx.conf /etc/nginx/sites-enabled/nginx.conf
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

# setup supervisor

RUN mkdir -p /var/log/supervisor
# COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN ln -s /usr/src/app/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
# COPY gunicorn.conf /etc/supervisor/conf.d/gunicorn.conf
RUN ln -s /usr/src/app/gunicorn.conf /etc/supervisor/conf.d/gunicorn.conf

CMD ["/usr/bin/supervisord"]