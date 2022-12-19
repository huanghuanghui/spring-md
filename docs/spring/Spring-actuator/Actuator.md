# Actuator

[toc]

## 简介

​		Endpoints 是 Actuator 的核心部分，它用来监视应用程序及交互，spring-boot-actuator中已经内置了非常多的Endpoints（health、info、beans、httptrace、shutdown等等），同时也允许我们扩展自己的端点。

​		Endpoints 分成两类：原生端点和用户自定义端点；自定义端点主要是指扩展性，用户可以根据自己的实际应用，定义一些比较关心的指标，在运行期进行监控。原生端点是在应用程序里提供的众多 restful api 接口，通过它们可以监控应用程序运行时的内部状况。原生端点又可以分成三类：

- 应用配置类：可以查看应用在运行期间的静态信息：例如自动配置信息、加载的spring bean信息、yml文件配置信息、环境信息、请求映射信息；
- 度量指标类：主要是运行期间的动态信息，例如堆栈、请求连、一些健康指标、metrics信息等；
- 操作控制类：主要是指shutdown，用户可以发送一个请求将应用的监控功能关闭。

## 使用

### 引入相关依赖

```xml
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>
```

### 配置

/actuator/health 和 /actuator/info 是默认开放的，其他的需要自己去配置，需要在配置文件中加入如下配置，actuator分为是否默认启用与是否默认公开

- 公开所有端口

```properties
management.endpoints.web.exposure.include=*
```

- 启用所有端口

```properties
management.endpoints.enabled-by-default=true
```



## Actuator 默认提供接口

访问http://localhost:8080/actuator可以获取到所有可以访问的端点信息。

| ID             | 描述                                                       | 默认启用 | 默认公开 |
| -------------- | ---------------------------------------------------------- | -------- | -------- |
| auditevents    | 公开当前应用程序的审计事件信息                             | Yes      | No       |
| beans          | 显示应用程序中所有Spring bean的完整列表                    | Yes      | No       |
| conditions     | 显示在配置和自动配置类上评估的条件以及它们是否匹配的原因   | Yes      | No       |
| configprops    | 显示所有@ConfigurationProperties对照的列表                 | Yes      | No       |
| env            | 从Spring的ConfigurableEnvironment中公开属性                | Yes      | No       |
| flyway         | 显示已应用的任何Flyway数据库迁移                           | Yes      | Yes      |
| health         | 显示应用程序健康信息                                       | Yes      | No       |
| httptrace      | 显示HTTP跟踪信息（默认情况下，最后100个HTTP请求-响应交互） | Yes      | No       |
| info           | 显示任意应用程序信息                                       | Yes      | Yes      |
| loggers        | 显示和修改应用程序中记录器的配置                           | Yes      | No       |
| liquibase      | 显示已应用的任何Liquibase数据库迁移                        | Yes      | No       |
| metrics        | 显示当前应用程序的“指标”信息                               | Yes      | No       |
| mappings       | 显示所有@RequestMapping路径对照的列表                      | Yes      | No       |
| scheduledtasks | 显示应用程序中调度的任务                                   | Yes      | No       |
| sessions       | 允许从Spring Session支持的会话存储中检索和删除用户会话     | No       | No       |
| shutdown       | 让应用程序优雅地关闭                                       | Yes      | No       |
| threaddump     | 执行线程转储                                               | Yes      | No       |

如果你的应用程序是一个web应用程序（Spring MVC、Spring WebFlux或Jersey），你可以使用以下附加端点：

| **ID**     | **描述**                                                     | **默认启用** | **默认公开** |
| ---------- | ------------------------------------------------------------ | ------------ | ------------ |
| heapdump   | 返回一个GZip压缩的`hprof`堆转储文件                          | Yes          | No           |
| jolokia    | 在HTTP上公开JMX bean（当Jolokia在类路径上时，WebFlux不可用） | Yes          | No           |
| logfile    | 返回日志文件的内容，支持使用HTTP `Range` header来检索日志文件内容的一部分 | Yes          | No           |
| prometheus | 公开指标，该格式可以被Prometheus服务器采集                   | Yes          | No           |

## Actuator源码

如果想阅读Actuator源码，那么可以访问/mapping端点，获取到所有暴露的端点信息与其控制类的信息

![image-20220823154551551](/Users/hhh/Library/Application Support/typora-user-images/image-20220823154551551.png)

在对应类`AbstractWebMvcEndpointHandlerMapping`打端点，就可以进行对应的源码查看

![image-20220823154628246](/Users/hhh/Library/Application Support/typora-user-images/image-20220823154628246.png)

## 集成prometheus

### 添加依赖

```xml
        <dependency>
            <groupId>io.micrometer</groupId>
            <artifactId>micrometer-registry-prometheus</artifactId>
        </dependency>
```

启动项目，访问http://localhost:8080/actuator查看是否有对应端点

![image-20220823155925663](/Users/hhh/Library/Application Support/typora-user-images/image-20220823155925663.png)

访问即可获取可被prometheus采集的数据

## 自定义Actuator

```yaml
management:
  endpoints:
    web:
      base-path: /actuator
      exposure:
        include: ["myendpoint"]
```



```java
@Endpoint(id="myendpoint")
@Component
public class MyCustomEndpoints {
	@ReadOperation
	@Bean
	public String hi() {
		return "Hi from custom endpoint";
	}
}
```

