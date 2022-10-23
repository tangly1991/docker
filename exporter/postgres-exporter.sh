#!/bin/bash

tar -zxvf /postgres_exporter-0.11.1.linux-amd64.tar.gz
mv /postgres_exporter-0.11.1.linux-amd64/postgres_exporter /usr/local/bin/postgres_exporter

rm -rf /postgres_exporter-0.11.1.linux-amd64.tar.gz


useradd postgres1
useradd postgres2
useradd postgres3

su - postgres1
export DATA_SOURCE_NAME="postgresql://postgres:postgres@pgnode0:5432/postgres?sslmode=disable"
nohup postgres_exporter --web.listen-address=":9187" >/dev/null 2>&1 &



su - postgres2
export DATA_SOURCE_NAME="postgresql://postgres:postgres@pgnode1:5432/postgres?sslmode=disable"
nohup postgres_exporter --web.listen-address=":9188" >/dev/null 2>&1 &




su - postgres3
export DATA_SOURCE_NAME="postgresql://postgres:postgres@pgnode2:5432/postgres?sslmode=disable"
nohup postgres_exporter --web.listen-address=":9189" >/dev/null 2>&1 &

netstat -tulnp | grep 918
