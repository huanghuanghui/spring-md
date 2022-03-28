#!/bin/bash

function DEBUG() {
    [ "$_DEBUG" == "on" ] && $@ || :
}
function foo() {
    echo "aaaaa"
}

foo1() {
    echo "aaaaaaaa"
}

myfoo1() {
    echo "aaaaaaaa"
}



fname() {
  echo $1,$2 #访问参数1和参数2
  echo "$@" #以列表的方式，一次打印所有参数
  echo "$*" #类似与$@，但是参数被作为单个实体
  return 0 #返回值
}

foo
foo1
fname xx aa

echo -----
pwd
(cd /bin;ls;)
pwd
for i in {1..5} ; do
    DEBUG echo $i
done