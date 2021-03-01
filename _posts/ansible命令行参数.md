---
author: djaigo
title: ansible命令行参数
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/golang.png'
categories:
  - ansible
tags:
date: 2021-01-26 11:50:03
---

# ansible
```text
$ ansible --help
usage: ansible [-h] [--version] [-v] [-b] [--become-method BECOME_METHOD]
               [--become-user BECOME_USER] [-K] [-i INVENTORY] [--list-hosts]
               [-l SUBSET] [-P POLL_INTERVAL] [-B SECONDS] [-o] [-t TREE] [-k]
               [--private-key PRIVATE_KEY_FILE] [-u REMOTE_USER]
               [-c CONNECTION] [-T TIMEOUT]
               [--ssh-common-args SSH_COMMON_ARGS]
               [--sftp-extra-args SFTP_EXTRA_ARGS]
               [--scp-extra-args SCP_EXTRA_ARGS]
               [--ssh-extra-args SSH_EXTRA_ARGS] [-C] [--syntax-check] [-D]
               [-e EXTRA_VARS] [--vault-id VAULT_IDS]
               [--ask-vault-pass | --vault-password-file VAULT_PASSWORD_FILES]
               [-f FORKS] [-M MODULE_PATH] [--playbook-dir BASEDIR]
               [-a MODULE_ARGS] [-m MODULE_NAME]
               pattern

Define and run a single task 'playbook' against a set of hosts

positional arguments:
  pattern               host pattern

optional arguments:
  --ask-vault-pass      ask for vault password
  --list-hosts          显示匹配主机列表
  --playbook-dir BASEDIR
                        Since this tool does not use playbooks, use this as a
                        substitute playbook directory.This sets the relative
                        path for many features including roles/ group_vars/
                        etc.
  --syntax-check        在playbook上进行语法检测，但不执行
  --vault-id VAULT_IDS  the vault identity to use
  --vault-password-file VAULT_PASSWORD_FILES
                        vault password file
  --version             显示程序的版本号，配置文件位置，配置的模块搜索路径，
                        模块位置，可执行文件位置和退出
  -B SECONDS, --background SECONDS
                        异步运行，SECONDS后失败 (default=N/A)
  -C, --check           不做任何变化，尝试预测发生的变化
  -D, --diff            更改小文件时显示文件的不同，与--check搭配起来更好
  -M MODULE_PATH, --module-path MODULE_PATH
                        用冒号分隔添加模块库路径 (default=~/.ansible/plu
                        gins/modules:/usr/share/ansible/plugins/modules)
  -P POLL_INTERVAL, --poll POLL_INTERVAL
                        如果设置了-B 则设置轮询间隔 (default=15)
  -a MODULE_ARGS, --args MODULE_ARGS
                        模块使用参数
  -e EXTRA_VARS, --extra-vars EXTRA_VARS
                        设置额外的变量或文件变量（key=value 或 YAML/JSON），
                        如果是文件则需要在前面加上 @
  -f FORKS, --forks FORKS
                        指定并发运行的进程数 (default=5)
  -h, --help            打印帮助文档
  -i INVENTORY, --inventory INVENTORY, --inventory-file INVENTORY
                        指定主机列表文件或用逗号隔开主机列表，--inventory-file已经弃用
  -l SUBSET, --limit SUBSET
                        further limit selected hosts to an additional pattern
  -m MODULE_NAME, --module-name MODULE_NAME
                        指定执行模块 (default=command)
  -o, --one-line        输出日志为一行
  -t TREE, --tree TREE  log output to this directory
  -v, --verbose         详细模式 (-vvv 展示更多, -vvvv 开启连接调试)

Privilege Escalation Options:
  control how and which user you become as on target hosts

  --become-method BECOME_METHOD
                        使用指定的切换用户方法 (default=sudo), 使用
                        `ansible-doc -t become -l`显示有效的选择
  --become-user BECOME_USER
                        使用指定用户执行操作 (default=root)
  -K, --ask-become-pass
                        设置切换用户密码
  -b, --become          用become执行操作 (没有密码提示)

Connection Options:
  control as whom and how to connect to hosts

  --private-key PRIVATE_KEY_FILE, --key-file PRIVATE_KEY_FILE
                        使用私钥文件认证连接
  --scp-extra-args SCP_EXTRA_ARGS
                        specify extra arguments to pass to scp only (e.g. -l)
  --sftp-extra-args SFTP_EXTRA_ARGS
                        specify extra arguments to pass to sftp only (e.g. -f,
                        -l)
  --ssh-common-args SSH_COMMON_ARGS
                        specify common arguments to pass to sftp/scp/ssh (e.g.
                        ProxyCommand)
  --ssh-extra-args SSH_EXTRA_ARGS
                        specify extra arguments to pass to ssh only (e.g. -R)
  -T TIMEOUT, --timeout TIMEOUT
                        设置连接超时 (default=10)
  -c CONNECTION, --connection CONNECTION
                        设置连接类型 (default=smart)
  -k, --ask-pass        询问连接密码
  -u REMOTE_USER, --user REMOTE_USER
                        远端连接用户 (default=None)

Some modules do not make sense in Ad-Hoc (include, meta, etc)
```

