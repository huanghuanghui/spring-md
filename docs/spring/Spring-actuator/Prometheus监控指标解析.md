# Prometheus监控指标解析

[toc]

## 源码解析

### 从/actuator/prometheus接口追踪代码

从上文Actuator源码解析中，可以根据代码`AbstractWebMvcEndpointHandlerMapping#handle`追踪到`PrometheusScrapeEndpoint`类

![image-20221129144841553](/Users/hhh/Library/Application Support/typora-user-images/image-20221129144841553.png)

查看scrape()方法代码中，所有的采集信息都是由this.collectorRegistry.metricFamilySamples();中获取，可以看到，注册了很多的指标Key

![image-20221129150452756](/Users/hhh/Library/Application Support/typora-user-images/image-20221129150452756.png)

### 查看指标注册代码

### MeterBinder类图

MeterBinder相关JVM指标信息

![image-20221129173335545](/Users/hhh/Library/Application Support/typora-user-images/image-20221129173335545.png)



## 总结

prometheus采集指标的代码，其实是通过java management提供的代码采集的

![image-20221129173724537](/Users/hhh/Library/Application Support/typora-user-images/image-20221129173724537.png)

例如我们需要采集类加载信息的指标可以参考代码`ClassLoaderMetrics`，使用ClassLoadingMXBean去获取

![image-20221129173819272](/Users/hhh/Library/Application Support/typora-user-images/image-20221129173819272.png)