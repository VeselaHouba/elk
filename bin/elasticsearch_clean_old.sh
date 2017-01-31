#!/bin/bash
def=7
if [ $# -ne 1 ] ;then
	echo "using default $def days"
else
	def=$1
fi
if [ -e /usr/bin/curator_cli ] ;then 
	# elastic 5.x
	curator_cli --host localhost delete_indices --older-than $def --time-unit days --timestring '%Y.%m.%d'
else 
	# elastic 2.x
	curator --host localhost delete indices --older-than $def --time-unit days --timestring '%Y.%m.%d'
fi