#!/bin/bash
#for i in /etc/init.d/logstash* /etc/init.d/elasticsearch /etc/init.d/redis ;do
for i in /etc/init.d/logstash* ;do
	if [ -e $i ] ; then
		$i status &>/dev/null
		if [ $? -ne 0 ]; then
			echo "$i is not running, now restarting" |tee >(mail -s "$HOSTNAME" jan.michalek@embedit.cz)
			$i restart
			exit 1
		fi
	fi
done
