#!/bin/bash

mkdir -p data/archive
mkdir -p data/tmp
mkdir -p data/logs

# tanti file fake
for i in {1..40}; do
    echo "Log entry $i" > data/logs/log_$i.txt
done

# file nascosto
echo "Nothing important here" > data/archive/notes.txt

# file con flag ma camuffato
echo "temporary text" > data/tmp/.cache
echo "fl4g{p1p35_4nd_f1nd_4r3_k3y}" >> data/tmp/.cache

# permessi strani
chmod 000 data/tmp/.cache
chmod -R 755 data
