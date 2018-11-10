#!/bin/sh

# Uninstall script for Flask Web App which.
# WARNNING: this script will delete the App's dependences and runtime dependency
# run it as root and at the root directory of app(same as .env file)

set -e

# Output color variable define
YELLOW='\033[00;33m'
PLAIN='\033[0m'


echo "${YELLOW}Stop service${PLAIN}"
# kill all of gunicorn workers
# kill -9 `ps aux |grep gunicorn |grep gogo:app | awk '{ print $2 }'`
PIDS=`ps -ef | grep gunicorn |grep gogo:app | awk '{print $2}'`
for pid in $PIDS
do
  kill -9 $pid
done

echo "${YELLOW}Stop gunicorn successfully${PLAIN}"
sleep 1

# stop nginx.service
if [ systemctl -q is-active nginx.service ]; then
    echo "${YELLOW}Application is still running, stop it${PLAIN}"
    systemctl stop nginx
    echo "${YELLOW}Stop service successfully${PLAIN}"
else
    echo "${YELLOW}No nginx service is running.${PLAIN}"
fi

sleep 1

# remove nginx
if [ -x /usr/sbin/nginx ]; then
    echo "${YELLOW}Nginx is installed, now uninstall it${PLAIN}"
    apt-get purge nginx nginx-common -y
else
    echo "${YELLOW}Not Found nginx${PLAIN}"
fi

# delete .env file at root directory
if [ -f ".env" ]; then
    rm .env
else
    echo "${YELLOW}No env file found${PLAIN}"
    sleep 1
fi

# Remove pip
echo "${YELLOW}Remove pip${PLAIN}"
pip uninstall -r requirements.txt -y
apt-get purge python-pip -y

echo "${YELLOW}All is cleared, please delete the bare Repository${PLAIN}"
