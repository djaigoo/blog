---
author: djaigo
title: protocol buffer
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/golang.png'
categories:
  - protobuf
tags:
  - protobuf
  - proto3
date: 2020-04-23 15:32:37
updated: 2020-04-23 15:32:37
---
# 简介
`protocol buffer`是一种与语言无关，与平台无关的可扩展机制，用于序列化结构化数据。它通过定义`.proto`文件，使用`protoc`工具生成指定代码的文件，让程序猿没有了心智负担。与json相比，它编码和解码快，生成数据体积小。
# protobuf类型

| .proto Type | Notes | Go Type |
| --- | --- | --- |
| double |  | float64 |
| float |   | float32 |
| int32 | 使用可变长度编码。负数编码效率低下–如果您的字段可能具有负值，请改用sint32。 | int32 |
| int64 |  使用可变长度编码。负数编码效率低下，如果您的字段可能具有负值，请改用sint64。 | int64 |
| uint32 | 使用可变长度编码。 | uint32 |
| uint64 | 使用可变长度编码。 | uint64 |
| sint32 | 使用可变长度编码。有符号的int值。与常规int32相比，它们更有效地编码负数。 | int32 |
| sint64 | 使用可变长度编码。有符号的int值。与常规int64相比，它们更有效地编码负数。 |  int64 |
| fixed32 | 始终为八个字节。如果值通常大于$2^{28}$，则比uint32更有效。 | uint32 |
| fixed64 | 始终为八个字节。如果值通常大于$2^{56}$，则比uint64更有效。 |  uint64 |
| sfixed32 | 始终为4字节。 |  int32 |
| sfixed64 | 始终为8字节。 |  int64 |
| bool |  |  bool |
| string | 字符串必须始终包含UTF-8编码或7位ASCII文本，并且不能超过$2^{32}$。 |  string |
| bytes | 可以包含不超过$2^{32}$的字节序列。 | []byte | 

* sint，对负数的编码结果更优秀，如果用int存小负数会占用4字节，用sint能像正数一样占少量空间
* fixed，对应位数占固定字节数
* sfixed，对应位数占固定字节数，使用sint的编码格式

# 参考文献
* [proto3 guide](https://developers.google.com/protocol-buffers/docs/proto3)
