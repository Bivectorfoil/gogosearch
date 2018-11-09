#!/bin/bash

# Uninstall script for Flask Web App which.
# WARNNING: this script will delete the App's dependences and runtime dependency
# run it as root and at the root directory of app(same as .env file)

set -e

echo "Stop service"
# kill all of gunicorn workers
# kill -9 `ps aux |grep gunicorn |grep gogo:app | awk '{ print $2 }'`
PIDS=`ps -ef | grep gunicorn |grep gogo:app | awk '{print $2}'`
for pid in $PIDS
do
  kill -9 $pid
done

echo "Stop gunicorn successfully"
sleep 1

# stop nginx.service
if [ systemctl -q is-active nginx.service ]; then
    echo "Application is still running, stop it"
    systemctl stop nginx
    echo "Stop service successfully"
else
    echo "No nginx service is running."
fi

sleep 1

# remove nginx
if [ -x /usr/sbin/nginx ]; then
    echo "Nginx is installed, now uninstall it"
    apt-get purge nginx nginx-common -y
else
    echo "Not Found nginx"
fi

# delete .env file at root directory
if [ -f ".env" ]; then
    rm .env
else
    echo "No env file found"
    sleep 1
fi

# Remove pip
echo "Remove pip"
pip uninstall -r requirements.txt -y
apt-get purge python-pip -y

echo "All is cleared, please delete the bare Repository"
