#!/bin/sh

# Develop script for Flask Web App, with gunicorn and nginx in docker container
# run it as root or sudo

set -e

# load private env file(if exits) to app root directory
if [ ! -f ".env" ]; then
    echo "${YELLOW}Cannot find env file, please copy it manually immediately${PLAIN}"
    echo "${YELLOW}Exiting install, after copy env file, please re-run this script${PLAIN}"
    sleep 2
    exit
fi

# Install docker
apt-get update

apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

apt-get update && apt-get install -y docker-ce

docker version

# Install docker Compose
curl -L
"https://github.com/docker/compose/releases/download/1.23.1/docker-compose-$(uname
-s)-$(uname -m)" -o /usr/local/bin/docker-compose

chmod +x /usr/local/bin/docker-compose

docker-compose --version

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

static_dir=`pwd`"/etc/nginx/html"
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
