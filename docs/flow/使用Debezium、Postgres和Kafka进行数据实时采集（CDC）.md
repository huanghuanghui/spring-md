# 使用Debezium、Postgres和Kafka进行数据实时采集（CDC）

[toc]



## 1. 背景

​		最近在研究审批流系统的建设，目前方案是采用的是Flowable/Camunda工作流引擎。使用Flowable/Camunda工作流，就会涉及到工作流引擎的用户体系如何与现有用户体系集成的问题。现有设计中，工作流定位偏重于企业内部或多租户流程的流转，在业务系统端需要设计部门、角色、人员以及人事归属岗位与工作流用户体系对应。

​		现在面临一个问题，如何解决现有人事体系数据如何【`实时`】同步至工作流引擎中。如果现有体系数据与工作流数据在同一个库中，相对比较好解决。而微服务架构中，不同服务的数据通常存放在不同数据库中，那么就需要进行数据的同步。采用的方式不同，可以取得的效果也相同。

​		考虑如下三种方案：

- ETL：使用ETL工具进行数据同步是典型的方式，可以选择工具也比较多。开源的ETL工具增量同步问题解决的并不理想，不使用增量同步数那么数据同步始终存在时间差；商业的ETL工具增量同步解决的比较好，但是庞大且昂贵。
- 消息队列：消息队列是多系统集成普遍采用的方式，可以很好的解决数据同步的实时问题。但是数据同步的两端都需要自己编写代码，一端写生产代码一端写消费代码，生产端代码还要捆绑现有体系数据所有操作，需要的编写量比较大。
- 经过公司总监的建议，看了一些Debezimu相关文档，发现可以使用Debezimu来解决以上说明的审批流的数据同步问题，以及未来出现的数据同步的需求。

![image-20220412160902542](/Users/hhh/Library/Application Support/typora-user-images/image-20220412160902542.png)

## 2. Debezium介绍

​		RedHat开源的Debezium是一个将多种数据源实时变更数据捕获，形成数据流输出的开源工具。它是一种CDC（Change Data Capture）工具，工作原理类似大家所熟知的Canal, DataBus, Maxwell等，是通过抽取数据库日志来获取变更的。官方地址为：https://debezium.io/documentation/reference/1.9/。

​		Debezium是一个分布式平台，它将您现有的数据库转换为事件流，因此应用程序可以看到数据库中的每一个行级更改并立即做出响应。Debezium构建在Apache Kafka之上，并提供Kafka连接兼容的连接器来监视特定的数据库管理系统。

​		与ETL不同，Debezimu只支持在生产端连接数据库，消费端不支持连接数据库，而是需要自己编写代码接收Kafka消息数据。分析下来这种方式更加灵活，还可以很好利用现有微服务架构中的Kafka。

## 3. Docker Compose搭建Debezimu环境

### 3.1.Mac brew安装PostgreSQL

```shell
brew install postgres
psql -version
# 若之前安装过，请确保/usr/local/var路径下无任何postrges相关文件残留
initdb --locale=C -E UTF-8 /usr/local/var/postgres

ln -sfv /usr/local/opt/postgresql/*.plist ~/Library/LaunchAgents

# 检查server状态，并确认已开启
brew services list
brew services start postgresql

# mac上新建用户，设置密码并确认
createuser postgres -P

# 删掉默认的postgres库
dropdb postgres

# 新建postgres库，若客户端连接报错，有时候需要额外创建跟当前用户同名的库
createdb postgres -O postgres -E UTF8 -e

# 进入交互模式
psql -U hhh -d postgres -h 127.0.0.1
```

### 3.2.修改PostgreSQL配置

```shell
#查看PostgreSQL安装配置，提示This formula has created a default database cluster with:initdb --locale=C -E UTF-8 /usr/local/var/postgres
brew info postgresql
#修改配置
vim /usr/local/var/postgres/postgresql.conf
```

**Logical Decoding**功能是PostgreSQL在9.4加入的，它是一种机制，允许提取提交到事务日志的更改，并在输出插件的帮助下以用户友好的方式处理这些更改。输出插件使客户机能够使用更改。

