# Kafka

[toc]

## 1.kafka概述

一个分布式的，基于发布订阅的消息队列，主要用于大数据实时处理。

### 1.1.消息队列异步处理

- 业务接耦
- 削峰
- 可恢复性：一个系统宕机不会影响一整个系统
- 缓冲：解决生产大于消费的问题
- 异步通行：死信队列等

![image-20220416162042796](/Users/hhh/Library/Application Support/typora-user-images/image-20220416162042796.png)

### 1.2.消息队列的模式

- 发布订阅：消息消费后，不会删除数据，但是消息队列不是一个存储系统，过了一定时限后数据会被删除。生产者将数据发送到topic中，同时有多个消费者订阅消费该消息，与点对点的方式不同的是，发送到topic中的数据会被所有的消费者所消费。
  - kafka是消费者主动去Topic中拉取数据的模式，消费者的消费速度由消费者自己决定，缺点是：消费者需要有一个长链接，一直去轮训Topic中是否有消息，没消息的时候，会比较消耗资源。
  - 一种是Topic主动推数据，下游的消费者，处理能力不同，Topic推送能力相同，比如Topic可以推送50M/s的数据，A机器可以消费100M/s，这就造成资源浪费，B机器只能消费10M/s，这时候B就会宕机

![image-20220416162650106](/Users/hhh/Library/Application Support/typora-user-images/image-20220416162650106.png)

- 点对点：消费端主动拉取数据，消息收到后消息删除

![image-20220416162631791](/Users/hhh/Library/Application Support/typora-user-images/image-20220416162631791.png)

### 1.3.Kafka基础架构

- Broker：相当于一台服务器，启了一个kafka进程，使用Broker组成kafka集群，远数据存储在Broker中
- Topic：Broker中有不同的Topic，Topic相当于对数据进行分类
- Partition：Topic下的组件，比如在Broker1与Broker2中各有Topic A，Topic下可以分多个Partition，可以提升某个Topic的负载能力，提高并发度
- Leader/Follower：针对的是Partition的Leader，需要对应一个Follower，Follower是Leader的备份，分布在不同机器上，如果Leader所在的机器宕机，Follower的数据会顶上，提升集群容错能力。
- Consumer Group：一个Partition只能被一个Consumer Group中的一个一个Consumer消费，Kafka中，将一个Consumer Group当作一个Consumer来处理，来提升Consumer的并发能力，所以kafka最优配置为，消费者的数量，等于分区数量
- zookeeper：Kafka集群注册到zookeeper上
- offset：偏移量，Kafka挂掉重启以后，从什么位置开始消费
  - 0.9版本之前，offset存储在zk
  - 0.9版本之后offset存储在Kafka集群本地，consumer 会将offset信息写回集群。是因为消费者本身就与Kafka集群通信，与Kafka链接，消费者是以拉取的方式，从Kafka集群中获取数据，与Kafka集群的交互非常频繁，如果在需要维护与zk的链接，将offset写会zk，就造成资源浪费，而且zk只是一个分布式的存储中心，不合适一直高并发往zk写数据。Kafka会将offset默认存在磁盘，7天（168h）





![image-20220416173312461](/Users/hhh/Library/Application Support/typora-user-images/image-20220416173312461.png)



### 1.4.Kafka使用

#### 1.4.0.Kafka集群

启动一个Kafka集群非常简单，只需修改broker_id属性，指定当前Broker在集群中的ID，必须是正整数，链接的zookeeper地址，然后将多台的Kafka启动就完成了

#### 1.4.1.Topic

对于topic的使用，具体请参照Kafka-topics --help

