---
author: djaigo
title: protocol buffer
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/golang.png'
mathjax: true
categories:
  - protobuf
tags:
  - protobuf
  - proto3
date: 2023-02-23 15:32:37
---
# 简介
Protocol Buffers （简称 Protobuf）是 Google 开源的一款跨语言，跨平台，扩展性好的序列化工具，相比于 XML 和 JSON 等流行的编码格式，Protobuf 的性能非常高。因此，Protobuf 的编码格式（文件后缀为 `.proto`）在网络开发中得到了广泛的应用，**protoc** 作为 Protobuf 的编译器，可以根据 Protobuf 的定义文件 `.proto` 生成多种语言（如：C++, Java, Go, Python 等）的类型定义文件及编解码操作代码。
其他详情可以参考[官方文档](https://protobuf.dev/)。

## 安装
### 源码安装
官方源码：[https://github.com/google/protobuf](https://github.com/google/protobuf)
可以选择[releases](https://github.com/protocolbuffers/protobuf/releases)获取最新版和选择官方支持的语言版本

### 安装依赖
如官网所列，protoc 有如下依赖：
autoconf, automake, libtool, curl, make, g++, unzip, gmock
其中 gmock 依赖于 libtool

### 编译安装：

```
$ wget https://github.com/protocolbuffers/protobuf/releases/download/v3.7.1/protobuf-all-3.7.1.tar.gz
$ tar xf protobuf-all-3.7.1.tar.gz
$ cd protobuf-all-3.7.1
$ ./configure
$ make
$ make check
$ sudo make install
```

注：
安装完成之后，会在 /usr/lib 目录下生成前缀为 libprotobuf, libprotobuf-lite, libprotoc 这三类静态和动态库文件。

## 优缺点
### 优点
*   小巧，采用二进制流，便于传输数据
*   快速，编码解码比较快
*   方便，自动生成相应的操作代码，减少了维护代码的成本，支持大部分主流语言，无需关心底层，直接调用函数即可
*   兼容性好，不必破坏已部署的、依靠“老”数据格式的程序就可以对数据结构进行升级。这样您的程序就可以不必担心因为消息结构的改变而造成的大规模的代码重构或者迁移的问题。因为添加新的消息中的 field 并不会引起已经发布的程序的任何改变。

### 缺点
*   可读性差，对机器友好，对人不友好。如果没有`.proto`文件无法表示数据含义，所以使用场景一般是内部服务的数据传输
*   描述数据能力差，无法类似xml那样自描述字段相关内容

# Protobuf
常见protobuf文件格式
```proto
syntax = "proto3";

package foo.bar;
option go_package = "foo/bar";

message SearchRequest {
  string query = 1;
  int32 page_number = 2;
  int32 result_per_page = 3;
}

```

## Package

## Field
### 字段类型

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

类型默认值：
* string，空字符串
* bytes，空二进制流
* bool，false
* numeric，0
* enum，默认值**第一个枚举值**，且必须是0
* message，取决于具体语言实现，对于Golang来说是空指针
* repeated，空元素

### 字段标号
每个字段的标号在同一个message中必须唯一，一旦使用就不能修改。
标号最小为1，最大为$2^{29}-1$或`536,870,911`，其中19000到19999为protobuf内部保留字段，如果使用protoc会报错。
### 字段规则
支持一下字段规则：
* `singular`，默认规则，表示单一字段
* `optional`，表示可选字段
* `repeated`，表示重复字段，在 proto3 中，`repeated`类型默认使用`packed`编码
* `map`，表示key-value对的字段

### 未知字段

## Enum
枚举值会映射为数字类型，且必须拥有零值，且在第一个元素。
可以分配相同的值给不同常量枚举值，为此需要将`allow_alias`设置为true，否则会生成警告。序列化时始终使用第一个类型。
由于枚举值使用int32类型，因此负值效率低下，建议不使用。


### 保留枚举字段
可以完全删除枚举项或将其注释，或使用保留字段，将其弃用，防止后续消息复用导致未知错误。
```proto
enum Foo {
  reserved 2, 15, 9 to 11, 40 to max;
  reserved "FOO", "BAR";
}

```

注意：同一条语句不用同时混用字段和标号。

### 处理枚举值风格
针对未知枚举值，proto有两种风格处理，一种是设置为零值也即默认值（`Closed`），一种是设置为原值但无意义（`Open`），应该满足以下规则：
* proto2应为`Closed`模式
* proto3应为`Open`模式
* proto3引用proto2的枚举值，protoc将会报错
* proto2引用proto3的枚举值，将视为`Open`模式

GO实现版本并没有按照上述规则实现，始终视为`Open`模式。


## Oneof

## Message
使用message关键字定义消息体。

### 消息类型
使用其他消息作为消息类型
```proto
message SearchResponse {
  repeated Result results = 1;
}

message Result {
  string url = 1;
  string title = 2;
  repeated string snippets = 3;
}

```

如果需要导入其他文件的proto文件，可以使用import声明导入的proto文件路径，路径相对于protoc的`--proto_path`参数，如果不指定`--proto_path`参数，默认为当前目录，例如：
```proto
import "myproject/other_protos.proto";
import "google/protobuf/any.proto";
```

引用时使用`package.Message`表示消息类型。
### 消息嵌套


### 自定义保留字段
除了上述protobuf保留字段，还可以自定义保留字段，用于占位，防止后续消息复用导致未知错误。
```proto
message Foo {
  reserved 2, 15, 9 to 11;
  reserved "foo", "bar";
}

```

注意：同一条语句不用同时混用字段和标号。
## WellKnownType
### Any
引入路径`import "google/protobuf/any.proto";`
### Timestamp


## Service


## Option

### file
### message
### field


# 编码格式

## varint
varint作为protobuf的核心编码方式，可以将数字转为变长二进制格式。
以每字节最高位（符号位，`most significant bit(msb)`）标识是否有后续字节，后续7位表示数字有效载荷，由此组成一个字节，多个字节组成的数字使用小端字节序排列。
```txt
0000 0001 // 表示1
^msb

1001 0110 0000 0001 // 表示150
^msb      ^msb
```

## 消息结构
消息序列化，即将消息按`key-value`方式序列化，`key`为字段标号，`value`则为值，不同类型的值序列化方式不同。
目前有6种线性化类型（`wire_type`）： `VARINT`，`I64`，`LEN`，`SGROUP`，`EGROUP`，`I32`。

| ID | Name | Used For |
| --- | --- | --- |
| 0 | VARINT | int32, int64, uint32, uint64, sint32, sint64, bool, enum |
| 1 | I64 | fixed64, sfixed64, double |
| 2 | LEN | string, bytes, embedded messages, packed repeated fields |
| 3 | SGROUP | group start (deprecated) |
| 4 | EGROUP | group end (deprecated) |
| 5 | I32 | fixed32, sfixed32, float |

消息标号序列化方式为 `(field_number << 3) | wire_type`，即将字段标号和线性化类型通过或的方式转为一个数字，该数字在进行varint编码，即为线性化的key。所以建议常用字段最好只使用1-15作为标号，这样只需要占用一个字节表示字段类型。
```txt
0000 1000 // 表示1:VARINT

0000 1000 1001 0110 0000 0001 // 表示1:VARINT 150
```

## 其他数字类型
### 布尔和枚举
布尔和枚举都将视为`int32`类型。
### 有符号整数
`varint`是对符号无感知的，所以使用`int`表示`-1`时则会序列化出10个字节（包含`wire_type`）。
为了解决浪费的情况，`sint`使用`ZigZag`编码来编码整数，正整数`n`编码为`2*n`，负整数`-n`编码为`2*n+1`。例如：

| Signed Original | Encoded As |
| --- | --- |
| 0 | 0 |
| -1 | 1 |
| 1 | 2 |
| -2 | 3 |
| … | … |
| 0x7fffffff | 0xfffffffe |
| -0x80000000 | 0xffffffff |

### 非varint数字
`fixed`，`double`，`float`都表示固定位数的数字编码，`I64`表示固定8字节，`I32`表示固定4字节。

## 长度分隔字段
拥有动态变化长度的字段，在序列化即为原始数据，并在前加上`varint`的长度数据，例如：
```txt
07 74  65  73  74  69  6e  67 // 表示长度为7 内容为testing
12 07 74  65  73  74  69  6e  67 // 2:LEN VARINT:7 testing
```

其他`LEN`类型的数据编码类似。

## 重复字段
重复字段会出现多个标号相同的字段排列，其中可能会插入其他字段序列化（合法但不合理），例如：
```txt
28 01 28 02 28 03 // 5:LEN VARINT:1 5:LEN VARINT:2 5:LEN VARINT:3
```

如果出现非重复字段出现重复字段，则最后一次出现的值为最终值（`last one wins`）。

### 打包重复字段
使用`[packed=true]`选项（proto2中为选项，proto3则为默认值）表示不是被编码为每个条目一个记录，而是被编码为单个`LEN`记录，其中包含每个连接的元素。为了解码，元素从`LEN`记录中被一个一个地解码，直到有效载荷被耗尽。下一个元素的开始由前一个元素的长度决定，这本身取决于字段的类型。例如：
```txt
28 04 01 02 96 01 // 5:LEN VARINT:4 VARINT:1 VARINT:2 VARINT:150

28 02 01 02 28 02 96 01 // 多个重复字段 结果同上
```

只有原始数字类型的重复字段才能声明为打包，即`wire_type`为`VARINT`，`I32`，`I64`。
## MAP
map仅是一种特殊的重复字段简写，例如：
```proto
message Test6 {
  map<string, int32> g = 7;
}

```

实际与下面是相同的：
```proto
message Test6 {
  message g_Entry {
    optional string key = 1;
    optional int32 value = 2;
  }
  repeated g_Entry g = 7;
}

```

因此，map的编码完全像一个重复的消息字段：作为 LEN 类型记录的序列，每个记录有两个字段。


# proto文件风格

## 文件格式化
标准proto文件格式化风格：
* 每行最长80字符
* 缩进为2个空格
* 使用双引号作为标记字符串

## 文件结构
文件名为小写蛇形形式`lower_snake_case.proto`。
文件行排序遵从如下顺序：
* License头
* 文件描述
* 声明syntax
* 声明package
* 列出import，且已排序
* 列出选项
* 其他内容

## 命名规则
命名规则定义：
* 包名应该小写，并且基于项目唯一
* 消息名使用驼峰且首字母大写
* 字段名使用小写蛇形，如果字段名包含数字，引用下划线分开`song_name_1`
* repeated字段名应使用复数形式
* 枚举类型名使用驼峰且首字母大写，枚举类型值应使用大写蛇形
* 枚举值应加消息前缀，零值后缀应为`UNSPECIFIED`
* 服务类型名使用驼峰且首字母大写，方法名使用驼峰且首字母大写

# 设计技巧
## 流式传输多条消息
流式处理多条消息，由于protobuf消息没有自定义边界，所以无法确定结束位置。
解决方案：使用长度标识在每个消息流前，辅助protobuf确定消息边界。

## 大数据传输
protobuf设计不是为大数据而设计的，如果消息超过1M则需要思考替换方案。

## 自描述信息
protobuf不包含它们自己类型的描述。因此，如果只给定原始消息而没有定义其类型的相应`.proto`文件，则很难提取任何有用的数据。
可以通过`google.protobuf.FileDescriptorSet`获取文件的描述信息。
使用protoc可以使用`--descriptor_set_out`输出自描述信息。
也可以使用如下定义自描述信息消息

```proto
syntax = "proto3";

import "google/protobuf/any.proto";
import "google/protobuf/descriptor.proto";

message SelfDescribingMessage {
  // Set of FileDescriptorProtos which describe the type and its dependencies.
  google.protobuf.FileDescriptorSet descriptor_set = 1;

  // The message and its type, encoded as an Any message.
  google.protobuf.Any message = 2;
}
```


# proto文件最佳实现

* 不可复用字段标号
* 不能修改字段类型
* 不要添加必填字段，proto3中已删除
* 消息不能拥有太多字段
* 枚举第一个字段应是无意义枚举值等于零，类似`*_UNSPECIFIED = 0`
* 枚举值不应使用`C/C++`宏常量
* 使用总所周知的类型或常见类型：
  * 周知类型
    * duration，表示有符号固定长度的时间跨度（例如，`42s`）。
    * timestamp，独立于任何时区或日历的时间点（例如，`2017-01-15T01:30:15.01Z`）。
    * field_mask，表示符号路径（例如，`f.b.d`）。
  * 常见类型
    * interval，独立于任何时区或日历的时间区域（例如，`2017-01-15T01:30:15.01Z - 2017-01-16T02:30:15.01Z`）。
    * date，表示完整日历时间（例如，`2005-09-19`）。
    * dayofweek，表示星期几（例如，`Monday`）。
    * timeofday，一天中的时间（例如，`10:42:23`）。
    * lalng，表示经纬度对（例如，`37.386051 latitude and -122.083855 longitude`）。
    * money，具有货币类型的金钱（例如，`42 USD`）。
    * postal_address，邮政地址（例如，`1600 Amphitheatre Parkway Mountain View, CA 94043 USA`）。
    * color，表示RGBA域中的一个颜色（例如，`rgba(0.1,0.2,0.3,0.5)`）。
    * month，一年中的某月（例如，`April`）。
* 常用消息应定义在单独文件中
* 为已删除字段应该保留字段标号
* 为已删除的枚举值保留字段标号
* 不要更改字段的默认值
* 不要重复定义标量
* 遵循生成代码的样式指南
* 切勿使用文本格式消息进行交换，非protobuf序列化消息
* 不要依赖跨构建的序列化稳定性


# 参考文献
* [protobuf guide](https://protobuf.dev/programming-guides/)
