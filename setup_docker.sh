#!/bin/sh

# Develop script for Flask Web App, with gunicorn and nginx in docker container
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
curl -L \
    "https://github.com/docker/compose/releases/download/1.23.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

chmod +x /usr/local/bin/docker-compose

docker-compose --version

echo "${YELLOW}Evething is ready for deploy, run docker-compose up -d \
    for deploy${PLAIN}"
