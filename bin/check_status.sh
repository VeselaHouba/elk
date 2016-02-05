#!/bin/bash
for i in /etc/init.d/logstash* /etc/init.d/elasticsearch /etc/init.d/redis ;do
	if [ -e $i ] ; then
		$i status &>/dev/null
		if [ $? -ne 0 ]; then
			echo "$i is not running" |tee >(mail -s "$HOSTNAME" jan.michalek@embedit.cz)
			exit 1
		fi
	fi
done