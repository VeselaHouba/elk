#!/bin/bash
# RHEL 6
if grep -q 6 /etc/redhat-release ;then
	for i in /etc/init.d/logstash* ;do
		if [ -e $i ] ; then
			$i status &>/dev/null
			if [ $? -ne 0 ]; then
				FNAME=""
				if [[ $(basename $i) == logstash* ]];then
					FNAME="/log/logstash/$(basename $i).err_$(date +%F_%H-%M)"
					cp /log/logstash/$(basename $i).err /log/logstash/$(basename $i).err_$(date +%F_%H-%M)
				fi 
				echo "$i is not running, restarting. $FNAME" |tee >(mail -s "$HOSTNAME" middleware_run@homecredit.net)
				$i restart
				exit 1
			fi
		fi
	done
# US issues with systemctl
elif hostname |grep -q "us.prod"; then
	service logstash status &>/dev/null
	if [ $? -ne 0 ]; then
		echo "Logstash is not running, restarting." |tee >(mail -s "$HOSTNAME" middleware_run@homecredit.net)
		systemctl restart logstash
		exit 1
	fi 
# RHEL 7, single instance
else
	systemctl status logstash &>/dev/null
	if [ $? -ne 0 ]; then
		echo "Logstash is not running, restarting." |tee >(mail -s "$HOSTNAME" middleware_run@homecredit.net)
		systemctl restart logstash
		exit 1
	fi 
fi
