# Spring Security

[toc]

## 一、springSecurityFilterChain登录拦截

- 配置过滤器链 springSecurityFilterChain 名称固定 ，从springSecurityFilterChain进行登录拦截

## 二、UserDetailsService配置用户校验

- org.springframework.security.core.userdetails.UserDetailsService，配置用户校验

```java
//用户认证状态，是否可用，是否过期，凭证是否过期，用户是否锁定,UserDetails对象返回给类UserDetailsService
UserDetails userDetails = new org.springframework.security.core.userdetails.User(
                        user.getUserName(),user.getPassword(),true,true,true,true,authorities);
         
```

## 三、密码加密

```xml
<bean class="org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder" id="bCryptPasswordEncoder"/>

    <!-- 认证用户信息 -->
    <security:authentication-manager>
      <!-- 配置用户信息校验类 -->
        <security:authentication-provider user-service-ref="userServiceImpl">
          <!-- 配置加密规则 -->
            <security:password-encoder ref="bCryptPasswordEncoder" />
        </security:authentication-provider>
    </security:authentication-manager>
```

## 四、RememberMe

- 会在cookie中，填写上remember-me匹配的会话信息
- 记住我的功能会方便大家的使用，但是安全性确是令人担忧的，因为cookie信息存储在客户端，很容易被盗取，这时候我们可以将这些数据持久化到数据库中
- 创建表persistence_logins，不是随意建的，是固定的

```xml
<input type="checkbox" name="remember-me" value="true"> 记住我 <br>

<!-- 放开RememberMe 功能 data-source-ref表示将会话信息存到数据库中 -->
<security:remember-me token-validity-seconds="1200" data-source-ref="dataSource" remember-me-parameter="remember-me"/>
```

## 五、基本应用权限管理

### 授权-注解使用

- 注解式无法动态判断角色，角色要写死在注解上

```xml
    <!--
        开启权限控制注解支持
        jsr250-annotations="enabled" 表示支持jsr250-api的注解支持，需要jsr250-api的jar包
        pre-post-annotations="enabled" 表示支持Spring的表达式注解
        secured-annotations="enabled" 这个才是SpringSecurity提供的注解
     -->
    <security:global-method-security
        jsr250-annotations="enabled"
        pre-post-annotations="enabled"
        secured-annotations="enabled"
    />
```

#### jsr250使用

```xml
    <dependency>
      <groupId>javax.annotation</groupId>
      <artifactId>jsr250-api</artifactId>
      <version>1.0</version>
    </dependency>
```

```java
		//只有角色为  ROLE_ADMIN才有权限访问，没权限会报错403  
		@RolesAllowed(value = {"ROLE_ADMIN"})
    @RequestMapping("/query")
    public String query(){
        System.out.println("用户查询....");
        return "/home.jsp";
    }
```

#### Spring表达式注解使用

```java
		@PreAuthorize(value = "hasAnyRole('ROLE_USER')")
    @RequestMapping("/query")
    public String query(){
        System.out.println("用户查询....");
        return "/home.jsp";
    }
```

#### SpringSecurity提供的注解

```java
    @Secured("ROLE_USER")
    @RequestMapping("/query")
    public String query(){
        System.out.println("用户查询....");
        return "/home.jsp";
    }
```

### 授权-标签使用

注解式权限管理可以控制用户是否具有这个操作的权限，但是当用户具有了这个权限后，进入到具体的操作页面，这时候我们还要进行更细粒度的控制，这时注解的方式就不太适用了，这时候就可以使用标签来控制。

```jsp
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="security" uri="http://www.springframework.org/security/tags" %>
<html>
<head>
    <title>Title</title>
</head>
<body>
    <h1>欢迎光临...</h1>
    <security:authentication property="principal.username" />
    <security:authorize access="hasAnyRole('ROLE_USER')" >
        <a href="#">用户查询</a><br>
    </security:authorize>
    <security:authorize access="hasAnyRole('ROLE_ADMIN')" >
        <a href="#">用户添加</a><br>
    </security:authorize>
    <security:authorize access="hasAnyRole('ROLE_USER')" >
        <a href="#">用户更新</a><br>
    </security:authorize>
    <security:authorize access="hasAnyRole('ROLE_ADMIN')" >
        <a href="#">用户删除</a><br>
    </security:authorize>
</body>
</html>
```

### 无权限错误跳转

在Spring-security.xml文件中配置就可以了

```xml
<security:access-denied-handler error-page="/error.jsp" />
```

## 源码解析



## 整合springboot

- 通过继承`WebSecurityConfigurerAdapter`，来做密码/用户/校验

- 通过Spring.factory auto configuration，进行Spring security自动配置

```prope
#初始化
org.springframework.boot.autoconfigure.security.servlet.SecurityAutoConfiguration,\
#认证，生成默认账号密码
org.springframework.boot.autoconfigure.security.servlet.UserDetailsServiceAutoConfiguration,\
#过滤器链 DelegatingFilterProxyRegistrationBean创建filter链
org.springframework.boot.autoconfigure.security.servlet.SecurityFilterAutoConfiguration,\
```