PostgreSQL connector 读取和处理数据库变化主要包含两个部分：

- Logical Decoding 输出插件：根据选择可能需要安装输出插件。运行PostgreSQL服务之前，必须配置`replication slot `来启用你所选择的输出插件，有以下几个输出插件供选择：
  - `decoderbufs` 是基于`Protobuf`的，目前由Debezimu社区维护
  - `wal2json` 是基于`JSON`的，目前由wal2json社区维护
  - `pgoutput`在PostgreSQL 10及以上版本中是标准的Logical Decoding 输出插件。是由PostgreSQL社区维护，由PostgreSQL自己用于Logical Replication。这个插件是内置安装的，所以不需要额外安装。
- Java代码（就是连接Kafka Connect的代码）：负责读取由Logical Decoding 输出插件产生的数据。
  - Logical Decoding 输出插件不支持DDL变更，这意味着Connector不能把DDL变更事件发送给消费者
  - Logical Decoding Replicaiton Slots支持数据库的`primary`服务器。因此如果是PostgreSQL服务的集群，Connector只能在`primary`服务器激活。如果`primary`服务器出现问题，那么connector就会停掉。

需要修改如下配置：

```shell
wal_level=logical
max_wal_senders=1
max_replication_slots=1
```

- `wal_level` 通知数据库使用 logical decoding 读取预写日志
- `max_wal_senders` 通知数据库独立处理WAL变更的独立进程数量
- `max_replication_slots` 通知数据库处理WAL变更流所允许最大replication slots数目

### 3.3.设置数据库权限

需要给PostgreSQL 用户分配replication权限。定义一个PostgreSQL role，**至少**分配`REPLICATION`和`LOGION`两项权限，示例代码如下：

```sql
CREATE ROLE <name> REPLICATION LOGIN;
```

具体操作可以参考一下脚本：

```sql
-- pg新建用户
CREATE USER user WITH PASSWORD 'pwd';

-- 给用户复制流权限
ALTER ROLE user replication;

-- 给用户登录数据库权限
grant CONNECT ON DATABASE test to user;

-- 把当前库public下所有表查询权限赋给用户
GRANT SELECT ON ALL TABLES IN SCHEMA public TO user;
```

### 3.4.Docker-Compose启动CDC

debezium最新版本为1.9

```yaml
version: "3"
services:
  zookeeper:
    image: debezium/zookeeper:1.9
    container_name: zookeeper
    hostname: zookeeper
    environment:
      ZOOKEEPER_SERVER_ID: 1
    ports:
      - 2181:2181
      - 2888:2888
      - 3888:3888

  kafka:
    image: debezium/kafka:1.9
    container_name: kafka
    hostname: kafka
    ports:
      - 9092:9092
    environment:
      BROKER_ID: 1
      ZOOKEEPER_CONNECT: zookeeper:2181
      KAFKA_LISTENERS: LISTENER_INNER://kafka:29092,LISTENER_OUTER://0.0.0.0:9092
      KAFKA_ADVERTISED_LISTENERS: LISTENER_INNER://kafka:29092,LISTENER_OUTER://kafka:9092
      KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: LISTENER_INNER:PLAINTEXT,LISTENER_OUTER:PLAINTEXT
      KAFKA_INTER_BROKER_LISTENER_NAME: LISTENER_INNER
      KAFKA_ALLOW_PLAINTEXT_LISTENER: 'yes'
      KAFKA_AUTO_CREATE_TOPICS_ENABLE: 'true'
    depends_on:
      - zookeeper

  connect:
    image: debezium/connect:1.9
    container_name: connect
    hostname: connect
    ports:
      - 8083:8083
    environment:
      GROUP_ID: 1
      CONFIG_STORAGE_TOPIC: herodotus_connect_configs
      OFFSET_STORAGE_TOPIC: herodotus_connect_offsets
      STATUS_STORAGE_TOPIC: herodotus_connect_statuses
      BOOTSTRAP_SERVERS: kafka:9092
    depends_on:
      - kafka
```

