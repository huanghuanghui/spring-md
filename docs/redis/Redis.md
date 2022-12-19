# Redis

[toc]

## 部署方式

### 单节点

![image-20221023150317875](/Users/hhh/Library/Application Support/typora-user-images/image-20221023150317875.png)

#### 缺点

无法高可用，不支持横向扩展

### 主从部署

主从（master-slave）部署的方式如下图，一个master节点和n个slave节点，其中slave也可以有更多的slave节点，主从之间同步分为全量或增量。在主从架构中，客户端针对**写请求转发至master节点，读请求多走slave节点**。相对于单节点部署，主从架构提高了Redis的性能

- **全量同步**：master节点通过BGSAVE生成对应的RDB文件，然后发送给slave节点，slave节点接收到写入命令后将master发送过来的文件加载并写入
- **增量同步**：即在master-slave关系建立开始，master每执行一次数据变更的命令就会同步至slave节点。

![image-20221023150521838](/Users/hhh/Library/Application Support/typora-user-images/image-20221023150521838.png)





#### 缺点

节点宕机需要人为进行节点上下线，不灵活

### 哨兵

哨兵（Sentinel）部署方式如下图，分别有哨兵集群与Redis的主从集群，哨兵作为操作系统中的一个监控进程，对应监控每一个Redis，如果master服务异常（**ping pong其中节点没有回复且超过了一定时间**），就会多个哨兵之间进行确认，如果超过一半确认服务异常，则对master服务进行下线处理，并且选举出当前一个slave节点来转换成master节点；如果slave节点服务异常，也是经过多个哨兵确认后，进行下线处理；相对于前面的单节点、主从，哨兵的部署方式使redis集群有了高可用的特性，但横向扩展能力依然是强依赖于宿主机。

![image-20221023150658823](/Users/hhh/Library/Application Support/typora-user-images/image-20221023150658823.png)





#### 缺点

- 所有节点数据相同，浪费资源

- 木桶效应，最多数据存储取决于最低配置的服务器节点

## 集群

Redis官方集群（cluster）部署方式如下图，属于“去中心化”的一种方式，多个master节点保存整个集群中的全部数据，而**数据根据key进行crc-16校验算法进行散列，将key散列成对应16383个slot**，而Redis cluster集群中每个master节点负责不同的slot范围。每个master节点下还可以配置多个slave节点，同时也可以在集群中再使用sentinel哨兵提升整个集群的高可用性。

![image-20221023151004991](/Users/hhh/Library/Application Support/typora-user-images/image-20221023151004991.png)





### 缺点

需要大量服务器资源，至少需要3主3从

### 集群搭建方式

与部署一个单机的redis一致，修改redis.conf，启动redis服务，使用redis-cli启动集群，配置集群副本数量

```json
port 7000
cluster-enabled yes
cluster-config-file nodes.conf
cluster-node-timeout 5000
appendonly yes


redis-cli --cluster create 127.0.0.1:7000 127.0.0.1:7001 127.0.0.1:7002 127.0.0.1:7003 127.0.0.1:7004 127.0.0.1:7005 --cluster-replicas 1
```





# Redis分布式锁之红锁

## 问题

分布式锁，当我们请求一个分布式锁的时候，成功了，但是这时候slave还没有复制我们的锁，masterDown了，我们的应用继续请求锁的时候，会从继任了master的原slave上申请，也会成功。

这就会导致，同一个锁被获取了不止一次。

## 办法

Redis中针对此种情况，引入了红锁的概念。

## 原理

用Redis中的多个master实例，来获取锁，只有大多数实例获取到了锁，才算是获取成功。具体的红锁算法分为以下五步：

- 获取当前的时间（单位是毫秒）。
- 使用相同的key和随机值在N个节点上请求锁。这里获取锁的尝试时间要远远小于锁的超时时间，防止某个masterDown了，我们还不断的获取锁，而被阻塞过长的时间。
- 只有在大多数节点上获取到了锁，而且总的获取时间小于锁的超时时间的情况下，认为锁获取成功了。
- 如果锁获取成功了，锁的超时时间就是最初的锁超时时间进去获取锁的总耗时时间。
- 如果锁获取失败了，不管是因为获取成功的节点的数目没有过半，还是因为获取锁的耗时超过了锁的释放时间，都会将已经设置了key的master上的key删除。