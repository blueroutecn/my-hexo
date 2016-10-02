---
mathjax: true
title: 白话LeetCode | 149. Max Points on a Line
date: 2016-10-02 17:12:04
categories: 白话LeetCode
tags: [HashTable, Math]
---


<meta http-equiv=Content-Type content="text/html;charset=utf-8">


##	问题描述

(原题链接：[LeetCode | 149. Max Points on a Line](https://leetcode.com/problems/max-points-on-a-line/))

给定n个二维平面上的点坐标，求位于同一条直线上的点的最大数目。

##	解题思路

首先，根据平面上的一个点p以及一个斜率k可以唯一的确定一条直线。

因此，我们可以按照如下步骤进行：

1.	枚举题目中给出的点坐标作为点p；
2.	计算所有点与点p构成的直线的斜率k，通过哈希表来记录不同斜率出现的次数，即为同一条直线上的点的数目；
3.	从第(2)步中选取最大值即为所求。

到这里，我们可以发现这道题目其实很简单，但是需要注意以下情况：

1.	可能存在与点p重合的点而导致无法计算斜率，因此需要使用一个变量来统计与点p重合的点的个数；
2.	可能存在通过点p且与X轴垂直的直线，因此需要使用另一个变量来统计通过点p且与X轴垂直的点的个数。

OK，问题得解，`时间复杂度为O(n^2)`。


##	代码实现


```c++
class Solution {
public:
    int maxPoints(vector<Point>& points) {
        int ans = 0;
        for (int i = 0; i < points.size(); ++i) {
            // 记录通过点i的不同斜率的直线上的点的个数
            unordered_map<double, int> mp;
            // 记录通过点i且垂直于X轴的直线上的点的个数
            int vertical = 0;
            // 记录与点i重合的点的个数
            int duplicate = 0;
            for (int j = 0; j < points.size(); ++j) {
                if (points[i].x == points[j].x) {
                    if (points[i].y == points[j].y) {
                        // 点i与点j完全重合
                        ++duplicate;
                    } else {
                        // 点i与点j组成的直线垂直于X轴
                        ++vertical;
                    }
                } else {
                    // k表示点i与点j组成的直线的斜率，且不与X轴垂直
                    double k = 1.0 * (points[j].y - points[i].y) / (points[j].x - points[i].x);
                    ++mp[k];
                }
            }
            for (auto kv : mp) {
                ans = max(ans, kv.second + duplicate);
            }
            ans = max(ans, vertical + duplicate);
        }
        return ans;
    }
};

```