#!/bin/bash

SECS=60
UNIT_TIME=5

STEPS=$(( $SECS / $UNIT_TIME ))
echo Watching CPU usage...;
for((i=0;i<STEPS;i++))
do
    ps -eo comm,pcpu | tail -n +2 >> /tmp/cpu_usage.$$
    sleep $UNIT_TIME
done

echo
echo CPU eaters:
cat /tmp/cpu_usage.$$ | \
awk '
{ process[$1] += $2; }
END{
    for(i in process)
    {
        printf("%-20s%s\n",i,process[i]);
    }
}' | sort -nrk 2 | head
rm /tmp/cpu_usage.$$