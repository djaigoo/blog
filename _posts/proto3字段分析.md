---
title: proto3字段分析
tags:
  - pb
categories:
  - tech
mathjax: true
date: 2019-04-10 10:05:40
---

# 定义消息类型
定义一个简单的消息类型：
```cpp
syntax = "proto3";

message SearchRequest {
  string query = 1;
  int32 page_number = 2;
  int32 result_per_page = 3;
}
```

* 文件的第一行指定您正在使用proto3语法：如果不这样做，协议缓冲区编译器将假定您正在使用proto2。这必须是文件的第一行非空、非注释行。
* `SearchRequest`消息定义指定了三个字段（名称/值对），每个字段对应一个要包含在此类型消息中的数据。每个字段都有一个名称和类型。

## 字段类型
在上面的示例中，所有字段都是标量类型：两个整数（`page_number`和`result_per_page`）和一个字符串（query）。但是，还可以为字段指定复合类型，包括枚举和其他消息类型。
## 字段编号
如您所见，消息定义中的每个字段都有一个唯一的数字。这些字段编号用于以消息二进制格式标识您的字段，一旦您的消息类型被使用，就不应该更改这些字段。请注意，范围1到15中的字段编号采用一个字节进行编码，包括字段编号和字段类型（您可以在协议缓冲区编码中了解更多有关此内容的信息）。16到2047之间的字段号采用两个字节。因此，您应该为经常出现的消息元素保留数字1到15。记住为将来可能添加的经常发生的元素留出一些空间。
您可以指定的最小字段号是1，最大字段号是$2^{29}-1$或536870911。您也不能使用19000到19999之间的数字（FieldDescriptor:：kFirstServedNumber到FieldDescriptor:：klastervedNumber），因为它们是为协议缓冲区实现保留的-如果您在.proto中使用这些保留的数字之一，协议缓冲区编译器将投诉。同样，不能使用任何以前保留的字段编号。
## 字段规则
* `singular`，标志零个或一个字段
* `repeated`，消息中重复任意次数（包括零），将保留重复值的顺序。

