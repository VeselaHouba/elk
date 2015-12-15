#!/bin/bash
for i in apache weblogic hsapp; 
do 
	vals=$(redis-cli debug OBJECT $i|awk '{print $5}'|cut -b 18-)
	echo $i ":" $vals
done
