#!/bin/bash
def=7
if [ $# -ne 1 ] ;then
	echo "using default $def days"
else
	def=$1
fi
curator_cli --host localhost delete_indices --older-than $def --time-unit days --timestring '%Y.%m.%d'
