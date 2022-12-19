# Java并发源码

[toc]

## 什么是线程模型

Java代码运行在JVM中，所以当JVM想要进行线程创建与线程回收的操作的时候，势必需要调用操作系统的接口，所以操纵系统的线程与JVM的线程存在映射关系，这种映射关系就是Java的线程模型

### 为什么需要线程模型

为什么需要线程模型而不直接调用操作系统的线程呢？

- 使用至上而下的高级抽象管理，JVM需要根据不同的操作系统的原声线程进行高级抽象，使得开发者不要关注底层细节只要关注上层开发。
- 操作系统内核线程：Linux系统中，线程会被称之为轻量进程

![image-20221027202056089](/Users/hhh/Library/Application Support/typora-user-images/image-20221027202056089.png)

## 线程模型

### 一对一

简单易用便于控制，能够解决大部分问题

![image-20221027202250767](/Users/hhh/Library/Application Support/typora-user-images/image-20221027202250767.png)

### 多对一 

缺点：当一个用户线程进行了内核调用，并且阻塞，那么其他线程在这个时间段内都无法进行内核调用。Java早期使用该线程模型，后期被摒弃了。

![image-20221027202311598](/Users/hhh/Library/Application Support/typora-user-images/image-20221027202311598.png)

### 多对多

底层实现复杂，go中使用，并发更高

![image-20221027202745080](/Users/hhh/Library/Application Support/typora-user-images/image-20221027202745080.png)