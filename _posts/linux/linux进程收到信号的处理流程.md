---
author: djaigo
title: linux进程收到信号的处理流程
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/linux.png'
categories:
  - linux
tags:
  - signal
  - process
  - kernel
---

信号（Signal）是 Linux 系统中进程间通信的一种机制，用于通知进程发生了某个事件。当进程收到信号后，系统会按照特定的流程处理该信号。本文档详细说明 Linux 进程收到信号后的完整处理流程。

# 信号的基本概念

## 什么是信号

信号是 Linux 系统中一种异步通知机制，用于：
- 通知进程发生了某个事件
- 请求进程执行某个操作
- 中断进程的正常执行流程

## 信号的分类

### 按行为分类

| 类型 | 说明 | 示例 |
|------|------|------|
| **终止信号** | 导致进程终止 | SIGTERM, SIGKILL, SIGQUIT |
| **忽略信号** | 进程可以忽略 | SIGCHLD（默认忽略） |
| **停止信号** | 暂停进程执行 | SIGSTOP, SIGTSTP |
| **继续信号** | 恢复暂停的进程 | SIGCONT |
| **错误信号** | 由硬件异常产生 | SIGSEGV, SIGFPE, SIGILL |

### 按可处理性分类

| 类型 | 说明 | 示例 |
|------|------|------|
| **可捕获信号** | 可以注册处理函数 | SIGTERM, SIGINT, SIGHUP |
| **不可捕获信号** | 无法注册处理函数 | SIGKILL, SIGSTOP |

## 常用信号列表

| 信号编号 | 信号名 | 默认行为 | 说明 |
|---------|--------|---------|------|
| 1 | SIGHUP | 终止 | 挂起信号，终端关闭时发送 |
| 2 | SIGINT | 终止 | 中断信号（Ctrl+C） |
| 3 | SIGQUIT | 终止+核心转储 | 退出信号（Ctrl+\） |
| 9 | SIGKILL | 终止 | 强制终止，不可捕获 |
| 11 | SIGSEGV | 终止+核心转储 | 段错误 |
| 13 | SIGPIPE | 终止 | 管道破裂 |
| 14 | SIGALRM | 终止 | 定时器信号 |
| 15 | SIGTERM | 终止 | 终止信号（可捕获） |
| 17 | SIGCHLD | 忽略 | 子进程状态改变 |
| 18 | SIGCONT | 继续 | 继续执行 |
| 19 | SIGSTOP | 停止 | 停止信号，不可捕获 |
| 20 | SIGTSTP | 停止 | 终端停止信号（Ctrl+Z） |

# 信号处理的完整流程

## 流程图概览

```
发送信号 (kill/signal)
    ↓
内核检查权限
    ↓
信号投递到目标进程
    ↓
检查信号掩码（是否被阻塞）
    ↓
信号被阻塞？ → 是 → 加入待处理信号集（pending）
    ↓ 否
检查信号处理方式
    ↓
┌─────────────────┬─────────────────┬─────────────────┐
│  默认处理        │  忽略信号        │  自定义处理函数   │
│  (SIG_DFL)       │  (SIG_IGN)       │  (用户函数)      │
└─────────────────┴─────────────────┴─────────────────┘
    ↓                    ↓                    ↓
执行默认动作        直接返回            切换到用户空间
(终止/停止等)                             执行处理函数
```

## 详细处理步骤

### 1. 信号发送阶段

```sh
# 用户空间发送信号
➜ kill -TERM 1234

# 或程序内部发送
raise(SIGTERM);
kill(getpid(), SIGTERM);
```

**内核操作：**
- 检查发送者权限（能否向目标进程发送信号）
- 验证目标进程是否存在
- 将信号加入目标进程的信号队列

### 2. 信号投递阶段

内核在以下时机检查并投递信号：
- 从系统调用返回用户空间时
- 从中断/异常处理返回用户空间时
- 进程从睡眠状态被唤醒时

### 3. 信号处理阶段

#### 3.1 检查信号掩码（Signal Mask）

```c
// 信号掩码决定哪些信号被阻塞
sigset_t mask;
sigemptyset(&mask);
sigaddset(&mask, SIGINT);
sigprocmask(SIG_BLOCK, &mask, NULL);  // 阻塞 SIGINT
```

