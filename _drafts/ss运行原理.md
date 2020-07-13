---
author: djaigo
title: ss运行原理
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/golang.png'
categories:
  - null
tags:
  - null
date: 2020-03-11 15:51:22
updated: 2020-03-11 15:51:22
---


解析一下ss的运行机制

```mermaid
sequenceDiagram
    participant Alice
    participant Bob
    Alice->>John: Hello John, how are you?
    loop Healthcheck
        John->>John: Fight against hypochondria
    end
    Note right of John: Rational thoughts <br/>prevail!
    John-->>Alice: Great!
    John->>Bob: How about you?
    Bob-->>John: Jolly good!
```

下面是程序的源代码
```text
sequenceDiagram
    participant Alice
    participant Bob
    Alice->>John: Hello John, how are you?
    loop Healthcheck
        John->>John: Fight against hypochondria
    end
    Note right of John: Rational thoughts <br/>prevail!
    John-->>Alice: Great!
    John->>Bob: How about you?
    Bob-->>John: Jolly good!
```

通过上图可以知道ss是通过本地和远端分别部署两个程序进行加密通信。