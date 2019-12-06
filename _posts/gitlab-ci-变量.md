---
title: GitLab CI/CD Variables
tags:
  - gitlab
  - ci
  - cd
categories:
  - gitlab


date: 2018-11-13 15:39:09
---

# GitLab CI/CD Variables
每当GitLab接收一个job，Runner就会准备构建环境，它会预定义的设置一些变量和用户定义的一些变量。
<!--more-->

## 变量优先级
变量会被优先级高的覆盖：
1. [Trigger variables](https://docs.gitlab.com/ce/ci/triggers/README.html#pass-job-variables-to-a-trigger) or [scheduled pipeline variables](https://docs.gitlab.com/ce/user/project/pipelines/schedules.html#making-use-of-scheduled-pipeline-variables) (最高优先级，优先于所有)
2.  Project-level [variables](https://docs.gitlab.com/ce/ci/variables/README.html#variables) or [protected variables](https://docs.gitlab.com/ce/ci/variables/README.html#protected-variables)
3.  Group-level [variables](https://docs.gitlab.com/ce/ci/variables/README.html#variables) or [protected variables](https://docs.gitlab.com/ce/ci/variables/README.html#protected-variables)
4.  YAML-defined [job-level variables](https://docs.gitlab.com/ce/ci/yaml/README.html#variables)
5.  YAML-defined [global variables](https://docs.gitlab.com/ce/ci/yaml/README.html#variables)
6.  [Deployment variables](https://docs.gitlab.com/ce/ci/variables/README.html#deployment-variables)
7.  [Predefined variables](https://docs.gitlab.com/ce/ci/variables/README.html#predefined-variables-environment-variables) (优先级最低)

例如，如果在`project variable`中定义`API_TOKEN=secure`和在`.gitlab-ci.yml`定义`API_TOKEN=yaml`，最终`API_TOKEN`的值将会是`secure`，因为`project variable`的优先级要高。

## 不支持的变量

There are cases where some variables cannot be used in the context of a `.gitlab-ci.yml` definition (for example under `script`). Read more about which variables are [not supported](https://docs.gitlab.com/ce/ci/variables/where_variables_can_be_used.html).

## Predefined variables (Environment variables)
下表显示了能使用的predefined variables的最低Runner版本。

**Note:** Starting with GitLab 9.0, we have deprecated some variables. Read the [9.0 Renaming](https://docs.gitlab.com/ce/ci/variables/README.html#9-0-renaming) section to find out their replacements. **You are strongly advised to use the new variables as we will remove the old ones in future GitLab releases.**

| Variable | GitLab | Runner | Description |
| --- | --- | --- | --- |
| **ARTIFACT_DOWNLOAD_ATTEMPTS** | 8.15 | 1.9 | 下载运行作业的工件的尝试次数 |
| **CI** | all | 0.4 | 标记该作业在当前CI环境中执行 |
| **CI_COMMIT_REF_NAME** | 9.0 | all | 当前构建项目的`branch`或`tag` |
| **CI_COMMIT_REF_SLUG** | 9.0 | all | `$CI_COMMIT_REF_NAME` lowercased, shortened to 63 bytes, and with everything except `0-9` and `a-z` replaced with `-`. No leading / trailing `-`. Use in URLs, host names and domain names. |
| **CI_COMMIT_SHA** | 9.0 | all | 构建项目的`commit revision` |
| **CI_COMMIT_BEFORE_SHA** | 11.2 | all | 在push请求前，branch上最新的`commit` |
| **CI_COMMIT_TAG** | 9.0 | 0.5 | `commit tag`名字，仅在构建标签时出现 |
| **CI_COMMIT_MESSAGE** | 10.8 | all | 所有的`commit message` |
| **CI_COMMIT_TITLE** | 10.8 | all | commit的title，即`commit message`的第一行 |
| **CI_COMMIT_DESCRIPTION** | 10.8 | all | 如果`commit`标题行没有100个字符，那么不会有第一行消息，其他情况下会有所有完整消息 |
| **CI_CONFIG_PATH** | 9.4 | 0.5 | CI配置文件的路径，默认`.gitlab-ci.yml` |
| **CI_DEBUG_TRACE** | all | 1.7 | 是否启用[debug tracing](https://docs.gitlab.com/ce/ci/variables/README.html#debug-tracing) |
| **CI_DEPLOY_USER** | 10.8 | all | 验证用户名[GitLab Deploy Token](https://docs.gitlab.com/ce/user/project/deploy_tokens/index.html#gitlab-deploy-token), 仅在`Project`有一个相关的情况下才会出现 |
| **CI_DEPLOY_PASSWORD** |  10.8 |  all |  [GitLab Deploy Token](https://docs.gitlab.com/ce/user/project/deploy_tokens/index.html#gitlab-deploy-token)的验证密码, 仅在`Project`有一个相关的情况下才会出现 |
| **CI_DISPOSABLE_ENVIRONMENT** | all | 10.1 | 确定作业是在一次性环境中执行的（只为此作业创建并在执行后处理/销毁，除`shell`和`ssh`之外的所有执行程序）。 |
| **CI_ENVIRONMENT_NAME** | 8.15 | all | 此job的环境名称 |
| **CI_ENVIRONMENT_SLUG** | 8.15 | all | 环境名称的简化版本，适合包含在DNS，URL，Kubernetes标签中 |
| **CI_ENVIRONMENT_URL** | 9.3 | all | job环境的URL |
| **CI_JOB_ID** | 9.0 | all | CI在内部使用的当前job的唯一ID |
| **CI_JOB_MANUAL** | 8.12 | all | 表示job是手动启动标志 |
| **CI_JOB_NAME** | 9.0 | 0.5 | `.gitlab-ci.yml`中定义的job名称 |
| **CI_JOB_STAGE** | 9.0 | 0.5 | `.gitlab-ci.yml`中定义的stage名称 |
| **CI_JOB_TOKEN** | 9.0 | 1.2 | Token used for authenticating with the [GitLab Container Registry](https://docs.gitlab.com/ce/user/project/container_registry.html) and downloading [dependent repositories](https://docs.gitlab.com/ce/user/project/new_ci_build_permissions_model.html#dependent-repositories) |
| **CI_NODE_INDEX** | 11.5 | all | job集种的索引，如果作业未并行化，则不设置此变量 |
| **CI_NODE_TOTAL** | 11.5 | all | 并行运行的此作业的实例总数。如果作业未并行化，则此变量设置为1。 |
| **CI_JOB_URL** | 11.1 | 0.5 | job详细URL |
| **CI_REPOSITORY_URL** | 9.0 | all | 克隆Git存储库的URL |
| **CI_RUNNER_DESCRIPTION** | 8.10 | 0.5 | gitlab中保存的runner的信息 |
| **CI_RUNNER_ID** | 8.10 | 0.5 | 将被使用runner的唯一id |
| **CI_RUNNER_TAGS** | 8.10 | 0.5 | 定义的runner tags |
| **CI_RUNNER_VERSION** | all | 10.6 | 正在执行当前作业的runner版本 |
| **CI_RUNNER_REVISION** | all | 10.6 | 正在执行当前作业的runner revision  |
| **CI_RUNNER_EXECUTABLE_ARCH** | all | 10.6 | The OS/architecture of the GitLab Runner executable (note that this is not necessarily the same as the environment of the executor) |
| **CI_PIPELINE_ID** | 8.10 | 0.5 | CI在内部使用的当前管道的唯一ID |
| **CI_PIPELINE_IID** | 11.0 | all | 作为项目范围的当前管道的唯一ID |
| **CI_PIPELINE_TRIGGERED** | all | all | 标志该作业已经[triggered](https://docs.gitlab.com/ce/ci/triggers/README.html) |
| **CI_PIPELINE_SOURCE** | 10.0 | all | 指示管道是如何触发的。可能的选项包括：`push`, `web`, `trigger`, `schedule`, `api`, `pipeline`。对于在GitLab 9.5之前创建的管道，这将显示为`unknown` |
| **CI_PROJECT_DIR** | all | all | 克隆存储库的完整路径以及运行作业的位置克隆存储库的完整路径以及运行作业的位置 |
| **CI_PROJECT_ID** | all | all | CI在内部使用的当前项目的唯一ID |
| **CI_PROJECT_NAME** | 8.10 | 0.5 | 当前正在构建的项目名称（实际上是项目文件夹名称）|
| **CI_PROJECT_NAMESPACE** | 8.10 | 0.5 | 当前正在构建的项目命名空间（用户名或组名）|
| **CI_PROJECT_PATH** | 8.10 | 0.5 | 具有项目名称的命名空间 |
| **CI_PROJECT_PATH_SLUG** | 9.3 | all | `$CI_PROJECT_PATH` lowercased and with everything except `0-9` and `a-z` replaced with `-`. Use in URLs and domain names. |
| **CI_PIPELINE_URL** | 11.1 | 0.5 | pipeline详细的URL |
| **CI_PROJECT_URL** | 8.10 | 0.5 | 用于访问项目的HTTP地址 |
| **CI_PROJECT_VISIBILITY** | 10.3 | all | 项目的可见性(internal, private, public) |
| **CI_REGISTRY** | 8.10 | 0.5 | 如果启用`Container Registry`，则返回GitLab的`Container Registry`的地址 |
| **CI_REGISTRY_IMAGE** | 8.10 | 0.5 | 如果为项目启用了`Container Registry`，则它将返回与特定项目关联的注册表的地址 |
| **CI_REGISTRY_PASSWORD** | 9.0 | all | 用于将容器推送到GitLab容器注册表的密码 |
| **CI_REGISTRY_USER** | 9.0 | all | 用于将容器推送到GitLab容器注册表的用户 |
| **CI_SERVER** | all | all | 标记该作业在CI环境中执行 |
| **CI_SERVER_NAME** | all | all | 用于协调作业的CI服务器名称 |
| **CI_SERVER_REVISION** | all | all | 用于安排job的GitLab修订版 |
| **CI_SERVER_VERSION** | all | all | 用于安排job的GitLab版本 |
| **CI_SERVER_VERSION_MAJOR** | 11.4 | all | GitLab版本主要组件 |
| **CI_SERVER_VERSION_MINOR** | 11.4 | all | GitLab版本次要组件 |
| **CI_SERVER_VERSION_PATCH** | 11.4 | all | GitLab版本补丁组件 |
| **CI_SHARED_ENVIRONMENT** | all | 10.1 | Marks that the job is executed in a shared environment (something that is persisted across CI invocations like `shell` or `ssh` executor). If the environment is shared, it is set to true, otherwise it is not defined at all. |
| **GET_SOURCES_ATTEMPTS** | 8.15 | 1.9 | 获取运行job的sources的额尝试次数 |
| **GITLAB_CI** | all | all | 标记该job在CI环境中执行 |
| **GITLAB_USER_EMAIL** | 8.12 | all | 启动job的用户的Email |
| **GITLAB_USER_ID** | 8.12 | all | 启动job的用户的id |
| **GITLAB_USER_LOGIN** | 10.0 | all | 启动job的用户登录名 |
| **GITLAB_USER_NAME** | 10.0 | all | 启动job的用户真实名字 |
| **RESTORE_CACHE_ATTEMPTS** | 8.15 | 1.9 | 恢复运行job的缓存的尝试次数 |


## Renaming
遵循跨GitLab命名的约定，并进一步远离构建术语和工作CI变量已重命名为9.0版本。
从GitLab 9.0开始，我们已经弃用了`$CI_BUILD_ *`变量。强烈建议您使用新变量，因为我们将在以后的GitLab版本中删除旧变量。
| 8.x name | 9.0+ name |
| --- | --- |
| `CI_BUILD_ID` | `CI_JOB_ID` |
| `CI_BUILD_REF` | `CI_COMMIT_SHA` |
| `CI_BUILD_TAG` | `CI_COMMIT_TAG` |
| `CI_BUILD_BEFORE_SHA` | `CI_COMMIT_BEFORE_SHA` |
| `CI_BUILD_REF_NAME` | `CI_COMMIT_REF_NAME` |
| `CI_BUILD_REF_SLUG` | `CI_COMMIT_REF_SLUG` |
| `CI_BUILD_NAME` | `CI_JOB_NAME` |
| `CI_BUILD_STAGE` | `CI_JOB_STAGE` |
| `CI_BUILD_REPO` | `CI_REPOSITORY_URL` |
| `CI_BUILD_TRIGGERED` | `CI_PIPELINE_TRIGGERED` |
| `CI_BUILD_MANUAL` | `CI_JOB_MANUAL` |
| `CI_BUILD_TOKEN` | `CI_JOB_TOKEN` |

## `.gitlab-ci.yml` defined variables
GitLab CI允许在构建环境中设置`.gitlab-ci.yml`的变量，变量保存在存储库中，它用于存储非敏感项目配置
如果是全局变量，则将在所有已执行的命令和脚本中使用，局部变量只能在定义的局部使用，通过`$`符号进行调用，变量中可以引用其他变量，使用`$$`符号进行调用

重要提示：请注意，变量未被屏蔽，如果明确要求，它们的值可以显示在作业日志中。如果您的项目是公共项目或内部项目，则可以从项目的管道设置中将管道设置为私有。按照问题＃13784中的讨论来屏蔽变量。
在GitLab 9.4中添加了组级变量。GitLab CI允许您定义在管道环境中设置的每个项目或每个组的变量。变量存储在存储库之外（不在.gitlab-ci.yml中）并安全地传递给GitLab Runner，使它们在管道运行期间可用。这是用于存储密码，SSH密钥和凭据等内容的推荐方法。可以通过转到项目的“设置”>“CI / CD”，然后找到“变量”部分来添加项目级变量。同样，可以通过转到组的设置> CI / CD添加组级变量，然后找到名为变量的部分。子组的任何变量都将以递归方式继承。
## Using the CI variables in your job scripts
| Shell | Usage |
| --- | --- |
| bash/sh | `$variable` |
| windows batch | `%variable%` |
| PowerShell | `$env:variable` |

## Variables expressions
通过设置变量表达，可以在将代码推送到GitLab后限制在管道中创建的作业。这在与变量和触发的管道变量组合时特别有用。
提供的每个表达式都将在创建管道之前进行评估。如果`variables`评估的任何条件为真则使用`only`，创建新job。如果任何表达式在使用`except`时评估为真值，则不会创建job。
### Supported syntax
1. 判断字符串是否相同。例：`$VARIABLE == "some value"`，字符串可以使用单引号也可以使用双引号，顺序也是无关紧要的
2. 检查未定义的值。例：`$VARIABLE == null`
3. 检查是否是空值。例：`$VARIABLE == ""`，也可以是`$VARIABLE == ''`
4. 检查是否存在。例：`$STAGING`，如果您只想在存在某个变量时创建作业，这意味着它已定义且非空，您可以简单地使用变量名作为表达式，如`$STAGING`。如果`$STAGING`变量已定义且非空，则表达式将评估为真值。`$STAGING`值需要一个字符串，长度大于零。仅包含空格字符的变量不是空变量。
5. 模糊匹配。例：`$VARIABLE =~ /^content.*/`，可以对变量使用正则表达式进行模式匹配，如果找到匹配，则为真。默认情况下，模式匹配区分大小写，使用i标志来不区分大小写，例：`/pattern/i`






