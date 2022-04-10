# Camunda

[toc]

## 编译Camunda源码

- 修改版本`<version.quarkus>1.13.7.Final</version.quarkus>`
- 修改maven仓库配置

```xml
<?xml version="1.0" encoding="UTF-8"?>

<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 http://maven.apache.org/xsd/settings-1.0.0.xsd">

    <localRepository>/Applications/develop/apache-maven-3.6.3/repository</localRepository>

    <mirrors>
        <mirror>
            <id>alimaven</id>
            <name>aliyun maven</name>
            <url>http://maven.aliyun.com/nexus/content/groups/public/</url>
            <mirrorOf>central</mirrorOf>
        </mirror>
    </mirrors>
    <profiles>
        <profile>
            <id>camunda-bpm</id>
            <repositories>
                <repository>
                    <id>camunda-bpm-nexus</id>
                    <name>camunda-bpm-nexus</name>
                    <releases>
                        <enabled>true</enabled>
                    </releases>
                    <snapshots>
                        <enabled>true</enabled>
                    </snapshots>
                    <url>https://artifacts.camunda.com/artifactory/public/</url>
                </repository>
            </repositories>
        </profile>
    </profiles>
    <activeProfiles>
        <activeProfile>camunda-bpm</activeProfile>
    </activeProfiles>

</settings>
```

- 进入Camunda-bpm-platform，执行：`mvn clean install -pl '!webapps,!org.camunda.bpm.run:camunda-bpm-run-modules-swaggerui' -DskipTests`

## 启动webapps

- 要先编译camunda源码，才能启动

![image-20220407162319047](/Users/hhh/Library/Application Support/typora-user-images/image-20220407162319047.png)

- 修改`/Users/hhh/workspace/code/study/camunda-bpm-platform/webapps/pom.xml`文件的配置，去掉scope，不然会报错java.lang.NoClassDefFoundError: javax/ws/rs/NotFoundException

```xml
    <dependency>
      <groupId>org.jboss.spec.javax.ws.rs</groupId>
      <artifactId>jboss-jaxrs-api_2.1_spec</artifactId>
<!--      <scope>provided</scope>-->
    </dependency>
```

- 运行 grunt auto-build
- 等待 grunt auto-build运行完成后，访问localhost:8080，使用用户jonny1登录