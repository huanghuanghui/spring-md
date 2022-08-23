# CDC数据同步方案

[toc]

官网：https://debezium.io/documentation/reference/1.9/tutorial.html#starting-kafka-connect

https://github.com/debezium/debezium-examples/tree/main/tutorial

## 需要服务

- zookeeper
- kafka
- Kafka Connect
- Debezium

## 本地安装步骤

### zookeeper

```bash
docker run -it --rm --name zookeeper -p 2181:2181 -p 2888:2888 -p 3888:3888 quay.io/debezium/zookeeper:1.9
```

### kafka

```bash
docker run -it --rm --name kafka -p 9092:9092 --link zookeeper:zookeeper quay.io/debezium/kafka:1.9
```

### mysql

- USER=mysqluser 
- PASSWORD=mysqlpw

```bash
docker run -it --rm --name mysql -p 3306:3306 -e MYSQL_ROOT_PASSWORD=debezium -e MYSQL_USER=mysqluser -e MYSQL_PASSWORD=mysqlpw quay.io/debezium/example-mysql:1.9
```

### Kafka connect

```bash
docker run -it --rm --name connect -p 8083:8083 -e GROUP_ID=1 -e CONFIG_STORAGE_TOPIC=my_connect_configs -e OFFSET_STORAGE_TOPIC=my_connect_offsets -e STATUS_STORAGE_TOPIC=my_connect_statuses --link zookeeper:zookeeper --link kafka:kafka --link mysql:mysql quay.io/debezium/connect:1.9
```

#### 检查connect是否成功

```c
curl -H "Accept:application/json" localhost:8083/
```

#### 检查Kafka Connect 注册的连接器列表

```c
curl -H "Accept:application/json" localhost:8083/connectors/
```

### 注册 Debezium MySQL 连接器

```json
curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8083/connectors/ -d '{
    "name": "inventory-connector",
    "config": {
        "connector.class": "io.debezium.connector.mysql.MySqlConnector",
        "tasks.max": "1",
        "database.hostname": "mysql",
        "database.port": "3306",
        "database.user": "debezium",
        "database.password": "dbz",
        "database.server.id": "184054",
        "database.server.name": "dbserver1",
        "database.include.list": "inventory",
        "database.history.kafka.bootstrap.servers": "kafka:9092",
        "database.history.kafka.topic": "dbhistory.inventory"
    }
}'
```

### 获取连接器的任务

```json
curl -i -X GET -H "Accept:application/json" localhost:8083/connectors/inventory-connector
```





```
docker-compose -f docker-compose-mysql.yaml exec kafka /kafka/bin/kafka-console-consumer.sh \
    --bootstrap-server kafka:9092 \
    --from-beginning \
    --property print.key=true \
    --topic dbserver1.inventory.customers
```