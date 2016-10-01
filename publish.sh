#########################################################################
# File Name: publish.sh
# Author: HouJP
# mail: houjp1992@gmail.com
# Created Time: Sat Jun  4 10:20:55 2016
#########################################################################
#! /bin/bash

./submit.sh "$1"

echo "[`date`] [INFO] 生成博客新文件"
hexo clean
hexo g

echo "[`date`] [INFO] 删除过时文件"
rm -rf ../houjp.github.io/*
echo $?
echo "[`date`] [INFO] 拷贝新文件"
cp -r public/* ../houjp.github.io/
cp CNAME ../houjp.github.io/
cp submit.sh ../houjp.github.io/
echo "[`date`] [INFO] 发布新博客"
cd ../houjp.github.io/
./submit.sh "$1"

