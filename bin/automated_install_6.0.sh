#!/bin/bash
################### config ###############

# PREFLIGHT CHECK: #
# - Opened ssh to git.homecredit.net
# - java installed and linked to /opt/java
# - all install packages in machines (/root/install/)
# - enabled / disabled parameters below ( especially FS preparation )
# - /opt/elk in place (or enable auto install & open ssh)

export VERSION=6.0.1
export COUNTRY=CN_PROD_WH
export GIT_BRANCH="CN_PROD_v4"

# install git && clone
GITINSTALL=no
# prepare FS - RUN ONLY ONCE!
PREPAREFS=no
# volume group
VG="vgLOGS"
# prepare OS
PREPAREOS=yes
# install / update sw - repeatable
INSTALLSW=yes
#############################################################################
########################### END OF CONFIG ###################################
########################### DO NOT EDIT BELOW THIS LINE #####################
#############################################################################

umask 022

#################### FS PREPARATION ####################
if [ $PREPAREFS == "yes" ];then
	mkdir -p /log /elasticsearch
	#vgremove vgData || echo removed
	#vgextend $VG /dev/sdb || echo added

	#mkfs.ext4 /dev/mapper/$VG-opt
	#echo "/dev/mapper/$VG-opt                          /opt                    ext4    noatime                         1 2" >> /etc/fstab
	#mount /opt
	lvresize -L5G /dev/mapper/*-opt -r
	
	lvcreate -n elklog -L 1G $VG
	mkfs.ext4 /dev/mapper/$VG-elklog
	lvcreate -n opt -L 5g $VG
	echo "/dev/mapper/$VG-elklog                       /log                    ext4    noatime                         1 2" >> /etc/fstab
	mount /log

	lvcreate -n elastic -l 100%FREE $VG
	mkfs.ext4 /dev/mapper/$VG-elastic
	tune2fs -m 0 /dev/mapper/$VG-elastic
	mkdir -p /log /elasticsearch
	echo "/dev/mapper/$VG-elastic                      /elasticsearch          ext4    noatime                         1 2" >> /etc/fstab
	mount /elasticsearch
fi

if [ $PREPAREOS == "yes" ];then
	ln -sf /opt/elk/etc/cron.d/elk /etc/cron.d/elk
	service crond reload
fi


#################### CLONE GIT #########################
if [ $GITINSTALL == "yes" ];then
	yum install -y git
	cd /opt/
	[[ -e elk ]] || git clone git@git.homecredit.net:ops/elk.git
	cd elk
	git fetch
	git checkout $GIT_BRANCH
	git pull
fi
#################### CHECKS ############################
files="
/opt/elk/elasticsearch/config/elasticsearch.yml_elk-${COUNTRY}
/opt/elk/elasticsearch/config/jvm.options_elk-${COUNTRY}
/root/install/redis.tar.gz
/root/install/elasticsearch-${VERSION}.tar.gz
/root/install/logstash-${VERSION}.tar.gz
/root/install/kibana-${VERSION}*
/opt/java
"


function check_file {
	file=$1
	if [ -e $file ]; then
		echo $file ok
	else  
		echo "Missing file $file"
		echo "Aborting installation"
		exit 1
	fi
}

echo "Checking needed files"
for i in $files; do
	check_file $i
done 
	 

################### elasticsearch ####################
if [ $PREPAREOS == "yes" ];then
	groupadd elasticsearch -g 1100
	useradd -m elasticsearch -u 1100 -g 1100
	mkdir -p /log/elasticsearch
fi
if [ $INSTALLSW == "yes" ];then
	cd /opt/
	tar xzf /root/install/elasticsearch-${VERSION}.tar.gz
	rm -f elasticsearch
	ln -s elasticsearch-${VERSION} elasticsearch
	cp /opt/elk/usr/lib/systemd/system/elasticsearch.service /usr/lib/systemd/system/elasticsearch.service
	cp /opt/elk/usr/lib/sysctl.d/40-elasticsearch.conf /usr/lib/sysctl.d/40-elasticsearch.conf
	sysctl -w vm.max_map_count=262144
	ln -sf /opt/elk/etc/sysconfig/elasticsearch /etc/sysconfig/elasticsearch
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
	tar xzf /root/install/redis.tar.gz
	ln -sf /opt/elk/redis/redis.conf /opt/redis/redis.conf
	cp /opt/elk/usr/lib/systemd/system/redis.service /usr/lib/systemd/system/redis.service
	mkdir -p /log/redis/ /redis
	chown redis: /log/redis/ /redis
fi

################### logstash ####################
if [ $PREPAREOS == "yes" ];then
	groupadd logstash -g 1102
	useradd -m logstash -g 1102 -u 1102
	mkdir -p /log/logstash
	# listening on privileged port (514)
	echo "/opt/java/jre/lib/amd64/jli" > /etc/ld.so.conf.d/java.conf
	ldconfig
	setcap 'cap_net_bind_service=+ep' /opt/java/bin/java
fi
if [ $INSTALLSW == "yes" ];then
	cd /opt/
	tar xzf /root/install/logstash-${VERSION}.tar.gz
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
	mkdir -p /log/kibana
fi
if [ $INSTALLSW == "yes" ];then
	cd /opt/
	tar xzf /root/install/kibana-${VERSION}*
	rm -f kibana
	ln -s kibana-${VERSION}* kibana
	chown kibana: /log/kibana /opt/kibana/ -R
	cp /opt/elk/usr/lib/systemd/system/kibana.service /usr/lib/systemd/system/kibana.service
	ln -sf /opt/elk/kibana/config/kibana.yml /opt/kibana/config/kibana.yml
fi

if [ $INSTALLSW == "yes" ];then
	systemctl enable logstash.service
	systemctl enable redis.service
	systemctl enable elasticsearch.service
	systemctl enable kibana.service
fi
