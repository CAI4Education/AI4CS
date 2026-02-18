#!/bin/bash

mkdir logs
cd logs

touch system.log

for i in {1..100}; do
    echo "falg{$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 16)}" >> system.log
done

echo "fl4g{gr3p_15_p0w3rful}" >> system.log

for i in {1..100}; do
    echo "falg{$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 16)}" >> system.log
done