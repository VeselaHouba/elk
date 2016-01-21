#!/bin/bash
THRESHOLD=97
function stop_elk {
	ps aux | sort -nk +4 > /opt/logstash/memory_`date +%Y.%m.%d_%H.%M`
	echo "Out of resources, stopping elasticsearch" | mail -s "Elasticsearch problems" jan.michalek@embedit.cz
	echo "Out of resources, stopping elasticsearch" | mail -s "Elasticsearch problems" michal.busanic@embedit.cz
	/etc/init.d/elk stop
}
function stop_elastic {
	echo "Out of resources, stopping elasticsearch" | mail -s "Elasticsearch problems" jan.michalek@embedit.cz
	echo "Out of resources, stopping elasticsearch" | mail -s "Elasticsearch problems" michal.busanic@embedit.cz
	/etc/init.d/elasticsearch stop
}
#used=`free | awk '/buffers\/cache/{print 100-($4/($3+$4) * 100.0);}'`
#if (( $(echo "$used<$THRESHOLD" | bc -l) ));then 
#	echo memory ok
#else
#	stop_elk
#fi

disk=$(df /elasticsearch | grep /elasticsearch | awk '{ print $4}' | sed 's/%//g')
if [ $disk -ge $THRESHOLD  ]; then
	stop_elastic
else
	echo disk ok
fi
