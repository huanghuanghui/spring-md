# ApplicationContext

[toc]

## 简介
spring docs对ApplicationContext的描述:
>Central interface to provide configuration for an application. This is read-only while the application is running, but may be reloaded if the implementation supports this.

是一个应用程序提供配置的中央接口
## 核心功能
ApplicationContext 提供：
- 用于访问应用程序组件的 Bean 工厂方法。继承自 ListableBeanFactory。 
- 以通用方式加载文件资源的能力。继承自 ResourceLoader 接口。
- 向注册的监听器发布事件的能力。继承自 ApplicationEventPublisher 接口。
- 解决消息的能力，支持国际化。继承自 MessageSource 接口。
- 从父上下文继承。后代上下文中的定义将始终具有优先权。这意味着，例如，整个 Web 应用程序可以使用单个父上下文，而每个 servlet 都有自己的子上下文，该子上下文独立于任何其他 servlet。


除了标准的 BeanFactory 生命周期功能之外，ApplicationContext 实现还检测和调用 ApplicationContextAware bean 以及 ResourceLoaderAware、ApplicationEventPublisherAware 和 MessageSourceAware bean。
## 代码解读
```java
public interface ApplicationContext extends EnvironmentCapable, ListableBeanFactory, HierarchicalBeanFactory,
		MessageSource, ApplicationEventPublisher, ResourcePatternResolver {
}

```
ApplicationContext实现了如下接口，
- ApplicationEventPublisher
- BeanFactory
- EnvironmentCapable
- HierarchicalBeanFactory
- ListableBeanFactory
- MessageSource
- ResourceLoader
- ResourcePatternResolver

ApplicationContext是这些接口的整合，代表ApplicationContext有这些接口中的方法，但是ApplicationContext并没有自己对方法进行实现，而是调用具体接口具体实现类实现的方法。例如：BeanFactory#containsBean，在AbstractApplicationContext的实现为：
```java
	@Override
	public boolean containsBean(String name) {
		return getBeanFactory().containsBean(name);
	}

```
AbstractApplicationContext自己并不实现containsBean的具体逻辑，而是调用本类中的BeanFactory的实现类的方法。ApplicationContext继承自上层的接口有：
>Methods inherited from interface org.springframework.beans.factory.ListableBeanFactory
- containsBeanDefinition
- findAnnotationOnBean
- findAnnotationOnBean
- getBeanDefinitionCount
- getBeanDefinitionNames
- getBeanNamesForAnnotation
- getBeanNamesForType
- getBeanNamesForType
- getBeanNamesForType
- getBeanNamesForType
- getBeanProvider
- getBeanProvider
- getBeansOfType
- getBeansOfType
- getBeansWithAnnotation
>Methods inherited from interface org.springframework.beans.factory.HierarchicalBeanFactory
- containsLocalBean
- getParentBeanFactory
>Methods inherited from interface org.springframework.beans.factory.BeanFactory
- containsBean
- getAliases
- getBean
- getBean
- getBean
- getBean
- getBean
- getBeanProvider
- getBeanProvider
- getType
- getType
- isPrototype
- isSingleton
- isTypeMatch
- isTypeMatch
>Methods inherited from interface org.springframework.context.MessageSource
- getMessage
- getMessage
- getMessage
>Methods inherited from interface org.springframework.context.ApplicationEventPublisher
publishEvent
- publishEvent
>Methods inherited from interface org.springframework.core.io.support.ResourcePatternResolver
- getResources
>Methods inherited from interface org.springframework.core.io.ResourceLoader
- getClassLoader
- getResource

ApplicationContext中这些方法都是继承自父接口，他自己的方法只有如下6个：
```java
public interface ApplicationContext extends EnvironmentCapable, ListableBeanFactory, HierarchicalBeanFactory,
		MessageSource, ApplicationEventPublisher, ResourcePatternResolver {
	//返回此应用程序上下文的唯一 ID。
	@Nullable
	String getId();
	//返回此上下文所属的已部署应用程序的名称。
	String getApplicationName();
	//返回此上下文的展示名称。
	String getDisplayName();
	//获取程序启动日期
	long getStartupDate();
	//返回父上下文，如果没有父上下文，则返回 {@code null}，这是上下文层次结构的根。
	@Nullable
	ApplicationContext getParent();
	//公开此上下文的 AutowireCapableBeanFactory 功能，参与spring bean的生命周期，ApplicationContext方法内部使用的是beanFactory实现的功能
	AutowireCapableBeanFactory getAutowireCapableBeanFactory() throws IllegalStateException;
}

```
## 小结

ApplicationContext接口，是一个大接口，将他所extends的接口的功能进行整合，将继承的接口作为一种方便/特定的工具，放入ApplicationContext，比如需要使用BeanFactory#getBean，那么可以直接使用ApplicationContext#getBean。