**如果信号被阻塞：**
- 信号被加入待处理信号集（pending set）
- 进程继续执行，不处理该信号
- 直到信号被解除阻塞后才处理

**如果信号未被阻塞：**
- 进入下一步处理

#### 3.2 检查信号处理方式

每个信号有三种可能的处理方式：

```c
// 1. 默认处理 (SIG_DFL)
signal(SIGTERM, SIG_DFL);

// 2. 忽略信号 (SIG_IGN)
signal(SIGTERM, SIG_IGN);

// 3. 自定义处理函数
void handler(int sig) {
    // 处理信号
}
signal(SIGTERM, handler);
```

#### 3.3 执行相应的处理

**默认处理（SIG_DFL）：**
- 内核直接执行默认动作
- 如：SIGTERM → 终止进程，SIGSTOP → 停止进程

**忽略信号（SIG_IGN）：**
- 直接丢弃信号，进程继续执行

**自定义处理函数：**
- 内核切换到用户空间
- 执行用户注册的信号处理函数
- 处理函数执行完毕后返回

### 4. 信号处理函数执行

```c
void signal_handler(int signo) {
    // 1. 保存当前上下文
    // 2. 设置新的信号掩码（可选）
    // 3. 执行用户代码
    printf("Received signal %d\n", signo);
    // 4. 恢复上下文
    // 5. 返回
}
```

**注意事项：**
- 信号处理函数应该是可重入的（reentrant）
- 避免在信号处理函数中使用不可重入的函数（如 malloc, printf）
- 信号处理函数执行时，可能被其他信号中断

### 5. 从信号处理返回

处理函数执行完毕后：
- 恢复进程的执行上下文
- 继续执行被信号中断的代码
- 或执行 sigreturn 系统调用返回内核

# 内核层面的处理

## 进程的信号相关数据结构

```c
// 内核中的进程结构（简化）
struct task_struct {
    // ...
    struct sigpending pending;      // 待处理信号队列
    sigset_t blocked;                // 阻塞信号掩码
    struct sigaction sigaction[64];  // 信号处理动作数组
    // ...
};

// 待处理信号结构
struct sigpending {
    struct list_head list;           // 信号链表
    sigset_t signal;                 // 信号位图
};

// 信号处理动作
struct sigaction {
    __sighandler_t sa_handler;       // 处理函数指针
    sigset_t sa_mask;                // 执行处理函数时阻塞的信号
    unsigned long sa_flags;          // 标志位
    void (*sa_restorer)(void);       // 恢复函数
};
```

## 内核信号处理流程

### 1. 信号发送（send_signal）

```c
// 内核发送信号的流程（简化）
int send_signal(int sig, struct task_struct *t, int group) {
    // 1. 检查权限
    if (!check_permission(sig, t))
        return -EPERM;
    
    // 2. 创建信号结构
    struct sigqueue *q = sigqueue_alloc();
    q->info.si_signo = sig;
    
    // 3. 将信号加入目标进程的待处理队列
    sigaddset(&t->pending.signal, sig);
    list_add_tail(&q->list, &t->pending.list);
    
    // 4. 唤醒目标进程（如果被阻塞）
    if (t->state & TASK_INTERRUPTIBLE)
        wake_up_process(t);
    
    return 0;
}
```

### 2. 信号投递（deliver_signal）

```c
// 内核投递信号的时机
void do_signal(struct pt_regs *regs) {
    struct sigpending *pending;
    struct sigaction *sa;
    int signr;
    
    // 1. 获取待处理信号
    pending = &current->pending;
    
    // 2. 查找第一个未阻塞的待处理信号
    signr = dequeue_signal(current, &current->blocked, &info);
    if (signr == 0)
        return;  // 没有待处理信号
    
    // 3. 获取信号处理动作
    sa = &current->sigaction[signr];
    
    // 4. 根据处理方式执行
    if (sa->sa_handler == SIG_IGN) {
        // 忽略信号
        return;
    } else if (sa->sa_handler == SIG_DFL) {
        // 默认处理
        do_default_action(signr);
    } else {
        // 用户自定义处理函数
        handle_signal(signr, sa, regs);
    }
}
```

