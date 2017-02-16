#!/bin/bash -x
cd /opt/elk
git fetch
if [ $(git rev-parse HEAD) != $(git rev-parse @{u}) ];then
	echo "Need to pull"
	git pull
	#systemctl restart logstash
	service logstash restart
	[[ -e /etc/init.d/logstash_2 ]] && service logstash_2 restart  
fi
