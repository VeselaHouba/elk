#!/bin/bash
#for i in /etc/init.d/logstash* /etc/init.d/elasticsearch /etc/init.d/redis ;do
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