# ansible-doc
```text
$ ansible-doc -h
usage: ansible-doc [-h] [--version] [-v] [-M MODULE_PATH]
                   [--playbook-dir BASEDIR]
                   [-t {become,cache,callback,cliconf,connection,httpapi,inventory,lookup,shell,module,strategy,vars}]
                   [-j] [-F | -l | -s | --metadata-dump]
                   [plugin [plugin ...]]

plugin documentation tool

positional arguments:
  plugin                Plugin

optional arguments:
  --metadata-dump       **For internal testing only** Dump json metadata for
                        all plugins.
  --playbook-dir BASEDIR
                        Since this tool does not use playbooks, use this as a
                        substitute playbook directory.This sets the relative
                        path for many features including roles/ group_vars/
                        etc.
  --version             show program's version number, config file location,
                        configured module search path, module location,
                        executable location and exit
  -F, --list_files      Show plugin names and their source files without
                        summaries (implies --list)
  -M MODULE_PATH, --module-path MODULE_PATH
                        prepend colon-separated path(s) to module library (def
                        ault=~/.ansible/plugins/modules:/usr/share/ansible/plu
                        gins/modules)
  -h, --help            show this help message and exit
  -j, --json            Change output into json format.
  -l, --list            List available plugins
  -s, --snippet         Show playbook snippet for specified plugin(s)
  -t {become,cache,callback,cliconf,connection,httpapi,inventory,lookup,shell,module,strategy,vars}, --type {become,cache,callback,cliconf,connection,httpapi,inventory,lookup,shell,module,strategy,vars}
                        Choose which plugin type (defaults to "module").
                        Available plugin types are : ('become', 'cache',
                        'callback', 'cliconf', 'connection', 'httpapi',
                        'inventory', 'lookup', 'shell', 'module', 'strategy',
                        'vars')
  -v, --verbose         verbose mode (-vvv for more, -vvvv to enable
                        connection debugging)

See man pages for Ansible CLI options or website for tutorials
https://docs.ansible.com
```


