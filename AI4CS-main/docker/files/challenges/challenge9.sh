#!/bin/bash

mkdir backups

echo "Nothing here" > backups/data.txt
echo "fl4g{5ud0_15_p0w3rfu1}" > /root/root_flag.txt

useradd player 2>/dev/null

echo "player ALL=(root) NOPASSWD: /usr/bin/less" >> /etc/sudoers.d/player
chmod 440 /etc/sudoers.d/player

chown root:root /root/root_flag.txt
chmod 600 /root/root_flag.txt