- kafka-topics --list --bootstrap-server localhost:9092：查看topic
- kafka-topics --create --bootstrap-server localhost:9092 --replication-factor 1 --partitions 1 --topic tes：创建tes topic，-- zookeeper-factor API已经过期，要使用--bootstrap-server，创建完成以后，Kafka会将数据存储到**log.dirs**文件夹中，配置可以在service.properties中进行配置
- kafka-topics --describe --topic second --bootstrap-server localhost:9092：查看topic相关信息
- --replication-factor：副本数目，默认为集群Broker数量，若自己设置不能超过Broker数量，副本数量指的是，Follower的数量，Kafka宕机后，用来恢复

#### 1.4.2.生产者

- kafka-console-producer --topic frist --broker-list localhost:9092

#### 消费者

- kafka-console-consumer --topic frist --bootstrap-server  localhost:9092

#### 1.4.3.Offset

Offset默认会存到我们service.properties配置的log.dirs中的地址，默认有50个partition，一个副本

## 2.Kafka架构深入

Kafka是以topic作为分类的，生产者生产消息，消费者消费消息，都是基于topic的。topic是逻辑上的概念，partition是物理上的概念。每个partition对应一个log文件，该log文件就是存储的是producer产生的数据，producer 产生的数据会不断被追加到log文件末端，且每条数据都有其自己的offset，以便宕机恢复时，从上次消费的位置继续消费。

### 2.1.Kafka工作流程

![image-20220416204304239](/Users/hhh/Library/Application Support/typora-user-images/image-20220416204304239.png)

### 2.2.Kafka文件存储

Kafka默认会存168h，可以在service.properties文件中进行配置，过了时间会被自动删除。

生产者会不断生产数据，不断往log文件中进行追加，log文件默认文件最大为1G，超过1G会新建出新的分段数据，为了防止文件过大，导致读写效率低下，Kafka使用了分片与索引的机制，将每个partition分割为多个segment，每个segment对应一个log文件与一个index文件，该文件位于topic+partiotonId的文件夹下。

![image-20220416205407143](/Users/hhh/Library/Application Support/typora-user-images/image-20220416205407143.png)



index与log以当前segment的第一条数据的offset进行命名



![image-20220416210017771](/Users/hhh/Library/Application Support/typora-user-images/image-20220416210017771.png)

### 2.3.生产者

发送流程：

- RecordAccumulator：双端队列
- sender线程最多缓存5个线程

![image-20220417105538817](/Users/hhh/Library/Application Support/typora-user-images/image-20220417105538817.png)

#### 2.3.1.生产者分区策略

##### 2.3.1.1.分区原因

- 合理使用存储资源，每个partition在一个broker上存储，可以将海量的数据，按照partition切割成一块块存储在多个broker上，合理控制分区任务，实现负载均衡效果
- 提高并发：生产者可以以partition为单位发送数据，消费者以分区为单位消费数据

![image-20220417110739428](/Users/hhh/Library/Application Support/typora-user-images/image-20220417110739428.png)

##### 2.3.1.1.分区分配策略

我们需要将producer发送的数据，封装成一个Producer Record对象，在DefaultPartitioner类中有进行标注

- 例如有一个需求，我们需要将一个订单表单的数据，指定发送到同一个分区，那么只需将订单表的表名传入ProducerRecord，作为key，key相同，数据就会进入一个分区
- **可以重写DefaultPartitioner，使用自定义分区器，可以用来过滤脏数据或者包含指定key的数据**

![image-20220417111245956](/Users/hhh/Library/Application Support/typora-user-images/image-20220417111245956.png)



```java
public class MyPartitioner implements Partitioner {
    @Override
    public int partition(String topic, Object key, byte[] keyBytes, Object value, byte[] valueBytes, Cluster cluster) {
        //编写自定义逻辑
        return 0;
    }

    @Override
    public void close() {

    }

    @Override
    public void configure(Map<String, ?> configs) {

    }
}
//使用自定义分区
properties.put(ProducerConfig.PARTITIONER_CLASS_CONFIG, MyPartitioner.class.getName());
```

**生产提高吞吐量**

- 修改batch.size：默认修改为32k，批次大小，数据到这么大，Kafka就会发送数据
- 修改linger.ms：默认修改为5-100ms，等待时间，到这个等待时间，kafka就会发送数据

