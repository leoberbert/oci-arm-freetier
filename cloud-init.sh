#!/bin/env bash

apt-get update

apt-get install -y vim unzip

apt-get remove -y snapd

apt-get clean
apt-get autoremove -y

echo "Installation complete!
