# Brew 安装软件记录

[toc]

## brew

- brew安装的软件在/usr/local/Cellar
- 配置文件在：/usr/local/etc
- brew 服务启动 brew services list /start /usr/local/Cellar下的文件
- brew 启动日志/usr/local/var/log/

## Zookeeper 

brew install zookeeper 

Kafka依赖zookeeper，集群模式：

```properties
vim /usr/local/etc/zookeeper/zoo.cfg
------
追加
server.1=192.168.80.50:3188:3288
server.2=192.168.80.60:3188:3288
server.3=192.168.80.70:3188:3288
```

server.A=B:C:D
- A 是一个数字，表示这个是第几号服务器。集群模式下需要在zoo.cfg中dataDir指定的目录下创建一个文件myid，这个文件里面有一个数据就是A的值，Zookeeper启动时读取此文件，拿到里面的数据与zoo.cfg里面的配置信息比较从而判断到底是哪个server。
- B 是这个服务器的地址。
- C 是这个服务器Follower与集群中的Leader服务器交换信息的端口。
- D 是万一集群中的Leader服务器挂了，需要一个端口来重新进行选举，选出一个新的Leader，而这个端口就是用来执行选举时服务器相互通信的端口。

## Kafka

brew install kafka 

Kafka依赖zookeeper，集群模式：

```properties
vim /usr/local/etc/kafka/server.properties 
修改broker.id，为递增的数字类型，多启动几台，就行
zookeeper.connect=
修改连接zookeeper地址
brew安装，如果kafka一直起不来，可以删除配置文件中log.dir下的meta.properties
```

## debezium

### 需要应用

- zk
- kafka
- debezium官网下载mysql 连接器，解压到本地文件夹**这边有个大坑**，需要放置在top顶层文件夹，就是需要在连接器的上2层文件夹

例如：连接器放在*/opt/connectors/debe...*

![image-20220520175303805](/Users/hhh/Library/Application Support/typora-user-images/image-20220520175303805.png)

那么配置到/usr/local/etc/kafka/connect-distributed.properties文件的应该是

![image-20220520175427025](/Users/hhh/Library/Application Support/typora-user-images/image-20220520175427025.png)

### 配置

Mac 本地使用brew安装，kafka配置位置在/usr/local/etc/kafka/connect-distributed.properties，让Kafka知道他的连接器插件位置

- 配置Kafka地址
- 配置group ID
- key/value converter：都用默认json就行，有需要改，可以按照官网进行改动
- 副本数status.storage.replication.factor具体情况具体分析副本数，单机版就设置1
- **最重要的是** 告诉Kafka插件位置plugin.path，路径不要配置太深，会识别不出来
- 配置完成后，重启kafka
- 启动kafka连接器 `/usr/local/Cellar/kafka/3.1.0/bin/connect-distributed -daemon /usr/local/etc/kafka/connect-distributed.properties`
- 需要启动连接器，才能访问服务 `curl -H "Accept:application/json" 127.0.0.1:8083/connectors/`测试服务是否正常启动

### 注册连接器

![image-20220519233553669](/Users/hhh/Library/Application Support/typora-user-images/image-20220519233553669.png)



- 1.name 连接器名称，自己取名字

- 2.connector.class 连接器类，写死

- 3.hostname/port/user/password：需要连接的数据库信息

- 4.server.id/name：连接器会作为一个mysql的selves来工作，server.id指的是selve ID，随便写
  - name会作为topic的前缀
- include.list：指的是需要监听的mysql的database
- bootstrap.servers：历史记录存储地址
- history.kafka.topic：存储debezium的sechma使用

 

```c
curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8083/connectors/ -d '{
    "name": "showcon-mysql-connector",
    "config": {
        "connector.class": "io.debezium.connector.mysql.MySqlConnector",
        "database.hostname": "192.168.1.54",
        "database.port": "3322",
        "database.user": "root",
        "database.password": "dev_user_1234!",
        "database.server.id": "184054",
        "database.server.name": "showcon",
        "database.include.list": "draft",
        "database.history.kafka.bootstrap.servers": "localhost:9092",
        "database.history.kafka.topic": "schema-changes.inventory"
    }
}'
```

### Kafka producer

**debezium在连接器注册上去，salve开始工作时，会将所有数据当作一次快照全部采集，再次启动debizium不会采集原有数据，使用 springboot 内嵌的debezium会每次启动应用都采集原始数据。**

Kafka生产者会默认创建一个topic为`(database.server.name).(database_name).(table_name)`，我们只需开启一个java应用程序，监听对应topic，然后对数据进行实时处理就行

### 集群方案

debezium 的连接器，是挂载在kafka中，一般与kafka集群一一对应，集群配置与单机版配置一致，将connect-distributed.properties分发到不同的kafka集群集群上后，将连接器文件分发到Kafka所在机器，重启Kafka集群，启动各个节点的连接器



## Kibana

- brew tap elastic/tap

- brew install elastic/tap/kibana-full
- brew services start elastic/tap/kibana-full