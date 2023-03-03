---
author: djaigo
title: golang-单元测试
categories:
  - golang
date: 2021-05-13 16:05:32
tags:
---

推荐阅读：[golang test](https://golang.org/pkg/testing/)

# 命令行操作

## 帮助文档
`go test`帮助文档

```text
➜ go help test                               
usage: go test [build/test flags] [packages] [build/test flags & test binary flags]

'Go test' automates testing the packages named by the import paths.
It prints a summary of the test results in the format:

        ok   archive/tar   0.011s
        FAIL archive/zip   0.022s
        ok   compress/gzip 0.033s
        ...

followed by detailed output for each failed package.

'Go test' recompiles each package along with any files with names matching
the file pattern "*_test.go".
These additional files can contain test functions, benchmark functions, and
example functions. See 'go help testfunc' for more.
Each listed package causes the execution of a separate test binary.
Files whose names begin with "_" (including "_test.go") or "." are ignored.

Test files that declare a package with the suffix "_test" will be compiled as a
separate package, and then linked and run with the main test binary.

The go tool will ignore a directory named "testdata", making it available
to hold ancillary data needed by the tests.

As part of building a test binary, go test runs go vet on the package
and its test source files to identify significant problems. If go vet
finds any problems, go test reports those and does not run the test
binary. Only a high-confidence subset of the default go vet checks are
used. That subset is: 'atomic', 'bool', 'buildtags', 'errorsas',
'ifaceassert', 'nilfunc', 'printf', and 'stringintconv'. You can see
the documentation for these and other vet tests via "go doc cmd/vet".
To disable the running of go vet, use the -vet=off flag.

All test output and summary lines are printed to the go command's
standard output, even if the test printed them to its own standard
error. (The go command's standard error is reserved for printing
errors building the tests.)

Go test runs in two different modes:

The first, called local directory mode, occurs when go test is
invoked with no package arguments (for example, 'go test' or 'go
test -v'). In this mode, go test compiles the package sources and
tests found in the current directory and then runs the resulting
test binary. In this mode, caching (discussed below) is disabled.
After the package test finishes, go test prints a summary line
showing the test status ('ok' or 'FAIL'), package name, and elapsed
time.

The second, called package list mode, occurs when go test is invoked
with explicit package arguments (for example 'go test math', 'go
test ./...', and even 'go test .'). In this mode, go test compiles
and tests each of the packages listed on the command line. If a
package test passes, go test prints only the final 'ok' summary
line. If a package test fails, go test prints the full test output.
If invoked with the -bench or -v flag, go test prints the full
output even for passing package tests, in order to display the
requested benchmark results or verbose logging. After the package
tests for all of the listed packages finish, and their output is
printed, go test prints a final 'FAIL' status if any package test
has failed.

In package list mode only, go test caches successful package test
results to avoid unnecessary repeated running of tests. When the
result of a test can be recovered from the cache, go test will
redisplay the previous output instead of running the test binary
again. When this happens, go test prints '(cached)' in place of the
elapsed time in the summary line.

The rule for a match in the cache is that the run involves the same
test binary and the flags on the command line come entirely from a
restricted set of 'cacheable' test flags, defined as -cpu, -list,
-parallel, -run, -short, and -v. If a run of go test has any test
or non-test flags outside this set, the result is not cached. To
disable test caching, use any test flag or argument other than the
cacheable flags. The idiomatic way to disable test caching explicitly
is to use -count=1\. Tests that open files within the package's source
root (usually $GOPATH) or that consult environment variables only
match future runs in which the files and environment variables are unchanged.
A cached test result is treated as executing in no time at all,
so a successful package test result will be cached and reused
regardless of -timeout setting.

In addition to the build flags, the flags handled by 'go test' itself are:

        -args
            Pass the remainder of the command line (everything after -args)
            to the test binary, uninterpreted and unchanged.
            Because this flag consumes the remainder of the command line,
            the package list (if present) must appear before this flag.

        -c
            Compile the test binary to pkg.test but do not run it
            (where pkg is the last element of the package's import path).
            The file name can be changed with the -o flag.

        -exec xprog
            Run the test binary using xprog. The behavior is the same as
            in 'go run'. See 'go help run' for details.

        -i
            Install packages that are dependencies of the test.
            Do not run the test.
            The -i flag is deprecated. Compiled packages are cached automatically.

        -json
            Convert test output to JSON suitable for automated processing.
            See 'go doc test2json' for the encoding details.

        -o file
            Compile the test binary to the named file.
            The test still runs (unless -c or -i is specified).

The test binary also accepts flags that control execution of the test; these
flags are also accessible by 'go test'. See 'go help testflag' for details.

For more about build flags, see 'go help build'.
For more about specifying packages, see 'go help packages'.

See also: go build, go vet.

```

将当前包的测试文件编译成二进制后的帮助文档

```text
➜ go.test -h 
Usage of go.test:
-test.bench regexp
run only benchmarks matching regexp
-test.benchmem
print memory allocations for benchmarks
-test.benchtime d
run each benchmark for duration d (default 1s)
-test.blockprofile file
write a goroutine blocking profile to file
-test.blockprofilerate rate
set blocking profile rate (see runtime.SetBlockProfileRate) (default 1)
-test.count n
run tests and benchmarks n times (default 1)
-test.coverprofile file
write a coverage profile to file
-test.cpu list
comma-separated list of cpu counts to run each test with
-test.cpuprofile file
write a cpu profile to file
-test.failfast
do not start new tests after the first test failure
-test.list regexp
list tests, examples, and benchmarks matching regexp then exit
-test.memprofile file
write an allocation profile to file
-test.memprofilerate rate
set memory allocation profiling rate (see runtime.MemProfileRate)
-test.mutexprofile string
write a mutex contention profile to the named file after execution
-test.mutexprofilefraction int
if >= 0, calls runtime.SetMutexProfileFraction() (default 1)
-test.outputdir dir
write profiles to dir
-test.paniconexit0
panic on call to os.Exit(0)
-test.parallel n
run at most n tests in parallel (default 4)
-test.run regexp
run only tests and examples matching regexp
-test.short
run smaller test suite to save time
-test.testlogfile file
write test action log to file (for use only by cmd/go)
-test.timeout d
panic test binary after duration d (default 0, timeout disabled)
-test.trace file
write an execution trace to file
-test.v
verbose: print additional output

```

## 常用操作

由于包和二进制的操作方法类似，这里仅使用包作为示例。

单测函数只能写在以`_test.go`结尾的文件中，且函数名必须以Test开头，函数参数只能有一个参数必须是`*testing.T`类型，例如：
```go
func TestFunc(t *testing.T) {
    // do something
}
```

该单测函数可以实现任何逻辑，一个单测文件中可以有多个单测函数。

写完单测函数后，可以通过`go test -run TestFunc`命令，执行该单测函数。如果只执行`go test`就会执行当前包下的所有单测函数。`-run`后面可以是正则表达式，已匹配合适的函数组。

单测函数一般用于检测单个函数的正确性，同时也可以通过单测函数获取函数的代码覆盖率、CPU消耗、内存消耗等性能统计数据，用于分析被测函数的性能瓶颈点。

> [官方博客](https://blog.golang.org/pprof)介绍了更多关于pprof的设计理念。

例如：
```sh
➜ go test -coverprofile cover.out -cpuprofile cpu.out -memprofile mem.out -run TestFunc
```

执行后会生成三个文件，`cover.out`、`cpu.out`、`mem.out`，这些文件可以通过`go tool`打开，`cover.out`有`cover`工具打开，`cpu.out`和`mem.out`由`pprof`工具打开。

> 命令：`go tool cover -help`和`go tool pprof -help`可打印帮助文档。

例如：
```sh
➜ go tool pprof cpu.out
```

执行后会进入命令行模式操作，可以根据自己的需求输入不同命令。

命令行操作模式不是很优雅，golang提供了网页的方式，将内容更优雅的展现，
```sh
➜ go tool pprof -http=0.0.0.0:8888 cpu.out
```

在网页的VIEW下拉列表中：
* Top，通过列表的方式，由高到低显示相关信息
* Graph，通过图形连线的方式，显示各个节点调用关系和相关信息
* Flame Graph，通过火焰图展示各个节点调用关系和相关信息
* Peek，通过列表的方式，由高到低显示调用链的相关信息
* Source，以源码的方式，由高到低显示相关信息

其他操作可以参考上面的帮助文档。


# Goland操作
写完单测后，在单测函数名左边会有绿色小按钮，点击会出现下拉列表，包括常见一些运行操作条件，选中执行后，goland会自动将进行可视化展示。