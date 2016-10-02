---
mathjax: true
title: 白话LeetCode | 8. String to Integer (atoi)
date: 2016-10-02 15:28:36
categories: 白话LeetCode
tags: [字符串]
---



<meta http-equiv=Content-Type content="text/html;charset=utf-8">


##	问题描述

(原题链接：[LeetCode | 8. String to Integer (atoi)](https://leetcode.com/problems/string-to-integer-atoi/))

请实现C++内置的atoi函数，该函数可以将string类型转换为int类型。

##	解题思路

这是一道字符串类型的模拟题，编程者需要在动手之前与面试官沟通以下三点问题：

1.	当字符串为空时，函数的返回值是多少；
1.	当字符串中遇到非法字符时，函数的返回值是多少；
2.	当字符串表示的数值超过int类型的范围时，函数的返回值是多少。

对于以上的三点问题，我们可以做出以下假设：

*	对于第(1)点问题，可以假定返回值为0；
*	对于第(2)点问题，可以返回遇到非法字符之前的那部分字符串对应的数字；
*	对于第(3)点问题，可以假设当超过int可以容纳的最大值时返回INT_MAX，当超过int可以容纳的最小值时返回INT_MIN。


在编写代码的时候，还有两点问题需要注意：

1.	如果字符串的前缀或者后缀中包含空白符，需要对齐进行删除；
2.	字符串对应的int数值可能包含正负号，需要进行判断处理，例如`"+12"`、`"-1"`。


当以上情况都考虑清楚之后，相信你可以很快的写出正确的解题代码。

##	代码实现


```c++
class Solution {
public:
    int myAtoi(string str) {
        // 当字符串为空时，返回0
        if (0 == str.length()) return 0;
        // 删除前缀和后缀中包含的空白符
        str.erase(0, str.find_first_not_of(' '));
        str.erase(str.find_last_not_of(' ') + 1);
        
        int sign = 1, index = 0;
        long long ans = 0;
        // 处理字符串中的正负号
        if ('+' == str[index]) {
            ++index;
        } else if ('-' == str[index]) {
            sign = -1;
            ++index;
        }
        for (int i = index; i < str.length(); ++i) {
            // 当遇到非法字符时，返回之前那部分字符串对应的数值
            if ('0' > str[i] || '9' < str[i]) break;
            ans = ans * 10 + str[i] - '0';
            // 当超过int范围时，返回'INT_MAX'或'INT_MIN'
            if (INT_MAX < ans) break;
        }
        // 添加正负号
        ans *= sign;
        // 当超过int可以容纳的最大值时可以返回INT_MAX
        if (INT_MAX < ans) return INT_MAX;
        // 当超过int可以容纳的最小值时可以返回INT_MIN
        if (INT_MIN > ans) return INT_MIN;
        return ans;
    }
};

```