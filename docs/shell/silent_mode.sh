#!/bin/bash

if [ $# -ne 2 ]; then
    echo "$0 match_text file_name"
fi
match_text=$1
file_name=$2

grep -q $match_text $file_name

if [ $? -eq 0 ]; then
    echo $match_text exit in $file_name
    else
      echo $match_text not exit in $file_name
fi