#!/bin/bash -xv
printf "%-5s %-10s %-4s\n" NO NAME MARK
printf "%-5s %-10s %-4.2f\n" 1 hhh 80.345

echo -e "1\t2\t3\t"

var=value
echo $var

if [ $UID = 0 ]; then
    echo "NOT ROOT USER"
    else
      echo "ROOT USER"
fi

no1=3
no2=4
let result=no1+no2
echo $result

result2=$[no1+no2]
echo $result2

# no2=no2+6
let no2+=6
result3=$[no1+no2]
echo $result3

result4=`expr 5 + 6`
echo $result4

result5=$(expr $no1 + $no2)
echo $result5

echo "4 * 0.333 "| bc




cat <<EOF>log.txt
this is a test1 cc
EOF



array_var=(9 8 2 3 4 5)
echo ${array_var[0]}
echo ${!array_var[*]}


declare -a fruits_value
fruits_value=([apple]='100dollars' [orange]='200dollars')
echo ${fruits_value[apple]}
echo ${!fruits_value[orange]}

echo ----



start=$(date +%s)
sleep 2
end=$(date +%s)
different=$((end-start))
echo "start-end time is $different"


for i in {1..5} ; do
    set -x
    echo $i
    set +x
done
echo 'Script executed'