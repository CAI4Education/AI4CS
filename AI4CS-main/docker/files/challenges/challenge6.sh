#!/bin/bash
#change this challenge
mkdir -p data/archive/old
mkdir -p data/archive/backup
mkdir -p data/current

echo "Just junk" > data/archive/old/file1.txt
echo "Not here" > data/archive/backup/file2.txt
echo "fl4g{f1nd_m4st3r}" > data/current/very_secret.txt

chmod -R 755 data