#!/bin/bash
uname -n
uptime | grep -ohe 'load average[s:][: ].*' | awk '{ print $3" "$4" "$5 }'
echo ""
vals=""
for i in apache apache_rotated weblogic hsapp; 
do 
	var=$(redis-cli debug OBJECT $i|awk '{print $5}'|cut -b 18-)
	[ -z $var ] && var=0
	# load value
	pvar=`cat /tmp/$i 2>/dev/null`
	[ -z $pvar ] && pvar=0
	# save value
	echo $var > /tmp/$i

	vals=${vals}${i}" "${var}" "$(expr $var - $pvar)"\n"
done
header="=Key= =Lenght= =Difference=\n"
echo -e $header$vals|column -t