在proto3中，标量数值类型的重复字段默认使用压缩编码。 [了解更多Protocol Buffer Encoding](https://developers.google.com/protocol-buffers/docs/encoding.html#packed)

## 更多消息类型
可以在单个.proto文件中定义多个消息类型。如果要定义多条相关消息，这很有用。
例如，如果要定义与SearchResponse消息类型对应的答复消息格式，可以将其添加到相同的格式中。协议：
```cpp
message SearchRequest {
  string query = 1;
  int32 page_number = 2;
  int32 result_per_page = 3;
}

message SearchResponse {
 ...
}
```

## 注释
支持C/C++风格注释，`//` 和 `/* ... */`。

## 保留字段
如果通过完全删除字段或将其注释掉来更新消息类型，将来的用户可以在对该类型进行自己的更新时重用字段号。如果他们以后加载相同的.proto的旧版本，这可能会导致严重的问题，包括数据损坏、隐私错误等。确保不会发生这种情况的一种方法是指定保留已删除字段的字段编号（和/或名称，这也可能导致JSON序列化问题）。如果将来有任何用户试图使用这些字段标识符，协议缓冲区编译器都会报错。
```cpp
message Foo {
  reserved 2, 15, 9 to 11;
  reserved "foo", "bar";
}
```

注意，不能在同一个保留语句中混合字段名和字段号。

# 标量值类型
标量消息字段可以具有以下类型之一–该表显示.proto文件中指定的类型以及自动生成的类中相应的类型和proto2一样，了解更多关于[Protocol Buffer Encoding](https://developers.google.com/protocol-buffers/docs/encoding)

# 默认值
解析消息时，如果编码的消息不包含特定的单数元素，则解析对象中的相应字段将设置为该字段的默认值。这些默认值是特定于类型的：
* 对于字符串，默认值为空字符串。
* 对于字节，默认值为空字节。
* 对于bools，默认值为false。
* 对于数字类型，默认值为零。
* 对于重复字段，默认值为空列表。
* 对于枚举，默认值是第一个定义的枚举值，该值必须为0。
* 对于消息字段，未设置该字段。它的确切价值取决于语言。

请注意，对于标量消息字段，一旦解析了消息，就无法判断字段是否显式设置为默认值（例如布尔值是否设置为false），或者根本没有设置：在定义消息类型时，应该记住这一点。例如，如果您不希望某些行为在默认情况下也发生，则不要使用布尔值在设置为false时打开某些行为。还要注意，如果将标量消息字段设置为其默认值，则该值将不会在线路上序列化。
有关详细信息可以[了解更多generated code guide](https://developers.google.com/protocol-buffers/docs/reference/overview)。

# 枚举
在定义消息类型时，您可能希望它的一个字段只有一个预先定义的值列表。例如，假设您希望为每个搜索请求添加一个语料库字段，其中语料库可以是`UNIVERSAL`，`WEB`，`IMAGES`，`LOCAL`，`NEWS`，`PRODUCTS`或`VIDEO`。您可以通过为消息定义添加一个枚举来实现这一点，每个可能的值都有一个常量。
在下面的示例中，我们添加了一个名为corpus的枚举，其中包含所有可能的值和corpus类型的字段：
```cpp
message SearchRequest {
  string query = 1;
  int32 page_number = 2;
  int32 result_per_page = 3;
  enum Corpus {
    UNIVERSAL = 0;
    WEB = 1;
    IMAGES = 2;
    LOCAL = 3;
    NEWS = 4;
    PRODUCTS = 5;
    VIDEO = 6;
  }
  Corpus corpus = 4;
}
```

如您所见，corpus枚举的第一个常量映射到零：每个枚举定义必须包含一个作为其第一个元素映射到零的常量。这是因为：
* 必须有一个零值，以便我们可以使用0作为数值默认值。
* 零值需要是第一个元素，以便与proto2语义兼容，其中第一个枚举值始终是默认值。

可以通过为不同的枚举常量指定相同的值来定义别名。为此，您需要将allow_alias选项设置为true，否则当找到别名时，协议编译器将生成一条错误消息。
```cpp
enum EnumAllowingAlias {
  option allow_alias = true;
  UNKNOWN = 0;
  STARTED = 1;
  RUNNING = 1;
}
enum EnumNotAllowingAlias {
  UNKNOWN = 0;
  STARTED = 1;
  // RUNNING = 1;  // Uncommenting this line will cause a compile error inside Google and a warning message outside.
}
```

枚举器常量必须在32位整数的范围内。由于枚举值在线路上使用变量编码，因此负值效率很低，因此不推荐使用。您可以在消息定义中定义枚举，如上面的示例中所示，也可以在外部定义-这些枚举可以在.proto文件中的任何消息定义中重用。还可以使用一条消息中声明的枚举类型作为另一条消息中字段的类型，使用语法message type.enum type。
在使用EnUM的A.PROTO上运行协议缓冲区编译器时，生成的代码将有一个对应的枚举，用于Java或C++，Python的一个特殊枚举类，用于在运行时生成的类中创建具有整数值的一组符号常量。
在反序列化过程中，消息中将保留无法识别的枚举值，尽管反序列化消息时如何表示枚举值取决于语言。在支持具有指定符号范围之外的开放枚举类型的语言（如C++和GO）中，未知的枚举值仅作为其基础的整数表示形式存储。在具有封闭枚举类型的语言（如Java）中，枚举中的一个实例用于表示未识别的值，而基础的整数可以用特殊的访问器访问。在这两种情况下，如果消息被序列化，则无法识别的值仍将用消息序列化。
有关详细信息可以[了解更多generated code guide](https://developers.google.com/protocol-buffers/docs/reference/overview)。
## 保留值
如果通过完全删除枚举项或将其注释掉来更新枚举类型，将来的用户可以在对该类型进行自己的更新时重用该数值。如果他们以后加载相同的.proto的旧版本，这可能会导致严重的问题，包括数据损坏、隐私错误等。确保不会发生这种情况的一种方法是指定保留已删除条目的数值（和/或名称，这也可能导致JSON序列化问题）。如果将来有任何用户试图使用这些标识符，协议缓冲区编译器都会抱怨。可以使用max关键字指定保留的数值范围达到最大可能值。
```cpp
enum Foo {
  reserved 2, 15, 9 to 11, 40 to max;
  reserved "FOO", "BAR";
}
```

注意，不能在同一个保留语句中混合字段名和数值。

# 使用其他消息类型
您可以使用其他消息类型作为字段类型。例如，假设您希望在每个SearchResponse消息中包含结果消息–为此，可以在相同的.proto中定义结果消息类型，然后在SearchResponse中指定类型为result的字段：
```cpp
message SearchResponse {
  repeated Result results = 1;
}

message Result {
  string url = 1;
  string title = 2;
  repeated string snippets = 3;
}
```

## 引入定义
在上面的示例中，结果消息类型与searchresponse在同一个文件中定义——如果您要用作字段类型的消息类型已经在另一个.proto文件中定义了，该怎么办？
通过导入其他.proto文件，可以使用它们的定义。要导入另一个.proto的定义，请在文件顶部添加导入语句：
```cpp
import "myproject/other_protos.proto";
```

默认情况下，只能使用直接导入的.proto文件中的定义。但是，有时可能需要将.proto文件移动到新位置。现在，您可以在旧位置放置一个虚拟的.proto文件，使用import public概念将所有导入转发到新位置，而不是直接移动.proto文件并在一次更改中更新所有调用站点。任何导入包含import public语句的协议的人都可以传递依赖import public依赖项。例如：
```cpp

// new.proto
// All definitions are moved here
```
```cpp
// old.proto
// This is the proto that all clients are importing.
import public "new.proto";
import "other.proto";
```
```cpp
// client.proto
import "old.proto";
// You use definitions from old.proto and new.proto, but not other.proto
```

协议编译器使用-i/--proto_路径标志在协议编译器命令行上指定的一组目录中搜索导入的文件。如果没有给出任何标志，它将在调用编译器的目录中查找。通常，您应该将--proto_路径标志设置为项目的根目录，并对所有导入使用完全限定的名称。
## 使用proto2消息类型
可以导入proto2消息类型并在proto3消息中使用它们，反之亦然。但是，proto2枚举不能直接在proto3语法中使用（如果导入的proto2消息使用它们，也可以）。

# 嵌套类型
您可以在其他消息类型中定义和使用消息类型，如以下示例所示–此处结果消息在SearchResponse消息中定义：
```cpp
message SearchResponse {
  message Result {
    string url = 1;
    string title = 2;
    repeated string snippets = 3;
  }
  repeated Result results = 1;
}
```

如果要在父消息类型之外重用此消息类型，请将其称为父消息类型。类型：
```cpp
message SomeOtherMessage {
  SearchResponse.Result result = 1;
}
```

您可以根据自己的喜好将消息嵌套到最深的位置：
```cpp
message Outer {                  // Level 0
  message MiddleAA {  // Level 1
    message Inner {   // Level 2
      int64 ival = 1;
      bool  booly = 2;
    }
  }
  message MiddleBB {  // Level 1
    message Inner {   // Level 2
      int32 ival = 1;
      bool  booly = 2;
    }
  }
}
```

# 更新消息类型

# 未知类型
未知字段是格式良好的协议缓冲区序列化数据，表示解析程序无法识别的字段。例如，当一个旧的二进制文件用新字段解析新二进制文件发送的数据时，这些新字段就变成旧二进制文件中的未知字段。
最初，Proto3消息在解析过程中总是丢弃未知字段，但在3.5版中，我们重新引入了保留未知字段以匹配Proto2行为。在3.5及更高版本中，解析期间会保留未知字段，并包含在序列化输出中。

# Any
any消息类型允许您将消息用作嵌入类型，而不具有它们的.proto定义。any包含一个任意的序列化消息（字节），以及一个充当该消息类型的全局唯一标识符并解析为该消息类型的URL。要使用任何类型，您需要导入google/protobuf/any.proto。
```cpp
import "google/protobuf/any.proto";

message ErrorStatus {
  string message = 1;
  repeated google.protobuf.Any details = 2;
}
```

给定消息类型的默认类型url为type.googleapis.com/packagename.messagename。
不同的语言实现将支持运行库帮助器以类型化的方式打包和解开任何值。例如，在Java中，任何类型都有特殊的pack()和unpack()访问器，而在C++中，有PackFrom()和UnpackTo()方法：
```cpp
// Storing an arbitrary message type in Any.
NetworkErrorDetails details = ...;
ErrorStatus status;
status.add_details()->PackFrom(details);

// Reading an arbitrary message from Any.
ErrorStatus status = ...;
for (const Any& detail : status.details()) {
  if (detail.Is<NetworkErrorDetails>()) {
    NetworkErrorDetails network_error;
    detail.UnpackTo(&network_error);
    ... processing network_error ...
  }
}
```

当前正在开发用于处理任何类型的运行库。如果您已经熟悉proto2语法，那么any类型将替换扩展。

# Oneof
## 使用Oneof
## Oneof特性
## 兼容性
# Maps
## 兼容性
# Packages
# 定义服务
# Json Mapping
Proto3支持JSON中的规范化编码，使得在系统之间共享数据更加容易。下表按类型描述了编码。
如果JSON编码的数据中缺少一个值，或者它的值为空，那么当解析到协议缓冲区时，它将被解释为适当的默认值。如果一个字段在协议缓冲区中有默认值，那么默认情况下，它将在JSON编码的数据中被省略，以节省空间。一个实现可以提供在JSON编码的输出中使用默认值发出字段的选项

<style> 
table th {
 white-space: nowrap; /*表头内容强制在一行显示*/
}
table td:nth-child(1) {
 white-space: nowrap; 
}
table td:nth-child(2) {
 white-space: nowrap; 
}
 </style>

| `.proto3` | `JSON` | `JSON example` | `Notes` |
| --- | --- | --- | --- |
| message | object | `{"fooBar": v, "g": null,…}` | Generates JSON objects. Message field names are mapped to lowerCamelCase and become JSON object keys. If the `json_name` field option is specified, the specified value will be used as the key instead. Parsers accept both the lowerCamelCase name (or the one specified by the `json_name` option) and the original proto field name. `null` is an accepted value for all field types and treated as the default value of the corresponding field type. |
| enum | string | `"FOO_BAR"` | The name of the enum value as specified in proto is used. Parsers accept both enum names and integer values. |
| map<K,V> | object | `{"k": v, …}` | All keys are converted to strings. |
| repeated V | array | `[v, …]` | `null` is accepted as the empty list []. |
| bool | true, false | `true, false` |  |
| string | string | `"Hello World!"` |  |
| bytes | base64 string | `"YWJjMTIzIT8kKiYoKSctPUB+"` | JSON value will be the data encoded as a string using standard base64 encoding with paddings. Either standard or URL-safe base64 encoding with/without paddings are accepted. |
| int32, fixed32, uint32 | number | `1, -10, 0` | JSON value will be a decimal number. Either numbers or strings are accepted. |
| int64, fixed64, uint64 | string | `"1", "-10"` | JSON value will be a decimal string. Either numbers or strings are accepted. |
| float, double | number | `1.1, -10.0, 0, "NaN","Infinity"` | JSON value will be a number or one of the special string values "NaN", "Infinity", and "-Infinity". Either numbers or strings are accepted. Exponent notation is also accepted. |
| Any | `object` | `{"@type": "url", "f": v, … }` | If the Any contains a value that has a special JSON mapping, it will be converted as follows: `{"@type": xxx, "value": yyy}`. Otherwise, the value will be converted into a JSON object, and the `"@type"` field will be inserted to indicate the actual data type. |
| Timestamp | string | `"1972-01-01T10:00:20.021Z"` | Uses RFC 3339, where generated output will always be Z-normalized and uses 0, 3, 6 or 9 fractional digits. Offsets other than "Z" are also accepted. |
| Duration | string | `"1.000340012s", "1s"` | Generated output always contains 0, 3, 6, or 9 fractional digits, depending on required precision, followed by the suffix "s". Accepted are any fractional digits (also none) as long as they fit into nano-seconds precision and the suffix "s" is required. |
| Struct | `object` | `{ … }` | Any JSON object. See `struct.proto`. |
| Wrapper types | various types | `2, "2", "foo", true,"true", null, 0, …` | Wrappers use the same representation in JSON as the wrapped primitive type, except that `null` is allowed and preserved during data conversion and transfer. |
| FieldMask | string | `"f.fooBar,h"` | See `field_mask.proto`. |
| ListValue | array | `[foo, bar, …]` |  |
| Value | value |  | Any JSON value |
| NullValue | null |  | JSON null |

## JSON 选项
Proto3 JSON实现可以提供以下选项：
* 使用默认值发出字段
* 忽略未知字段
* 使用proto字段名而不是lowercamelcase名称
* 将枚举值作为整数而不是字符串发出

# 选项
# 生成代码

