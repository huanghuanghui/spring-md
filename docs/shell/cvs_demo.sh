#!/bin/bash
a=0
# 相等
if [ $a == 0 ]; then
  echo $a
fi

if test $a -eq 0 ; then echo discovery $a=0 ;fi

# 不相等
if [ $a == 0 ]; then
  echo $a
  else
    echo a is not 0
fi

str1=""
str2="xxx"
if [[ -z $str1 ]] && [[ -n $str2 ]] ; then
  echo $str1 is null ,$str2 is not null
fi

if [[ -z $str1 ]] || [[ -n $str2 ]] ; then
  echo $str1 is null or $str2 is not null
fi

e