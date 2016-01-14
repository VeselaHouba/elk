#!/bin/bash
uname -n
uptime | grep -ohe 'load average[s:][: ].*' | awk '{ print $3" "$4" "$5 }'
echo ""
vals=""
for i in apache apache_rotated weblogic hsapp; 
do 
	var=$(redis-cli debug OBJECT $i|awk '{print $5}'|cut -b 18-)
	[ -z $var ] && var=0
	vals=${vals}${i}" "${var}"\n"
done
echo -e $vals|column -t
