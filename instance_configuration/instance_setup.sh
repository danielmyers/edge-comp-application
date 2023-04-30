#!/bin/bash

#Update and upgrade all system packages
apt-get update -y
apt-get dist-upgrade -y

#Install OS dependencies for application
apt-get install -y nginx \
    python3-pip \
    python3-dev \
    python3-venv \
    libpq-dev 

#Make python3 the system default
ln -s /usr/bin/python3 /usr/bin/python

python -m pip install virtualenv

git clone <Repository URL> /opt/
virtualenv <Virtual Env>
source <Virtual Env>/activate
pip install -r <Project Dir>/requirements.txt

cp gunicorn/gunicorn.socket  /etc/systemd/system/gunicorn.socket
cp gunicorn/gunicorn.service /etc/systemd/system/gunicorn.service

cp nginx/movies /etc/nginx/sites-available/movies
ln -s /etc/nginx/sites-available/movies /etc/nginx/sites-enabled
rm /etc/nginx/sites-enabled/default

sudo systemctl start gunicorn.socket
sudo systemctl enable gunicorn.socket
