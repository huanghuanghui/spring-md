# Springboot中SpringMVC启动流程

[toc]

## 简述
不管是在SpringMVC正常启动流程，还是在SpringBoot中，都是由tomcat拉起的SpringMVC容器。本文以SpringBoot的视角走进源码，看看Webb大神如何操作，将tomcat/SpringMVC/Spring整合到SpringBoot中。

## 启动容器前配置
SpringBoot关于容器的启动配置，配置在spring.factories的EnableAutoConfiguration的ServletWebServerFactoryAutoConfiguration中，@SpringBootApplication包含@EnableAutoConfiguration，所以spring.factories的EnableAutoConfiguration类会通过Import的方式，被加入进Spring容器中，这些数据SpringBoot启动相关内容，在这边不赘述。
```java
@Configuration(proxyBeanMethods = false)
@AutoConfigureOrder(Ordered.HIGHEST_PRECEDENCE)
@ConditionalOnClass(ServletRequest.class)
@ConditionalOnWebApplication(type = Type.SERVLET)
@EnableConfigurationProperties(ServerProperties.class)
@Import({ ServletWebServerFactoryAutoConfiguration.BeanPostProcessorsRegistrar.class,
		ServletWebServerFactoryConfiguration.EmbeddedTomcat.class,
		ServletWebServerFactoryConfiguration.EmbeddedJetty.class,
		ServletWebServerFactoryConfiguration.EmbeddedUndertow.class })
public class ServletWebServerFactoryAutoConfiguration {

}
```
@Import了EmbeddedTomcat.class，@ConditionalOnClass如果存在Servlet.class, Tomcat.class, UpgradeProtocol.class，那么就加载EmbeddedTomcat（内嵌的Tomcat）

```java
	@Configuration(proxyBeanMethods = false)
	@ConditionalOnClass({ Servlet.class, Tomcat.class, UpgradeProtocol.class })
	@ConditionalOnMissingBean(value = ServletWebServerFactory.class, search = SearchStrategy.CURRENT)
	static class EmbeddedTomcat {

		@Bean
		TomcatServletWebServerFactory tomcatServletWebServerFactory(
				ObjectProvider<TomcatConnectorCustomizer> connectorCustomizers,
				ObjectProvider<TomcatContextCustomizer> contextCustomizers,
				ObjectProvider<TomcatProtocolHandlerCustomizer<?>> protocolHandlerCustomizers) {
			TomcatServletWebServerFactory factory = new TomcatServletWebServerFactory();
			factory.getTomcatConnectorCustomizers()
					.addAll(connectorCustomizers.orderedStream().collect(Collectors.toList()));
			factory.getTomcatContextCustomizers()
					.addAll(contextCustomizers.orderedStream().collect(Collectors.toList()));
			factory.getTomcatProtocolHandlerCustomizers()
					.addAll(protocolHandlerCustomizers.orderedStream().collect(Collectors.toList()));
			return factory;
		}
	}
```

## 加载bean

ServletWebServerFactoryAutoConfiguration配置类下：
- ServletWebServerFactoryAutoConfiguration
- ServerProperties

- servletWebServerFactoryCustomizer
- tomcatServletWebServerFactoryCustomizer

- ServletWebServerFactoryConfiguration
- EmbeddedTomcat
- tomcatServletWebServerFactory

EmbeddedTomcat拉起的bean（只是以ObjectProvider形式生成了代理的bean，没有真正生成bean）
- connectorCustomizers
- contextCustomizers
- protocolHandlerCustomizers

无生成bean：
- webServerFactoryCustomizerBeanPostProcessor
- errorPageRegistrarBeanPostProcessor
- forwardedHeaderFilter



额外拉起的bean
- org.springframework.boot.autoconfigure.websocket.servlet.WebSocketServletAutoConfiguration$TomcatWebSocketConfiguration
- websocketServletWebServerCustomizer
- org.springframework.boot.autoconfigure.web.embedded.EmbeddedWebServerFactoryCustomizerAutoConfiguration$TomcatWebServerFactoryCustomizerConfiguration
- tomcatWebServerFactoryCustomizer
- org.springframework.boot.autoconfigure.web.servlet.HttpEncodingAutoConfiguration
- localeCharsetMappingsCustomizer
- org.springframework.boot.autoconfigure.web.servlet.error.ErrorMvcAutoConfiguration
- org.springframework.boot.autoconfigure.web.servlet.DispatcherServletAutoConfiguration$DispatcherServletRegistrationConfiguration
- org.springframework.boot.autoconfigure.web.servlet.DispatcherServletAutoConfiguration$DispatcherServletConfiguration
- spring.mvc-org.springframework.boot.autoconfigure.web.servlet.WebMvcProperties
- dispatcherServlet
- spring.servlet.multipart-org.springframework.boot.autoconfigure.web.servlet.MultipartProperties
- org.springframework.boot.autoconfigure.web.servlet.MultipartAutoConfiguration
- multipartConfigElement
- dispatcherServletRegistration
- errorPageCustomizer


22







org.springframework.boot.autoconfigure.web.servlet.ServletWebServerFactoryConfiguration$EmbeddedTomcat
tomcatServletWebServerFactory
org.springframework.boot.autoconfigure.websocket.servlet.WebSocketServletAutoConfiguration$TomcatWebSocketConfiguration
websocketServletWebServerCustomizer
org.springframework.boot.autoconfigure.web.servlet.ServletWebServerFactoryAutoConfiguration
server-org.springframework.boot.autoconfigure.web.ServerProperties
servletWebServerFactoryCustomizer
tomcatServletWebServerFactoryCustomizer
org.springframework.boot.autoconfigure.web.embedded.EmbeddedWebServerFactoryCustomizerAutoConfiguration$TomcatWebServerFactoryCustomizerConfiguration
tomcatWebServerFactoryCustomizer
org.springframework.boot.autoconfigure.web.servlet.HttpEncodingAutoConfiguration
localeCharsetMappingsCustomizer
org.springframework.boot.autoconfigure.web.servlet.error.ErrorMvcAutoConfiguration
org.springframework.boot.autoconfigure.web.servlet.DispatcherServletAutoConfiguration$DispatcherServletRegistrationConfiguration
org.springframework.boot.autoconfigure.web.servlet.DispatcherServletAutoConfiguration$DispatcherServletConfiguration
spring.mvc-org.springframework.boot.autoconfigure.web.servlet.WebMvcProperties
dispatcherServlet
spring.servlet.multipart-org.springframework.boot.autoconfigure.web.servlet.MultipartProperties
org.springframework.boot.autoconfigure.web.servlet.MultipartAutoConfiguration
multipartConfigElement
dispatcherServletRegistration
errorPageCustomizer

