

# Activiti7

[toc]

通过计算机对业务流程自动化执行管理。它主要解决的是“使多个参与者之间按照预定的规则，自动进行文档传递，信息或者任务的过程，从而实现某个预期的业务目标，或促使此目标的实现”

## Activiti介绍

官网：https://www.activiti.org/

### BPM

Business Processor Managment ，业务流程管理，构造端对端管理

### BPMN

Business Processor Model AndNotation，业务流程模型和符号，使用BPMN符号可以创建业务流程

## Activiti应用



## Activiti源码解析

### 使用框架

- 使用原生mybatis，解析配置configuration，例如通过DbSqlSessionFactory#getSelectStatement获取mapper statement，使用org.apache.ibatis.session.SqlSession#selectOne(java.lang.String, java.lang.Object)执行数据库操作
- 使用spring框架，BeansConfigurationHelper#parseProcessEngineConfiguration，声明自己的DefaultListableBeanFactory，与spring隔开

### 核心代码

#### CommandExecutorImpl#execute

- ValidateExecutionRelatedEntityCountCfgCmd中定义了查询ACT_GE_PROPERTY表，与ACT_GE_PROPERTY的校验
- 用了Bulider/命令模式/责任链 设计模式

```java
//commandExecutor.execute传入ValidateExecutionRelatedEntityCountCfgCmd，经过责任链，然后掉到Cmd的execute，结束
commandExecutor.execute(new ValidateExecutionRelatedEntityCountCfgCmd());//核心代码  

@Override
  public <T> T execute(CommandConfig config, Command<T> command) {
    return first.execute(config, command);
  }
```

execute方法会根据`initCommandExecutors()`设置的责任链一层一层执行，最后一个责任链会调用到类`CommandInterceptor`,会调用到`DebugCommandInvoker`或者`CommandInvoker`，根据参数enableVerboseExecutionTreeLogging决定，类中有二个核心方法

```java
  @Override
  @SuppressWarnings("unchecked")
  public <T> T execute(final CommandConfig config, final Command<T> command) {
    final CommandContext commandContext = Context.getCommandContext();

    // Execute the command.
    // This will produce operations that will be put on the agenda.
    commandContext.getAgenda().planOperation(new Runnable() {
      @Override
      public void run() {
        commandContext.setResult(command.execute(commandContext));
      }
    });

    // Run loop for agenda
    executeOperations(commandContext);

    // At the end, call the execution tree change listeners.
    // TODO: optimization: only do this when the tree has actually changed (ie check dbSqlSession).
    if (commandContext.hasInvolvedExecutions()) {
      Context.getAgenda().planExecuteInactiveBehaviorsOperation();
      executeOperations(commandContext);
    }

    return (T) commandContext.getResult();
  }

public void executeOperation(Runnable runnable) {
    if (runnable instanceof AbstractOperation) {
      AbstractOperation operation = (AbstractOperation) runnable;

      // Execute the operation if the operation has no execution (i.e. it's an operation not working on a process instance)
      // or the operation has an execution and it is not ended
      if (operation.getExecution() == null || !operation.getExecution().isEnded()) {

        if (logger.isDebugEnabled()) {
          logger.debug("Executing operation {} ", operation.getClass());
        }

        runnable.run();

      }

    } else {
      runnable.run();
    }
  }
```

##### AbstractQuery

AbstractQuery中有一个默认实现，可以通过类型，走不通的重载方法

```java
  public Object execute(CommandContext commandContext) {
    if (resultType == ResultType.LIST) {
      return executeList(commandContext, null);
    } else if (resultType == ResultType.SINGLE_RESULT) {
      return executeSingleResult(commandContext);
    } else if (resultType == ResultType.LIST_PAGE) {
      return executeList(commandContext, null);
    } else {
      return executeCount(commandContext);
    }
  }
```



#### AbstractDataManager

##### MybatisProcessDefinitionDataManager

使用以下方式，重写mybatis

![image-20220330164953888](/Users/hhh/Library/Application Support/typora-user-images/image-20220330164953888.png)



自己的manager，会经过如下步骤

- 声明protected ProcessDefinitionEntityManager processDefinitionEntityManager;
- ProcessDefinitionEntityManager有一个实现类，ProcessDefinitionEntityManagerImpl，会重写如下方法

```java
  protected ProcessDefinitionDataManager processDefinitionDataManager;  
@Override
  protected DataManager<ProcessDefinitionEntity> getDataManager() {
    return processDefinitionDataManager;
  }
```

- getDataManager()在调用的时候，就会走到ProcessDefinitionEntityManagerImpl重写的方法，获得processDefinitionDataManager，他有一个实现类MybatisProcessDefinitionDataManager

```java
  @Override
  public EntityImpl findById(String entityId) {
    return getDataManager().findById(entityId);
  }
```

- 调用getManagedEntityClass()，会调用MybatisProcessDefinitionDataManager中的getManagedEntityClass

```sql
  @Override
  public EntityImpl findById(String entityId) {
    if (entityId == null) {
      return null;
    }
    // Cache
    EntityImpl cachedEntity = getEntityCache().findInCache(getManagedEntityClass(), entityId);
    if (cachedEntity != null) {
      return cachedEntity;
    }
    // Database
    return getDbSqlSession().selectById(getManagedEntityClass(), entityId, false);
  }
 
```

- 调用MybatisProcessDefinitionDataManager中的getManagedEntityClass，获取到类ProcessDefinitionEntityImpl

```sql
  @Override
  public Class<? extends ProcessDefinitionEntity> getManagedEntityClass() {
    return ProcessDefinitionEntityImpl.class;
  }
```

- 真正执行数据库操作，getSelectStatement获取Statement，例如上例获取出来的Statement id=selectProcessDefinition，那么就可以通过mapper ID 查找对应执行的mapper。**这边有个坑，如果自己去二开activiti，那么要确认Statement ID会不会重复的问题**

```java
public <T extends Entity> T selectById(Class<T> entityClass, String id, boolean useCache) {

				....
          
  			//prefix + entityClass去除EntityImpl
        String selectStatement = dbSqlSessionFactory.getSelectStatement(entityClass);
        selectStatement = dbSqlSessionFactory.mapStatement(selectStatement);
  //原生mybatis
        entity = (T) sqlSession.selectOne(selectStatement,id);
        if (entity == null) {
            return null;
        }
        entityCache.put(entity, true); // true -> store state so we can see later if it is updated later on
        return entity;
    }
```

## Activiti核心流程deploy

开始部署bpmn，org.activiti.engine.impl.bpmn.deployer.BpmnDeployer#deploy

```
deployer.deploy(deployment, deploymentSettings);
```

**bpmn解析处理器**最终调用路径为**BpmnParse->execute()->bpmnParser.getBpmnParserHandlers(i).parseElement()**



