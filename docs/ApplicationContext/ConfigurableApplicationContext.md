# ConfigurableApplicationContext
[toc]
## 简介
ApplicationContext所有常见的实现其实都是ConfigurableApplicationContext。ConfigurableApplicationContext 的 javadoc 中描述
>SPI interface to be implemented by most if not all application contexts.

ConfigurableApplicationContext提供了配置ApplicationContext和设置spring bean生命周期的方法。我们在代码中使用ApplicationContext，可以避免对ApplicationContext中的属性进行设置，避免破坏spring内部属性。（ApplicationContext只提供了获取方法，没有提供设置ApplicationContext中属性的方法）。比如从容器中getBean，可以使用ApplicationContext的方法，但是当我们想要管理容器的生命周期（初始化和销毁）时，需要使用ConfigurableApplicationContext

## 代码解读
ConfigurableApplicationContext在ApplicationContext的基础上，新extends 
Lifecycle, Closeable，这两个接口中，提供了管理容器生命周期与关闭容器的方法
```java
public interface ConfigurableApplicationContext extends public interface ConfigurableApplicationContext extends ApplicationContext, Lifecycle, Closeable {

    //任意数量的这些字符都被视为单个字符串值中多个上下文配置路径之间的分隔符。
	String CONFIG_LOCATION_DELIMITERS = ",; \t\n";
    //工厂中 ConversionService bean 的名称。如果未提供，则应用默认转换规则
	String CONVERSION_SERVICE_BEAN_NAME = "conversionService";
    //工厂中 LoadTimeWeaver bean 的名称。如果提供了这样的 bean，上下文将使用临时 ClassLoader 进行类型匹配，以允许 LoadTimeWeaver 处理所有实际的 bean 类。
	String LOAD_TIME_WEAVER_BEAN_NAME = "loadTimeWeaver";
    //Name of the {@link Environment} bean in the factory.
	String ENVIRONMENT_BEAN_NAME = "environment";
    //Name of the System properties bean in the factory.
	String SYSTEM_PROPERTIES_BEAN_NAME = "systemProperties";
    //Name of the System environment bean in the factory.
	String SYSTEM_ENVIRONMENT_BEAN_NAME = "systemEnvironment";
    // Name of the {@link ApplicationStartup} bean in the factory.
	String APPLICATION_STARTUP_BEAN_NAME = "applicationStartup";
    // {@link Thread#getName() Name} of the {@linkplain #registerShutdownHook()  shutdown hook} thread: {@value}.
	String SHUTDOWN_HOOK_THREAD_NAME = "SpringContextShutdownHook";
    //Set the unique id of this application context.
	void setId(String id);

    //Set the parent of this application context.请注意，不应更改父级：如果在创建此类的对象时它不可用，则仅应在构造函数之外设置它，例如在 WebApplicationContext 设置的情况下
	void setParent(@Nullable ApplicationContext parent);
	
    // Set the {@code Environment} for this application context.ApplicationContext中设置的为Environment，ConfigurableApplicationContext将其替换为ConfigurableEnvironment
	void setEnvironment(ConfigurableEnvironment environment);

    // Return the {@code Environment} for this application context in configurable
	@Override
	ConfigurableEnvironment getEnvironment();
	
    //Set the {@link ApplicationStartup} for this application context.
	void setApplicationStartup(ApplicationStartup applicationStartup);
	
    // Return the {@link ApplicationStartup} for this application context.
	ApplicationStartup getApplicationStartup();

    //添加一个新的 BeanFactoryPostProcessor，它将在刷新时应用于此应用程序上下文的内部 bean 工厂，然后再评估任何 bean definitions 。在上下文配置期间调用。

	void addBeanFactoryPostProcessor(BeanFactoryPostProcessor postProcessor);

    //添加一个新的 ApplicationListener，它将在上下文刷新和上下文关闭等上下文事件上得到通知。 <p>请注意，如果上下文尚未激活，则此处注册的任何 ApplicationListener 都将在刷新时应用，或者在上下文已处于活动状态的情况下与当前事件多播器一起应用。
	void addApplicationListener(ApplicationListener<?> listener);

    //指定 ClassLoader 来加载类路径资源和 bean 类。 <p>这个上下文类加载器将被传递到内部 bean 工厂。Java自带的三个加载器，无法加载到所需class，所以需要重写
	void setClassLoader(ClassLoader classLoader);

    //使用此应用程序上下文注册给定的协议解析器，允许处理其他资源协议。
	void addProtocolResolver(ProtocolResolver resolver);

    //刷新启动容器，加载bean
	void refresh() throws BeansException, IllegalStateException;

    //向 JVM 运行时注册一个关闭hook，在 JVM 关闭时关闭此上下文，除非它当时已经关闭。 <p>这个方法可以被多次调用。每个上下文实例只会注册一个关闭挂钩（最多）。
	void registerShutdownHook();

    //关闭此应用程序上下文，释放实现可能持有的所有资源和锁。这包括销毁所有缓存的单例 bean。
	@Override
	void close();

    //判断此应用上下文是否处于活动状态，即是否至少刷新过一次且尚未关闭。
	boolean isActive();

    //返回此应用程序上下文的内部 bean 工厂。可用于访问底层工厂的特定功能。ApplicationContext注册的为AutowireCapableBeanFactory，在GenericApplicationContext中实现，都是取的DefaultListableBeanFactory
	ConfigurableListableBeanFactory getBeanFactory() throws IllegalStateException;

}

public interface Lifecycle {
    //启动组件
	void start();
    //停止组件
	void stop();
	//检查组件是否在运行中
	boolean isRunning();
}

public interface Closeable extends AutoCloseable {
    //关闭此流并释放与其关联的任何系统资源。如果流已经关闭，则调用此方法无效。
    public void close() throws IOException;
}

```

## 小结
ConfigurableApplicationContext继承自ApplicationContext，增加了管理ApplicationContext生命周期与bean生命周期的方法