- 进入当前文件夹，docker-compose up -d，启动Debezium

docker-compose也提供了其他一些命令帮助你管理容器的生命周期，如：

```shell
#启动当前部署
docker-comopse start
#停止当前部署
docker-compose stop
#删除当前部署
docker-compose down
#获取当前部署的运行情况
docker-compose ps
```

### 3.5. 创建Connector

把下面的payload POST到`http://<ip addr of debezium>:8083/connectors/`

```c
curl --location --request POST 'http://127.0.0.1:8083/connectors/' \
--header 'Content-Type: application/json' \
--data-raw '{
    "name": "herodotus-connector",
    "config": {
        "connector.class": "io.debezium.connector.postgresql.PostgresConnector",
        "database.hostname": "127.0.0.1",
        "database.port": "5432",
        "database.user": "sync_user",
        "database.password": "Huang123.",
        "database.dbname": "test",
        "database.server.name": "herodotus",
        "slot.name": "herodotus_slot",
        "table.include.list": "public.sys_organization",
        "publication.name": "herodotus_public_connector",
        "publication.autocreate.mode": "filtered",
        "plugin.name": "pgoutput"
    }
}'
```

payload有两个字段，name是connector的名字，config是connector的配置信息，下表为config中的字段的解释：

| 字段名称                    | 说明                                                         |
| --------------------------- | ------------------------------------------------------------ |
| connector.class             | connector的实现类，本文使用的是io.debezium.connector.postgresql.PostgresConnector，因为我们的数据库是PostgreSQL |
| database.hostname           | 数据库服务的IP或域名                                         |
| database.port               | 数据库服务的端口                                             |
| database.user               | 连接数据库的用户                                             |
| database.password           | 连接数据库的密码                                             |
| database.dbname             | 数据库名                                                     |
| database.server.name        | 每个被监控的表在Kafka都会对应一个topic，topic的命名规范是<database.server.name>.<schema>.<table> |
| slot.name                   | PostgreSQL的复制槽(Replication Slot)名称                     |
| table.include.list          | 如果设置了table.include.list，即在该list中的表才会被Debezium监控 |
| plugin.name                 | PostgreSQL服务端安装的解码插件名称，可以是decoderbufs, wal2json, wal2json_rds, wal2json_streaming, wal2json_rds_streaming 和 pgoutput。如果不指定该值，则默认使用decoderbufs。<br/><br/>本例子中使用了pgoutput，因为它是PostgreSQL 10+自带的解码器，而其他解码器都必须在PostgreSQL服务器安装插件。 |
| publication.name            | PostgreSQL端的WAL发布(publication)名称，每个Connector都应该在PostgreSQL有自己对应的publication，如果不指定该参数，那么publication的名称为dbz_publication |
| publication.autocreate.mode | 该值在plugin.name设置为pgoutput才会有效。有以下三个值：<br/><br/>**all_tables** - debezium会检查publication是否存在，如果publication不存在，connector则使用脚本CREATE PUBLICATION <publication_name> FOR ALL TABLES创建publication，即该发布者会监控所有表的变更情况。<br/><br/>**disabled** - connector不会检查有无publication存在，如果publication不存在，则在创建connector会报错.<br/><br/>**filtered** - 与all_tables不同的是，debezium会根据connector的配置中的table.include.list生成生成创建publication的脚本： CREATE PUBLICATION <publication_name> FOR TABLE <tbl1, tbl2, tbl3>。例如，本例子中，“table.include.list"值为"public.sys_organization”，则publication只会监控这个表的变更情况。 |

下面结合本例子中connector的配置信息对几个重点属性进行进一步说明：

> Slot.name 重点说明

按照上例Debezium会在PostgreSQL创建一个名为`herodotus_slot`的复制槽，本例中创建的connector需要通过该复制槽获取数据变更的信息。

可以通过以下sql查看复制槽的信息：

```sql
select * from pg_replication_slots;
```