#########################################################################
# File Name: submit.sh
# Author: HouJP
# mail: houjp1992@gmail.com
# Created Time: 三  9/16 21:58:46 2015
#########################################################################
#! /bin/bash

git add --all .
git commit -m "$1"
git push -u origin master
