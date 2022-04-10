# Flowable工作流

[toc]

## 一、Flowable介绍

flowable是BPMN的一个基于Java的软件实现，包括：

- BPMN
- CMMN Case
- 拥有自己的API管理，用户管理等一系列功能

## 二、Flowable基础

中文翻译版：https://tkjohn.github.io/#/

## 三、源码解析

### 3.1启动Flowable

### 3.2创建DB相关

org.flowable.engine.impl.db.ProcessDbSchemaManager#dbSchemaUpdate负责表创建与升级

- org.flowable.idm.engine.impl.db.IdmDbSchemaManager：IDM相关表存储位置
- org.flowable.engine.common.impl.db.CommonDbSchemaManager：ge相关表存储位置，系统配置
- org.flowable.identitylink.service.impl.db.IdentityLinkDbSchemaManager：identitylink相关
- org.flowable.task.service.impl.db.TaskDbSchemaManager：task相关
- org.flowable.variable.service.impl.db.VariableDbSchemaManager：variable相关
- org.flowable.job.service.impl.db.JobDbSchemaManager：job相关
- org.flowable.engine.impl.db.ProcessDbSchemaManager：engin相关