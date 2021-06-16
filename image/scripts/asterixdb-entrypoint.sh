#!/usr/bin/env bash

cd /opt/asterixdb/

# Start sample cluster
opt/local/bin/start-sample-cluster.sh

tail -f opt/local/logs/cc.log -n 1000 &

# Keep running while cluster is running
while bin/asterixhelper get_cluster_state > /dev/null
do
    sleep 1s
done
