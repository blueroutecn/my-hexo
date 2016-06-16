---
mathjax: true
title: CodaLab Worksheets教程
date: 2016-06-16 17:40:13
categories: MLP
tags: [MLP]
---


## 概述

CodaLab是一个为了再现实验成果的协作平台。它有如下功能：

*    基于集群运行实验
*    分享实验
*    方便的追查之前的实验

CodaLab的理念在于它可以帮你掌控实验的整个过程，而你不需要关心这些事情。它记录了实验之间的依赖结构以及执行的过程。一个很好的比喻是Git：你可以向你的仓库中随意增删文件，它帮助你维护修订的历史信息。

CodaLab的主要接口是通过Codalab命令：上传、删除、添加、执行等。这些命令可以通过web终端(网页顶部)，对于喜欢shell环境的人也可以通过命令行界面(CLI)。

## 快速使用

### 上传bundles

创建`a.txt`，内容如下：

```
foo
bar 
baz
```

创建 `sort.py`，内容如下：

```
import sys
for line in sorted(sys.stdin.readlines()):
	print line,
```

#### Web界面

点击面板右侧的`Upload Bundle`按钮上传两个文件（如果需要上传目录，需要先压缩目录，生成zip文件）。

bundle被上传后，会追加到当前的worksheet中，作为表中的一行。每个bundle有一个32位的字符串UUID，作为唯一标识。在右侧面板中可以编辑它的meta信息（名字，描述等）。

#### CLI.(终端)

也可以通过终端命令行上传文件：

```
cl upload a.txt 
cl upload sort.py
```

通过如下命令编辑meta信息：

```
cl edit a.txt
```

列举已上传的bundles：

```
cl ls
```

查看指定bundle的meta信息：

```
cl info -v a.txt
```

`a.txt`和`sort.py`分别是数据和程序，从CodaLab的角度来看，他们均属于bundles。

### 运行命令

上传了一些bundles之后，可以执行一些命令。CodaLab允许你运行任意的shell命令，同时每个命令都会创建一个bundle来封装运算。

为了创建首个run bundle，在CodaLab 命令行中输入如下内容：

```
cl run sort.py:sort.py input:a.txt 'python sort.py < input' -n sort-run
```

上述命令会在当前的worksheet中新增一个名为`sort-run`的bundle。等待几秒钟后，面板右侧会出现运行结果。如果没有，请通过`shift-r`刷新worksheet。

<center>![运行命令](img/CodaLab-Worksheets教程/run-cmd.png)</center>

让我们来看看它是如何运转的。`cl run`的前两个参数指明了依赖，第三个参数是运行命令，运行在当前的依赖上。

CodeLab会捕获写入当前目录的所有文件及目录，以及stdout和stderr。这些形成了新建run bundle的内容。当命令 终止的时候，bundle的内容被锁定为固定内容。

一般来说，一个CodaLab的run命令可以有任意多个依赖，也可以没有依赖。每个依赖使用如下的形式指定：

```
<key>:<target>
```

target可以是一个bundle（例如a.txt），也可以是一个目录作为bundle，或者bundle中的一个目录或者文件（例如a.txt/file1）。当命令（例如`python sort.py < input`）被执行的时候，是在一个（临时的）目录完成的，这个目录中有一个只读的文件/目录名为\<key\>内容为\<target\>。运行时会向当前目录写入内容来填充bundle。

真实执行是在一台worker机器的`docker container`中进行的，你也可以指定需要的linux环境（提供需要的库和软件包）。如果你想要知道当前环境的配置，可以通过以下命令：

```
cl run 'python --version'
cl run 'uname -a'
cl run 'cat /proc/cpuinfo'
...
```

container运行时默认使用`Ubuntu Linux 14.04 画像`，它包含了一些标准的库，你也可以使用其他人或者自己创建的画像，通过 `--request-docker-image`来指定画像。

每个run bundle有`state`meta信息字段，它有如下取值：

*    `created`: 初始状态
*    `staged`: 依赖的bundles处于ready状态
*    `running`: worker在初始化执行环境或者命令正在执行
*    `ready`: 执行完毕，返回值为0（成功）
*    `failed`: 执行完毕，返回值非0或发生其他错误（失败）

你可以把当前的worksheet当做你的当前目录，在这里你可以在已有bundles的基础上执行命令并生成新的bundle。有两点不同：

1.    你必须明确知道你需要的依赖。CodaLab只会根据你明确指明的依赖来运行你的命令。
2.    如果你的命令输出在当前目录，这些文件或者目录包含在run bundle中。因此，后续的命令必须指明run bundle来引用它们。例如：

```
cl run 'echo hello > message' -n run1
cl run :run1/message 'cat message'     # right
cl run :message      'cat message'     # wrong
```

你可以并行执行任务，而且一个任务可以依赖于之前未完成的任务。因为CodaLab了解依赖关系，它会等待某个任务依赖的任务执行结束之后才会开始运行。

### 展现你的结果

迄今为止，你的worksheet只包含一张每行一个bundle的默认表。不过我们可以自定义这个视图来更好的展现我们的结果。点击`Edit Source`按钮来编辑worksheet，或者在命令行中执行如下命令：

```
cl wedit
```

然后你会进入一个文本编辑界面，在这个界面中你可以使用`CodaLab markdown`格式自由的编辑worksheet。CodaLab markdown是MD语言的扩展，允许你捆绑bundles和格式化指令。

例如，你可以编辑你的worksheet为如下形式（你的worksheet会显示不同的UUID）：

```
This is my **first** [CodaLab worksheet](https://worksheets.codalab.org).
I uploaded some bundles:
[dataset a.txt]{0x34a1fa62acc840ec96da98f17dbddf66}
[dataset sort.py]{0xf9fc733b19894eb2a97f6b47f35d7ea0}
Here's my first CodaLab run:
% display table name command /stdout time
[run sort-run -- :sort.py,input:a.txt : python sort.py < input]{0x08908cc6cb594b9394ed7ba6a0bd25f6}
```

`% display table ...`指令告诉CodaLab将bundle渲染为指定列的表形式。例如，`/stdout`列告诉CodaLab来显示bundle的`stdout`文件中的内容。这个自定义格式在你监视多个run的时候是非常有用的，你可以打印各种指标比如时间、准确度、迭代次数等。

需要注意的是，worksheet仅仅是bundle图的视图，`run sort-run ...`这些行是指向bundle的指针。因此，你可以重新排序、删除、复制worksheet中的bundles，可以在worksheet之间移动和复制bundle，就像编辑文本一样。

删除bundle的引用并不会真正删除bundle。如果要删除一个真实的bundle，需要运行如下命令：

```
cl rm sort.py
```

### 总结

到这里位置，你掌握了上传代码和数据来扩充bundles，运行命令来处理数据，使用不同的参数来运行算法，使用CodaLab来管理你的run。使用CodaLab markdown来创建worksheet来给你为你的实验生成文档（公共/私有）。

可以用如下命令来获取更多的信息：

```
cl help     # Print out the list of all commands
cl help rm  # Print out usage for a particular command
```