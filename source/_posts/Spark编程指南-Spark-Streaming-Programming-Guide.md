---
mathjax: true
title: <Spark编程指南>Spark Streaming Programming Guide
date: 2016-06-20 17:05:51
categories: Spark
tags: [Spark]
---

## 概述

Spark Streaming是Spark API核心的扩展，它支持弹性的、高吞吐的、容错的实时数据流处理。数据可以通过多种数据源获取，例如Kafka、Flume、Twitter、ZeroMQ、Kinesis以及TCP sockets，也可以通过高级函数map、reduce、join、window等组成的复杂算法所处理。最终，处理的数据可以输出到文件系统、数据库和live dashboards中。事实上，你也可以在数据流中应用Spark的机器学习和图处理算法。

实际上，它的工作原理如下所示。Spark Streaming接收实时的数据流输出并且将数据切分成多批，Spark引擎会按批处理数据并也通过多批的形式生成输出流。

<center>![streaming-flow](/img/Spark编程指南-Spark-Streaming-Programming-Guide/streaming-flow.png)</center>

Spark Streaming 提供了一个高层次的抽象叫做离散流或DStream，并以此来表示一个连续的数据流。DStream可以通过数据源（例如Kafka, Flume, and Kinesis）的输入数据流创建，也可以通过其他DStream的高级方法创建。实际上，DStream是通过一个RDD的序列来表示。

这个指南告诉我们如何用DStream来写Spark Streaming程序。你可以用Scala, Java或者Python来写Spark Streaming。

## 快速入门

在介绍Spark Streaming程序细节之前，先来看看一个简单的Spark Streaming程序是什么样子的。假设我们想要通过监听TCP socket的方式统计来自一个数据服务器的文本数据的单词数。你可以按照如下的方法去做：

```
import org.apache.spark._
import org.apache.spark.streaming._
import org.apache.spark.streaming.StreamingContext._ // not necessary since Spark 1.3

// Create a local StreamingContext with two working thread and batch interval of 1 second.
// The master requires 2 cores to prevent from a starvation scenario.

val conf = new SparkConf().setMaster("local[2]").setAppName("NetworkWordCount")
val ssc = new StreamingContext(conf, Seconds(1))
```

用这种context，我们可以创建流数据来自某个TCP源的DStream，需要指定hostname和端口号。

```
// Create a DStream that will connect to hostname:port, like localhost:9999
val lines = ssc.socketTextStream("localhost", 9999)
```

其中，DStream表示从数据服务器接收到的流数据。DStream中的每条记录都是一行文本。接下来，我们需要根据空格进行切分。

```
// Split each line into words
val words = lines.flatMap(_.split(" "))
```

flatMap是一对多的DStream运算，它将会创建一个新的DStream，并且原始DStream中的每个记录会对应生成多个记录。在这个例子中，每行被切分成了多个单词，并且单词流用words命令的DStream来表示。接下来，我们将会对单词计数。

```
import org.apache.spark.streaming.StreamingContext._ // not necessary since Spark 1.3
// Count each word in each batch
val pairs = words.map(word => (word, 1))
val wordCounts = pairs.reduceByKey(_ + _)

// Print the first ten elements of each RDD generated in this DStream to the console
wordCounts.print()
```

words变量接下来通过被map成了(word, 1)对儿的DStream形式，再通过reduce操作来计数每批数据中单词的频率。最终，通过wordCounts.print()方法打印每个单词的计数。

需要注意的是，当这些行被执行的时候，Spark Streaming只是设置了程序运行时将会进行的计算，而没有真正进行计算。当所有的转换操作设置完毕之后，我们可以通过如下方式在启动计算过程：

```
ssc.start()             // Start the computation
ssc.awaitTermination()  // Wait for the computation to terminate
```

如果你已经下载和编译好了Spark，那可以按照如下的方式来运行该样例。首先需要运行Netcat（大多数Unix系统都有的小工具）来作为数据服务器：

