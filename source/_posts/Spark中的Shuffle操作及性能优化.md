---
mathjax: true
title: Spark中的Shuffle操作及性能优化
date: 2015-12-28 20:17:05
categories: Spark
tags: [Spark]
---


##	Spark Shuffle的基本概念

Shuffle是MapReduce框架中的一个特殊阶段，介于Map阶段和Reduce阶段之间。当Map的输出结果要被Reduce使用的时候，输出结果需要按照key进行Hash操作，并且分发给每个Reducer，这个过程就是Shuffle。由于shuffle涉及到了磁盘的读写和网络的传输，因此shuffle性能的高低直接影响到了程序的运行效率。

下面这幅图描述了Spark Shuffle的流程：

<center>![IMG:shuffle.png](/img/Spark中的Shuffle操作及性能优化/shuffle.png)</center>

## Spark Shuffle相关优化1：减少宽依赖

对RDD进行转化操作可以生成新的RDD，这些RDD之间存在前后依赖(Dependencies)关系。在Spark中，RDD之间的依赖关系可以分为两种：宽依赖(Wide Dependencies)和窄依赖(Narrow Dependencies)。

*	宽依赖：父RDD的分区被子RDD的多个分区使用。
*	窄依赖：每个父RDD的分区被子RDD的最多一个分区使用。

<center>![IMG:dependencies.png](/img/Spark中的Shuffle操作及性能优化/dependencies.png)</center>


从图中对比可以知道宽窄依赖的区别如下：

1.	窄依赖可以在集群的节点上如流水线一般计算，各个节点之间并行计算且互不影响。宽依赖则需要取得父RDD的所有分区数据，利用Shuffle操作进行计算，而且要等待父RDD的所有分区都计算完毕之后才能继续进行。
2.	对于节点计算失败之后的恢复，窄依赖比宽依赖更加有效。窄依赖只需要计算失败节点对应的RDD分区即可，且多个分区间的计算可以并行执行。而对于宽依赖，每个节点的失败都需要重新计算父RDD的所有分区，代价是非常高的。

有上可知，宽依赖的存在非常影响算法的计算效率，因此我们要尽量避免宽依赖的出现。例如，如果迭代算法中存在某个非co-partitioned RDD在每轮迭代中都需要进行join操作，那么可以先利用partitioner分区函数将该RDD变量进行partitionBy操作，这样其后每一次迭代(从第二次开始)中的join操作都可以从宽依赖变成窄依赖，省去shuffle过程，提高效率。具体实例可以参考《Spark大数据处理计算》P21。

另外，很早之前查阅资料的时候，有人使用了下图中的方式对A.join(F)进行了优化：A先通过groupBy操作转成B，然后B.join(F)。没有想明白为什么要这样做，等想明白之后再补充这部分。

<center>![IMG:join.png](/img/Spark中的Shuffle操作及性能优化/join.png)</center>

## Spark Shuffle相关优化2：避免使用groupByKey操作

在计算WordCounts的时候，可以使用reduceByKey操作，也可以使用groupByKey操作，如下：

```
val words = Array("one", "two", "two", "three", "three", "three")
val wordPairsRDD = sc.parallelize(words).map(word => (word, 1))

val wordCountsWithReduce = wordPairsRDD
    .reduceByKey(_ + _)
    .collect()

val wordCountsWithGroup = wordPairsRDD
    .groupByKey()
    .map(t => (t._1, t._2.sum))
    .collect()
```

虽然这两个方法都可以得到正确的方法，但是reduceByKey在大数据集上的表现要比groupByKey操作好得多。这是因为Spark在reduceByKey的Shuffle操作之前，会在Map端分别对RDD的每个partition根据相同的key进行combine操作。

下面两幅图描述了WordCounts中reduceByKey和groupByKey的执行过程。

<center>![IMG:reduceByKey.png](/img/Spark中的Shuffle操作及性能优化/reduceByKey.png)</center>

对于reduceByKey，可以看到相同partition上拥有相同key的pairs会在shuffle开始之前完成合并（用传给reduceByKey的lamdba函数）,然后在reduce的过程中再次调用lamdba函数为每个partition合并pairs，从而得到最终的结果。

<center>![IMG:groupByKey.png](/img/Spark中的Shuffle操作及性能优化/groupByKey.png)</center>

而对于groupByKey，所有的键值对都会参与到shuffle当中去，会有大量不必要的数据在网络上进行传输。

Spark会为每个键值对的key调用分区函数来计算各个键值对shuffle到哪一个节点。当shuffle到某个exector的数据非常多，大于他可用的内存的时候，Spark就会把结果转移到硬盘上。这个转移的过程是以key为单位进行的，当某个key所包含的键值对无法在内存中容纳的时候，就会抛出<em>OutOfMemeryException</em>异常。不过这个异常随后会被Spark处理掉，并不会影响到程序的正常运行。不过我们还是要避免这样的情况发生，因为将数据从内存转移到硬盘会严重影响程序的性能。

你可以想象到，当数据规模非常非常大的时候，reduceByKey和groupByKey所需要shuffle的键值对的数量之间的差别是非常惊人的。

在需要用到groupByKey的时候，可以使用以下函数来代替：

*	<em>combineByKey</em> 输出值的类型和输入值的类型不同，combine具有相同key的键值对。
*	<em>foldByKey</em> 输出值的类型和输入值的类型相同，为每个key指定一个初始值，对相同key的元素进行合并。
	

##	参考链接

*	<a href="http://stackoverflow.com/questions/28395376/does-a-join-of-co-partitioned-rdds-cause-a-shuffle-in-apache-spark">Does a join of co-partitioned RDDs cause a shuffle in Apache Spark?</a>
*	<a href="https://databricks.gitbooks.io/databricks-spark-knowledge-base/content/best_practices/prefer_reducebykey_over_groupbykey.html">groupByKey和reduceByKey性能比较</a>

