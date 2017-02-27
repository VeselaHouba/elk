#!/bin/bash
MASTER=scnvx040.prod.itc.homecredit.cn
rsync -a $MASTER:/opt/elk/ /opt/elk/