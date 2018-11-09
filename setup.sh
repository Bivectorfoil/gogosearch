#!/bin/bash

# Develop script for Flask Web App, with gunicorn and nginx
# run it as root or sudo

set -e

# Check whether nginx is instlled
if [ ! -x /usr/sbin/nginx ]; then
    echo "Nginx not installed, now install Nginx"
    apt update && apt install -y nginx
fi

if [ ! -x /usr/local/bin/pip ]; then
    echo "Pip is not installed, install it firstly"
    apt-get install -y python-pip python-setuptools
    pip install --upgrade pip
else
    echo "Found pip, continue setup"
fi

# load private env file(if exits) to app root directory
if [ ! -f ".env" ]; then
    echo "Cannot find env file, please copy it manually immediately"
    echo "Exiting install, after copy env file, please re-run this script"
    sleep 2
    exit
fi

echo "Install requirements"
pip install -r requirements.txt

# setup nginx
get_ip(){
    local IP=$( ip addr | egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | egrep -v "^192\.168|^172\.1[6-9]\.|^172\.2[0-9]\.|^172\.3[0-2]\.|^10\.|^127\.|^255\.|^0\." | head -n 1 )
    [ -z ${IP} ] && IP=$( wget -qO- -t1 -T2 ipv4.icanhazip.com )
    [ -z ${IP} ] && IP=$( wget -qO- -t1 -T2 ipinfo.io/ip )
    [ ! -z ${IP} ] && echo ${IP} || echo
}
IP=$(get_ip)

touch nginx.conf

static_dir=`pwd`"/gogo/static/"
cat << EOF > ./nginx.conf
server {
    listen 80;

    server_name $IP;
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;
    
    location / {
        proxy_pass http://127.0.0.1:8000; # gunicorn run port
        proxy_redirect off;
        
        proxy_set_header Host               \$host;
        proxy_set_header X-Real-IP          \$remote_addr;
        proxy_set_header X-Forwarded-For    \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto  \$scheme;
    }
    location /static {
        alias $static_dir;
        expires 30d;
    }
}
EOF

if [ "`ls -A /etc/nginx/sites-enabled/`" != "" ]; then
    rm /etc/nginx/sites-enabled/*
fi
if [ "`ls -A /etc/nginx/sites-available/`" != "" ]; then
    rm /etc/nginx/sites-available/*
fi

cp ./nginx.conf /etc/nginx/sites-available/nginx.conf
ln -s /etc/nginx/sites-available/nginx.conf /etc/nginx/sites-enabled/nginx.conf

# test config files
nginx -t

# dependences install complete
echo "All dependences are ready, run Flask app..."
echo "First start gunicorn server..."
pwd

gunicorn -w 2 -b :8000 gogo:app --daemon

echo "gunicorn start normally, now start nginx..."
systemctl start nginx
echo "start nginx, check for status"
systemctl status nginx