### 3. 用户空间处理函数调用

```c
// 设置用户空间信号处理函数
void handle_signal(int sig, struct sigaction *sa, struct pt_regs *regs) {
    // 1. 保存当前寄存器上下文
    // 2. 修改用户空间栈，设置信号处理函数参数
    // 3. 修改程序计数器（PC）指向信号处理函数
    // 4. 设置返回地址为 sigreturn
    // 5. 返回用户空间执行处理函数
}
```

# 信号掩码和阻塞

## 信号掩码的作用

信号掩码（Signal Mask）用于控制哪些信号被阻塞（blocked），被阻塞的信号不会立即处理，而是加入待处理信号集。

## 信号掩码操作

```c
#include <signal.h>

// 设置信号掩码
sigset_t mask;
sigemptyset(&mask);           // 清空掩码
sigaddset(&mask, SIGINT);     // 添加 SIGINT 到掩码
sigaddset(&mask, SIGTERM);    // 添加 SIGTERM 到掩码
sigprocmask(SIG_BLOCK, &mask, NULL);  // 阻塞掩码中的信号

// 解除阻塞
sigprocmask(SIG_UNBLOCK, &mask, NULL);

// 替换信号掩码
sigprocmask(SIG_SETMASK, &mask, NULL);
```

## 临时阻塞信号

```c
// 在执行关键代码段时临时阻塞信号
sigset_t oldmask, newmask;
sigemptyset(&newmask);
sigaddset(&newmask, SIGINT);

// 阻塞信号
sigprocmask(SIG_BLOCK, &newmask, &oldmask);

// 关键代码段（不会被 SIGINT 中断）
critical_section();

// 恢复原来的信号掩码
sigprocmask(SIG_SETMASK, &oldmask, NULL);
```

# 实际代码示例

## 示例1：基本的信号处理

```c
#include <stdio.h>
#include <signal.h>
#include <unistd.h>

// 信号处理函数
void sig_handler(int signo) {
    if (signo == SIGINT) {
        printf("Received SIGINT (Ctrl+C)\n");
    } else if (signo == SIGTERM) {
        printf("Received SIGTERM\n");
    }
}

int main() {
    // 注册信号处理函数
    if (signal(SIGINT, sig_handler) == SIG_ERR) {
        perror("signal");
        return 1;
    }
    
    if (signal(SIGTERM, sig_handler) == SIG_ERR) {
        perror("signal");
        return 1;
    }
    
    printf("Process PID: %d\n", getpid());
    printf("Waiting for signal...\n");
    
    // 无限循环，等待信号
    while (1) {
        pause();  // 暂停，等待信号
    }
    
    return 0;
}
```

**编译运行：**
```sh
gcc -o signal_demo signal_demo.c
./signal_demo
# 在另一个终端：kill -TERM <PID>
```

## 示例2：使用 sigaction（推荐方式）

```c
#include <stdio.h>
#include <signal.h>
#include <unistd.h>
#include <string.h>

void sig_handler(int signo, siginfo_t *info, void *context) {
    printf("Received signal %d from PID %d\n", 
           signo, info->si_pid);
}

int main() {
    struct sigaction sa;
    
    // 设置信号处理函数
    memset(&sa, 0, sizeof(sa));
    sa.sa_sigaction = sig_handler;
    sa.sa_flags = SA_SIGINFO;  // 使用 sa_sigaction 而不是 sa_handler
    
    // 在执行处理函数时阻塞其他信号
    sigemptyset(&sa.sa_mask);
    sigaddset(&sa.sa_mask, SIGTERM);
    
    // 注册信号处理
    if (sigaction(SIGINT, &sa, NULL) == -1) {
        perror("sigaction");
        return 1;
    }
    
    printf("Process PID: %d\n", getpid());
    printf("Press Ctrl+C to send SIGINT\n");
    
    while (1) {
        pause();
    }
    
    return 0;
}
```

## 示例3：信号掩码的使用

