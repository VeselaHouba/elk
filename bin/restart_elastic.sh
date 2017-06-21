#!/bin/bash
# Restarts servers based on current hour modulo 7 - rotate one by one 

HOUR=$(date +%H)
# bash interprets 08 as octal -> force to int
HOUR=${HOUR#0}
HOUR=$(( HOUR%7 ))

########## CN
target=scnvx04${HOUR}.prod.itc.homecredit.cn
#echo $target
local=$(uname -n)
if [ $local = $target ] ;then
	systemctl restart elasticsearch &>/dev/null
	#echo "restarted $target"|mail -s "CN restart" jan.michalek@embedit.cz
fi
########### US
target=pxy0${HOUR}-uslogs1.us.prod
#echo $target
local=$(uname -n)
if [ $local = $target ] ;then
	systemctl restart elasticsearch &>/dev/null
	#echo "restarted $target"|mail -s "US restart" jan.michalek@embedit.cz
fi