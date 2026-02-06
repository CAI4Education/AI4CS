#!/bin/bash
#tail challenge
mkdir logs

for i in {1..50}; do
    echo "Normal log line $i" >> logs/access.log
done

echo "fl4g{t41l_s4v35_t1m3}" >> logs/access.log

chmod 644 logs/access.log