```c
#include <stdio.h>
#include <signal.h>
#include <unistd.h>

void sigint_handler(int sig) {
    printf("SIGINT handler called\n");
}

void sigterm_handler(int sig) {
    printf("SIGTERM handler called\n");
}

int main() {
    // 注册处理函数
    signal(SIGINT, sigint_handler);
    signal(SIGTERM, sigterm_handler);
    
    sigset_t mask, oldmask;
    sigemptyset(&mask);
    sigaddset(&mask, SIGINT);
    
    printf("Blocking SIGINT for 5 seconds...\n");
    
    // 阻塞 SIGINT
    sigprocmask(SIG_BLOCK, &mask, &oldmask);
    
    // 在这5秒内，SIGINT 会被阻塞
    sleep(5);
    
    printf("Unblocking SIGINT...\n");
    
    // 检查是否有待处理的 SIGINT
    sigset_t pending;
    sigpending(&pending);
    if (sigismember(&pending, SIGINT)) {
        printf("SIGINT was pending and will be delivered now\n");
    }
    
    // 解除阻塞，待处理的信号会被立即处理
    sigprocmask(SIG_SETMASK, &oldmask, NULL);
    
    printf("SIGINT is now unblocked\n");
    
    while (1) {
        pause();
    }
    
    return 0;
}
```

## 示例4：处理多个信号

```c
#include <stdio.h>
#include <signal.h>
#include <unistd.h>

volatile sig_atomic_t flag = 0;

void handler(int sig) {
    if (sig == SIGUSR1) {
        flag = 1;
        printf("Received SIGUSR1, setting flag\n");
    } else if (sig == SIGUSR2) {
        flag = 2;
        printf("Received SIGUSR2, setting flag\n");
    }
}

int main() {
    signal(SIGUSR1, handler);
    signal(SIGUSR2, handler);
    
    printf("Process PID: %d\n", getpid());
    printf("Send SIGUSR1 or SIGUSR2 to this process\n");
    
    while (1) {
        pause();  // 等待信号
        
        if (flag == 1) {
            printf("Processing SIGUSR1 action\n");
            flag = 0;
        } else if (flag == 2) {
            printf("Processing SIGUSR2 action\n");
            flag = 0;
        }
    }
    
    return 0;
}
```

# 信号处理的时机

## 信号投递的时机

信号在以下时机被检查和投递：

1. **从系统调用返回**
   ```c
   read(fd, buf, size);  // 系统调用
   // 返回时检查信号
   ```

2. **从中断/异常返回**
   ```c
   // 硬件中断处理完成后
   // 异常处理完成后
   ```

3. **进程被唤醒时**
   ```c
   sleep(10);  // 进程进入睡眠
   // 被信号唤醒时检查信号
   ```

4. **显式检查信号**
   ```c
   sigset_t pending;
   sigpending(&pending);  // 检查待处理信号
   ```

## 信号处理的原子性

- 信号处理函数执行期间，相同的信号默认会被阻塞
- 可以使用 `sa_mask` 指定在处理函数执行时阻塞其他信号
- 这确保了信号处理的原子性

# 特殊信号的处理

## SIGKILL 和 SIGSTOP

这两个信号的特殊之处：
- **无法被捕获**：不能注册处理函数
- **无法被阻塞**：不能通过信号掩码阻塞
- **无法被忽略**：必须执行默认动作

```c
// 以下操作都会失败
signal(SIGKILL, handler);        // 错误
signal(SIGSTOP, handler);       // 错误
sigprocmask(SIG_BLOCK, &mask);  // SIGKILL/SIGSTOP 无法被阻塞
```

## SIGCHLD 信号

子进程状态改变时发送给父进程：

```c
#include <stdio.h>
#include <signal.h>
#include <sys/wait.h>
#include <unistd.h>

void sigchld_handler(int sig) {
    int status;
    pid_t pid;
    
    // 处理所有已终止的子进程（避免僵尸进程）
    while ((pid = waitpid(-1, &status, WNOHANG)) > 0) {
        printf("Child %d terminated\n", pid);
    }
}

int main() {
    signal(SIGCHLD, sigchld_handler);
    
    pid_t pid = fork();
    if (pid == 0) {
        // 子进程
        sleep(2);
        exit(0);
    }
    
    // 父进程
    printf("Parent waiting for child...\n");
    while (1) {
        pause();
    }
    
    return 0;
}
```

