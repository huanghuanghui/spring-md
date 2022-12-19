# Actuator源码解读

[toc]

## 搭建简单的Prometheus监控SpringBoot项目

```yaml
spring:
  application:
    name: monitoring-demo

management:
  endpoints:
    web:
      base-path: /actuator
      exposure:
        include: [ "health","prometheus", "metrics","mappings" ]
  endpoint:
    health:
      show-details: always
    metrics:
      enabled: true
    prometheus:
      enabled: true
server:
  port: 8080
```

```xml
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>
        <dependency>
            <groupId>io.micrometer</groupId>
            <artifactId>micrometer-registry-prometheus</artifactId>
            <scope>runtime</scope>
        </dependency>
```

## 源码解析

### AutoConfiguration

找到actuator自动配置的类

![image-20221129110108819](/Users/hhh/Library/Application Support/typora-user-images/image-20221129110108819.png)

### ServletEndpointManagementContextConfiguration

![image-20221129110629716](/Users/hhh/Library/Application Support/typora-user-images/image-20221129110629716.png)



- 其中1为application.yml中配置的属性，Spring boot actuator会根据其做端口暴露
- 2注册了获取端点的Bean，进入类，点击其构造方法，可以找到注册`ServletEndpointDiscoverer`的bean，看到具体做了什么操作

![image-20221129111346280](/Users/hhh/Library/Application Support/typora-user-images/image-20221129111346280.png)

debug下这两个参数

![image-20221129113656718](/Users/hhh/Library/Application Support/typora-user-images/image-20221129113656718.png)

在处理参数时候，使用`ObjectProvider<T>` 会进入如下代码：org.springframework.beans.factory.support.DefaultListableBeanFactory#resolveDependency，判断类型是ObjectProvider，就直接返回了，交给你自己去处理，然后框架作者提供@FunctionalInterface ，比如PathMapper，我们自己去实现，他加入到参数集合中

![image-20221129113628377](/Users/hhh/Library/Application Support/typora-user-images/image-20221129113628377.png)

在orderedStream代码中把PathMapper对应的实现类的Bean注册到Spring里，去给Spring收集

![image-20221129115056613](/Users/hhh/Library/Application Support/typora-user-images/image-20221129115056613.png)

![image-20221129115101397](/Users/hhh/Library/Application Support/typora-user-images/image-20221129115101397.png)



下端点在org.springframework.boot.actuate.endpoint.annotation.EndpointDiscoverer#getEndpoints，的判断中，进这个判断的就是不同的EndpointsSupplier，分为：

- ServletEndpointsSupplier

- WebEndpointsSupplier
- JmxEndpointsSupplier

其中Supplier是以Discoverer进行重载的，例如JmxEndpointsSupplier与JmxEndpointDiscoverer

![image-20221129140338563](/Users/hhh/Library/Application Support/typora-user-images/image-20221129140338563.png)

获取所有打了@Endpoint注解的端点

![image-20221129135054777](/Users/hhh/Library/Application Support/typora-user-images/image-20221129135054777.png)

![image-20221129135040974](/Users/hhh/Library/Application Support/typora-user-images/image-20221129135040974.png)

注册Prometheus Endpoint

org.springframework.boot.actuate.autoconfigure.metrics.export.prometheus.PrometheusMetricsExportAutoConfiguration

![image-20221129135013493](/Users/hhh/Library/Application Support/typora-user-images/image-20221129135013493.png)

### Endpoint

例如配置文件中开了这几个端点

```xml
      exposure:
        include: [ "health","prometheus", "metrics","mappings" ]
```

那么spring actuator会加载如下端点

- HealthEndpoint

- MetricsEndpoint
- MappingsEndpoint
- PrometheusScrapeEndpoint