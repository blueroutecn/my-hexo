---
mathjax: true
title: 白话LeetCode | 151. Reverse Words in a String
date: 2016-10-02 20:05:21
categories: 白话LeetCode
tags: [String]
---


<meta http-equiv=Content-Type content="text/html;charset=utf-8">


##	问题描述

(原题链接：[LeetCode | 151. Reverse Words in a String](https://leetcode.com/problems/reverse-words-in-a-string/))

给定一个字符串，对其中包含的单词的顺序进行反转，例如：

输入：`"the sky is blue"`

输出：`"blue is sky the"`

##	解题思路

反转单词序列是一个经典的问题，方法如下：

1.	将其中的每个单词进行反转，即`"the sky is blue"`=>`"eht yks si eulb"`；
2.	将第(1)步中得到的字符串整体进行反转，即`"eht yks si eulb"`=>`"blue is sky the"`。

虽然你知道了正确的方法，但还需要与面试官确认如下注意事项，来进一步提高你在面试官心中的印象分：

1.	该字符串的前缀和后缀中，是否包含多余的空格，这些空格是否需要进行删除；
2.	单词与单词之间的空格是否只有一个，如果有多个空格是否需要用一个空格来代替。

至此，问题得解，`时间复杂度为O(n)`。


##	代码实现


```c++
class Solution {
public:
    void reverseWords(string &s) {
        int l = 0, r = 0;
        string tmp;
        while (true) {
            // 找到每一个单词，并分别对其进行反转
            while (' ' != s[r] && r < s.length()) ++r;
            string word = s.substr(l, r - l);
            reverse(word.begin(), word.end());
            if (0 != word.length()) {
                if (0 != tmp.length()) {
                    tmp.append(" ");
                }
                tmp.append(word);
            }
            l = r = r + 1;
            if (r >= s.length()) break;
        }
        s = tmp;
        // 反转每个单词后，再反转整个字符串
        reverse(s.begin(), s.end());
    }
};

```