```
nc -lk 9999
```

然后，另起一个终端，运行样例：

```
 ./bin/run-example streaming.NetworkWordCount localhost 9999
```

接下来，netcat运行的终端上输入任意内容都会被按秒计数然后显示在屏幕上。

## 基本概念

接下来，我们不局限于这个简单例子，阐述Spark Streaming的基本知识。

### 链接

与Spark类似，可以在Maven Central获取Spark Streaming。如果要写Spark Streaming的程序，你需要在你的SBT或者Maven项目中添加如下依赖。

```
// SBT
libraryDependencies += "org.apache.spark" % "spark-streaming_2.10" % "1.6.2"
```

Spark Streaming核心API中不包含从不同数据源获取数据的接口，你需要使用`spark-streaming-xyz_2.10`的形式添加对应的依赖包。最新的列表参考[Maven repository](http://search.maven.org/#search%7Cga%7C1%7Cg%3A%22org.apache.spark%22%20AND%20v%3A%221.6.2%22)。

### 初始化StreamingContext

为了初始化Spark Streaming程序，必须创建StreamingContext，这是整个Spark Streaming功能的关键点。

从SparkConf创建StreamingContext对象。

```
import org.apache.spark._
import org.apache.spark.streaming._

val conf = new SparkConf().setAppName(appName).setMaster(master)
val ssc = new StreamingContext(conf, Seconds(1))
```

`appName`参数是你应用的名称，并显示在集群UI上。`master`参数是Spark、Mesos或者Yarn集群的URL，也可以指定"local[*]"让它运行在本地模式下。实际上，当在集群上运行程序时，你并不希望将master硬编码到程序中，而是在spark-submit的时候指定。在本地测试和单测中，你可以使用"local[*]"来启动进程运行SparkStreaming的程序（检测本地系统内核的数量）。注意，它在内部创建了一个SparkContext（所有Spark功能的出发点），可以通过ssc.sparkContext获取。

批处理的间隔根据自己的应用程序的延迟要求及集群的可用资源设置，详见性能调优章节的介绍。

StreamingContext对象也可以通过已存在的SparkContext对象创建。

```
import org.apache.spark.streaming._

val sc = ...                // existing SparkContext
val ssc = new StreamingContext(sc, Seconds(1))
```

当context定义好后，你需要完成如下工作：

1.	通过创建输入DStream定义输入源。
2.	通过应用DStream的转化及输出操作定义流计算。
3.	通过`streamingContext.start()`开始接受和处理数据。
4.	通过`streamingContext.awaitTermination()`等待处理结束（手工结束或遇到错误）。
5.	通过`streamingContext.stop()`可以手动终止任务。

关键点：

*	一旦一个context启动，新的streaming计算不能设置及添加给它。
*	context在终止后不能重启。
*	在一个JVM的同一时刻，只能存在一个有效的StremaingContext。
*	stop()会同时终于StreamingContext和SparkContext。如果想只停止StreamingContext需要设置stop()的可选参数stopSparkContext为false。
*	SparkContext可以被复用来创建多个StreamingContext，在新的StreamingContext创建前停止之前的StreamingContext（不停止SparkContext）。

### 离散流（DStream）

`离散流`或`DStream`是Spark Streaming提供的基本抽象数据结构。它表示一个连续的数据流，不仅包括从源接收到的输入数据流，也包括输入流经过转化生成的处理后的数据流。在Spark内部，DStream使用RDD的连续序列来表示。DStream中的每个RDD包含一个固定间隔内的数据，如下图所示。

![streaming-dstream](/img/Spark编程指南-Spark-Streaming-Programming-Guide/streaming-dstream.png)

任何应用在DStream上的操作都会转化成对内部RDD的操作。例如，之前的例子中，将文本行的输入流切分为单词，*flatMap*操作被应用在了*lines*DStream的每个RDD中，来生成*words*DStream的RDD。如下图所示。

![streaming-dstream-ops](/img/Spark编程指南-Spark-Streaming-Programming-Guide/streaming-dstream-ops.png)

内部RDD的转换操作由Spark引擎来完成。DStream操作隐藏了这些细节，向开发提供了更高级的API。这些操作的细节在之后的章节中介绍。

### 输入DStream和Receiver

输入DStream表示从数据源接收的输入数据流。在快速入门的例子中，*lines*是输入DStream，它表示从netcat服务器接收的数据流。每个输入DStream（除了文件流，本章节之后讨论）都和一个Receiver对象关联，它从源接收数据，并将其存储在Spark内存中等待处理。

Spark Streaming提供两类内建的流源：

*	基本源：通过StreamingContext API直接获取源。例如：文件系统，socket连接，以及Akka actors。
*	高级源：通过外部工具获取的源，例如Kafka、Flume、Kinesis、Twitter等。他们要求添加额外的依赖。

本章节将介绍两类源中的一些代表。

如果你想在你的流应用中并行接收多个数据流，你可以创建多个输入DStream（性能调优章节中将会进一步介绍）。这将会创建多个Reciver，同时接收多个数据流。但是，Spark worker/executor是一个长期运行的任务，因此它会占用分配给Spark Streaming应用的一个内核。所以，Spark Streaming应用一定要保证有足够的内核来处理接收的数据以及运行receiver。

关键点：

*	当运行本地的Spark Streaming程序时，不要使用"local"或者"local[1]"作为master URL。这意味着你只有一个线程来运行本地任务。如果你使用了基于receiver（例如，sockets/Kafka/Flume等）的输入DStream，这个线程将会被用来运行receiver，没有多余的线程处理接收到的数据。因此，本地运行时，通常使用"local[n]"作为master URL，并保证n大于receiver的数目。
*	当在集群上运行时，分配给Spark Streaming应用的内核数目必须大于receiver的数目，否则，系统只能接收数据而不能处理数据。

#### 基本源

在之前的例子中，我们知道了如何创建DStream来接收来自TCP socket连接的数据。除了socket，StreamingContext API还提供了方法来创建DStream接收来自文件和Akka actor的输入源。

*	文件流：为了读取来自于HDFS API兼容的任何文件系统（HDFS, S3, NFS等）的数据，可以通过如下方法创建DStream:

	```
	streamingContext.fileStream[KeyClass, ValueClass, InputFormatClass](dataDirectory)
	```

	Spark Streaming将监视*dataDirectory*目录，并处理该目录创建的任何文件（不支持嵌套目录中的文件）。注意：

	*	文件的数据格式必须相同。
	*	通过移动或者重命名的方式在*dataDirectory*目录下创建文件。
	*	一旦移动，文件不可以再发生改变。所以一个文件如果被追加，则新数据不会被读到。
	
	对于简单的文本文件，有个更简单的方法 streamingContext.textFileStream(dataDirectory)。文件流不需要运行receiver，因此不需要分配内核。
	
*	基于Custom Actor的流：DStream可以通过*streamingContext.actorStream(actorProps, actor-name)*接收来自Akka actor的数据流。更多细节参考[Custom Receiver Guide](http://spark.apache.org/docs/latest/streaming-custom-receivers.html)。

*	RDD队列作为流： 为了使用测试数据测试Spark Streaming应用，你可以基于一个RDD序列通过*streamingContext.queueStream(queueOfRDDs)*创建DStream。每个进入队列的RDD将会被当做DStream中的一批数据，像流一样进行处理。

关于socket、文件和actor相关的流的更多细节，参考API文档：[StreamingContext ](http://spark.apache.org/docs/latest/api/scala/index.html#org.apache.spark.streaming.StreamingContext)。

#### 高级源

这类型的源要求非spark库的外部接口，其中一些有复杂的依赖（例如，Kafka和Flume）。因此，为了尽可能减少因为依赖的版本冲突而造成的问题，从这些源创建DStream的功能已经被移到了单独的库中，这些库在需要的时候可以显示链接。例如，如果你想要从Twitter的流数据创建DStream，你需要按照如下的步骤：

1.	链接：添加* spark-streaming-twitter_2.10*包到SBT/Maven工程依赖中。
2.	编程：引入*TwitterUtils*类，并且用如下所示的*TwitterUtils.createStream*方法创建DStream。
3.	部署：生成包含所有依赖（包含*spark-streaming-twitter_2.10*及其传递依赖）的JAR包，然后部署应用。

```
import org.apache.spark.streaming.twitter._

TwitterUtils.createStream(ssc, None)
```

这些高级源在Spark shell中无法使用，因此基于这些高级源开发的应用无法在shell中测试。如果你确实需要在Spark shell中使用，则需要下载对应的Maven包及其依赖，并添加到classpath中。

可以用的高级源如下：

*	Kafka
*	Flume
*	Kinesis
*	Twitter

#### 定制源

输入DStream可以自定义数据源创建。你需要做的是实现一个用户自定义的receiver，这个receiver可以用来接收来自自定义源的数据并推送给Spark。更多的细节请参考[Custom Receiver Guide](http://spark.apache.org/docs/latest/streaming-custom-receivers.html)。

#### Receiver的可靠性

根据可靠性可以将数据源划分为两种。像Kafka和Flume这些源允许传输的数据进行确认。如果从这些具有可靠性的源接收数据，可以确保不会因为任何类型的故障导致数据丢失。这产生了如下两种receiver：

1.	可靠Receiver：一个可靠receiver会在正确接收数据并存储在Spark上时，发送确认信号给一个可靠的源。
2.	非可靠Receiver：一个非可靠receiver不会发送确认信号给源。它适用于不支持确认信号的源，或者一些不想使用或不必要使用确认信号的可靠源。

如何实现一个可靠receiver请参考[Custom Receiver Guide](http://spark.apache.org/docs/latest/streaming-custom-receivers.html)。

### DStream上的转换操作

和RDD类似，转换操作允许输入DSteam中的数据被修改。DStream支持很多RDD上的转换操作。列举部分如下：

*	map
*	flatMap
*	filter
*	repartition
*	union
*	count
*	reduce
*	countByValue
*	reduceByKey
*	join
*	cogroup
*	updateStateByKey

接下着重介绍其中的一些转换操作。

#### UpdateStateByKey操作

*UpdateStateByKey*操作可以让你在持续利用新信息更新时保持任意的状态。使用它需要如下两步：

1.	定义状态：状态可以是任意的数据类型
2.	定义状态更新函数：定义一个函数指明如何根据之前的状态及输入流的新值更新状态

在每批数据中，Spark会对所有存在的键应用状态更新函数，无论他们在该批数据中是否有新的数据。如果更新函数返回*None*则该键值对将会删除。

让我们通过例子来进行说明。假设你希望维持文本数据流中出现的单词的数量。这里，动态计数值是状态，并且它是个整数。我们定义更新函数如下所示：

```
def updateFunction(newValues: Seq[Int], runningCount: Option[Int]): Option[Int] = {
    val newCount = ...  // add the new values with the previous running count to get the new count
    Some(newCount)
}
```

把它应用在一个包含单词的DStream上（名为*pairs*的DStream中，包含(word, 1)对，来自于之前的样例）。

```
val runningCounts = pairs.updateStateByKey[Int](updateFunction _)
```

对于每个单词，都会调用一次更新函数，*newValues*是一个1的序列（来自(word, 1)对）并且*runningCount*记录了之前的统计值。

使用*udpateStateByKey*要求配置checkpoint目录，这在[checkpointing](http://spark.apache.org/docs/latest/streaming-programming-guide.html#checkpointing)章节中有详细介绍。

#### Transform操作

*transform*操作（以及它的变形，例如*transformWith*）允许在DStream上应用任意的RDD到RDD的函数。它可以使用任何DStream API中不包含的RDD操作。例如，数据流中每批数据与其他数据集进行join操作在DStream API中并不支持。但是，你可以通过*transform*来完成这一功能。这使得很多事情成为了可能。例如，你可以通过将输入数据流与事先准备好的垃圾信心join并且基于它进行过滤来完成实时数据的清洗.

```
val spamInfoRDD = ssc.sparkContext.newAPIHadoopRDD(...) // RDD containing spam information

val cleanedDStream = wordCounts.transform(rdd => {
  rdd.join(spamInfoRDD).filter(...) // join data stream with spam information to do data cleaning
  ...
})
```

需要注意的是，提供的函数在每个批间隔中都会被调用。这允许你完成随时间变化的操作，也就是：RDD操作、分区数量、广播变量等，这些可以在不同批次间发生变化。

#### Window操作

Spark Streaming也提供了窗口化的计算方法，它允许你在一个数据的滑动窗口上完成转化操作。下图对滑动窗口进行了说明。

![streaming-dstream-window](/img/Spark编程指南-Spark-Streaming-Programming-Guide/streaming-dstream-window.png)

如图所示，窗口随着时间在DStream上滑动，落在窗口内的源RDD被结合在一起并通过运算产生了窗口化DStream中的RDD。在上述例子中，每三个时间单位的数据会被执行一次转化操作，每两个时间单位滑动一次窗口。这意味着任意的窗口操作都需要指明两个参数。

*	窗口大小：窗口的时间跨度（上图为3）
*	滑动间隔：窗口操作的计算间隔（上图为2）

这两个参数必须是源DStream批间隔的倍数（上图为1）。

使用例子来对窗口操作进行说明：在之前的例子中，每10s对过去30s的数据统计词频。为了实现这一需求，我们需要对名为*pairs*的DStream中过去30s的(word,1)对应用*reduceByKey*操作。这可以通过*reduceByKeyAndWindow*实现。

```
// Reduce last 30 seconds of data, every 10 seconds
val windowedWordCounts = pairs.reduceByKeyAndWindow((a:Int,b:Int) => (a + b), Seconds(30), Seconds(10))
```

一些常用的窗口操作如下所示。所有这些操作都需要两个参数：windowLength和slideInterval。


|Transformation| 	Meaning|
| ---- | ---- |
|window(windowLength, slideInterval)|	Return a new DStream which is computed based on windowed batches of the source DStream.|
|countByWindow(windowLength, slideInterval)|	Return a sliding window count of elements in the stream.|
|reduceByWindow(func, windowLength, slideInterval)|	Return a new single-element stream, created by aggregating elements in the stream over a sliding interval using func. The function should be associative so that it can be computed correctly in parallel.|
|reduceByKeyAndWindow(func, windowLength, slideInterval, [numTasks])|	When called on a DStream of (K, V) pairs, returns a new DStream of (K, V) pairs where the values for each key are aggregated using the given reduce function func over batches in a sliding window. Note: By default, this uses Spark's default number of parallel tasks (2 for local mode, and in cluster mode the number is determined by the config property spark.default.parallelism) to do the grouping. You can pass an optional numTasks argument to set a different number of tasks.|
|reduceByKeyAndWindow(func, invFunc, windowLength, slideInterval, [numTasks])|A more efficient version of the above reduceByKeyAndWindow() where the reduce value of each window is calculated incrementally using the reduce values of the previous window. This is done by reducing the new data that enters the sliding window, and “inverse reducing” the old data that leaves the window. An example would be that of “adding” and “subtracting” counts of keys as the window slides. However, it is applicable only to “invertible reduce functions”, that is, those reduce functions which have a corresponding “inverse reduce” function (taken as parameter invFunc). Like in reduceByKeyAndWindow, the number of reduce tasks is configurable through an optional argument. Note that checkpointing must be enabled for using this operation.|
|countByValueAndWindow(windowLength, slideInterval, [numTasks])|	When called on a DStream of (K, V) pairs, returns a new DStream of (K, Long) pairs where the value of each key is its frequency within a sliding window. Like in reduceByKeyAndWindow, the number of reduce tasks is configurable through an optional argument.|

#### join操作

Spark Streaming中可以方便的执行各种不同类型的join操作。

##### Stream-stream joins

Streams可以与其他Streams进行join。

```
val stream1: DStream[String, String] = ...
val stream2: DStream[String, String] = ...
val joinedStream = stream1.join(stream2)
```

在每批数据中，stream1生成的RDD会与stream2生成的RDD进行join你可以执行leftOuterJoin, rightOuterJoin, fullOuterJoin。甚至，你可以对stream的windows进行join操作。

```
val windowedStream1 = stream1.window(Seconds(20))
val windowedStream2 = stream2.window(Minutes(1))
val joinedStream = windowedStream1.join(windowedStream2)
```

##### Stream-dataset joins

在解释*DStream.transform*操作的过程中，已经用到了该操作。这里使用另一个例子来介绍stream和dataset的join。

```
val dataset: RDD[String, String] = ...
val windowedStream = stream.window(Seconds(20))...
val joinedStream = windowedStream.transform { rdd => rdd.join(dataset) }
```

事实上，你也可以动态的改变你要join的数据集。这个用来*transform*的函数在每次批处理的时候会重新评估，因此会使用*dataset*指向的当前数据。

完整的DStream transformation请参考API文档。

### DStream上的输出操作

输出操作允许将DStream中的数据导出到诸如数据库和文件系统等的外部系统中去。因为输出操作允许外部系统消费经过转化操作的数据，因此它会触发DStream上的所有转化操作的真实执行（类似于RDD的action操作）。接下来介绍已有的输出操作：

|Output Operation|	Meaning |
| ---- | ---- |
|print()|	Prints the first ten elements of every batch of data in a DStream on the driver node running the streaming application. This is useful for development and debugging. Python API This is called pprint() in the Python API.|
|saveAsTextFiles(prefix, [suffix])	|Save this DStream's contents as text files. The file name at each batch interval is generated based on prefix and suffix: "prefix-TIME_IN_MS[.suffix]". |
|saveAsObjectFiles(prefix, [suffix])|	Save this DStream's contents as SequenceFiles of serialized Java objects. The file name at each batch interval is generated based on prefix and suffix: "prefix-TIME_IN_MS[.suffix]". Python API This is not available in the Python API.|
|saveAsHadoopFiles(prefix, [suffix])|	Save this DStream's contents as Hadoop files. The file name at each batch interval is generated based on prefix and suffix: "prefix-TIME_IN_MS[.suffix]". Python API This is not available in the Python API.|
|foreachRDD(func)|	The most generic output operator that applies a function, func, to each RDD generated from the stream. This function should push the data in each RDD to an external system, such as saving the RDD to files, or writing it over the network to a database. Note that the function func is executed in the driver process running the streaming application, and will usually have RDD actions in it that will force the computation of the streaming RDDs.|

#### 使用foreachRDD的设计模式

*dstream.foreachRDD*可以将数据发送到外部系统。然而，必须要学会正确使用，避免犯一些常见的错误。

通常，写数据到外部系统需要创建一个连接对象（例如，到远程服务器的TCP连接）并且使用它来向远程系统发送数据。为了达到这一目的，开发者可能错误的在Spark driver上创建一个连接对象，然后在Spark worker上使用该对象来保存RDD中的记录。例如：

```
dstream.foreachRDD { rdd =>
  val connection = createNewConnection()  // executed at the driver
  rdd.foreach { record =>
    connection.send(record) // executed at the worker
  }
}
```

这是不正确的，因为它要求序列化连接对象，并且将其从driver发送到worker。这种连接对象是不允许在机器间转移的。这将会引起序列化错误（连接对象不可序列化），初始化错误（连接对象需要在worker上初始化）等。

【未完待续】