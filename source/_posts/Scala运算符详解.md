---
mathjax: true
title: Scala运算符详解
date: 2016-01-09 22:11:30 2016
categories: Scala
tags: [Scala]
---

## 运算符的本质

在Scala中，真正的运算符只有直接赋值运算符（<em>=</em>），其他的的运算符其实都是方法(函数)。

```
val a = 1 + 2     // 等价于 1.+(2)
val b = 1 + 2 * 3 // 等价于 1.+(2.*(3))
```

## 运算符的重载

Scala中的运算符重载很简单，不需要多余的关键字，只要把运算符放在方法名的位置上就好了：

```
class MyClass(val x: Int) {
  def +(o: MyClass) = new MyClass(x + o.x)
  def *(o: MyClass) = new MyClass(x * o.x)

  override def toString: String = {
    x.toString
  }
}

object MyClass {

  def main(args: Array[String]) {
    val o1 = new MyClass(2)
    val o2 = new MyClass(3)

    println(o1 + o2)
    println(o1 * o2)
  }
}
```

重载运算符可以是任意长度，但是只能由符号或者字母中的一类构成（<em>$</em>和<em>_</em>算作字母）。比如<em>&lt;:&lt;</em>是合法的，但是<em>&lt;a&lt;</em>是不合法的。

###	前缀运算符

前缀运算符只支持四种：<em>~!+-</em>，分别用<em>unary_</em>作为前缀来定义：

```
class MyClass(val x: Int) {
  def unary_+ = new MyClass(x)
  def unary_- = new MyClass(-x)

  override def toString: String = {
    x.toString
  }
}

object MyClass {

  def main(args: Array[String]) {
    val o = new MyClass(2)

    println(+o)
    println(-o)
  }
}
```

###	后缀运算符
</h3>

<p>
	后缀运算符支持并非默认开启，如果使用时不注意很容易编译不通过或者产生语义问题，实际中也较少使用到，所以在此不做过多说明。
</p>


##	运算符的调用方向

前缀运算符调用方向从右至左，后缀运算符从左至右。对于中缀运算符，Scala做了一个规定：以<em>:</em>结尾的运算符为从右至左调用，其他的运算符从左至右调用。


对于<em>+</em>，以下表达式是等价的：

```
a +: b +: c
a +: c.+:(b)
c.+:(b).+:(a)
```

也就是说，从右至左调用的运算符会将右边的对象作为调用方法的对象，同时同等优先级下最右侧的运算符先执行，反之亦然。


##	运算符的优先级

运算符的优先级是由第一个字符的优先级决定的，键盘上可以输入，且不是语法要素的符号的优先级见下表：

<table>
<tbody>
<tr><td>优先级</td><td>	运算符首字母</td><td>	备注</td></tr>
<tr><td>1</td><td>	~，@，#，?，\	 </td><td> Java中不会出现的符号</td></tr>
<tr><td>2</td><td>	*，/，%	</td><td> 乘除法</td></tr>
<tr><td>3</td><td>	+，-	 </td><td> 加减法</td></tr>
<tr><td>4</td><td>	:	</td><td></td></tr>
<tr><td>5</td><td>	&lt;，&gt;	 </td><td>移位运算符和比较运算符</td></tr>
<tr><td>6</td><td>	!，=	 </td><td> 等于和不等于</td></tr>
<tr><td>7</td><td>	&amp; </td><td>	与运算符 </td></tr>
<tr><td>8</td><td>	^ </td><td>	异或运算符 </td></tr>
<tr><td>9</td><td>	| </td><td>	或运算符 </td></tr>
<tr><td>10</td><td>	$，_，英文字母 </td><td>	$和_是可以写入标识符的符号，和上面的符号有本质区别 </td></tr>
</tbody>
</table>

特别注意以下几点：

1.	前缀运算符高于所有中缀运算符。
2.	以<em>=</em>结尾而又不以<em>=</em>开始的运算符会被当做赋值运算符而优先级低于以上所有运算符。
3.	第一个字符相同的运算符优先级相同，从左至右依次执行（以<em>:</em>结尾的从右向左依次执行）。
	

对于第三点请参照以下程序及运行结果进行理解：

```
// 程序
class MyClass(val x: Int) {
  def :*(o: MyClass) = new MyClass(x * o.x)
  def :+(o: MyClass) = new MyClass(x + o.x)

  override def toString: String = {
    x.toString
  }
}

object MyClass {

  def main(args: Array[String]) {
    val o1 = new MyClass(2)
    val o2 = new MyClass(3)
    val o3 = new MyClass(4)

    println(o1 :+ o2  :* o3)
    println(o1 :* o2  :+ o3)
  }
}

// 运行结果
20
10
```
