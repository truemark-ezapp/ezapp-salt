#!/usr/bin/env bash

set -ex
echo "127.0.0.1 salt" >> /etc/hosts
apt-get update
apt-get install -y wget gnupg
wget -O - https://repo.saltstack.com/apt/ubuntu/18.04/amd64/latest/SALTSTACK-GPG-KEY.pub | sudo apt-key add -
echo 'deb http://repo.saltstack.com/apt/ubuntu/18.04/amd64/latest bionic main' > /etc/apt/sources.list.d/saltstack.list
apt-get update
apt-get install -y salt-master salt-minion
output=$(salt-key -Ay --no-color)
echo $output
while [[ $output == *"does not match"* ]]; do
    output=$(salt-key -Ay --no-color)
    echo $output
done
sleep 10
salt '*' saltutil.refresh_pillar
sleep 10
salt-call --local state.apply master.config
sleep 10
salt '*' state.apply