# ansible-playbook
```text
$ ansible-playbook -h
usage: ansible-playbook [-h] [--version] [-v] [-k]
                        [--private-key PRIVATE_KEY_FILE] [-u REMOTE_USER]
                        [-c CONNECTION] [-T TIMEOUT]
                        [--ssh-common-args SSH_COMMON_ARGS]
                        [--sftp-extra-args SFTP_EXTRA_ARGS]
                        [--scp-extra-args SCP_EXTRA_ARGS]
                        [--ssh-extra-args SSH_EXTRA_ARGS] [--force-handlers]
                        [--flush-cache] [-b] [--become-method BECOME_METHOD]
                        [--become-user BECOME_USER] [-K] [-t TAGS]
                        [--skip-tags SKIP_TAGS] [-C] [--syntax-check] [-D]
                        [-i INVENTORY] [--list-hosts] [-l SUBSET]
                        [-e EXTRA_VARS] [--vault-id VAULT_IDS]
                        [--ask-vault-pass | --vault-password-file VAULT_PASSWORD_FILES]
                        [-f FORKS] [-M MODULE_PATH] [--list-tasks]
                        [--list-tags] [--step] [--start-at-task START_AT_TASK]
                        playbook [playbook ...]

Runs Ansible playbooks, executing the defined tasks on the targeted hosts.

positional arguments:
  playbook              Playbook(s)

optional arguments:
  --ask-vault-pass      ask for vault password
  --flush-cache         clear the fact cache for every host in inventory
  --force-handlers      run handlers even if a task fails
  --list-hosts          outputs a list of matching hosts; does not execute
                        anything else
  --list-tags           list all available tags
  --list-tasks          list all tasks that would be executed
  --skip-tags SKIP_TAGS
                        only run plays and tasks whose tags do not match these
                        values
  --start-at-task START_AT_TASK
                        start the playbook at the task matching this name
  --step                one-step-at-a-time: confirm each task before running
  --syntax-check        perform a syntax check on the playbook, but do not
                        execute it
  --vault-id VAULT_IDS  the vault identity to use
  --vault-password-file VAULT_PASSWORD_FILES
                        vault password file
  --version             show program's version number, config file location,
                        configured module search path, module location,
                        executable location and exit
  -C, --check           don't make any changes; instead, try to predict some
                        of the changes that may occur
  -D, --diff            when changing (small) files and templates, show the
                        differences in those files; works great with --check
  -M MODULE_PATH, --module-path MODULE_PATH
                        prepend colon-separated path(s) to module library (def
                        ault=~/.ansible/plugins/modules:/usr/share/ansible/plu
                        gins/modules)
  -e EXTRA_VARS, --extra-vars EXTRA_VARS
                        set additional variables as key=value or YAML/JSON, if
                        filename prepend with @
  -f FORKS, --forks FORKS
                        specify number of parallel processes to use
                        (default=5)
  -h, --help            show this help message and exit
  -i INVENTORY, --inventory INVENTORY, --inventory-file INVENTORY
                        specify inventory host path or comma separated host
                        list. --inventory-file is deprecated
  -l SUBSET, --limit SUBSET
                        further limit selected hosts to an additional pattern
  -t TAGS, --tags TAGS  only run plays and tasks tagged with these values
  -v, --verbose         verbose mode (-vvv for more, -vvvv to enable
                        connection debugging)

Connection Options:
  control as whom and how to connect to hosts

  --private-key PRIVATE_KEY_FILE, --key-file PRIVATE_KEY_FILE
                        use this file to authenticate the connection
  --scp-extra-args SCP_EXTRA_ARGS
                        specify extra arguments to pass to scp only (e.g. -l)
  --sftp-extra-args SFTP_EXTRA_ARGS
                        specify extra arguments to pass to sftp only (e.g. -f,
                        -l)
  --ssh-common-args SSH_COMMON_ARGS
                        specify common arguments to pass to sftp/scp/ssh (e.g.
                        ProxyCommand)
  --ssh-extra-args SSH_EXTRA_ARGS
                        specify extra arguments to pass to ssh only (e.g. -R)
  -T TIMEOUT, --timeout TIMEOUT
                        override the connection timeout in seconds
                        (default=10)
  -c CONNECTION, --connection CONNECTION
                        connection type to use (default=smart)
  -k, --ask-pass        ask for connection password
  -u REMOTE_USER, --user REMOTE_USER
                        connect as this user (default=None)

Privilege Escalation Options:
  control how and which user you become as on target hosts

  --become-method BECOME_METHOD
                        privilege escalation method to use (default=sudo), use
                        `ansible-doc -t become -l` to list valid choices.
  --become-user BECOME_USER
                        run operations as this user (default=root)
  -K, --ask-become-pass
                        ask for privilege escalation password
  -b, --become          run operations with become (does not imply password
                        prompting)
```


# 参考文献
* [Ansible中文权威指南](https://ansible-tran.readthedocs.io/en/latest/index.html)
* [Ansible Documentation](https://docs.ansible.com/ansible/latest/index.html)