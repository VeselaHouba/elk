#!/bin/bash
cd /opt/elk
git fetch
if [ $(git rev-parse HEAD) != $(git rev-parse @{u}) ];then
    echo "Need to pull"
    git pull
    for i in /etc/init.d/logstash* ;do
    	$i restart
    done 
fi