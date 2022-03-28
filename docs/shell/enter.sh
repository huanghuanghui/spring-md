#!/bin/bash
read -p "Enter number:" no;
read -p "Enter name:" name;
echo you have enter number:$no,$name

cd /Users/hhh/workspace/gitbook/docs/shell/txt_dir/touch
for name in {1..100}.txt ; do
    touch $name
done