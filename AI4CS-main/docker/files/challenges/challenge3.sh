#!/bin/bash

# Creating a maze of folders
mkdir -p lab/start/hall1/roomA
mkdir -p lab/start/hall1/roomB/deep1/deep2
mkdir -p lab/start/hall2/side1
mkdir -p lab/start/hall2/side2/more/depth
mkdir -p lab/hidden/place/where/flag/is
mkdir -p lab/confusing/area/trap1
mkdir -p lab/confusing/area/trap2/fakepath

# Fake flags
echo "fake{not_this_one}" > lab/start/hall1/roomA/fake_flag.txt
echo "fake{keep_looking}" > lab/start/hall1/roomB/deep1/fake_flag2.txt
echo "fake{nope}" > lab/start/hall2/side1/another_fake.txt
echo "fake{wrong_way}" > lab/confusing/area/trap1/fake.txt
echo "fake{still_wrong}" > lab/confusing/area/trap2/fakepath/not_here.txt

# Real flag
echo "fl4g{cd_15_d1ff3r3n7_fr0m_dvd}" > lab/hidden/place/where/flag/is/real_flag.txt