![image-20220417112943242](/Users/hhh/Library/Application Support/typora-user-images/image-20220417112943242.png)

##### 2.3.1.2.数据可靠性

为保证producer发送的数据，能可靠的发送到对应的topic中，topic中的partition在收到producer发送的数据后，都需要向producer发送ack信息（acknowledge），如果producer收到ack信息，就进入下一条数据的发送，否则会重新发送

![image-20220416222741030](/Users/hhh/Library/Application Support/typora-user-images/image-20220416222741030.png)



| 方案                     | 优点                                             | 缺点                                                         |
| ------------------------ | ------------------------------------------------ | ------------------------------------------------------------ |
| 半数以上follower同步完成 | 延迟低                                           | 选举新的leader时，容忍n台节点故障，需要2n+1个副本/大量数据冗余 |
| 全部follower同步完成     | 选举新的leader时，容忍n台节点故障，需要n+1个副本 | 延迟高                                                       |

- Kafka选择了第二种方案，第一种方案需要2n+1的副本数量，而第二种方案只需要n+1个副本数量，Kafka的每个分区中，都有大量的数据，第一种方案会造成大量的数据冗余
- 虽然第二种方案延迟较高，但网络延迟对Kafka影响较小

##### 2.3.1.3.ISR

ISR的出现，是为了解决上述问题中，全部follower同步完成，网络延迟会较高，Kafka针对leader与follower之间的数据同步做了优化。Leader维护了一个动态的ISR列表（in-sync replica set），比如一个partition有9个follower，那么我只需将其中的5个动态维护到isr中，当leader挂掉以后，我只需优先从isr列表中选择一个作为leader，这样除非5个全挂了，我再去其他的follower中选取leader。replica.lag.time.max.ms配置多久未向leader同步数据的follower提出isr

##### 2.3.1.3.ACK应答机制

对于一些不太重要的数据，例如日志信息，可以容忍丢失，没必要等待isr的follower全部接收。

acks参数配置：

- 0：producer不等待broker的ack，就直接返回，不做重试，这时候如果broker故障，就有可能丢失数据
- 1:producer等待broker的ack，Leader partition的数据落盘后返回ack，不等待follower的写入，follower同步成功之前故障，或者Leader挂了，就有可能丢失数据

![image-20220417000103741](/Users/hhh/Library/Application Support/typora-user-images/image-20220417000103741.png)

- -1:partition与isr中的Leader与ISR中的所有follower全部落盘成功后在返回ack，如果ISR只有一个Leader，也有可能丢数据，-1更多的是数据重复问题，producer没接收到ack，producer将数据多次推送，leader又进行了重新选举，数据就重复了

![image-20220417000114763](/Users/hhh/Library/Application Support/typora-user-images/image-20220417000114763.png)



##### 2.3.1.4.消费/存储一致性问题

- LEO：每个副本最大的offset
- HW：最高水位，消费者能见到的最大的offset，ISR队列最小的LEO

**注意：LEO与HW只能保证数据一致性问题，不能保证数据不丢失/不重复，数据的丢失与重复是ACK配置决定的**

![image-20220417000945147](/Users/hhh/Library/Application Support/typora-user-images/image-20220417000945147.png)



- Follower故障：会被踢出ISR，等到follower恢复后，会读取本地磁盘上次的HW，将log文件高于HW部分截取，从HW向leader进行同步数据，等待该**Follower的LEO大于等于该partition的HW，**即follower追上leader后，重新加入ISR
- Leader故障：从ISR中重新选择一个Leader，为保证多个副本之间数据一致性，各个follower会**将高于HW部分的数据截取**，然后从leader重新同步数据。



#### 2.3.2.Exactly Once语义

##### 2.3.2.1.Act Least Once

