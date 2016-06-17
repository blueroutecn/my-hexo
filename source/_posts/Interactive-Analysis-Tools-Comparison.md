---
mathjax: true
title: 交互式分析工具的比较
date: 2016-06-17 09:44:50
categories: MLP
tags: [MLP]
---

说明：译自[Interactive Analysis Tools Comparison: R Language, Matlab, esProc, SAS, SPSS, Excel, and SQL](http://www.smartdatacollective.com/raqsoft/78711/interactive-analysis-tools-comparison-r-language-matlab-esproc-sas-spss-excel-and-sql)

交互式分析是指由提出假设、验证假设和分析校准组成的环形过程，用来实现模糊计算的目标。更多的细节可以参考另一篇文章：[交互分析和相关工具]()。

对于交互式分析有很多工具，有些工具并不是所有人都了解，这里将主要比较以下7个工具：R、Matlab、esProc、SAS、SPSS、Excel以及SQL。这些工具和语言各有千秋。实际上，笔者认为还有一些很好的工具，比如BMDP、Eview、Stata、S-Plus、Octave、Scilab、Mathematica以及minitab，只列举了一些。这些将在其他文章中讨论。

在比较交互式工具的过程中，会考虑典型性和相关性。笔者使用5个度量指标，每个指标中评分为5为最高级。某个工具的某个指标获得的★越多，该工具在这方面拥有越明显的优势。

例如：

*	UI友好性：★越多，界面越友好，操作越方便。
*	技术能力要求：★越多，数学算法和编程基础要求越低
*	分步计算：★越多，越容易分解并解决复杂问题
*	结构化数据支持性：★越多，越容易对结构化数据进行分析
*	内嵌算法：★越多，内嵌算法越多，功能越强大

这五个衡量指标肯定不能衡量交互式工具的方方面面，也没有涉及所有的交互式分析工具。在实际的使用过程中，有很多的指标需要考虑，这里我们只考虑其中一部分，剩余的会在以后提及，例如：价格、文档数量、售后服务、稳定性和鲁棒性、运算速度、数据量、并发计算能力、输入输出文件格式、二次开发接口、平台可移植性以及多方协作能力。

## SQL

准确地讲，SQL或结构化查询语言并不是一个工具。SQL由E.F.Codd提出，IBM实现，并且现在是一个ANSI和ISO标准的计算机语言。它被大多数厂商所支持，用户查询和分析结构化数据，例如：Oracle, DB2, SQL Server, Sybase, Informix, MySQL, VF, Access, Firebird, 以及sqlite。这些厂商的语法互不兼容。

SQL用户最多，拥有最广泛的平台支持。SQL的语法接近自然语言，编程者们很容易学会。但是，另一方面，SQL的确定也是显而易见的，例如：易学但是难以掌握并进行数据分析。SQL的嵌套查询可以用来实现分步计算，但是它很难实现树状的易分解和复用的分步计算，R语言和其他工具可以做到这一点。另外，SQL缺乏Matlab或其他工具中的面向定量的函数。如果要执行复杂的计算，SQL用户需要重排序已有的由其他编程人员开发的功能，这需要强大的编程功底。SQL也缺乏基于对象的访问模式（esProc和替他工具可以），多表的join操作对于SQL用户来说也显得相对复杂，不利于业务分析以及从业务的角度来分析问题。

*	UI友好性: ★☆☆☆☆
*	技术能力要求: ★☆☆☆☆
*	分步计算: ★☆☆☆☆
*	结构化数据支持性: ★★★★★
*	内嵌算法: ★☆☆☆☆
*	目标用户：程序员，数据库管理人员

## Excel

Excel是微软开发的商务应用。它有直观的界面，出色计算能力和完备的图表工具。另外通过内嵌VBA，Excel更加灵活多变。每个人都可以用它来满足公司、企业等任意工作场合的需求。

Excel的特定是用户友好性。Excel用户可以命令单元格中的变量，而且不需要像SAS或者其他工具一样命名。Excel自然对齐，省去了排版的工夫。Excel允许调用其他单元和自动计算，还能分步计算。然而在另一方面，Excel的普遍性使得Excel的特色较少。第一个单元格为最小单位，使得Excel对结构化数据的支持并不是很好。函数的功能较为简单，Excel语法的表现性较差，不能处理复杂数据分析和专门的科学计算。


*	UI友好性: ★★★★★
*	技术能力要求: ★★★★★
*	分步计算: ★★★★☆
*	结构化数据支持性: ★☆☆☆☆
*	内嵌算法: ★★☆☆☆
*	目标用户：金融人员，不需要技术背景的人

## R

R语言由Ross Ihaka 和 Robert Gentleman在奥克兰大学创建。它是开源的开发语言，跨平台运行。R语言是面向对象的程序设计风格，有非常好的表格绘制能力、内置统计和数学分析功能。R最大的应用领域是生物信息研究，也应用在金融经济、人文研究等领域。

R语言的最大特点是其是开放的（Free）。R是开源的项目，由统计学家和数学家维护。另外，它的语法简洁优雅，拥有二次开发接口，因此有大量的第三方应用包。但是R缺乏优秀的UI界面。使用R要求较强的技术背景。

*	UI友好性: ★☆☆☆☆
*	技术能力要求: ★★☆☆☆
*	分步计算: ★★★★☆
*	结构化数据支持性: ★★★☆☆
*	内嵌算法: ★★★★☆
*	目标用户：统计学家，数学家，科研人员

## Matlab

Matlab是MathWorks公司开发的商业应用。它是用于数值计算、算法开发和数据分析的交互式计算环境和第四代编程语言。你可以使用它来绘制图表和创建用户界面。Matlab在工业自动化设计和分析以及图像处理、信号处理、通信、金融建模分析等领域广泛使用。

与R类似，Matlab也有很好的扩展性。它提供类似于工具箱的功能给用户，可以审核、编辑和分享它的扩展功能。尽管Matlab的第三方应用不如R多，Matlab可以提供更高品质的管理以及更加强大的功能。另外，考虑到他的图形操作界面，Matlab要比R有更强的优势。


*	UI友好性: ★★☆☆☆
*	技术能力要求: ★★☆☆☆
*	分步计算: ★★★★☆
*	结构化数据支持性: ★★★☆☆
*	内嵌算法: ★★★★☆
*	目标用户：工程师，统计学家

## esProc

esProc是RAQSOFT公司开发的商业桌面应用，专门针对结构化数据的交互分析。esProc自由的数据分析，要求相对低的技术能力。它有很强的灵活性和易于使用的语法体系。因此，esProc被技术背景相对较弱的公司所广泛采纳，包括绝大多数商业用户，以及工业和金融部门的一些用户。

esProc最鲜明的特点是Excel风格的分析界面。这意味着esProc可以实现复杂的或者需要分步计算的任务。基于功能丰富的结构化数据，esProc在很多方面强过SQL。然而，esProc缺乏内嵌算法和一些特定行业的功能需求，如相关分析和回归分析。


*	UI友好性: ★★★★☆
*	技术能力要求: ★★★★☆
*	分步计算: ★★★★★
*	结构化数据支持性: ★★★★★
*	内嵌算法: ★☆☆☆☆
*	目标用户：商业数据分析、非专业统计人员、金融分析
*	官网：[http://www.raqsoft.com/products](http://www.raqsoft.com/products)

## SAS


SAS是SAS研究院开发的商业应用。它是用于决策制定的大型信息系统。SAS系统对数据要求复杂而严格，用户学习困难。不过从另一方面来看，它具有高精度和可信度。SAS主要应用在自然科学、经济决策和企业决策。SAS产品被各个领域广泛使用。

SAS的库函数非常多并且拥有针对各个行业的非常强大的绘图能力。虽然用户界面已经改善许多，SAS与其他分析软件相比还是不够友好。

*	UI友好性: ★★☆☆☆
*	技术能力要求: ★☆☆☆☆
*	分步计算: ★★★★☆
*	结构化数据支持性: ★★★★☆
*	内嵌算法: ★★★★★
*	目标用户：统计学家，金融专家，政府，跨国公司
*	官网：[http://www.sas.com
](http://www.sas.com
)

## SPSS

SPSS以及PASW是IBM开发的商业应用，主要应用在统计分析、数据挖掘已经决策支持方面。SPSS除了提供友好的用户界面用来分析，还有一组常见和成熟的统计程序可以用来满足大多数非专业统计人员的工作要求。SPSS主要应用在通信、医药、金融和社会科学领域。事实上，SPSS是最广泛使用的专业分析工具之一。

SPSS致力于打造最易于使用的统计程序。因此，SPSS有强大的用户界面易于初学者掌握。与其他编程语言的语法相比，SPSS的语法较差，而且不能自由的分析而是由固定的算法完成。菜单式的界面也是分步计算的一个重要障碍。

*	UI友好性: ★★★★☆
*	技术能力要求: ★★★★☆
*	分步计算: ★★☆☆☆
*	结构化数据支持性: ★★★☆☆
*	内嵌算法: ★★★☆☆
*	目标用户：商业数据分析、非专业统计人员、经济分析师
*	官网：[http://www-01.ibm.com/software/analytics/spss/](http://www-01.ibm.com/software/analytics/spss/)

结论：

R通常用于一般的科学计算以及交互分析。但是R的用户界面非常简陋而且技术要求较高。Matlab要比R简介，通常用于工业设计。Matlab中的一些算法比R要优秀而且更加可依赖。esProc用于典型的商业计算，并且足够强大可以提供友好的界面来处理交互分析，对用户的技术背景要求较低。但是esProc缺乏科学领域的一些固定算法。SAS与R类似，在金融决策和自然科学领域有足够的能力来完成交互分析。SAS的界面也非常简单，因此对使用者的技术背景要求较高。SPSS最广泛的应用是在社会科学领域，使用简单并且功能强大，但是处理复杂交互分析不够灵活。作为商业应用的基础，SQL几乎不能处理交互分析而且非常复杂。Excel被大家广泛用户处理日常office工作，可以处理简单的交互分析，但是不能用于专业问题。
