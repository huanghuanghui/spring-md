#!/bin/bash
cd /Users/hhh/workspace/gitbook/docs/shell
file=md5_sum.txt
name=${file%.*}
echo File name is :$name
extension=${file#*.}
echo extension name is :$extension