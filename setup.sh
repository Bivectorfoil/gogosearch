#!/bin/bash

# Develop script for Flask Web App, with gunicorn and nginx
# run it as root

set -e

# Check whether nginx is instlled
if [ ! -x /usr/sbin/nginx ]; then
    echo "Nginx not installed, now install Nginx"
    apt update && apt install -y nginx
fi

# load private env file(if exits) to app root directory
if [ ! -f ".env" ]; then
    echo "Cannot find env file, please copy it manually immediately"
    echo "Exiting install, after copy env file, please re-run this script"
    sleep 2
    exit
fi

echo "Now install pipenv for create virtualenv"
pip install --no-cache-dir pipenv

echo "Install requirements from pipfile..."
pipenv install

# setup nginx
if [ "`ls -A /etc/nginx/sites-enabled/`" != "" ]; then
    rm /etc/nginx/sites-enabled/*
fi
cp ./nginx.conf /etc/nginx/sites-available/nginx.conf
ln -s /etc/nginx/sites-available/nginx.conf /etc/nginx/sites-enabled/nginx.conf

# test config files
nginx -t

# dependences install complete
echo "All dependences are ready, run Flask app..."
echo "First start gunicorn server..."
pwd
pipenv run gunicorn -w 2 -b :8000 gogo:app --daemon

echo "gunicorn start normally, now start nginx..."
systemctl start nginx
echo "start nginx, check for status"
systemctl status nginx