- 将服务器的ack级别设置为-1，可以保证Producer与Server之间的数据不丢失，为Act Least Once语义。
- Act Least Once只能保证数据不丢失，不能保证数据不重复

##### 2.3.2.2.Act Most Once

- 将服务器的ack级别设置为0，可以保证Producer每条消息只会被发送一次，为Act Least Once语义
- Act Most Once只能保证数据不重复，不能保证数据不丢失 

##### 2.3.2.3.Exactly Once

对于非常重要的信息，比如交易数据，既不能丢失数据，又不能重复数据，这时候就是Exactly Once的语义。Kafka为了解决这个问题，引入了幂等性的概念，Producer不论向server发送多少次数据，Server都只会持久化一条。（在Kafka的服务器中，就将其幂等），**<ProducerID,Partition，SEQ Number>进行去重，幂等性只能解决单次会话，单个Partition的数据幂等问题，如果Producer挂掉了，Kafka集群幂等性还是无法保证**

| 类型           | 语义                                                  | 不重复 | 不丢失 |
| -------------- | ----------------------------------------------------- | ------ | ------ |
| Act Least Once | 保证Producer与Server之间的数据不丢失                  | ❌      | ✅      |
| Act Most Once  | 保证Producer每条消息只会被发送一次                    | ✅      | ❌      |
| Exactly Once   | 既不能丢失数据，又不能重复数据（Act Least Once+幂等） | ✅      | ✅      |

要启用幂等性，只需**将Producer中的enable.idompotence设置为true**就行了，ACK模式默认会被设置为-1。

#### 2.3.3.幂等性与生产者事务

##### 2.3.3.1.幂等性

- 开启enable.idempotence=true，默认是开发的

![image-20220417130420046](/Users/hhh/Library/Application Support/typora-user-images/image-20220417130420046.png)

##### 2.3.3.2.事务原理

Kafka提供了5个事务API，必须指定事务ID



![image-20220417130915427](/Users/hhh/Library/Application Support/typora-user-images/image-20220417130915427.png)



#### 2.3.4.数据有序

由于多分区的原因，所以无法保证数据有序，若想数据有序可以

- 使用单分区，单分区内数据有序



![image-20220417131559413](/Users/hhh/Library/Application Support/typora-user-images/image-20220417131559413.png)

#### 2.3.5.保证数据不乱序

![image-20220417132018231](/Users/hhh/Library/Application Support/typora-user-images/image-20220417132018231.png)



## 3.Kafka Broker

### 3.1.zk中存储的Kafka信息

![image-20220417132604990](/Users/hhh/Library/Application Support/typora-user-images/image-20220417132604990.png)

### 3.2.Kafka Broker工作流程

![image-20220417133034521](/Users/hhh/Library/Application Support/typora-user-images/image-20220417133034521.png)

### 3.3.Kafka 节点服役与退役

#### 3.3.1.Kafka 节点服役

新机器上安装jdk，下载Kafka包，修改broker ID，修改zk地址，直接启动就行了，Kafka的broker就会被加入到集群中。这种新加入的服役机器，原先的topic不会被分到加入的节点broker中，

##### 3.3.1.1.Kafka 节点服役/负载均衡

新建一个json，

```json
{
  "topics":["topic":"frist"],
  "version":1
}
```

需要根据这个json，生成一个负载均衡计划：

- kafka-reassign-partitions --bootstrap-server localhost:9092 --topic-to-move-json-file xxx.json --broker-list "0,1,2,3" --generate



#### 3.3.2.Kafka 节点退役

新建一个json，

```json
{
  "topics":["topic":"frist"],
  "version":1
}
```

需要根据这个json，生成一个负载均衡计划，--broker-list需要缩减需要退役的节点信息 ：

- kafka-reassign-partitions --bootstrap-server localhost:9092 --topic-to-move-json-file xxx.json --broker-list "0,1,2" --generate

### 3.4.Kafka副本

