# Shell

[toc]

## 小试牛刀

### shebang

为`#!/bin/bash`,指定了bash文件路径，当前的sh文件，给什么解释器执行。shell文件以`#!`开头

### 单引号双印号

- 使用单引号，shell不会对引号中的`$`变量进行饮用
- 双引号可以对变量进行引用

### 打印字符串

- echo "welcome"
- printf "welcome"

#### 格式化输出

```shell
#!/bin/bash
printf "%-5s %-10s %-4s\n" NO NAME MARK
printf "%-5s %-10s %-4.2f\n" 1 hhh 80.345

输出：
NO    NAME       MARK
1     hhh        80.34
```

- -5s表示左对齐，宽度为5的字符串
- %-4.2f表示省略2位小数

#### 转译转译序列

echo -e可以转译其中的转译字符

- ```
  echo -e "1\t2\t3\t"
  输出：
  1       2       3
  ```

### 玩转变量

#### 变量赋值

var=value，value的值没有空格，可以不使用引号，否则必须使用引号。

**var = value不同于var=value，var = value包含空格，指的是是否相等**

#### 变量引用

```shell
#!/bin/bash
var=value
echo $var
```

#### 识别当前使用SHELL

```shell
echo $SHELL
输出：
/bin/bash
echo $0
输出:
-zsh
```

#### 检查是否为超级用户

$UID = 0指代当前用户的ID=0，为超级用户

```shell
if [ $UID = 0 ]; then
    echo "NOT ROOT USER"
    else
      echo "ROOT USER"
fi
```

### 通过Shell进行数学运算

#### expr-整数运算

```shell
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
```

#### bc-浮点运算

```shell
echo "4 * 0.333 "| bc
bcno=53
result6=`echo "$bcno * 1.5"|bc
```

### 标准输入输出

- 0-stdin （标准输入）:对应的设备文件为：/dev/stdin
- 1-stdout（标准输出）:echo "test temp">>temp.txt，会将标准输出重定向到文本，对应的设备文件为：/dev/stdout
- 2-stderr（标准错误）:ls + 2>>temp.txt，会将错误重定向到temp.txt，对应的设备文件为：/dev/stderr

#### 重定向`>`与`>>`的区别

- `>`会首先清空文件后再写入
- `>>`会在文件后追加

#### 丢弃错误信息

```shell
echo a1>a1
cp a1 a2 ; cp a2  a3
chmod 000 a1 #清除所有权限
cat a* #会输出
-----
cat: a1: Permission denied
a1
a1
-----
cat a* 2>err.txt #错误会被重定向到err.txt文件，输出
-----
a1
a1
-----
some_command 2>/dev/null
cat a* 2>/dev/null #将错误文件全部丢弃，/dev/null是一个垃圾桶或是黑洞文件，可以将文件直接丢掉
```

#### tee

只会读取stdin的数据，会覆盖原先的数据，如果想追加数据，可以添加-a参数

```shell
cat a* |tee output.txt|cat -n
-----
cat: a1: Permission denied
     1	a1
     2	a1
-----
cat output.txt
-----
a1
a1
-----
```

#### 将文件重定向到命令

- cmd < file

```shell
cat <<EOF>log.txt
this is a test1 cc
EOF

