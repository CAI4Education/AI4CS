#!/bin/bash
#rifare questa challenge

mkdir secret

touch readme.txt
echo "This is public info" > readme.txt

touch secret/flag.txt
echo "fl4g{0wn3r_m4tt3r5}" > secret/flag.txt

useradd developer 2>/dev/null
useradd analyst 2>/dev/null

chown developer:developer readme.txt
chown analyst:analyst secret/flag.txt

chmod 600 secret/flag.txt
chmod 644 readme.txt