- 提升数据可靠性
- Kafka默认副本一个，一半生产配置2个，过多的副本会导致浪费磁盘，也会增加网络压力
- Kafka中的副本分为Leader与Follower，Kafka只会往Leader上发送数据，Leader找follower去同步数据
- Kafka副本统称为AR，AR=ISR+OSR，OSR为延时过多的副本，ISR为正常与Leader同步的副本

### 3.4.Kafka选举规则

![image-20220417135238229](/Users/hhh/Library/Application Support/typora-user-images/image-20220417135238229.png)



### 3.4.Kafka Leader与Follower故障处理

#### 3.4.1.Follower故障

![image-20220417135630586](/Users/hhh/Library/Application Support/typora-user-images/image-20220417135630586.png)

#### 3.4.2.Leader故障

![image-20220417135856604](/Users/hhh/Library/Application Support/typora-user-images/image-20220417135856604.png)

### 3.5.Kafka分区副本分配

- leader与follower的分配，会互相错位，需要尽量保证负载与数据可靠性

![image-20220417140308827](/Users/hhh/Library/Application Support/typora-user-images/image-20220417140308827.png)

#### 3.5.1.Kafka手动分配分区副本

![image-20220417140536796](/Users/hhh/Library/Application Support/typora-user-images/image-20220417140536796.png)

#### 3.5.2.Leader Partition的负载均衡

![image-20220417140939865](/Users/hhh/Library/Application Support/typora-user-images/image-20220417140939865.png)

#### 3.5.3.增加副本因子

在Kafka集群中，不能通过命令直接修改副本数量，需要手动修改副本数量

![image-20220417141112533](/Users/hhh/Library/Application Support/typora-user-images/image-20220417141112533.png)

### 3.6.Kafka怎么做到高速读写

- 分布式集群，分区技术，并行度高
- 读取数据有索引
- 磁盘顺序写数据
- 页缓存/零拷贝

## 4.Kafka的消费者

### 4.1.Kafka的消费方式

- Kafka是消费者主动拉取数据

![image-20220417141807656](/Users/hhh/Library/Application Support/typora-user-images/image-20220417141807656.png)



### 4.2.Kafka的消费流程

![image-20220417142201018](/Users/hhh/Library/Application Support/typora-user-images/image-20220417142201018.png)

### 4.3.Kafka的消费者组

![image-20220417171229330](/Users/hhh/Library/Application Support/typora-user-images/image-20220417171229330.png)



![image-20220417171332351](/Users/hhh/Library/Application Support/typora-user-images/image-20220417171332351.png)

#### 4.3.1.Kafka的消费者组初始化

**有消费者挂了，或者处理任务时间过长，会触发再平衡，会影响Kafka的性能**

![image-20220417171744990](/Users/hhh/Library/Application Support/typora-user-images/image-20220417171744990.png)

#### 4.3.2.Kafka的消费者详细消费流程

![image-20220417172541480](/Users/hhh/Library/Application Support/typora-user-images/image-20220417172541480.png)



### 4.4.Kafka独立消费者案例（订阅Topic）

- 在消费者API中，必须配置消费者组ID，命令行会自动帮我们配置消费者组ID

```java
/**
 * 消费者必须定义消费者ID
 * 开了多个消费者组，多个消费者组都会收到消息
 * 本案例接收订阅topic案例
 */
public class CustomerConsumer {
    public static void main(String[] args) {
        Properties properties = new Properties();
        properties.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG,"localhost:9092");
        properties.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
        properties.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
        properties.put(ConsumerConfig.GROUP_ID_CONFIG, "SECOND_GROUP_ID");
        KafkaConsumer<String,String> kafkaConsumer = new KafkaConsumer(properties);
        List<String> topics = new ArrayList<>();
        topics.add("second");
        //订阅分区
        kafkaConsumer.subscribe(topics);
        while (true){
            ConsumerRecords<String, String> consumerRecords = kafkaConsumer.poll(Duration.ofSeconds(1));
            for (ConsumerRecord<String, String> consumerRecord : consumerRecords) {
                System.out.println("接收到数据-"+consumerRecord);
            }
        }
    }
}
```