# 上面的命令指的是，从标准输入开始读数据，一直到EOF结束，然后将读到数据重定向到log.txt
# <<EOF>与结束的EOF，指代的是一个占位符，等遇到EOF的时候结束，在EOF之间的数据，都作为stdin标准输入数据
# >指标准输出到log.txt
```

#### 文件描述符

linux启动后，会默认打开3个文件描述符，分别是：标准输入standard input 0,正确输出standard output 1,错误输出：error output 2

以后打开文件后。新增文件绑定描述符 可以依次增加。 一条shell命令执行，都会继承父进程的文件描述符。因此，所有运行的shell命令，都会有默认3个文件描述符。

linux shell下常用输入输出操作符是：

-  标准输入  (stdin) ：代码为 0 ，使用 < 或 << ； /dev/stdin -> /proc/self/fd/0  0代表：/dev/stdin 
-  标准输出  (stdout)：代码为 1 ，使用 > 或 >> ； /dev/stdout -> /proc/self/fd/1 1代表：/dev/stdout
-  标准错误输出(stderr)：代码为 2 ，使用 2> 或 2>> ； /dev/stderr -> /proc/self/fd/2 2代表：/dev/stderr

### 数组和关联数组

#### 普通数组

```shell
array_var=(0 1 2 3 4 5)
echo ${array_var[0]}
echo ${array_var[*]} #输出arr所有值=echo ${array_var[@]}
echo ${#array_var[*]}# 输出数组长度
echo ${!array_var[*]}#列出数组索引=
```

#### 关联数组

```shell
declare -a fruits_value
fruits_value=([apple]='100dollars' [orange]='200dollars')
echo ${fruits_value[apple]}
-----
100dollars
-----
```

### 使用别名

```shell
alias new_command = 'command seq'

alias lsss='ls' #这样设置，每次重启终端都会使别名失效，要想让别名一直生效，可以写入~/.bashrc文件，因为每启动一个终端，都会执行这个文件

echo 'alias new_command="command"'>>~/.bashrc 

unalias lsss #去除别名 或者从~/.bashrc 中删除文件

#将rm修改为先复制一份到/backup文件夹
alias rm='cp $@ ~/backup;rm $@'
```

### 时间相关

```shell
data +%s #获取时间世纪元，时间戳
#世纪元可以用来计算一个shell执行了多少时间
start=$(date +%s)
sleep 2
end=$(date +%s)
different=$((end-start))
echo "start-end time is $different"
```

### 调试脚本

```shell
bash -x script.sh #会打印出shell脚本中，每一行的命令，以及状态，执行过的每一行，都输出到stdout
```

- set -x :在执行时，显示参数与命令
- set +x：禁止调试
- set -v ：当命令进行读取时，显示输入
- set +v：禁止打印输入

```shell
# 如下的脚本的意思是，在set -x，set +x，之间的代码，会以debug的方式打出
for i in {1..5} ; do
    set -x
    echo $i
    set +x
done
echo 'Script executed'
```

#### _DEBUG调试

```shell
#!/bin/bash
function DEBUG() {
		#	：代表，如果不满足前置条件，就什么都不执行
    [ "$_DEBUG" == "on" ] && $@ || :
}

for i in {1..5} ; do
		#是否满足DEBUG条件，不满足就退出，啥都不执行
    DEBUG echo $i
done


_DEBUG=on ./debug_demo.sh
-----
1
2
3
4
5
-----
./debug_demo.sh #什么都不会输出
```

#### SheBang调试

将shebang从`#!/bin/bash`修改为`#!/bin/bash -xv`，就可以开启调试功能

### 函数和参数

```shell
function foo() {
    echo aa
}
-----
foo() {
    echo aa
}

foo #调用函数
```

参数传递给函数，使得脚本可以访问

```shell
fname() {
  echo $1,$2
  echo "$@"
  echo "$*"
  return 0
}
```

### 读取命令序列输出

将多个命令或工具组合起来生成输出，一个命令的输出可以作为另一个命令的输入。命令组合的输出，可以存储到一个变量中。

```shell
#cmd1的输出，作为cmd2的输入，cmd2的输出作为cmd3的输入
cmd1 | cmd2 | cmd3
ls | cat -n >outls.txt
```

#### 子Shell

```shell
cmd_output=$(ls | cat -n)
echo $cmd_output #会输出cat -n的内容
```

在shell脚本中，可以使用**()**开启子shell

```shell
pwd
(cd /bin;ls;) #这边子shell的路径变更，不会影响下个pwd的输出
pwd
```

可以通过子shell，保留文件中的\n

```shell
cat testn.txt
-----
1
2
3
-----
out=$(cat testn.txt)
echo $out
-----
1
2
3
-----
```

#### 反引用

```shell
cmd_output=`ls | cat -n`
echo $cmd_output #会输出cat -n的内容
```

### Read

用于在键盘或者文件中获得标准输入。可以使用Read的方式，获得与用户的交互输入

```shell
read -s var #读取密码
read -p "Enter input:" var #显示提示信息
read -t timeout var #限时输入
read -d delim_char #使用结束符
```

### 字段分隔符和迭代器

#### CVS



#### 比较与测试

- -eq：相等（equal）
- -ne：不等（not equal）
- -gt：大于（giant than）
- -lt：小于（less then）
- -ge：大于或等于（giant equal）
- -le：小于或等于（less equal）

```shell
#!/bin/bash
a=0
# 相等
if [ $a -eq 0 ]; then
  echo $a
fi

# 不相等
if [ $a -ne 0 ]; then
  echo $a
  else
    echo a is not 0
fi
```

##### 文件系统相关测试

- [ -f $file_var ]：如果给定的变量存在对应的文件夹或文件，就返回true
- [ -x $var ]：包含的文件可执行，返回true
- [ -d $var ]：是目录，返回true
- [ -e $var ]：文件存在，返回true
- [ -c $var ]：是一个字符设备文件路径，返回true
- [ -b $var ]：块设备文件路径，返回true
- [ -w $var ]：文件可写，返回true
- [ -r $var ]：文件可读，返回true
- [ -L $var ]：文件是一个符号链接，返回true

##### 字符串比较

字符串比较的时候，最好使用双中括号，因为使用单中括号有可能会产生错误，所以最好避开他们。

- [[ $str1 = $str2 ]]：str1与str2文本是否一模一样
- [[ $str1 ==$str2 ]]：str1与str2文本是否一模一样
- [[ $str1 != $str2 ]]：str1与str2文本是否不同
- [[ $str1 > $str2 ]]：str1母序是否大于str2
- [[ $str1 < $str2 ]]：str1母序是否小于str2
- [[ -z $str2 ]]：str2是否是空字符串
- [[ -n $str2 ]]：str2是否是非空字符串

```shell
str1=""
str2="xxx"
if [[ -z $str1 ]] && [[ -n $str2 ]] ; then
  echo $str1 is null ,$str2 is not null
fi

if [[ -z $str1 ]] || [[ -n $str2 ]] ; then
  echo $str1 is null or $str2 is not null
fi
```

##### test命令

if的命令可以简写为test

```shell
if [ $a -eq 0 ]; then
  echo $a
fi

if test $a -eq 0 ; then echo $a ;fi
```



## 命令之乐

### cat

cat全名为contract，为拼接的意思

```shell
cat -s muti_lines.txt #压缩连续的空行 squash
cat -s muti_lines.txt |tr -s '\n' #使用tr去除空行

#将制表符重点标记，制表符会以^I的方式输出
cat -T muti_lines.txt #Table
cat -n muti_lines.txt #输出行号 number
```

### 录制与回放终端会话script与scriptreplay

```shell
script -t 2>timing.log -a output.session #进入演示
-----
输入命令
exit #退出录制
-----
scriptreplay timing.log output.session #查看回放

```

#### Linux实时视频演示

```shell
mkfifo scriptfifo #terminal1
cat scriptfifo #terminal2
script -f scriptfifo #terminal1，开始演示 需要结束，就输入exit，并enter
```

### 玩转find

沿着文件层次向下遍历，匹配符合条件的文件，执行对应操作

- find -print0表示在find的每一个结果之后加一个NULL字符，而不是默认加一个换行符，find的默认在每一个结果后加一个'\n'，所以输出结果是一行一行的。当使用了-print0之后，就变成一行了。然后xargs -0表示xargs用NULL来作为分隔符。这样前后搭配就不会出现空格和换行符的错误了

```shell
find base_path #列出当前目录及其子目录下的所有文件
find . -print #打印文件和目录列表 .是当前目录 ..是父目录，print使用/n作为分割文件界定符
find . -print0 #打印文件，当文件名中有\n时，使用-print0
```

#### 根据文件名或正则表达式匹配搜索

- -name：根据文件名称进行匹配

```shell
find . -name "*.txt" -print # 根据名称查找文件，并打印
find . -iname "*.txt" -print #忽略正则匹配出的大小写 ignore
find . \( -name "*.txt" -o -name "*.pdf" \) -print #找出txt或pdf结尾的文件，并打印，\(与\)将文件视为一个整体
```

- -path：将文件路径作为一个整体进行匹配
- -regex：基于正则表达式来匹配路径
- -maxdepth与-mindepth应该作为第三个参数出现，如果出现在第四个参数会影响递归效率，使用find应该先指定-maxdepth与-mindepth，在指定type

```shell
find /home/users -path "*dev*" -print #会打印出路径包含dev的所有文件与文件名包含dev的所有文件
find . -regex ".*\(\.txt\|\.sh\)$" #使用正则匹配，-iregex，匹配忽略大小写

find . !  \( -name "*.txt" -o -name "*.pdf" \) -print #打印不是txt与pdf结尾的文件

find . -maxdepth 1 -type f #规定find的递归深度，文件类型为普通文件

find . -mindepth 2 -type f #查找文件的深度
```

#### 根据文件类型

- -f：file
- -d：dir文件夹

```shell
find . -type d -print
find . -type f -print
```

#### 根据文件时间

- -atime：用户最后访问时间，时间单位是天
- -mtime：文件内容最后一次被修改时间，时间单位是天
- -ctime：变化时间，文件元数据，例如权限或所有权/metadata变化时间，时间单位是天

```shell
find . -type f -atime -7 -print #找出最近7天访问过的文件
find . -type f -atime 7 -print #正好7天访问的文件
find . -type f -atime 7 -print #大于7天前访问的文件
```

- -amin：用户最后访问时间，时间单位是分钟
- -mmin：文件内容最后一次被修改时间，时间单位是分钟
- -cmin：变化时间，文件元数据，例如权限或所有权/metadata变化时间，时间单位是分钟

```shell
find . -type f -amin -7 -print #找出最近7分钟访问过的文件
find . -type f -amin 7 -print #正好7分钟访问的文件
find . -type f -amin 7 -print #大于7分钟前访问的文件
```

- -newer：找到比参考文件更新的文件

```shell
 find . -type f -newer a.pdf -prin
```

#### 基于文件大小搜索

- k
- b
- g
- c
- w
- m

```shell
find . -type f -size +2k -print #大小大于2k的文件
find . -type f -size -2k -print #大小小于2k的文件
find . -type f -size 2k -print #大小等于2k的文件
```

#### 删除匹配文件

- -delete可以用来删除匹配文件

```shell
find . -type f -name *.pdf -delete #删除匹配的文件
```

#### 基于文件权限与所有权

- -perm
- -user

```shell
find . -perm 644 -print #找出权限为644的文件
find . -user hhh -print #找出所有者为hhh的文件
```

#### 结合find执行命令或动作

- -exec：find最强大的功能，find可以借用-exec与其他命令结合

```shell
find . -type f -name "*.txt" -exec cat {} \;>all_txt_file.txt #将所有找到的文件内容重定向到all_txt_file.txt

find . -type f -name *.txt -atime -7 -exec -cp {} NLD \; #将7天内的文件复制到NLD文件夹

find . -type f -name "*.txt" -exec printf "Text file is: %s\n" {} \; #自定义格式输出
```

#### find跳过特定目录

```shell
#查找文件夹下除了.git与.idea的文件夹
find . \( -name ".git" -prune  -or -name ".idea"  -prune \) -o \( -type f -print \)
```

### 玩转xargs

- 擅长将标准输入命令，转成命令行参数
- 可以将单行或多行文本转换成其他格式，例如单行变多行，多行变单行
- 紧跟在管道符之后，将管道符的标准输入作为数据源 `command |xargs`
- xargs将收到的stdin数据重新格式化，在将其作为参数提供给其他命令
- 作用类似于find -exec

#### 行处理

```shell
cat example.txt
-----
1 2 3 4 5 6 7
8 9 10
11 12
-----
cat example.txt|xargs #多行转成一行输出
-----
1 2 3 4 5 6 7 8 9 10 11 12
-----
#单行转成多行输出
cat example.txt|xargs -n 3
-----
1 2 3
4 5 6
7 8 9
10 11 12
-----

```

#### 按指定分割符分割

```shell
#按照X分割
echo "splitXsplitXsplitXsplitXsplitXsplitXsplitX"|xargs -d X
-----
split split split split split split split
-----
#指定每行多少个
echo "splitXsplitXsplitXsplitXsplitXsplitXsplitX"|xargs -d X -n 2
-----
split split
split split
split split
split
-----
```

#### 模拟echo

```shell
cat echo.sh
-----
#!/bin/bash
echo $* '#'
-----
cat args.txt
-----
args1
args2
args3
-----
cat args.txt|xargs -n 2 ./echo.sh
-----
args1 args2 #
args3 #
-----
cat args.txt|xargs ./echo.sh
-----
args1 args2 args3 #
-----

```

#### Xargs -I

- -I可以指定替换字符串，可以拼接命令

```shell
cat echo.sh
-----
#!/bin/bash
echo $* '#'
-----
cat args.txt
-----
args1
args2
args3
-----
# -I {}指定了一个替换字符串，对于每一个命令参数，字符串{}，会被从stdin取到的参数所替换，使用-I，命令就像是在循环执行一样，如果有3个参数，那么命令就会被循环执行三次
cat args.txt|xargs -I {} ./echo.sh -p {} -l
-----
-p args1 -l #
-p args2 -l #
-p args3 -l #
-----
```

#### 结合xargs与find

xargs与find是一对死党，通常是两者结合的方式使用他们。但是很多人用错，比如这样使用：

```shell
 find . -name "*.iml" |xargs rm -rf ; 
```

这样做很危险，因为有可能删除不匹配的文件。我们没法界定find查找文件的分隔符是\n还是空格，很多文件名中包含空格，他们会被xargs认为是界定符，导致删除不必要的文件比如hell test.txt 会被xargs误认为hell 与test.txt。

**所以只要我们将find与xargs一起使用，那么必须要使用-print0与find一起用**，以null字符串来做分割符，应该这么写

```shell
# -t 指出当前删了什么
find . -name "*.txt" -print0 |xargs  -0 -t rm -rf 
```

#### 统计代码行数

find -print0表示在find的每一个结果之后加一个NULL字符，而不是默认加一个换行符，find的默认在每一个结果后加一个'\n'，所以输出结果是一行一行的。当使用了-print0之后，就变成一行了。然后xargs -0表示xargs用NULL来作为分隔符。这样前后搭配就不会出现空格和换行符的错误了

```shell
find . -type f -name "*.txt" -print0 | xargs -0 wc -l 
```

### 使用tr（translate）进行转换

Linux tr 命令用于转换或删除文件中的字符。

tr 指令从标准输入设备读取数据，经过字符串转译后，将结果输出到标准输出设备。

```shell
#小写转大写
echo "this is translate demo" | tr 'a-z' 'A-Z'
-----
THIS IS TRANSLATE DEMO
-----
#大写转小写
echo "THIS IS TRANSLATE DEMO" | tr 'A-Z' 'a-z' # echo "test"|tr '[:lower:]' '[:upper:]'
-----
this is translate demo
-----
#使用tr删除字符 -d
echo "hello 123 world 456"|tr -d '0-9'
-----
hello  world
-----
#字符集补集，最常见的用法是，使用补集将未出现在集合中的字符全部删除
echo "hello 1 char 2 next 4"|tr -d -c '0-9 \n'#hello 1 char 2 next 4中，与0-9的补集，意思是，除了0-9外的，全部删除

#使用tr进行压缩字符
echo "this     is    translate       demo ? " |tr -s ' '
-----
this is translate demo ? 
-----
echo "test"|tr '[:lower:]' '[:upper:]'#小写转大写
-----
TEST
-----
echo "test 1111 " | tr '[:alnum:]' 'a'#所有字母与数字转为a
```

使用tr，可以将以下的所有字符进行转换

- [:alnum:] ：所有字母字符与数字
- [:alpha:] ：所有字母字符
- [:blank:] ：所有水平空格
- [:cntrl:] ：所有控制字符
- [:digit:] ：所有数字
- [:graph:] ：所有可打印的字符(不包含空格符)
- [:lower:] ：所有小写字母
- [:print:] ：所有可打印的字符(包含空格符)
- [:punct:] ：所有标点字符
- [:space:] ：所有水平与垂直空格符
- [:upper:] ：所有大写字母
- [:xdigit:] ：所有 16 进位制的数字

### 校验与核实

在网络传输中，数据有可能丢失，我们在下载文件时，需要对文件进行校验，看看文件是否完整。最常用的是md5sum与sha1sum。

#### md5sum

```shell
#对多个文件进行md5加密
md5sum log.txt output.txt sum.txt>md5_sum.txt         
cat md5_sum.txt
-----
87098301c6655465f7c6db9577667131  log.txt
19fbef8d0c2f19e7ff2227f9a31c6876  output.txt
a8800118258e3d5f2a5446a99125b440  sum.txt
-----
#对加密的文件进行校验，核实文件是否完整
md5sum -c md5_sum.txt
-----
log.txt: OK
output.txt: OK
sum.txt: OK
-----
```

### 排序单一与重复

使用sort对stdin进行排序,uniq是一个经常与sort一起使用的命令，作用是从文本或stdin中提取单一的行。sort与uniq可以用来查找重复的数据。

#### sort

- -r ：倒序，revert
- -n：数字排，number
- -m：merge，合并
- -k：line，按照哪一行排
- -b：去除空白字符
- -d：按照字典顺序排
- sort A.txt -o A.txt：将A进行排序后写入A文件

```shell
cat log.txt  
-----
b
d
g
h
b
-----
sort -n log.txt   #顺序
-----
b
b
d
g
h
-----
sort -r log.txt   #倒序
-----
h
g
d
b
b
-----
sort -m file1 file2 #合并两个排序的文件

cat price.txt 
-----
1       mac     2000
2       windows 4000
3       bsd     1000
4       linux   1000
-----
sort -nrk 1 price.txt #按照第一列的数字倒序排，如果需要用数字排，需要明确给出-n
-----
4       linux   1000
3       bsd     1000
2       windows 4000
1       mac     2000
-----
sort -k 2 price.txt #按照第二列排
-----
3       bsd     1000
4       linux   1000
1       mac     2000
2       windows 4000
-----
cat data.txt  
-----
1010hellothis
2189balabalab
7464dfbbbasss
-----
sort -nk 2,3 data.txt #使用第二跟第三个字符排序
-----
1010hellothis
2189balabalab
7464dfbbbasss
-----
sort -bd data.txt #-b 忽略空白字符，-d是以字典方式排序
```

#### uniq

通过消除重复内容，从给定输入中，找到单一的行

- -u：只显示唯一的行，unique
- -c：count，统计
- -d：找出重复行
- -s：跳过前n个字符
- -w：指定用与比较最大字符数

```shell
cat sorted.txt       
-----
bash
foss
hack
hack
-----
uniq sorted.txt  #去除重复行   
-----
bash
foss
hack
-----
uniq -u sorted.txt #只显示唯一的行
-----
bash
foss
-----
sort sorted.txt|uniq -c #重复行出现次数
-----
1 bash
1 foss
2 hack
-----
uniq -d sorted.txt #找出重复行
-----
hack
-----
```

### 分割文件和数据

#### split

提高可读性，或者生成日志的时候，都会使用到文件的分割，比如按天生成日志。

- k：Kb，按k分割
- m：MB
- g：GB
- c：Byte
- w：word
- -l：按行分割

```shell
dd if=/dev/zero bs=100k count=1 of=data.file #生成一个100k的文件
split -b 10k data.file -d -a 4  #将文件分为10k的小文件，使用数字结尾，有4位数字
```

#### csplit

split只能使用大小或行分割文件，csplit可以使用特定规则分割文件。

### 根据扩展名切分文件名

有一些脚本是根据文件名进行各种处理的。我们可能在保留扩展名的同时，修改文件名，修改文件格式（保留文件名，修改扩展名），或提取部分文件名。

借助%可以轻松将名称从“名称.扩展名中提取出来。

- name=${file%.*}  获取文件名
  - 工作原理：%会删除位于%右侧的通配符，上例是.*，所以会删掉文件扩展名，取到md5_sum
  - %是非贪婪，如果要使用贪婪模式，请使用%%
- extension=${file#*.} 获取扩展名
  - 工作原理：与%类似，求值方向是从左到右，删除位于#右侧的通配符，是非贪婪
  - 如果要使用贪婪模式，请使用##

```shell
#!/bin/bash
cd /Users/hhh/workspace/gitbook/docs/shell
file=md5_sum.txt
# 获取文件名
name=${file%.*} 
echo File name is :$name
#获取扩展名
extension=${file#*.}
echo extension name is :$extension
-----
File name is :md5_sum
echo extension name is :txt
-----

#展示贪婪与非贪婪%
my_var=a.b.c.d.txt
echo ${my_var%.*} #只会删掉最后一个匹配的
-----
a.b.c.d
-----
echo ${my_var%%.*} #有匹配到就全删了
-----
a
-----
```

#### 截取域名的例子

```shell
GOOGLE_URL=www.google.com   
#删除%最后匹配的右边字符
echo ${GOOGLE_URL%.*} 
-----
www.google
-----
#贪婪匹配，删除从第一个.开始后的所有字符
echo ${GOOGLE_URL%%.*} 
-----
www
-----
#删除最后一个*.左边所有内容
echo ${GOOGLE_URL#*.} 
-----
www.google
-----
#贪婪删除*.左边所有内容
echo ${GOOGLE_URL##*.} 
-----
com
-----

```

### 批量重命名与移动

重命名命令为rename，我们一般组合使用rename/find/mv，对文件进行操作

#### 实战演练

##### 用特定的文件名重命名文件

- $?：用于获取最后一个命令的返回值，如果返回值为0，代表执行成功，用来检查退出状态

```shell
#!/bin/bash
cd /Users/hhh/workspace/gitbook/docs/shell/image
count=1
for img in *.jpg ; do
    new=image-$count.${img##*.}
    mv "$img" "$new" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo Rename "$img" To "$new"
        let count++
    fi
done
-----
Rename image-1.jpg To image-1.jpg
Rename image-2.jpg To image-2.jpg
Rename image-3.jpg To image-3.jpg
Rename a.png To image-4.png
-----
```

##### 将指定文件移动到指定文件夹

```shell
find . -type f -name "*.txt" |xargs -I {} mv {} txt_dir
```

### 拼写检查与词典操作

/usr/share/dict/下有一个dict文件，存储了一个词典，可以用来检查单词拼写。

### 交互输入自动化

- read -p：用来读取数据

```shell
#!/bin/bash
read -p "Enter number:" no;
read -p "Enter name:" name;
echo you have enter number:$no,$name
```

## 以文件之名

Unix系统，一切都视为文件，文件与每一个操作息息相关。

### 生成任意大小的文件

```shell
dd if=/dev/zero bs=100k count=1 of=data.file  
```

### 文本文件的交集与差集

- 交集：打印出两个文件共有的行
- 求差：打印出指定文件所包含的且不同的行
- 差集：打印出包含在文件A中，但是不包含在其他文件中的行

```shell
cat A.txt  
-----
Apple
Gold
Iorn
Orange
Steel
-----
cat B.txt
-----
Carrot
Cookie
Gold
Iorn
Orange
-----
# 第一列输出只包含在A.txt文件中的数据，第二列输出只在B中的数据，第三列是A与B相同的行
comm A.txt B.txt
-----
Apple
        Carrot
        Cookie
                Gold
                Iorn
                Orange
Steel
        ~     
-----
```

第一列输出只包含在A.txt文件中的数据，第二列输出只在B中的数据，第三列是A与B相同的行

- -1：删除第一列
- -2：删除第二列
- -3：删除第三列

如果想要打印交集，那么删除第一列跟第二列，只打印第三列。需要差集，只需要第一列跟第二列，删除第三列

```shell
comm -1 -2 A.txt B.txt
-----
Gold
Iorn
Orange
-----
#将1和2列合并起来
comm -3 A.txt B.txt|sed 's/^\t//'
-----
Apple
Carrot
Cookie
Steel
~ 
-----
```

### 查找并删除重复文件



### 创建长目录文件

```shell
mkdir -p /dev/test/a/b/c/d
```

### 文件权限/所有权粘滞键

- user：用户
- group：用户组
- Others：除了用户和用户组外的所有用户
- List -l ：列出所有文件的权限信息

```shell
ls -l
-----
-rw-------  1 hhh  staff      38 Mar 25 15:54 B.txt
-rw-r--r--  1 hhh  staff       0 Mar 25 15:37 a b.txt
drwxr-xr-x  2 hhh  staff      64 Mar 25 16:35 aaa
-----
```

拿drwxr-xr-x举例子，第一列明确了后面的输出

- -：普通文件
- d：目录
- c：字符设备
- b：块设备
- l：符号链接
- s：套接字
- p：管道

后面三组，每组分为3个字符。

- 第一组3个字符对应的用户权限是所有者
- 第二组3个字符对应的用户权限是对应用户组权限
- 第三组3个字符对应的用户权限是其他用户权限

权限分为：

- S：文件所有者允许其他用户以文件所有者的权限执行文件
- T：粘滞键，保护文件的一种策略，只有文件所有者才能删除该文件
- r：可读
- w：可写
- x：可执行

#### 实战演练

```shell
chmod u=rwx g=wx o=r
```

- u：指定用户权限
- g：指定用户组权限
- o：指定其他实体权限

```shell
chmod o+x file
chmod a+x file
chmod a-x file
```

- chmod o+x file：给其他组用户加上可执行权限
- chmod a+x file：给所有用户加上可执行权限
- chmod a-x file：给所有用户减去可执行权限

### 批量生成空白文件

```shell
#!/bin/bash
for name in {1..100}.txt ; do
    touch $name
done
```

### 查询符号链接及其指向目标

相当于mac中的别名，或者Windows中的快捷方式

```shell
ln -s target target_link
```



### 列举文件类型统计信息

```shell
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
```

### diff

查找标记多个代码版本之间的差异，可以找出不容的部分，然后打patch，将修补文件应用到原始文件中，也可以再次修补，来撤销改变。

```shell
cat v1.txt
-----
this is a origin file
line2
line3
line4
happy hacking !
-----
cat v2.txt                                                                   
this is a origin file 
-----
line2
line3
line4
happy hacking !
GUN IS NOT UNIX
-----
diff -u v1.txt v2.txt  #与GIT的diff一致
-----
--- v1.txt      2022-03-25 17:30:01.000000000 +0800
+++ v2.txt      2022-03-25 17:32:04.000000000 +0800
@@ -1,5 +1,6 @@
-this is a origin file
+this is a origin file 
 line2
 line3
 line4
 happy hacking !
+GUN IS NOT UNIX
-----

diff -u v1.txt v2.txt>version.patch#打patch
patch -p1 v1.txt <version.patch #应用patch
diff -u v1.txt v2.txt#打完patch后，两个文件就一样了
```

- N：将所有缺失的文件视为空文件
- a：将所有文件视为文本文件
- u：生成一体化输出
- r：遍历文本下的所有文件

### head与tail

读取大数据的时候，我们可以只需要前n行或者后n行，或者出了前n后n外所有的行

```shell
cat v2.txt|head -n 2
seq 100 | head -n 2 v1.txt #打印前2行
seq 100 | head -n -N file #打印除了最后n行外的所有内容

tail file #打印后10行
tail -n 5 v1.txt #打印后5行
tail -n +5 v1.txt #打印出了前5行后所有的行、
tail -f file #file不断刷新的时候，可以一直打出最后的行
```

### 只列出目录

- ls -d */  

- ls -F |grep "/$"  
- ls -l|grep "^d"
- find . -type d -maxdepth 1 -print

### 统计文件行数/单词数/字符数

- wc -l file：统计所有行
- cat file |wc -l：统计所有行
- wc -w file：统计所有单词
- cat file | wc -w file：统计所有单词
- echo -n 123 |wc -c ：统计所有字符，-n避免统计换行符
- wc file ：打出行数/单词数/字符数
- wc file -L :打印出最长行

### tree打印目录树

- tree PATH -P PATTERN：使用通配符描述样式(❯ tree shell -P "*.sh"  )
- tree PATH -I PATTERN：重点标记文件
- tree -h：打印文件目录大小

## 让文本飞

### 正则表达式

https://github.com/ziishaned/learn-regex

### grep

#### 在文本中搜索一个单词

- --color=auto：标记找到的单词
- -E：使用正则，或者使用egrep，默认使用正则
- -o：只输出匹配的部分
- -v：打印除了匹配的其他行
- -c：统计文本中匹配行的数量，是有多少行有这个数，需要知道单词数量多少可以使用wc -l
- -n：打印字符在第几行
- -b -o：打印字符所在的行什么位置
- -f：使用文件中的正则匹配

```shell
 grep Apple A.txt  #完全匹配
 echo -e "this is a word\n next line"|grep word --color=auto
 -----
 this is a word
 -----
 grep -E '[a-z]+' A.txt
 -----
 Apple
 Gold
 Iorn
 Orange
 Steel
 -----
 echo -e "this is a word\n next line"|grep word -v
 -----
 next line
 -----
 echo -e '11\n 22\n test443\n ass'|grep -E -c '[0-9]'
 -----
 3
 -----
 echo -e '11\n 22\n test443\n ass'|grep -E -o '[0-9]'|wc -l 
 -----
 7
 -----
 grep -n Orange A.txt B.txt
 -----
 A.txt:4:Orange
 B.txt:5:Orange
 -----
 echo 'gun is not unix'|grep -b -o not
 -----
 7:not
 -----
```

#### 递归搜索文件

```shell
 grep 'test' . -R -n
```

#### 忽略大小写

```shell
grep 'apple' -i A.txt 
```

#### 匹配多个样式

```shell
grep -e [pattern1] -e [pattern2]

 echo 'this is a line for text'|grep -e 'this' -e 'line' -o
 -----
 this
 line
 -----
 
```

#### 在grep搜索中包括或排除文件

- --include
- --exclude

```shell
 grep 'test' . -r --include "*.txt"  
  grep 'test' . -r --exclude "*.txt"  
```

#### 删除出现匹配字符的文件

xargs命令通常用于将文件名列表作为命令行参数，传递给其他命令，当文件名作为参数时，建议使用0值作为文件名终止符，而不是使用空格或者换行

```shell
grep 'test' file* -lZ|xargs -I {}  rm {}
```

#### grep静默输出

```shell
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




../silent_mode.sh Apple A.txt 
-----
Apple exit in A.txt
-----
```

#### 打印文本之前或之后的行

- -A：结果之后n行
- -B：结果之前n行
- -C：之前之后n行
- 如果多次匹配，多次匹配之间用--隔开

```shell
seq 10 |grep 5 -A 5  
-----
5
6
7
8
9
10
-----
seq 10 |grep 5 -B 5  
-----
1
2
3
4
5
-----
seq 10 |grep 5 -C 5                                                          
----- 
1
2
3
4
5
6
7
8
9
10
-----
echo -e 'a\nv\nc\n\nd\na\nm'|grep a -C 1
-----
a
v
--
d
a
-----

```

### 用cut切分文件

grep是按行切分文件，我们有时候需要按列切分文件。例如

- cut -f file_list file_name
- --complement：打印出除了指定列外的所有列
- -d 自己指定分割符，例如：-d';'
- -b：字节
- -c：字符，按照指定字符展示
- -f：字段

```shell
cat student.txt                                                              
-----
No      Name    Address Age
1       h1      home1   11
2       h2      home2   12
3       h3      home3   13
4       h4      home4   14
-----
cut -f1 student.txt 
-----
No
1
2
3
4
-----
cut -f2,4 student.txt 
-----
Name    Age
h1      11
h2      12
h3      13
h4      14
-----
cat student_split.txt   
-----
No;Name;Address;Age
1;h1;home1;11
2;h2;home2;12
3;h3;home3;13
4;h4;home4;14
-----
cut -f2 -d';' student_split.txt 
-----
Name
h1
h2
h3
h4
-----
```

### 统计特定文件中的词频

### sed入门

- sed是stream editor流编辑器的缩写
- 能够完美的配合正则表达式的使用
- sed [options] 'command' file(s) 
- sed [options] -f scriptfile file(s)

#### 使用正则替换文本中的字符串

- sed 's/pattern/replace_string' file，字符/在sed中为界定符，我们可以使用任意的界定符
- cat file sed 's/pattern/replace_string' file
- -i 将替换结果运用于原文件
- sed 's/pattern/replace_string' file > file.txt

```shell
echo this thisthisthis|sed 's/this/THIS/g' #替换所有，需要从第N处开始匹配，可以使用Ng
-----
THIS THISTHISTHIS
-----
#使用任意界定符
echo this thisthisthis|sed 's&this&THIS&g'
```

#### 移除空白行

```shell
sed '/^$/d' empty_line.txt
```

#### 已匹配的字符串标记&

在sed中，使用&，可以在替换字符串时，使用已匹配的内容

```shell
echo this is example | sed 's/\w\+/[&]/g'
-----
[this] [is] [example]
-----
```

#### 子串匹配标记\1

```shell
#匹配给定样式的其中一部分
echo this is digit 7 in a number | sed 's/digit \([0-9]\)/\1/'
-----
this is 7 in a number
-----
#命令中 digit 7，被替换成了 7。样式匹配到的子串是 7，(..) 用于匹配子串，对于匹配到的第一个子串就标记为 \1 ，依此类推匹配到的第二个结果就是 \2 
echo aaa BBB | sed 's/\([a-z]\+\) \([A-Z]\+\)/\2 \1/'
-----
BBB aaa
-----
```

#### 组合多个表达式

sed 'expression'|sed 'expression'

#### 引用

sed中也可以引用变量

```shell
test=hello
echo hello world|sed "s/$test/HELLO/"
```

### awk入门

#### 脚本结构

```shell
awk [options] 'script' var=value file(s)
awk [options] -f scriptfile var=value file(s)
```



## 一团乱麻？没这回事

### wget

wget可以用来下载网页或远程文件。

- -c断点续传
- -- limit- rate：限制网速

```shell
wget URL1 URL2 URL3
```

### curl

curl可以进行下载，发送http请求，指定http头部等操作

- -- silent：使得curl命令不显示进度信息
- --progress：下载显示进度信息
- -o：用来下载数据，写入文件

```shell
curl URL --silent -o
```

## B计划

### tar

```shell
 #压缩
 tar -cf output.tar out*.txt 
 #解压缩
 tar -zxvf output.tar
```

## 无往不利

### ifconfig

用来显示网络接口，子网掩码等详细信息

#### 打印网络接口列表

```shell
ifconfig|cut -c-10|tr -d ' '|tr -s '\n'
```

#### Dns与名字服务器

例如：www.google.com，只是一组符合，在网络世界中需要使用IP地址才能访问到对应的服务器，使用符合无法访问，这时候就出现了DNS（Domain name service）服务器，维护了域名与IP地址的关系。在本地网络中，我们可以设置本地DNS使用主机名命名本地网络上的主机。

分配给当前系统的名字服务器，可以通过 cat /etc/resolv.conf 文件来查看。一般我们会添加114.114.114.114/8.8.8.8的DNS，114.114.114.114是国内3大运营商共同维护的DNS，不存在DNS劫持的情况，对于国内的域名支持较好，8.8.8.8是Google提供的DNS域名服务器，对于国外的支持较好，Google承诺不会在DNS中添加广告信息，做DNS劫持等

```shell
#添加DNS服务器
echo nameserver ip_address>> /etc/resolv.conf 
```

#### DNS查找

有多种工具可以进行DNS查找，nslookup与host就是其中两种，他们会想DNS服务器请求IP地址解析

- host:当执行host的时候，会列出域名对应的所有IP地址
- nslookup是一个类似与host的命令，用于列出dns相关信息

```shell
host google.com  
-----
google.com has address 93.46.8.90
google.com has address 46.82.174.69
google.com has address 59.24.3.174
-----
nslookup google.com  
-----
Server:         8.8.8.8
Address:        8.8.8.8#53

Name:   google.com
Address: 93.46.8.90
-----
```

#### 为IP地址添加符号名

在工作中，我们会经常访问某台服务器上的某些资源，那么一直去记忆他们的IP地址，通过IP地址对我们自己的服务进行访问，显然是十分不方便的，但是我们又只是测试的时候，先用用，并不需要真正的走域名服务器，去解析我们的域名（这需要购买）。那么这时候，我们就可以通过修改我们本机的hosts文件，来实现，直接使用域名访问我们的机器服务的需求。

例如使用switch host就可以直接配置hosts文件了，我们可以通过访问Kubernetes这个域名，直接访问啊都10.210.13.4这台服务器。

![image-20220326224935602](/Users/hhh/Library/Application Support/typora-user-images/image-20220326224935602.png)



#### 手动添加Hosts

```shell
echo IP_ADDRESS symbolic_name>>/ect/hosts
```

### route设置默认网关/显示路由表

关注路由配置的原因是因为单位办公环境不允许访问互联网，在原来只有一块网卡的时候，不得不频繁的在办公网和互联网之间切换。为了解决这个问题，我在Macbook Pro上外接了一块USB无线网卡，通过两块网卡实现既能上办公网，也能上互联网。使用route可以实现

### traceroute

当请求Internet的时候，服务器可能位于远端，通过多个设备节点连接，分组要穿过网关，才能到达目的地。traceroute命令可以显示所有途径的网关地址。通过traceroute就可以知道到达对应的地址服务器，需要经过多少跳。中途的网关或者路由器的数量，给出了一个测量网络上两个节点之间的的直接距离的度量（metric）

```shell
traceroute www.google.com
-----
traceroute to www.google.com (108.160.170.41), 64 hops max, 52 byte packets
 1  192.168.2.1 (192.168.2.1)  3.472 ms  1.956 ms  1.934 ms
 2  192.168.1.1 (192.168.1.1)  2.583 ms  2.562 ms  5.196 ms
 3  100.76.160.1 (100.76.160.1)  5.683 ms  5.711 ms  14.994 ms
 4  112.5.152.65 (112.5.152.65)  18.421 ms
    112.5.152.69 (112.5.152.69)  6.743 ms
    112.5.152.65 (112.5.152.65)  5.860 ms
 5  218.207.222.121 (218.207.222.121)  16.701 ms *  6.122 ms
 6  * 112.5.152.165 (112.5.152.165)  6.101 ms *
-----
```

### 使用ping

验证网络上，两天机器网络是否联通的工具。ping可以用来获取两台机器之间的往返时间。ping的机器会向目标机器发送一个echo分组的命令，并等待目标机器返回

- ping ADDRESS -c 2：ADDRESS可以是域名/IP地址/主机名，-c是指定ping多少次
- 

```shell
ping www.baidu.com                                                               
PING www.wshifen.com (103.235.46.39): 56 data bytes
64 bytes from 103.235.46.39: icmp_seq=0 ttl=44 time=52.084 ms
64 bytes from 103.235.46.39: icmp_seq=1 ttl=44 time=47.666 ms
```

### 列出网络上所有的活动主机

```shell
#!/bin/bash

for ip in 192.168.1.{0..2} ; do
    echo ping $ip
    ping $ip -c 2
    if [ $? -eq 0 ]; then
        echo $ip is live
        else
          echo $ip is not alive
    fi
done
```

### 传输文件

- 使用FTP传输文件可以使用lftp命令
- 使用SSH传输文件，可以使用sftp
- RSYNC使用SSH与rsync命令，并借助scp通过SSH进行传输

一般文件传输都是使用scp（Security Copy），所有的文件都是通过SSH加密通道进行传输的。

scp：

- -r：递归复制
- -p：保留权限

```shell
#将本机文件复制到远程主机
scp filename user@remote_address:/home/path
#将本机目录复制到远程主机 添加-r命令
scp -r txt_dir root@10.210.13.4:/tmp     
#将远程主机的目录复制到本机，与传输的命令相反
 scp -r root@10.210.13.4:/tmp/test_dit test_dit
```

一旦实现了ssh登录，那么scp是不需要输入密码，可以直接进行文件传输

### 用SSH实现无密码自动登录

SSH广泛用于脚本自动化。借助SSH我们可以在远程主机上执行命令，读取输出。

SSH采用基于公钥与基于私钥的加密技术进行自动化认证。认证密钥包括两部分：公钥和私钥。我们可以通过`ssh-keygen`命令创建认证密钥。想要实现自动化认证，密钥必须放在服务器中（将其加入文件 ~/.ssh/authorized_keys），与公钥对应的私钥放置在客户端机器的~/.ssh文件夹中。另一些关于ssh的相关配置信息，例如authorized_keys可以通过修改/ect/ssh/sshd_config 来修改配置。

设置ssh自动化认证需要2步骤：

- 生成ssh密钥
- 将生成的公钥上传到远程主机，并将其加入到` ~/.ssh/authorized_keys`中

创建密钥需要使用`ssh-keygen -t rsa`，并规定加密算法为rsa。需要输入一个口令来生成一对公钥和私钥，这时候 id_rsa.pub与id_rsa已经生成

- id_rsa.pub是生成的公钥，公钥需要添加到远程服务器 ~/.ssh/authorized_keys文件中
- id_rsa是生成的私钥

```shell
ssh USER@REMOTE_HOST "cat >> ~/.ssh/authorized_keys"< ~/.ssh/id_rsa.pub
```

#### 使用SSH在远程主机执行命令

SSH是一个很有意思的管理系统工具，它能通过shell登录并控制远程主机。SSH是source shell的缩写，我们可以登录远程主机来执行命令，这就像是在本地执行命令一样的。

ssh服务器默认运行在22端口，如果需要修改端口，那么可以使用-p修改目标主机所在的shell端口

```shell
ssh root@10.210.13.4 "echo user :$(whoami);echo os:$(uname)"
-----
user :hhh
os:Darwin
-----
```

#### SSH压缩功能

带宽有限时，可以使用SSH压缩功能，- C开启压缩

#### 将数据重定向到远程Shell的stdin

```shell
echo "test"|ssh USER@IP_ARRRESS 'cat >> list'
或者
ssh USER@IP_ARRRESS 'cat >> list' <file
如：
ssh USER@REMOTE_HOST "cat >> ~/.ssh/authorized_keys"< ~/.ssh/id_rsa.pub
```

### 在本地挂载点上挂载远程驱动器

要将远程主机的文件系统挂载到本机，可以使用：

```shell
#挂载
sshfs USER@REMOTE_ADDRESS:/home/path /mnt/mountpoint
#卸载
umount /mnt/mountpoint
```

### 网络流量与端口分析lsof/netstat

网络端口是网络应用程序必不可少的参数。应用程序在主机上打开端口，然后通过远程主机中打开的端口实现远程通信。出于安全方面的考虑，必须留意系统中打开及关闭的端口。恶意软件和rootkits可能会利用特定的端口及服务运行在系统中，从而使攻击者可以对数据及资源进行末经授权的访问。通过获取开放端口列表以及运行在端口之上的服务，我们便可以分析并抵御rootkits的操纵，而且这些信,息还有助于我们对其进行清除。开放端口列表不仅能够协助检测恶意软件，而且还能够收集开放端口的相关信息对网络应用程序进行调试。它可以用来分析某些端口连接及端口侦听功能是否正常。

列出系统中开放的端口及端口上所运行的服务

- lsof -i :8080 查看8080端口有哪些PID在占用

#### netstat查看开放端口及服务

- netstat -antu

- List all ports:netstat --all
- List all listening ports:netstat --listening
- List listening TCP ports:netstat --tcp
- Display PID and program names:netstat --program
- netstat  -anp  |grep  端口号：查看端口是否被占用。` netstat -an|grep 3306 `

## 当个好管家

### 统计磁盘使用情况df/du

- df：disk free，df -h以更适合读的方式打印出磁盘使用情况
- du：disk usage，默认统计以字节为单位
  -  du -sh txt_dir  ：以更适合查看的方式统计文件夹磁盘用量

```shell
 du md5.sh 
 -----
 8       md5.sh
 -----
 #查看文件夹内所有文件磁盘使用量
 du -a txt_dir
 #使用更友好的方式查看磁盘占用
 du -h manpages-zh-1.5.1 
 #统计多个文件的合计使用量
 du -c file1 file2
 
 #找到指定目录中最大的10个文件，包含文件夹
 du -ak PATH |sort -nrk 1|head -n 10
 #找到指定目录中最大的10个文件，排除文件夹
 find . -type f -exec du -k {} \;sort -nrk 1|head 
```

### 统计命令执行时间time

```shell
time ls 
-----
ls -G  0.00s user 0.00s system 71% cpu 0.009 total
-----
```

### 当前登录用户/启动日志/启动故障日志相关信息

- who：查看当前登录用户

- w：查看当前登录用户
- users：查看当前登录用户
- uptime：查看系统已经通电运行了多久
- last：提供登录回话信息，last reboot：获取重启信息
- lastb：获取失败的登录用户信息

#### 获取当前登录用户who/w/users

```shell
who
-----
hhh      console  Mar 18 15:42 
hhh      ttys001  Mar 27 00:12 
hhh      ttys003  Mar 24 13:44 
-----
w
-----
15:35  up 8 days, 23:53, 3 users, load averages: 2.47 2.42 2.59
USER     TTY      FROM              LOGIN@  IDLE WHAT
hhh      console  -                18Mar22 8days -
hhh      s001     -                 0:12   15:18 -zsh          ��    /bin/zsh       
hhh      s003     -                Thu13   15:20 ssh root@10.210.13.4 bin      ��    /usr/bin/ssh
-----
users
-----
hhh
-----
```

#### 查看系统已经通电运行了多久

```shell
uptime
-----
15:36  up 8 days, 23:54, 3 users, load averages: 2.34 2.44 2.5
-----
```

#### 打印出10条最常用的命令

```shell
#!/bin/bash
printf "%-32s %-10s\n" 命令 次数

cat ~/.bash_history | awk '{ list [$1] ++; } END {  for (i in list ) { printf ("%-30s %-10s\n",i,list [i]); }  }'| sort -nrk 2 | head
```

#### 用Watch监视命令输出

```shell
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
```

#### 用watch监视命令输出

watch命令可以用来在终端中，以固定的间隔监视命令的输出。

```shell
watch ls
#以间隔5秒输出一次
watch -n 5 'ls -l'
```

#### 对文件及目录访问进行记录inotifywait

inotifywait可以用来访问文件修改的相关信息。

#### 使用logrotate管理日志文件

logrotate是日志文件轮替的意思。一旦日志文件的大小超过了一定大小，就对他的内容进行抽取，同时将日志文件中的旧条目存储到归档文件中，因此日志文件旧得以保存，以便于日后的查阅。

logrotate可以将日志大小限定在一定SIZE以内，各种程序将会将信息添加到日志文件中，最新添加的总是出现在文件尾部，logrotate根据配置扫描特定日志文件log_file1，将剩下的数据，移入到新文件中，如果log_file1该日志文件数据越来越多，超过了SIZE限定的限额，logrotate就会使用最近内容更新日志文件log_file1，然后使用较旧的内容创建log_file2。

使用logrotate指令，可让你轻松管理系统所产生的记录文件。它提供自动替换，压缩，删除和邮寄记录文件，每个记录文件都可被设置成每日，每周或每月处理，也能在文件太大时立即处理。您必须自行编辑，指定配置文件，预设的配置文件存放在/etc目录下，文件名称为logrotate.conf。

可以在网上查看对应的使用方法，最主要的功能就是日志文件的管理

#### 使用syslog记录日志

日志文件是那些为用户提供服务的应用程序的重要组成部分。应用程序在运行时将状态信息写人日志文件。如果程序崩溃或者当我们需要查询服务的相关信,息时，就可以借助日志文件。在var/log目录中，你可以找到与各种守护进程和应用程序相关的日志文件。var/log是存储日志文件的公共目录。如果你该过日志文件，你就会看出它们都采用了一种通用的格式。在Linux系统中，在/var/log中创建井写人日志信息是由被称为syslog的协议处理的。它由守护进程sylog负责执行。每一个标准应用进程都可以用syslog记录日志信,息。在这则攻路中，我们将讨论如何在脚本中用syslog记录日志信息。

### 管理重任

#### 收集进程信息

和进程相关的命令是top/ps/pgrep

#### PS

ps是收集进程信息的重要工具。它提供的信息包括：拥有进程的用户、进程的起始时间、进程所对应的命令行路径、进程ID (PID)、进程所属的终端(TTY)、进程使用的内存、进程占用的CPU等。

- -f：显示更多信息
- -e：获取运行在系统中的每一个进程信息

```shell
 ps -ef
-----
  UID   PID  PPID   C STIME   TTY           TIME CMD
  501 18103 77604   0 Fri11AM ttys000    1:59.41 /bin/zsh --login -i
  501 18108     1   0 Fri11AM ttys000    0:00.01 /bin/zsh --login -i
  501 18175     1   0 Fri11AM ttys000    0:00.00 /bin/zsh --login -i
  501 18176     1   0 Fri11AM ttys000    0:00.48 /bin/zsh --login -i
-----
```

#### top

top会默认输出一个占用CPU最多的进程列表

- top -o cup 
- top -o mem
- Top -o cpu -O mem

#### kill

杀死进程

#### which/Whereis/file/whatis与平均负载

- which：用来查找某个命令的位置
- whereis：与which相似，但是可以打印出命令手册及源代码所在位置
- file：用来确定文件类型，flie /bin/ls会打印出与该文件类型相关的细节信息
- whatis：会输出命令的简短帮助信息
- 平均负载：使用uptime获取系统平均负载

### 收集系统信息

- hostname：打印系统主机名（uname -n）
- uname -a：打印Linux内核版本
- uname -r：Linux发行版本
- unama -m：打印主机类型
- cat /proc/cpuinfo：打印cpu相关信息
- cat /proc/meminfo：打印cpu相关信息
- fdisk -l列出系统分区信息
- lshw：获取系统详细信息

### 使用corn进行调度

Linux中可以使用corn表达式，来执行定时任务

## 特殊变量（$0、$1、$2、 $?、 $# 、$@、 $\*）

shell编程中有一些特殊的变量可以使用。这些变量在脚本中可以作为全局变量来使用。

| **名称** | **说明**                                                     |
| -------- | ------------------------------------------------------------ |
| $0       | 脚本名称                                                     |
| $1-9     | 脚本执行时的参数1到参数9                                     |
| $?       | 脚本的返回值                                                 |
| $#       | 脚本执行时，输入的参数的个数                                 |
| $@       | 输入的参数的具体内容（将输入的参数作为一个多个对象，即是所有参数的一个**列表**） |
| $*       | 输入的参数的具体内容（将输入的参数作为一个单词）             |

**$@与$\*的区别：**

　　**$@与$\*都可以使用一个变量来来表示所有的参数内容，但这两个变量之间有一些不同之处。**

　　**$@：将输入的参数作为一个列表对象**

　　**$\*：将输入的参数作为一个单词**











