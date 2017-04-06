#!/bin/bash
PATH=$PATH:/opt/redis/bin/
uname -n
uptime | grep -ohe 'load average[s:][: ].*' | awk '{ print $3" "$4" "$5 }'
echo ""
vals=""
keys=$(redis-cli keys \* 2>/dev/null|sort)
for i in $keys; 
do 
	var=$(redis-cli debug OBJECT $i 2>/dev/null|awk '{print $5}'|cut -b 18-)
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
echo "###############################################################"
