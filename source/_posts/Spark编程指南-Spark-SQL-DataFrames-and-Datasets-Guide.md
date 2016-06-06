---
mathjax: true
title: '<Spark编程指南>Spark SQL, DataFrames and Datasets Guide'
date: 2016-06-06 08:40:43
categories: Spark
tags: [Spark]
---

说明：译自[Spark1.6.1 Programming Guides](http://spark.apache.org/docs/latest/sql-programming-guide.html#spark-sql-dataframes-and-datasets-guide)

## 概览

Spark SQL 是Spark的一个模块用户处理结构化数据。Spark SQL的接口可以为Spark提供更多关于数据结构和计算性能的信息。基于这些信息，Spark SQL可以完成额外的优化。有多种与Spark SQL（SQL）、DataFrames API 以及 Datasets API 交互的方式。

### SQL

Spark SQL用来执行由基础SQL语法及HiveQL编写的SQL查询。Spark SQL也可以用来读取已安装的Hive中的数据。关于该特征的更多信息，请参考[Hive Tables](http://spark.apache.org/docs/latest/sql-programming-guide.html#hive-tables)章节。当执行SQL时，结果将以DataFrame的形式返回。你也可以通过command-line或者JDBC/ODBC的方式与SQL接口交互。

### DataFrames

DataFrame是分布式的数据集合，他被组织成了有命名的列集合。它与关系数据库中的表以及R /Python中的 data frame是概念等同的，但是有更丰富的优化。DataFrame的构造可以通过各式各样的源进行：结构化数据文件、hive中的表、外部数据库以及RDD等。Dataset可以从JVM对象构造，并且使用功能转化函数（map, flatmap, filter等）进行操作。

统一的Dataset API支持scala和java编程。目前不支持python，但是部分动态特征已经可用，完整的Python支持将在之后发布。

### Datasets

Dataset是Spark1.6之后引入的新的实验接口，它试图结合并提供RDDs（强大的lambda函数）和Spark SQL（优化执行引擎）的优点。

## 开始使用

### 起点：SQLContext

使用Spark SQL的功能需要从SQLContext类开始，或者它的子类。通过SparkContext来创建SQLContext。

```
val sc: SparkContext // 已存在的SparkContext
val sqlContext = new org.apache.spark.sql.SQLContext(sc)

// 用于将RDD隐式转换为DataFrame
import sqlContext.implicits._
```

除了基本的SQLContext，也可以创建HiveContext，它可以提供SQLContext功能的超集。可以使用更完整的HiveQL parser完成写请求，使用Hive UDFs，从Hive表读取数据。使用HiveContext，你不需要有一个现有的Hive设置，所有SQLContext可用的数据源依然可用即可。HiveContext是一个单独的包，这样可以避免在默认Spark中包含所有的Hive依赖。如果这些对你的应用来说不是问题的话，就推荐你使用HiveContext（Spark1.3之后的版本）。未来将致力于实现SQLContext与HiveContext的特性平等。

解析查询可以通过spark.sql.dialect参数指定特定的SQL变种。这个参数可以通过SQLContext的setConf进行改变。对于SQLContext，dialect的值只可以设置为“sql"（SparkSQL提供的简单SQL解析器）。在HiveContext中，默认为"hiveql"，也可以使用“sql”。因为HiveQL解析器更加完整，因此推荐使用。

### 创建DataFrames

通过SQLContext，应用可以根据已存在的RDD创建DataFrames，或者从Hive表，或者从其他的数据源。

下面这个例子从JSON文件中创建DataFrame：

```
val sc: SparkContext // An existing SparkContext.
val sqlContext = new org.apache.spark.sql.SQLContext(sc)

val df = sqlContext.read.json("examples/src/main/resources/people.json")

// Displays the content of the DataFrame to stdout
df.show()
```

### DataFrame操作

DataFrames提供对结构化数据处理的领域特定语言，包括Scala,Java,Python和R。
下面提供了使用DataFrames处理结构化数据的样例：

```
val sc: SparkContext // An existing SparkContext.
val sqlContext = new org.apache.spark.sql.SQLContext(sc)

// Create the DataFrame
val df = sqlContext.read.json("examples/src/main/resources/people.json")

// Show the content of the DataFrame
df.show()
// age  name
// null Michael
// 30   Andy
// 19   Justin

// Print the schema in a tree format
df.printSchema()
// root
// |-- age: long (nullable = true)
// |-- name: string (nullable = true)

// Select only the "name" column
df.select("name").show()
// name
// Michael
// Andy
// Justin

// Select everybody, but increment the age by 1
df.select(df("name"), df("age") + 1).show()
// name    (age + 1)
// Michael null
// Andy    31
// Justin  20

// Select people older than 21
df.filter(df("age") > 21).show()
// age name
// 30  Andy

// Count people by age
df.groupBy("age").count().show()
// age  count
// null 1
// 19   1
// 30   1
```

### 运行SQL查询编程

SQLContext的sql函数允许应用通过编程的方式运行SQL查询，并返回DataFrame。

```
val sqlContext = ... // An existing SQLContext
val df = sqlContext.sql("SELECT * FROM table")
```

### 创建Datasets

Datasets与RDDs类似，不过，它在处理及传输的时候使用的是特定的编码方法，而不是Java Serialization 或者Kryo。他们都将对象转化为比特流，但是该编码方法可以动态生成，并且允许Spark在不需要反序列化的情况下完成filtering,sorting以及hashing等操作。

```
// Encoders for most common types are automatically provided by importing sqlContext.implicits._
val ds = Seq(1, 2, 3).toDS()
ds.map(_ + 1).collect() // Returns: Array(2, 3, 4)

// Encoders are also created for case classes.
case class Person(name: String, age: Long)
val ds = Seq(Person("Andy", 32)).toDS()

// DataFrames can be converted to a Dataset by providing a class. Mapping will be done by name.
val path = "examples/src/main/resources/people.json"
val people = sqlContext.read.json(path).as[Person]
```

### 与RDDs的互操作

Spark SQL 支持两种不同的方法来把已存在的RDD转为DataFrames。

第一种方法使用reflection机制来腿短包含特定类别对象的RDD的schema信息。这种反射机制的方法可以让你实现更加简洁的代码，并且当你写Spark应用的时候已经对schema信息有所了解的时候会非常的便捷。

第二种方法是通过编程接口创建DataFrames，由用户来构建schema信息，并应用于已存在的RDD。这种方法导致代码冗长。这种方法构建的DataFrames只有在运行时才能知道列元素的类型。

#### 使用Reflection生成Schema

Spark SQL的Scala接口支持将包含case class的RDD转化为DataFrame。case class定义了表的schema信息。case class中参数的名字通过reflection机制转化为列明。case class也可以嵌套或包含复杂的类型，诸如Sequences或者Arrays。RDD被隐式转化为DataFrame，同时被注册为一张表。这些表在随后的SQL语句中被使用。

```
// sc is an existing SparkContext.
val sqlContext = new org.apache.spark.sql.SQLContext(sc)
// this is used to implicitly convert an RDD to a DataFrame.
import sqlContext.implicits._

// Define the schema using a case class.
// Note: Case classes in Scala 2.10 can support only up to 22 fields. To work around this limit,
// you can use custom classes that implement the Product interface.
case class Person(name: String, age: Int)

// Create an RDD of Person objects and register it as a table.
val people = sc.textFile("examples/src/main/resources/people.txt").map(_.split(",")).map(p => Person(p(0), p(1).trim.toInt)).toDF()
people.registerTempTable("people")

// SQL statements can be run by using the sql methods provided by sqlContext.
val teenagers = sqlContext.sql("SELECT name, age FROM people WHERE age >= 13 AND age <= 19")

// The results of SQL queries are DataFrames and support all the normal RDD operations.
// The columns of a row in the result can be accessed by field index:
teenagers.map(t => "Name: " + t(0)).collect().foreach(println)

// or by field name:
teenagers.map(t => "Name: " + t.getAs[String]("name")).collect().foreach(println)

// row.getValuesMap[T] retrieves multiple columns at once into a Map[String, T]
teenagers.map(_.getValuesMap[Any](List("name", "age"))).collect().foreach(println)
// Map("name" -> "Justin", "age" -> 19)
```

#### 编程指定Schema

当case classses不能提前被定义的时候（例如，记录的结构被记录在字符串中，或者对于不同的用户将以不同的方式解析文本数据集和投影字段）。DataFrame通过三步来手动创建：

1.	从原始RDD创建Row类型的RDD。
2.	创建通过StructType表示的schema信息来匹配第一步中创建的RDD。
3.	通过SQLcontext提供的createDataFrame方法将shcema信息应用在Row类型的RDD上。

样例如下所示：

```
// sc is an existing SparkContext.
val sqlContext = new org.apache.spark.sql.SQLContext(sc)

// Create an RDD
val people = sc.textFile("examples/src/main/resources/people.txt")

// The schema is encoded in a string
val schemaString = "name age"

// Import Row.
import org.apache.spark.sql.Row;

// Import Spark SQL data types
import org.apache.spark.sql.types.{StructType,StructField,StringType};

// Generate the schema based on the string of schema
val schema =
  StructType(
    schemaString.split(" ").map(fieldName => StructField(fieldName, StringType, true)))

// Convert records of the RDD (people) to Rows.
val rowRDD = people.map(_.split(",")).map(p => Row(p(0), p(1).trim))

// Apply the schema to the RDD.
val peopleDataFrame = sqlContext.createDataFrame(rowRDD, schema)

// Register the DataFrames as a table.
peopleDataFrame.registerTempTable("people")

// SQL statements can be run by using the sql methods provided by sqlContext.
val results = sqlContext.sql("SELECT name FROM people")

// The results of SQL queries are DataFrames and support all the normal RDD operations.
// The columns of a row in the result can be accessed by field index or by field name.
results.map(t => "Name: " + t(0)).collect().foreach(println)
```


## 数据源

Spark SQL通过DataFrame接口支持各种各样的数据源。DataFrame可以像普通的RDD一样被操作，也可以被注册为一张临时的表。将DataFrame注册为表之后，允许你在其数据之上执行SQL查询。这部分介绍使用Spark Data Sources加载和保存数据的一般方法，然后介绍内置数据源的指定选项。

### 通用Load/Save方法

默认的数据源（parquet，可以在spark.sql.sources.default中配置）以最简洁的形式适用于所有的操作。

#### 手动指定选项

你也可以手动指定数据源，也可以将一些额外的配置一起传给你所想使用的数据源。数据源通过它们的合法全名来指定（例如，org.apache.spark.sql.parquet），但是对于内置数据源来说，你也可以使用它们的缩略名（json,parquet,jdbc）。任意类型的ataFrame都可通过这种语法转换成其他类型。

```
val df = sqlContext.read.format("json").load("examples/src/main/resources/people.json")
df.select("name", "age").write.format("parquet").save("namesAndAges.parquet")
```

#### 对文件直接运行SQL

除了使用读取的API来将文件加载为DataFrame然后去查询，也可以直接使用SQL来查询文件：

```
val df = sqlContext.sql("SELECT * FROM parquet.`examples/src/main/resources/users.parquet`")
```

#### 存储模式

存储操作可以随意选择SaveMode，它将指明如何处理已存在的现有数据。认识到这些存储模式没有用到锁并且不是原子操作是非常重要的。另外，当执行覆盖操作的时候，旧数据将会在生成新数据之前被删除。


| Scala / Java | Any Language | Meaning |
| ---- | ---- | ---- |
|SaveMode.ErrorIfExists (default)	|	"error" (default)|	当把DataFrame保存到一个数据源的时候，如果数据已经存在，会抛出一个异常 |
|SaveMode.Append			|	"append"	|	当把DataFrame保存到一个数据源的时候，如果数据已经存在，那么内容会追加到已经存在的数据后|
|SaveMode.Overwrite			|	"overwrite"	|	当把DataFrame保存到一个数据源的时候，如果数据已经存在，已存在的数据会被DataFrame中的数据覆盖|
|SaveMode.Ignore			|	"ignore"	|	当把DataFrame保存到一个数据源的时候，如果数据已经存在，那么该选项不会保存DataFrame中的内容，并且不会改变已存在的数据。这与SQL中的CREATE TABLE IF NOT EXIST类似|

#### 存储为持久化表格

当使用HiveContext时，DataFrames可以通过saveAsTable命令保存为持久化表格。与registerTempTabel命令不同的地方在于，saveAsTabel将固化dataframe中的内容，并且在HiveMetastore中创建一个指向数据的指针。持久化表格将一直存在，直到你的Spark程序重启，你只需维持到该metastore的连接即可。为dataframe创建持久化表格只需调用SQLContext的table方法，并传入表格的名字。

默认的saveAsTable方法将会创建一张“managed table”，这意味着由metastore来控制数据的位置。Managed talbe 将会在表被删除时自动删除它们的信息。

### Parquet文件


Parquet是一种被很多数据处理系统所支持的列状数据格式。Spark SQL提供了对Parquet文件的读写支持，这样可以自动保留原始数据的schema信息。当写parquet文件时，出于兼容性的考虑，所有的列都被自动转化为可为空的类型。

#### 编程加载数据

使用之前样例中的数据：


```
// sqlContext from the previous example is used in this example.
// This is used to implicitly convert an RDD to a DataFrame.
import sqlContext.implicits._

val people: RDD[Person] = ... // An RDD of case class objects, from the previous example.

// The RDD is implicitly converted to a DataFrame by implicits, allowing it to be stored using Parquet.
people.write.parquet("people.parquet")

// Read in the parquet file created above. Parquet files are self-describing so the schema is preserved.
// The result of loading a Parquet file is also a DataFrame.
val parquetFile = sqlContext.read.parquet("people.parquet")

//Parquet files can also be registered as tables and then used in SQL statements.
parquetFile.registerTempTable("parquetFile")
val teenagers = sqlContext.sql("SELECT name FROM parquetFile WHERE age >= 13 AND age <= 19")
teenagers.map(t => "Name: " + t(0)).collect().foreach(println)
```

#### 分区发现


表格分区是诸如Hive等系统中普遍的优化方法。在一个分区的表中，数据被存放在不同的目录下，分区的列值被编码在了分区目录的路径中。Parquet数据源现在可以自动发现和推测分区信息。例如，我们可以将之前使用的人口数据存储为分区表，它的目录结构如下所示，有两个额外的列，性别和国籍是分区的列：


```
path
└── to
    └── table
        ├── gender=male
        │   ├── ...
        │   │
        │   ├── country=US
        │   │   └── data.parquet
        │   ├── country=CN
        │   │   └── data.parquet
        │   └── ...
        └── gender=female
            ├── ...
            │
            ├── country=US
            │   └── data.parquet
            ├── country=CN
            │   └── data.parquet
            └── ...
```

将'path/to/table'传递给'SQLContext.read.parquet'或者'SQLContext.read.load'，Spark SQL可以自动从路径中提取分区信息。这样，DataFrame的schema信息如下所示：


```
root
|-- name: string (nullable = true)
|-- age: long (nullable = true)
|-- gender: string (nullable = true)
|-- country: string (nullable = true)
```

注意分区列的数据类型会被自动推测，目前支持数值类型和字符串类型。有些时候用户可能并不希望自动推测分区列的类型，对于这种情况，可以通过'spark.sql.sources.partitionColumnTypeInference.enabled'来配置，默认为'true'。当关闭自动推测类型后，分区列的类型被统一为字符串类型。

从Spark1.6开始，分区发现功能默认只会给定路径进行分区寻找。对于上述例子，如果用户传递'path/to/table/gender=male'给'SQLContext.read.parquet'或'SQLContext.read.load'，那么gender将不会被视作分区列。如果用户需要指定分区发现开始的基准路径，他们可以设置数据源选项中的basePath。例如，当' path/to/table/gender=male'作为数据的路径并设置basePath为'path/to/table/'时，gender将会是分区列。

#### Schema合并

与ProtocolBuffer, Avro以及Thrift类似，Parquet支持schema的演变。用户最初可以简单的schema开始，逐渐增加一些schema需要的列进去。通过这种方法，用户最终可以得到schema不同但是互相兼容的多个parquet文件。parquet数据源现在可以自动检测并且合并这些文件的schema信息。

因为schema合并是相对消耗资源的操作，在绝大多数场景下是不需要的，因此从1.5.0开始默认关闭该功能。你可以通过以下操作开启它：

1.	在读取parquet文件时设置数据源选项'mergeSchema'为true，或者
2.	设置全局SQL选项'spark.sql.parquet.mergeSchema'为true


```
// sqlContext from the previous example is used in this example.
// This is used to implicitly convert an RDD to a DataFrame.
import sqlContext.implicits._

// Create a simple DataFrame, stored into a partition directory
val df1 = sc.makeRDD(1 to 5).map(i => (i, i * 2)).toDF("single", "double")
df1.write.parquet("data/test_table/key=1")

// Create another DataFrame in a new partition directory,
// adding a new column and dropping an existing column
val df2 = sc.makeRDD(6 to 10).map(i => (i, i * 3)).toDF("single", "triple")
df2.write.parquet("data/test_table/key=2")

// Read the partitioned table
val df3 = sqlContext.read.option("mergeSchema", "true").parquet("data/test_table")
df3.printSchema()

// The final schema consists of all 3 columns in the Parquet files together
// with the partitioning column appeared in the partition directory paths.
// root
// |-- single: int (nullable = true)
// |-- double: int (nullable = true)
// |-- triple: int (nullable = true)
// |-- key : int (nullable = true)
```



#### Hive metastore Parquet table转化


当读写Hive metastore Parquet table时，Spark SQL使用的是自带的Parquet支持，而不是Hive SerDe，这样可以获得更好的性能。可以通过配置'spark.sql.hive.convertMetastoreParquet'来配置这一功能，默认开启。


##### Hive/Parquet Schema Reconciliation

从表schema处理的角度来看，Hive和Parquet有两个关键区别：

1.	Hive不区分大小写，而Parquet区分
2.	Hive中的所有列都是可空的，而为空性对于Parquet是有意义的

由于这个原因，当Hive metastore Parquet talbe转换为Spark SQL Parquet table时我们必须使Hive metastore schema和Parquet schema保持一致。一致的规则如下：


1.    schema中对于相同名字的字段必须属于相同的数据类型，忽略为空性(nullability)。一致的字段必须在Parquet中含有对应的数据类型，同时nullability得到了保证。
2.    为了保证一致性，schema中只包含Hive metastore schema中定义的如下字段：
    *    在一致的schema中，只出现在Parquet schema中的字段被丢弃。
    *    在一致的schema中，只出现在Hive metastore schema中的字段被添加为可空字段。
    
##### 更新metadata

Spark SQL出于性能的考虑会缓存Parquet metadata。当Hive metastore Parquet table转换被开启，这些被转化的表的metadata也会被缓存。当Hive或其他外部工具更新了这些表时，你必须手动更新它们来保证一致的metadata。

```
// sqlContext is an existing HiveContext
sqlContext.refreshTable("my_table")
```

#### 配置

Parquet的配置可以通过SQLContext的setConf方法或SQL的'SET key=value'命令来配置。

点击[http://spark.apache.org/docs/latest/sql-programming-guide.html#configuration](http://spark.apache.org/docs/latest/sql-programming-guide.html#configuration)查看配置参数信息。

### JSON数据集

Spark SQL可以自动推断JSON数据集的schema信息，进而加载为DataFrame。这种转化可以从String类型的RDD或JSON文件通过'SQLContext.read.json()'来完成。

注意，提供的json文件并不是一般意义上的Json文件，每一行都必须包含一个自定义的独立合法的JSON对象。因此，一个普通的多行JSON文件通常会加载失败。

```
// sc is an existing SparkContext.
val sqlContext = new org.apache.spark.sql.SQLContext(sc)

// A JSON dataset is pointed to by path.
// The path can be either a single text file or a directory storing text files.
val path = "examples/src/main/resources/people.json"
val people = sqlContext.read.json(path)

// The inferred schema can be visualized using the printSchema() method.
people.printSchema()
// root
//  |-- age: integer (nullable = true)
//  |-- name: string (nullable = true)

// Register this DataFrame as a table.
people.registerTempTable("people")

// SQL statements can be run by using the sql methods provided by sqlContext.
val teenagers = sqlContext.sql("SELECT name FROM people WHERE age >= 13 AND age <= 19")

// Alternatively, a DataFrame can be created for a JSON dataset represented by
// an RDD[String] storing one JSON object per string.
val anotherPeopleRDD = sc.parallelize(
  """{"name":"Yin","address":{"city":"Columbus","state":"Ohio"}}""" :: Nil)
val anotherPeople = sqlContext.read.json(anotherPeopleRDD)
```

### Hive表

Spark SQL支持读写Apache Hive中的数据。然而，因为Hive的依赖很多，它不被包含在默认的Spark集合中。通过在编译Spark的时候增加 -Phive 和 -Phive-thriftserver标志位，可以提供对Hive的支持。这个命令会编译生成一个新的包含hive的jar包。注意，这个hive的jar包在worker节点上也必须存在，因为在访问hive数据的时候需要调用hive的序列化和反序列化库（SerDes）。

配置Hier需要在‘conf/’下包含'hive-site.xml','core-site.xml'(安全性配置),'hdfs-site.xml'(HDFS配置)这几个文件。当在YARN集群（cluster模式）上执行查询时，driver和yarn集群下的所有executor都必须包含lib中的datanucleus包和conf中的hive-site.xml文件。最便捷的方式是在执行spark-submit命令的时候通过--jars参数和--file参数添加它们。

如果要使用Hive，必须创建HiveContext，继承自SQLContext，同时增加了从MetaStore中查找表格的支持，以及使用HiveQL来完成查询。即使没有部署Hive，依然可以创建HiveContext。如果没有通过hive-site.xml配置，那么context将自动在当前目录下创建metastore_db，同时根据HiveConf创建warehouse目录。注意，你必须保证启动Spark应用的人在/user/hive/warehouse下有写权限。

```
// sc is an existing SparkContext.
val sqlContext = new org.apache.spark.sql.hive.HiveContext(sc)

sqlContext.sql("CREATE TABLE IF NOT EXISTS src (key INT, value STRING)")
sqlContext.sql("LOAD DATA LOCAL INPATH 'examples/src/main/resources/kv1.txt' INTO TABLE src")

// Queries are expressed in HiveQL
sqlContext.sql("FROM src SELECT key, value").collect().foreach(println)
```

#### 与不同版本的Hive Metastore交互

Spark SQL对Hive支持最终要的一个方面就是与Hive metastore交互，允许Spark SQL访问Hive表的metadata。从Spark 1.4.0开始，Spark SQL的二进制版本可以通过如下描述的配置来查询不同版本的Hive metastore。Hive的独立版本可以用来连接metastore，Spark SQL内部使用Hive1.2.1，并且使用这些类来完成内建执行操作(serdes, UDFs, UDAFs, etc)。

[这些选项](http://spark.apache.org/docs/latest/sql-programming-guide.html#interacting-with-different-versions-of-hive-metastore)用来配置检索metadata的hive版本。

### JDBC访问其他数据库

Spark SQL包含可以通过JDBC从其他数据库读取数据的数据源。相较于jdbcRDD更推荐使用该功能。这是因为结果以DataFrame的形式返回，并且易于被SparkSQL处理或与其他数据源结合。 JDBC数据源对于java或python也很好用，因为他不需要用户提供ClassTag。（这与Spark SQL JDBC server 是不同的，后者允许其他应用通过Spark SQL执行查询）。

在开始使用之前，你需要在spark classpath中包含你所访问的特定数据库的JDBC驱动。例如，为了从Spark Shell连接postgres，你需要运行如下命令：

```
SPARK_CLASSPATH=postgresql-9.3-1102-jdbc41.jar bin/spark-shell
```

远程数据库的表可以通过Data Sources API加载为DataFrame或Spark SQL临时表。支持这些[参数](http://spark.apache.org/docs/latest/sql-programming-guide.html#jdbc-to-other-databases)。

```
val jdbcDF = sqlContext.read.format("jdbc").options(
  Map("url" -> "jdbc:postgresql:dbserver",
  "dbtable" -> "schema.tablename")).load()
```

### 常见问题

*    JDBC驱动必须对连接客户端和所有的executors的原始类加载器课件。这是因为当你去建立一个连接的时候，java的DriverManager类会进行安全检查，这会导致它忽略所有对原始类加载器不可见的驱动。解决这个问题的一种方便的办法就是在所有worker节点上修改compute_classpath.sh来包含驱动的jar包。
*    一些数据库，如H2，所有的名字都是大写。你需要使用大写字母来在Spark SQL中指定这些名字。

## 性能调优

对于一些工作来说，是可以通过把数据cache到内存或者开启实验选项来提高性能的。

### 数据缓存到内存

Spark SQL 可以通过调用sqlContext.cacheTable("tableName")或dataFrame.cache()的方式将数据表以内存列格式缓存在内存中。Spark就可以只扫描需要的列并且会自动调整压缩及GC压力。你可以通过调用sqlContext.uncacheTable("tableName")将内存中的表移除。

可以通过SQLContext的setConf方法及SQL的'SET key=value'命令来配置内存缓存配置。

[配置选项](http://spark.apache.org/docs/latest/sql-programming-guide.html#caching-data-in-memory)

### 其他配置选项


下面的这些选项也可以用来提高查询性能。不过未来版本发布后，很多优化会自动进行，这些选项有可能弃用。

[配置选项](http://spark.apache.org/docs/latest/sql-programming-guide.html#other-configuration-options)

## 分布式SQL引擎

通过JDBC/ODBC或者命令行接口，Spark SQL可以充当一个分布式查询引擎。在这种模式下，终端用户或者应用可以与Spark SQL直接交互来运行SQL查询，不需要写额外的代码。

### 运行Thrift JDBC/ODBC server

这里实现的JDBC/ODBC server与Hive 1.2.1中的HiveServer2相对应。你可以使用Spark或Hive 1.2.1中的beeline脚本对JDBC server进行测试。

在Spark目录中运行如下命令启动JDBC/ODBC server：

```
./sbin/start-thriftserver.sh
```

这个脚本接受bin/spark-submit命令行的所有参数，以及一个--hiveconf参数来指定hive的属性。你可以通过运行 ./sbin/start-thriftserver.sh --help来查看完整的参数帮助。server默认监听localhost:10000端口。你可以通过修改环境变量来覆盖这一默认设置：

```
export HIVE_SERVER2_THRIFT_PORT=<listening-port>
export HIVE_SERVER2_THRIFT_BIND_HOST=<listening-host>
./sbin/start-thriftserver.sh \
  --master <master-uri> \
  ...
```

也可以通过系统属性来修改这一默认设置：

```
./sbin/start-thriftserver.sh \
  --hiveconf hive.server2.thrift.port=<listening-port> \
  --hiveconf hive.server2.thrift.bind.host=<listening-host> \
  --master <master-uri>
  ...
```

然后，你可以通过beeline脚本来测试Thrift JDBC/ODBC server：


```
./bin/beeline
```

在beeline中，通过如下方式连接JDBC/ODBC server:

```
beeline> !connect jdbc:hive2://localhost:10000
```

Beeline将会向你询问用户名和密码。在non-secure模式下，只需要出入你机器的用户名和空密码即可。在secure模式下，你需要按照[beeline 文档](https://cwiki.apache.org/confluence/display/Hive/HiveServer2+Clients)中的指示进行操作。

将 hive-site.xml, core-site.xml和hdfs-site.xml放置在conf/下即可完成hive的配置。

你也可以使用Hive中的beeline脚本。

Thrift JDBC server 也支持通过HTTP发送thrift RPC消息。使用系统属性或hive-site.xml文件中的如下设置来开启HTTP模式：

```
hive.server2.transport.mode - Set this to value: http
hive.server2.thrift.http.port - HTTP port number fo listen on; default is 10001
hive.server2.http.endpoint - HTTP endpoint; default is cliservice
```

为了测试，使用beeline连接http模式下的JDBC/ODBC server:

```
beeline> !connect jdbc:hive2://<host>:<port>/<database>?hive.server2.transport.mode=http;hive.server2.thrift.http.path=<http_endpoint>
```

### 运行Spark SQL CLI

Spark SQL CLI 是一个便捷的工具来在本地模式下运行hive metastore serveice同时执行来自命令的查询输入。注意，Spark SQL CLI不能与Thrift JDBC server对话。

在Spark目录下执行如下命令来启动Spark SQL CLI:

```
./bin/spark-sql
```

将 hive-site.xml, core-site.xml和hdfs-site.xml放置在conf/下即可完成hive的配置。你可以运行./bin/spark-sql --help来获取全部可用的参数帮助。
