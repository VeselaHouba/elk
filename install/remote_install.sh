#!/bin/bash
if [ $# -ne 2 ];then
	echo "Usage $0 serverlist commandlist"
	exit 1
fi
echo "It's REQUIRED that target servers can connect to git.homecredit.net via ssh"
echo "Continue? y/n"
read cont
if [ $cont != 'y' ];then
	exit 1
fi
for i in `cat $1`;do
	echo $i
	scp -o "StrictHostKeyChecking=no" $2 $i:/tmp/commands &>/dev/null
	rsync -Paz /root/install/distribute/ $i:/root/distribute/
	#ssh -R 2222:git.homecredit.net:22 -o "ForwardAgent=yes" $i -- "bash /tmp/commands"
	ssh -o "ForwardAgent=yes" $i -- "bash /tmp/commands"
	sleep 1
done
