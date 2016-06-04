---
mathjax: true
title: 'Codeforces#549B Looksery Party'
date: 2015-06-09 22:05:11
categories: [ACM解题报告]
tags: [Codeforces, 构造, 解题报告]
---


##	题目来源

Codeforces Looksery Cup 2015 B. Looksery Party

##	题目类型

构造

##	问题描述

条件：给定一个大小为N的数(N<=100)，代表有n个节点。接下来给定n*n的矩阵adj[N][N]，如果adj[i][j]=1，表示存在一条从点i到点j的边，反之不存在。最后给定长度为N的数组arr[N]。

求解：能否从原图中挑出一些点，从这些点出发的边构成新的图G'，新图G'满足每个点i的入度都与给定序列对应的值arr[i]不相同。

## 解题思路

首先不难发现，如果原图所有点的入度都不为0，那么一定有解，解为空集。

接下来讨论原图存在入度为0的点的情况。这种情况下一定有解，解集按照如下步骤构造：

1.	选择入度为0的点，将其加入解集。并删除从这些入度为0的点出发的边。
2.	重复步骤1，直至不存在入度为0的点，得到解集。
	
通过以上步骤，我们可以发现，原图存在入度为0的点的情况下一定有解。再结合原图不存在入度为0的点的情况下有解，可知，问题一定有解。

##	反思总结

想到了在存在入度为0的点的情况下，先处理入度为0的点，然后构造出新的入度为0的点，如此不停的迭代。但是没有想出来如何选点来处理入度为0的点，我的想法是有可能存在N个点存在指向这些点的边，枚举这些点的复杂度是2^N次，不可解。其实只要枚举自己就好了。

也就是说，<font color="#FF0000">对于输出一种可行解的问题，如果采用构造的方法：首先排除掉没有解的情况（不存在或者可判断出什么时候无解），然后对于剩余情况构造一种可行解即可</font>，而不需要知道所有的可行解。

##	代码实现


```
/*************************************************************************
    > File Name: 2.cpp
    > Author: HouJP
    > Mail: houjp1992@gmail.com
    > Created Time: 二  6/ 9 19:26:55 2015
 ************************************************************************/

#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <queue>

using namespace std;

#define MAXN (100 + 2)

int n;
char s[MAXN][MAXN];
int num[MAXN];
bool flag[MAXN];
int ans;

void in() {
	for (int i = 0; i < n; ++i) {
		scanf("%s", s[i]);
	}
	for (int i = 0; i < n; ++i) {
		scanf("%d", &num[i]);
	}
	memset(flag, 0, sizeof(flag));
	ans = 0;
}

void run() {
	queue<int> que;
	for (int i = 0; i < n; ++i) {
		if (num[i] == 0) {
			que.push(i);
		}
	}
	while (!que.empty()) {
		int id = que.front();
		que.pop();
		if (0 != num[id]) {
			continue;
		}
		flag[id] = true;
		++ans;
		for (int i = 0; i < n; ++i) {
			if ('1' == s[id][i]) {
				if (0 == (--num[i])) {
					que.push(i);
				}
			}
		}
	}
}

void out() {
	printf("%d\n", ans);
	bool fir = true;
	if (0 == ans) {
		return;
	}
	for (int i = 0; i < n; ++i) {
		if (flag[i]) {
			if (fir) {
				printf("%d", i + 1);
				fir = false;
			} else {
				printf(" %d", i + 1);
			}
		}
	}
	printf("\n");
}

int main() {
	//freopen("data", "r", stdin);

	while (~scanf("%d", &n)) {
		in();
		run();
		out();
	}

	return 0;
}
```

