#########################################################################
# File Name: publish.sh
# Author: HouJP
# mail: houjp1992@gmail.com
# Created Time: Sat Jun  4 10:20:55 2016
#########################################################################
#! /bin/bash

./submit.sh "$1"

hexo clean
hexo g
rm -rf ../houjp.github.io/*
cp -r public/* ../houjp.github.io/
cd ../houjp.github.io/
pwd
../houjp.github.io/submit.sh "$1"