## 实时信号（RT Signals）

Linux 支持实时信号（SIGRTMIN 到 SIGRTMAX）：

```c
// 实时信号的特点：
// 1. 可以排队（不会丢失）
// 2. 按顺序处理
// 3. 可以携带数据

union sigval value;
value.sival_int = 123;
sigqueue(pid, SIGRTMIN, value);  // 发送实时信号并携带数据
```

# 常见问题和注意事项

## 1. 信号处理函数应该是可重入的

```c
// 错误示例：使用不可重入函数
void handler(int sig) {
    printf("Signal received\n");  // printf 不是可重入的
    malloc(100);                   // malloc 不是可重入的
}

// 正确示例：使用可重入函数或设置标志
volatile sig_atomic_t flag = 0;

void handler(int sig) {
    flag = 1;  // 只设置标志，在主循环中处理
}
```

## 2. 信号可能丢失

标准信号（1-31）不支持排队，如果信号在处理期间再次到达，可能会丢失：

```c
// 解决方案：使用实时信号或信号掩码
sigset_t mask;
sigaddset(&mask, SIGINT);
sigprocmask(SIG_BLOCK, &mask, NULL);  // 阻塞信号
// 处理关键代码
sigprocmask(SIG_UNBLOCK, &mask, NULL);  // 解除阻塞
```

## 3. 信号处理函数的执行时间

信号处理函数应该尽可能简短，避免长时间阻塞：

```c
// 错误：长时间操作
void handler(int sig) {
    sleep(10);  // 不推荐
    complex_operation();  // 不推荐
}

// 正确：快速设置标志
void handler(int sig) {
    flag = 1;  // 快速返回
}
```

## 4. 信号处理中的系统调用

如果信号处理函数中断了阻塞的系统调用，系统调用可能返回 EINTR：

```c
while (1) {
    n = read(fd, buf, size);
    if (n == -1 && errno == EINTR) {
        // 被信号中断，重试
        continue;
    }
    break;
}
```

## 5. 信号处理函数中的异步安全函数

信号处理函数中只能使用异步安全（async-signal-safe）的函数：

**异步安全的函数：**
- `write()`
- `read()`（某些情况下）
- `_exit()`
- `sigaction()`
- `kill()`
- 等等

**不安全的函数：**
- `printf()`, `malloc()`, `free()`
- 大部分标准库函数

# 调试信号处理

## 使用 strace 跟踪信号

```sh
# 跟踪进程的信号操作
strace -e trace=signal -p <PID>

# 跟踪所有信号相关系统调用
strace -e signal -p <PID>
```

## 使用 gdb 调试

```sh
# 在 gdb 中设置信号处理断点
(gdb) handle SIGINT stop print
(gdb) handle SIGTERM stop print

# 查看信号处理函数
(gdb) info signals
```

## 查看进程的信号状态

```sh
# 查看进程的详细信息
cat /proc/<PID>/status | grep Sig

# 查看进程的信号掩码（需要 root）
cat /proc/<PID>/status
```

# 总结

Linux 进程收到信号的处理流程可以概括为：

1. **信号发送**：通过 kill、raise 等函数发送信号
2. **权限检查**：内核检查发送者是否有权限
3. **信号投递**：在适当的时机（系统调用返回、中断返回等）投递信号
4. **掩码检查**：检查信号是否被阻塞
5. **处理方式**：根据信号的处理方式（默认/忽略/自定义）执行相应操作
6. **用户处理**：如果是自定义处理函数，切换到用户空间执行
7. **返回恢复**：处理完成后恢复进程执行

理解这个流程对于编写健壮的 Linux 程序非常重要，特别是在处理信号、实现优雅关闭、处理异常情况等方面。

# 参考文献

* [Linux 信号机制详解](https://www.kernel.org/doc/html/latest/)
* [POSIX 信号处理](https://pubs.opengroup.org/onlinepubs/9699919799/)
* [Advanced Programming in the UNIX Environment](https://www.apuebook.com/)
* [Linux 内核源码 - signal.c](https://elixir.bootlin.com/linux/latest/source/kernel/signal.c)

