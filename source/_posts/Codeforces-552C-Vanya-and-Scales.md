---
mathjax: true
title: 'Codeforces#552C Vanya and Scales'
date: 2015-06-19 14:42:24
categories: ACM解题报告
tags: [Codeforces, 数学, 解题报告, 递归]
---


##	题目来源

[Codeforces Round #308 (Div. 2) C. Vanya and Scales](http://codeforces.com/contest/552/problem/C)

##	题目类型

数学，递归

##	问题描述

给定两个数字w和m（$2 \leq w \leq 10^{9}, 1 \leq m \leq 10^{9}$），有一个物品的重量等于m克，有一架天平和101个砝码，砝码的重量分别为$w^{0}, w^{1}, ..., w^{99}, w^{100}$，求解能否用这架天平和这些砝码称出该物品的重量（也就是说找一些砝码和物品一起放在天平的左盘，再找另外一些砝码放在天平的右端，使天平处于平衡状态）。

##	解题思路

首先来看当$w=2$的时候，由于任何一个数字都可以用二进制表示，也就是说我们可以将数字"m"分解为$m=2^{p\_{1}}+2^{p\_{2}}+...+2^{p\_{k}}$的形式，其中$p\_{1}, p\_{2}, ..., p\_{k}$中的元素不发生重复，所以我们可以用这101个砝码组合出任意的数字。故当$w==2$的时候一定有解。

当$w>2$的时候，存在一条性质：[性质1] $w^{0}+w^{1}+...+w^{i}<\frac{w^{i+1}}{2}$。假设我们在称量物体的时候用到的砝码为$w^{p\_{1}}, w^{p\_{2}}, ..., w^{p\_{k}}$，且满足$w^{p\_{1}}<w^{p\_{2}}<...<w^{p\_{k}}$。

首先来求解质量最大的砝码的位置：根据性质1，我们可以知道，重量最大的砝码$w^{p\_{k}}$一定与物品不在同一边（反证法：如果在同一边的话，把用到的其余所有砝码都放在另一边也不足以使天平达到平衡状态）。

再来求解质量最大的砝码的质量：根据假设，我们知道质量最大的砝码的质量为$w^{p\_{k}}$，令$j=p\_{k}$，质量最大的砝码的质量$w^{p\_{k}}$转化为$w^{j}$，那么“j”一定满足以下两条性质：

1.	$w^{0}+w^{1}+...+w^{j-1}<m$
	*	证明（反证法）：假设$w^{0}+w^{1}+...+w^{j-1} \geq m$。根据之前的推论，已经知道质量最大的砝码$w^{j}$与物品不在同一侧。根据[假设1]可知，$w^{0}+w^{1}+...+w^{j-1}<\frac{w^{j}}{2}$，再结合假设条件可推出$w^{0}+w^{1}+...+w^{j-1}+m<w^{j}$，也就是说：即使把除了质量最大的砝码之外的所有砝码都放在物品的那一侧，也无法让天平达到平衡状态。因此假设条件下不存在可行解，假设不成立。
2.	$w^{0}+w^{1}+...+w^{j-1}+w^{j} \geq m$
	*	证明（反证法）：假设$w^{0}+w^{1}+...+w^{j-1}+w^{j} < m$。我们可以知道，即使把用到的所有砝码都放在质量最大的砝码所在的那侧（与物品不在同一侧），也无法使天平达到平衡状态（不管怎么放，天平都会向物品的那一侧倾斜）。故假设条件下不存在可行解，假设不成立。

根据上述两条性质，我们就可以通过计算前缀和的方式，来找到质量最大的砝码的质量$w^{j}$，也就是$w^{p\_{k}}$（前缀和刚好大于等于物品的重量）。

通过上述的推导，我们成功求解出了质量最大的砝码的质量和位置，那么接下来就该求解质量次大的砝码的质量和位置。这个问题其实可以通过递归，转化为求解质量最大的砝码的质量和位置。转化的方法：因为通过之前的推导，我们知道质量最大的砝码一定与物品不在同一侧，计算它俩质量差的绝对值并记做${m}' = \left | w^{p\_{k}} - m \right |$，${m}'$可看做一个新的物品，就可以通过前述方法，求得为了称量${m}'$的大小所需要的质量最大的砝码的质量，也就是$w^{p\_{k-1}}$的大小。由于这是质量次大的砝码，因此需要满足$w^{p\_{k-1}} < w^{p\_{k}}$，如果不满足的话，就不存在可行解，输出“NO”。如果满足小于条件的话，就继续递归求解$w^{p\_{k-2}}, w^{p\_{k-3}}, ..., w^{p\_{1}}$，直到${m}'=0$，输出“YES”。

##	反思总结

其实半夜已经蒙圈了，全是凭感觉推出来的，今天重新整理了一下思路。

##	代码实现

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
#include <functional>
#include <vector>
#include <queue>
#include <map>

using namespace std;

#define LL long long

#define mp make_pair
#define pb push_back
#define fi first
#define se second
#define all(x)	x.begin(), x.end()
#define rall(x)	x.rbegin(), x.rend()
#define sz(a)	int(a.size())
#define reset(a, x)	memset(a, x, sizeof(a))

#define MAX(a,b)		((a) > (b) ? (a) : (b))
#define MIN(a,b)		((a) > (b) ? (b) : (a))
#define ABS(a)			((a) > 0 ? (a) : (-(a)))
#define FOR(i, a, b)	for(int i = a; i <= b; ++i)
#define FORD(i, a, b)	for(int i = a; i >= b; --i)
#define REP(i, n)		for(int i = 0, _n = n; i < _n; ++i)
#define REPD(i, n)		for(int i = n - 1; i >= 0; --i)
#define FORSZ(i, x)		for(int i = 0; i < sz(x); ++i)

#define MAX_NUM (2000000000)

LL w, m;
LL num[102], num_index;
LL sum[102];

bool judge(LL m, int lev) {
	if (0 == m) {
		return true;
	}
	for (num_index = 0; sum[num_index] < m; ++num_index) {
	}
	if (num_index > lev) {
		return false;
	} else {
		return judge(ABS(m - num[num_index]), num_index - 1);
	}
}

void init() {
}

void in() {
	num[0] = 1;
	sum[0] = 1;
	num_index = 0;

	while (num[num_index] < MAX_NUM) {
		++num_index;
		num[num_index] = num[num_index - 1] * w;
		sum[num_index] = sum[num_index - 1] + num[num_index];
	}
}

void run() {
}

void out() {
	if (judge(m, num_index)) {
		printf("YES\n");
	} else {
		printf("NO\n");
	}
}

void out(int cas) {
}

int main() {
	freopen("data", "r", stdin);

	init();
	while (~scanf("%lld%lld", &w, &m)) {
		in();
		run();
		out();
	}

	return 0;
}
```