---
mathjax: true
title: 'Codeforces#551C GukiZ hates Boxes'
date: 2015-06-11 13:31:53
categories: ACM解题报告
tags: [Codeforces, 二分, 解题报告, 贪心]
---

<meta http-equiv=Content-Type content="text/html;charset=utf-8">


##	题目来源

[Codeforces Round #307 (Div. 2) C. GukiZ hates Boxes](http://codeforces.com/problemset/problem/551/C)

##	题目类型

二分，贪心

##	问题描述

有n堆盒子（n<=10^5），m个人（m<=10^5）。n堆盒子从左到右依次排列，它们的位置分别对应坐标轴的1~n，个数分别为a[1],a[2],a[3],...,a[n]（a[i]<=10^9）。m个人初始时刻均位于坐标轴的原点。现在要求控制这m个人（m个人可以同时行动并做不同的事情），摧毁所有的盒子。控制的规则如下：

1.	从坐标的i位置移动到j位置，需要花费|j-i|的时间。
2.	每个人摧毁一个盒子需要花费1个单位时间，一个盒子只能被一个人摧毁。
	
求解摧毁所有盒子需要花费的最少时间。

##	解题思路

花费的时间可能很大，所以打算采用二分来逼近答案。接下来，问题就变成了：给定一个时间time，判断要这个时间内完成，需要多少个人。

转移出来的这个问题可以用贪心的办法解决：首先看最远的那堆盒子需要多少人来摧毁：ceil((time-n)/a[i])，如果这些人摧毁了最后一堆盒子之后还剩余一些时间可以摧毁别的盒子，那么就用剩余的时间去摧毁紧挨着最后一堆的之前的盒子。然后，再去判断之前一堆的盒子需要多少人来摧毁，如此类推。

通过以上的方法，就可以知道给定时间time的情况下，最少需要多少个人来摧毁所有的盒子，与m比较大小，即可知道是否可行。然后二分查找，问题得解。

##	思路补充

感谢<font color="#FF0000">Lik</font>的提问，经过证明发现<font color="#FF0000">从左向右贪心也是可行的</font>。

首先来看，为什么从右向左贪心，因为非常直观、好证明：假设当前给定的时间是time，判断该时间内完成，最少需要多少个人。从右向左贪心的过程中，如果某个人销毁了第i堆的盒子之后还剩余一些时间可以利用，那么他一定可以把这些时间用在销毁第i堆之前的盒子上（因为他之前路过了这些盒子，可以顺手为之）。这样子的话，就可以保证除了最后一个人之外的其余所有人都不会有时间剩余，换句话说，最后如果时间出现了剩余，那么一定是最后一个人的。所以剩余的时间一定比 time 小，这样算出来的人数一定是最少的（因为最终剩余的时间比time小，不能再少人了）。

那么从左向右贪心正确性的证明也是一样的道理，也就是说，我们只要证明最终剩余的时间比time小就可以了（因为不能再少人了）：考虑最坏的情况，当我们摧毁第一堆的盒子的时候，有时间剩余，这个剩余的时间可以让我们刚好走到下一堆盒子面前，但是不能做任何事情，这样的情况是最糟糕的（从第一堆盒子走到下一堆盒子的时间被浪费了，没有摧毁下一堆的任何盒子），浪费的时间等于第一堆盒子到下一堆盒子的距离。如果每次都产生这样的浪费，那么总的浪费的时间最大就是time-2，比time小，故这样算出来的人数依然是最少的。

实现细节见代码部分。
</p>


##	反思总结

二分想到了，二分完判断答案是否可行想的慢了，比赛结束了才写完代码。平时要注意休息。

##	代码实现

从右向左贪心。

```
/*************************************************************************
    > Author: HouJP
    > Mail: houjp1992@gmail.com
 ************************************************************************/

#include <cstdio>
#include <cstring>
#include <cmath>
#include <cstdlib>
#include <algorithm>

using namespace std;

#define LL long long

#define MAX(a,b)		((a) > (b) ? (a) : (b))
#define MIN(a,b)		((a) > (b) ? (b) : (a))

#define N (100000 + 2)
#define INF (0x3f3f3f3f3f3f3f3fLL)

int n, m;
LL a[N], pmax;
LL ans;

bool judge(LL ans) {
	LL p = 0;
	LL r = 0;
	for (int i = n - 1; i >= 0; --i) {
		if (a[i] == 0) {
			continue;
		}
		if (ans - (i + 2) < 0 ) {
			return false;
		}
		p += (a[i] - MIN(a[i], r)) / (ans - (i + 1));
		if (0 != ((a[i] - MIN(a[i], r)) % (ans - (i + 1)))) {
			++p;
			r = ans - (i + 1) - (a[i] - r) % (ans - (i + 1));
		} else {
			r -= a[i];
		}
		//printf("ans = %I64d, p = %I64d, r = %I64d\n",ans,  p, r);
	}
	if (p <= m)  {
		return true;
	} else {
		return false;
	}
}

void init() {
}

void in() {
	for (int i = 0; i < n; ++i) {
		scanf("%I64d", &a[i]);
	}
}

void run() {
	LL l = 0, r = INF;
	while (l <= r) {
		ans = (l + r) / 2;
		if (judge(ans)) {
			r = ans - 1;
		} else {
			l = ans + 1;
		}
	}
	ans = l;
}

void out() {
	printf("%I64d\n", ans);
}

void out(int cas) {
}

int main() {
	//freopen("data", "r", stdin);

	init();
	while (~scanf("%d%d", &n, &m)) {
		in();
		run();
		out();
	}

	return 0;
}
```

从左向右贪心。

```
/*************************************************************************
    > File Name: codeforces_551C.cpp
    > Author: HouJP
    > Mail: houjp1992@gmail.com
    > Created Time: 六  6/20 09:51:18 2015
 ************************************************************************/

#include <cstdio>
#include <cstring>
#include <cstdlib>

using namespace std;

#define LL long long
#define MAXN (100000 + 2)
#define INF (0x3f3f3f3f3f3f3f3fLL)
#define MIN(a, b) ((a) < (b) ? (a) : (b))
#define MAX(a, b) ((a) > (b) ? (a) : (b))

LL num[MAXN];
LL n, m;
LL ans;

bool judge() {
	LL cnt = 0;
	LL r = 0;
	for (int i = 1; i <= n; ++i) {
		--r;
		if (0 == num[i]) {
			continue;
		}
		if (0 >= (ans - i)) {
			return false;
		}
		r = MAX(r, 0);
		cnt += (num[i] - MIN(num[i], r)) / (ans - i);
		if (0 != ((num[i] - MIN(num[i], r)) % (ans - i))) {
			++cnt;
			r = ans - i - (num[i] - MIN(num[i], r)) % (ans - i);
		} else {
			r -= num[i];
		}
	}
	if (cnt <= m) {
		return true;
	} else {
		return false;
	}
}

void in() {
	for (int i = 1; i <= n; ++i) {
		scanf("%I64d", &num[i]);
	}
}

void run() {
	LL l = 0, r = INF;
	while (l <= r) {
		ans = (l + r) / 2;
		if (judge()) {
			r = ans - 1;
		} else {
			l = ans + 1;
		}
	}
	ans = l;
}

void out() {
	printf("%I64d\n", ans);
}

int main() {
	//freopen("data", "r", stdin);

	while (~scanf("%I64d%I64d", &n, &m)) {
		in();
		run();
		out();
	}

	return 0;
}
```
