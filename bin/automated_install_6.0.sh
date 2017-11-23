#!/bin/bash
################### config ###############

# PREFLIGHT CHECK: #
# - java installed and linked to /opt/java
# - all install packages in machines (/root/install/)
# - enabled / disabled parameters below ( especially FS preparation )
# - /opt/elk in place


export VERSION=6.0.0
export COUNTRY=DEV
# prepare FS (cn specific)
PREPAREFS=no
# prepare OS - run only once
PREPAREOS=yes
# install / update sw - repeatable
INSTALL=yes
################### /config ###############


umask 022
#################### FS PREPARATION ####################
if [ $PREPAREFS == "yes" ];then
	#vgremove vgData || echo removed
	#vgextend vg00 /dev/sdb || echo added
	lvcreate -n elklog -L 1G vg00
	lvcreate -n elastic -L 3t vg00
	lvcreate -n opt -L 5g vg00
	mkfs.ext4 /dev/mapper/vg00-elklog
	mkfs.ext4 /dev/mapper/vg00-elastic
	mkfs.ext4 /dev/mapper/vg00-opt
	tune2fs -m 0 /dev/mapper/vg00-elastic
	mkdir /log /elasticsearch
	echo "/dev/mapper/vg00-elastic                      /elasticsearch          ext4    noatime                         1 2" >> /etc/fstab
	echo "/dev/mapper/vg00-elklog                       /log                    ext4    noatime                         1 2" >> /etc/fstab
	echo "/dev/mapper/vg00-opt                          /opt                    ext4    noatime                         1 2" >> /etc/fstab
	mount /log
	mount /elasticsearch
	mount /opt
fi

if [ $PREPAREOS == "yes" ];then
	yum install git -y
	ln -sf /opt/elk/etc/cron.d/elk /etc/cron.d/elk
	service crond reload
fi

################### elasticsearch ####################
if [ $PREPAREOS == "yes" ];then
	groupadd elasticsearch -g 1100
	useradd -m elasticsearch -u 1100 -g 1100
	mkdir /log/elasticsearch
fi
if [ $INSTALL == "yes" ];then
	cd /opt/
	tar xzf ~/install/elasticsearch-${VERSION}.tar.gz
	rm -f elasticsearch
	ln -s elasticsearch-${VERSION} elasticsearch
	cp /opt/elk/usr/lib/systemd/system/elasticsearch.service /usr/lib/systemd/system/elasticsearch.service
	ln -sf /opt/elk/etc/sysconfig/elasticsearch_elk-${COUNTRY} /etc/sysconfig/elasticsearch
	ln -sf /opt/elk/elasticsearch/config/elasticsearch.yml_elk-${COUNTRY} /opt/elasticsearch/config/elasticsearch.yml
	ln -sf /opt/elk/elasticsearch/config/jvm.options_elk-${COUNTRY} /opt/elasticsearch/config/jvm.options
	chown elasticsearch: /log/elasticsearch /elasticsearch /opt/elasticsearch/ -R
fi

################### redis ####################
# redis is installed only once - no updates
if [ $PREPAREOS == "yes" ];then
	yum install -y jemalloc
	groupadd redis -g 1101
	useradd -m redis -g 1101 -u 1101
	cd /opt
	tar xzf ~/install/redis.tar.gz
	ln -sf /opt/elk/redis/redis.conf /opt/redis/redis.conf
	cp /opt/elk/usr/lib/systemd/system/redis.service /usr/lib/systemd/system/redis.service
	mkdir /log/redis/ /redis
	chown redis: /log/redis/ /redis
fi

################### logstash ####################
if [ $PREPAREOS == "yes" ];then
	groupadd logstash -g 1102
	useradd -m logstash -g 1102 -u 1102
	mkdir /log/logstash
	# listening on privileged port (514)
	echo "/opt/java/jre/lib/amd64/jli" > /etc/ld.so.conf.d/java.conf
	ldconfig
	setcap 'cap_net_bind_service=+ep' /opt/java/bin/java
fi
if [ $INSTALL == "yes" ];then
	cd /opt/
	tar xzf ~/install/logstash-${VERSION}.tar.gz
	rm -f logstash
	ln -s logstash-${VERSION} logstash
	ln -s /opt/elk/logstash/opt/logstash/patterns /opt/logstash/patterns
	ln -sf /opt/elk/logstash/config/logstash.yml /opt/logstash/config/logstash.yml
	ln -sf /opt/elk/logstash/config/log4j2.properties /opt/logstash/config/log4j2.properties
	ln -s /opt/elk/logstash/config/conf.d /opt/logstash/config/conf.d
	chown logstash: /log/logstash/ /opt/logstash/ -R
	# set java home in logstash startup script
	sed -i '1s#^#JAVA_HOME=/opt/java\n#' /opt/logstash/bin/logstash.lib.sh
	cp /opt/elk/usr/lib/systemd/system/logstash.service /usr/lib/systemd/system/logstash.service 
fi

################### kibana ####################
if [ $PREPAREOS == "yes" ];then
	groupadd kibana -g 1103
	useradd -m kibana -g 1103 -u 1103
	mkdir /log/kibana
fi
if [ $INSTALL == "yes" ];then
	cd /opt/
	tar xzf ~/install/kibana-${VERSION}*
	ln -s kibana-${VERSION}* kibana
	chown kibana: /log/kibana /opt/kibana/ -R
	cp /opt/elk/usr/lib/systemd/system/kibana.service /usr/lib/systemd/system/kibana.service
	ln -sf /opt/elk/kibana/config/kibana.yml /opt/kibana/config/kibana.yml
fi

if [ $PREPAREOS == "yes" ];then
	systemctl enable logstash.service
	systemctl enable redis.service
	systemctl enable elasticsearch.service
	systemctl enable kibana.service
fi
