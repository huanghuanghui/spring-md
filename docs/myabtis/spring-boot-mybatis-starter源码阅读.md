# spring-boot-mybatis-starter源码阅读

[toc]

## 官网

https://mybatis.org/spring-boot-starter/mybatis-spring-boot-autoconfigure/index.html

## 初入源码

阅读starter源码，先从起spring.factories文件入手阅读，引入了2个AutoConfiguration，看其源码只要看这2个类中的代码就行

- MybatisLanguageDriverAutoConfiguration
- MybatisAutoConfiguration

![image-20221214104154830](/Users/hhh/Library/Application Support/typora-user-images/image-20221214104154830.png)

## MybatisAutoConfiguration

![image-20221215114642708](/Users/hhh/Library/Application Support/typora-user-images/image-20221215114642708.png)

先从MybatisAutoConfiguration入手，看其代码，可以发现，Mybatis依赖的类有

- DataSourceAutoConfiguration：负责创建DataSource，Springboot-start-jdbc默认引入/创建Hikari CP的连接池，连接池详细见data source相关
- MybatisLanguageDriverAutoConfiguration：无用FreeMarker等模版引擎不会加载

在spring boot bean启动后，会通过afterProperties检测，如果我们有使用自定义的配置文件，该文件是否存在。

![image-20221215115011862](/Users/hhh/Library/Application Support/typora-user-images/image-20221215115011862.png)