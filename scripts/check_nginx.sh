#! /bin/bash

if systemctl is-active --quiet nginx; then

	echo 1
else 
	echo 0
fi
