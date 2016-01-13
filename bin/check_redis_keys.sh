#!/bin/bash
vals=""
for i in apache apache_rotated weblogic hsapp; 
do 
	var=$(redis-cli debug OBJECT $i|awk '{print $5}'|cut -b 18-)
	[ -z $var ] && var=0
	vals=${vals}${i}" "${var}"\n"
done
echo -e $vals|column -t
