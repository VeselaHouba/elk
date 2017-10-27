#!/bin/bash
service logstash stop 
curl -XDELETE "http://10.27.12.44:9200/logstash-`date +%Y.%m.%d`/" 
sleep 10
service logstash start
tail -1f /log/logstash/logstash.log
