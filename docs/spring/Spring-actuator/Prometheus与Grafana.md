# SpringBoot使用Prometheus与Grafana进行监控示例

[toc]

## 新增POM配置

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

## 配置Actuator暴露端点

```yaml
spring:
  application:
    name: monitoring-demo

management:
  endpoints:
    web:
      base-path: /actuator
      exposure:
        include: [ "health","prometheus", "metrics"]
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

## 启动Prometheus与Grafana

使用Docker-Compose启动Prometheus与Grafana

```yml
version: "3"

services:
  prometheus:
    image: prom/prometheus:v2.25.0
    restart: always
    volumes:
      - ./prometheus_conf/prometheus.yml:/etc/prometheus/prometheus.yml
    ports:
      - "9090:9090"

  grafana:
    image: grafana/grafana:7.3.7
    restart: always
    ports:
      - "3000:3000"
    volumes:
      - "./grafana_conf/provisioning:/etc/grafana/provisioning"
      - "./grafana_conf/dashboards:/var/lib/grafana/dashboards"
      - "./grafana_conf/config/grafana.ini:/etc/grafana/grafana.ini"
```

prometheus.yml

```yml
global:
  scrape_interval: 1s     # By default, scrape targets every 15 seconds.

  # Attach these labels to any time series or alerts when communicating with
  # external systems (federation, remote storage, Alertmanager).
  external_labels:
    stack: "apisix"


# 可以配置多个job，需要采集多少服务的，就配置多少服务的，- 代表一个list
scrape_configs:
  - job_name: 'Spring Boot Application input'
    metrics_path: '/actuator/prometheus'
    scrape_interval: 3s
    static_configs:
      - targets: ['192.168.1.3:8080']
        labels:
          application: 'My Spring Boot Application'
```

## 启动后访问

Grafana:http://localhost:3000/

Prometheus:http://localhost:9090/

查看Prometheus配置是否生效

![image-20221128203402949](/Users/hhh/Library/Application Support/typora-user-images/image-20221128203402949.png)



## 配置Grafana

添加数据源

![image-20221128203543072](/Users/hhh/Library/Application Support/typora-user-images/image-20221128203543072.png)

![image-20221128203447758](/Users/hhh/Library/Application Support/typora-user-images/image-20221128203447758.png)

![image-20221128203516001](/Users/hhh/Library/Application Support/typora-user-images/image-20221128203516001.png)



![image-20221129100912859](/Users/hhh/Library/Application Support/typora-user-images/image-20221129100912859.png)