### 4.5.Kafka独立消费者案例（订阅分区）

![image-20220417174139278](/Users/hhh/Library/Application Support/typora-user-images/image-20220417174139278.png)



```java
/**
 * 消费者必须定义消费者ID
 * 开了多个消费者组，多个消费者组都会收到消息
 * 本案例接收订阅topic特定partition数据
 */
public class CustomerConsumerPartition {
    public static void main(String[] args) {
        Properties properties = new Properties();
        properties.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG,"localhost:9092");
        properties.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
        properties.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
        properties.put(ConsumerConfig.GROUP_ID_CONFIG, "SECOND_GROUP_ID");
        KafkaConsumer<String,String> kafkaConsumer = new KafkaConsumer(properties);
        //订阅具体分区
        Collection<TopicPartition> partitions = new ArrayList<>();
        partitions.add(new TopicPartition("second",0));
        kafkaConsumer.assign(partitions);
        while (true){
            ConsumerRecords<String, String> consumerRecords = kafkaConsumer.poll(Duration.ofSeconds(1));
            for (ConsumerRecord<String, String> consumerRecord : consumerRecords) {
                System.out.println("接收到数据-"+consumerRecord);
            }
        }
    }
}
```



### 4.6.Kafka独立消费者组案例

- 同一个topic的分区数据，只能被同一个消费者消费
- 下图是分区数量与consumer数量相同时
- 分区数量与consumer数量不同时，Kafka会进行分配，一个consumer消费多个partition值

![image-20220417175001954](/Users/hhh/Library/Application Support/typora-user-images/image-20220417175001954.png)





### 4.6.Kafka分区分配再平衡

- 所有的分区分配在平衡，**Range模式**是在一个consumer退出消费者组的时候，会将退出原消费者的消费的分区，都给到第一个消费者进行消费，然后在进行分区的平衡在分配

![image-20220417214825826](/Users/hhh/Library/Application Support/typora-user-images/image-20220417214825826.png)

#### 4.6.1.Kafka分区分配再平衡-Range模式

- 例如前面案例，有5个分区，3个消费者，那么0，1消费者就会多分配一个分区消费 
- 这个时候如果一个consumer挂了，那么等到coordinator与消费这通信，45秒后没有上报consumer的健康状态，就会**被认为consumer已经推出消费者组，会触发在平衡，再分配会将所有的数据一次性全部给到一个consumer，造成数据倾斜**，等到consumer的数据消费完成后，会重新分配

![image-20220417215200830](/Users/hhh/Library/Application Support/typora-user-images/image-20220417215200830.png)

#### 4.6.2.Kafka分区分配再平衡-Round Robin模式

- 通过设置`KafkaProducer的Properties的ProducerConfig.PARTITIONER_CLASS_CONFIG`，可以修改分区分配策略
- 当有消费者挂掉，也是以轮询的方式进行平衡再分配

![image-20220417220000138](/Users/hhh/Library/Application Support/typora-user-images/image-20220417220000138.png)



#### 4.6.3.Kafka分区分配再平衡- Sticky模式

- 往consumer上分配消费分区的时候是随机分配的

- 考虑上一次的分配结果，尽量均衡的放置的消费者上，将退出的消费者的数据，打散放置到consumer上
- 尽量保持原有的分区不变化

## 5.Kafka offset

### 5.1.offset默认存储位置  

- 我们使用较新的Kafka版本，是存储在_consumer_offsets的topic中，默认系统是不让看的，我们需要将配置文件`consumer.perperties`的`excute.internal.topics=false`添加，改完只需要分发配置，无需重启系统

![image-20220417221400155](/Users/hhh/Library/Application Support/typora-user-images/image-20220417221400155.png)



### 5.2.offset自动提交offset

- 修改自动offset的参数：

