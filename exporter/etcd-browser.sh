#!/bin/bash

tar -zxvf /etcd-browser-master.tar.gz -d /usr/local/etcd

tar -xvf /node-v16.18.0-linux-x64.tar.xz -C /usr/local/etcd
ln -s /usr/local/etcd/node-v16.18.0-linux-x64 /usr/local/etcd/nodejs

rm -rf /etcd-browser-master.tar.gz
rm -rf /node-v16.18.0-linux-x64.tar.xz

# 启动etcd-browser
cd /usr/local/etcd/etcd-browser-master
nohup /usr/local/etcd/nodejs/bin/node /usr/local/etcd/etcd-browser-master/server.js &

netstat -tulnp | grep 8000
