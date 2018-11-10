#!/bin/sh

# Develop script for Flask Web App, with gunicorn and nginx
# run it as root or sudo

set -e

# Output color variable define
YELLOW='\033[00;33m'
PLAIN='\033[0m'

# load private env file(if exits) to app root directory
if [ ! -f ".env" ]; then
    echo "${YELLOW}Cannot find env file, please copy it manually immediately${PLAIN}"
    echo "${YELLOW}Exiting install, after copy env file, please re-run this script${PLAIN}"
    sleep 2
    exit
fi

# Check whether nginx is instlled
if [ ! -x /usr/sbin/nginx ]; then
    echo "${YELLOW}Nginx is not installed, now install it${PLAIN}"
    apt update && apt install -y nginx
fi

if [ ! -x /usr/local/bin/pip ]; then
    echo "${YELLOW}Pip is not installed, install it firstly${PLAIN}"
    apt-get install -y python-pip python-setuptools
    pip install --upgrade pip
else
    echo "${YELLOW}Found pip, continue setup${PLAIN}"
fi

echo "${YELLOW}Install requirements${PLAIN}"
pip install -r requirements.txt

# Setup nginx
# Get public IP address
##############################################################################
# @authorlink      https://github.com/teddysun                               #
# @copyright       Copyright (C) 2014-2018 Teddysun                          #
# @codelink(get_ip)                                                          #
# https://github.com/teddysun/shadowsocks_install/blob/master/shadowsocks.sh #
##############################################################################
get_ip(){ 
    local IP=$( ip addr | egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | egrep -v "^192\.168|^172\.1[6-9]\.|^172\.2[0-9]\.|^172\.3[0-2]\.|^10\.|^127\.|^255\.|^0\." | head -n 1 )
    [ -z ${IP} ] && IP=$( wget -qO- -t1 -T2 ipv4.icanhazip.com )
    [ -z ${IP} ] && IP=$( wget -qO- -t1 -T2 ipinfo.io/ip )
    [ ! -z ${IP} ] && echo ${IP} || echo
}
IP=$(get_ip)

NGINXCONF='nginx.conf'
touch $NGINXCONF

static_dir=`pwd`"/gogo/static/"
cat > $NGINXCONF <<EOF
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
echo "${YELLOW}All dependences are ready, run Flask app...${PLAIN}"
echo "${YELLOW}First start gunicorn server...${PLAIN}"
pwd

gunicorn -w 2 -b :8000 gogo:app --daemon

echo "${YELLOW}gunicorn start normally, now start nginx...${PLAIN}"

# use restart to avoid nginx load default index page
systemctl restart nginx
sleep 1
echo "${YELLOW}Start nginx successfully, check for status${PLAIN}"
systemctl status nginx
