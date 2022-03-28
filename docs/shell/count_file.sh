#!/bin/bash
if [ $# -ne 1 ]; then
    echo $0 basepath;
    echo
fi
path=$1
declare A statArray
while read line; do
    ftype=`file -b "$line"`
    let statArray["$ftype"]++
done< <(find $path -type f -print)
echo ===============file types and count ===============
for ftype in "${!statArray[@]}" ; do
    echo $ftype: ${statArray["$ftype"]}
done