```java
        //自动提交offset，默认true
        properties.put(ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG, true);
        //配置自动提交毫秒数
        properties.put(ConsumerConfig.AUTO_COMMIT_INTERVAL_MS_CONFIG, 1);
```



![image-20220417222307167](/Users/hhh/Library/Application Support/typora-user-images/image-20220417222307167.png)





### 5.3.offset手动提交offset

- 同步提交

```java
        //自动提交offset，默认true
        properties.put(ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG, false);
				//发送完数据，需手动同步提交offset
				kafkaConsumer.commitSync();
```

- 异步提交，在生产中使用异步发送offset的方式比较多，追求效率

```java
				//自动提交offset，默认true
        properties.put(ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG, false);
				//发送完数据，需手动异步提交offset
				kafkaConsumer.commitAsync();
```



![image-20220417222949985](/Users/hhh/Library/Application Support/typora-user-images/image-20220417222949985.png)



### 5.3.指定offset消费

- earliest：从最早开始消费，-- from- beginning 
- latest：（默认值）自动将偏移量设置为最新偏移量
- none：未找到消费组的先向前偏移量

```java
        Set<TopicPartition> assignment = kafkaConsumer.assignment();
        //保证分区已经初始化完成
        while (assignment.size()==0){
            kafkaConsumer.poll(Duration.ofSeconds(1));
            kafkaConsumer.assignment();
        }
        //指定从offset开始消费，需要保证分区分配方案已经分配完毕
        for (TopicPartition topicPartition : kafkaConsumer.assignment()) {
            //从100的offset开始消费
            kafkaConsumer.seek(topicPartition,100);
        }
```

### 5.3.按照指定时间进行offset消费

```java
        //保证分区已经初始化完成
        while (assignment.size()==0){
            kafkaConsumer.poll(Duration.ofSeconds(1));
            kafkaConsumer.assignment();
        }
        //将时间转换成指定offset
        HashMap<TopicPartition, Long> topicPartitionLongHashMap = new HashMap<>();
        for (TopicPartition topicPartition : kafkaConsumer.assignment()) {
            //第二个参数为时间，表示从一天前的这个时间点后的offset进行消费
            topicPartitionLongHashMap.put(topicPartition,System.currentTimeMillis()-1*24*3600*1000);
        }
        //将时间转为offset
        Map<TopicPartition, OffsetAndTimestamp> topicPartitionOffsetAndTimestampMap = kafkaConsumer.offsetsForTimes(topicPartitionLongHashMap);
        //指定从offset开始消费，需要保证分区分配方案已经分配完毕
        for (TopicPartition topicPartition : kafkaConsumer.assignment()) {
            //获取offset
            OffsetAndTimestamp offsetAndTimestamp = topicPartitionOffsetAndTimestampMap.get(topicPartition);
            //从指定时间的offset开始消费
            kafkaConsumer.seek(topicPartition,offsetAndTimestamp.offset());
        }
```



### 5.4.消费者事务

- 重复消费：自动提交offset引起的，自动提交offset5s一次，如果消费一半，consumer挂了，就有可能导致数据消费了一半，恢复后下次继续从offset处进行消费

- 漏消费：手动offset引起

![image-20220417225717074](/Users/hhh/Library/Application Support/typora-user-images/image-20220417225717074.png)

- 对于生产环境，上述的重复消费与漏消费都是不可接受的，必须做到精确一次性消费，需要消费者使用事务方式解决

![image-20220417225916785](/Users/hhh/Library/Application Support/typora-user-images/image-20220417225916785.png)

### 5.5.消费者数据积压（消费者如何提交吞吐量）

对于增加吞吐量，分为生产者端，与消费者短

- 生产者：批次大小/缓冲区大小/超时时间/压缩算法
- 消费者：分区数，批次拉取数量

![image-20220417230220912](/Users/hhh/Library/Application Support/typora-user-images/image-20220417230220912.png)





















