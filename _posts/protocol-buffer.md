---
author: djaigo
title: protocol buffer
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/golang.png'
categories:
  - protobuf
tags:
  - protobuf
date: 2020-04-23 15:32:37
updated: 2020-04-23 15:32:37
---

| .proto Type | Notes |  Go Type |
| --- | --- | --- | --- |
| double | float64 | |  
| float |  float32 |  | 
| int32 | int32 | Uses variable-length encoding. Inefficient for encoding negative numbers – if your field is likely to have negative values, use sint32 instead. | 
| int64 | int64 | Uses variable-length encoding. Inefficient for encoding negative numbers – if your field is likely to have negative values, use sint64 instead. | 
| uint32 | Uses variable-length encoding. | uint32 |
| uint64 | Uses variable-length encoding. | uint64 | 
| sint32 | Uses variable-length encoding. Signed int value. These more efficiently encode negative numbers than regular int32s. | int32 | 
| sint64 | Uses variable-length encoding. Signed int value. These more efficiently encode negative numbers than regular int64s. |  int64 |
| fixed32 | Always four bytes. More efficient than uint32 if values are often greater than 228. | uint32 | Fixnum or Bignum (as required) | uint | 
| fixed64 | Always eight bytes. More efficient than uint64 if values are often greater than 256. |  uint64 |
| sfixed32 | Always four bytes. |  int32 |
| sfixed64 | Always eight bytes. |  int64 |
| bool |  |  bool | 
| string | A string must always contain UTF-8 encoded or 7-bit ASCII text, and cannot be longer than 232. |  string |
| bytes | May contain any arbitrary sequence of bytes no longer than 232. |  []byte | 

