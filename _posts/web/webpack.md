---
author: djaigo
title: Webpack 的主要功能
categories:
  - web
tags:
  - Webpack
  - 构建工具
  - 模块化
  - JavaScript
  - TypeScript
  - tsc
---

推荐阅读：[Webpack 官方文档](https://webpack.js.org/) | [概念说明](https://webpack.js.org/concepts/)

# Webpack 是什么

**Webpack** 是一个面向现代前端的**静态模块打包器（module bundler）**。它从指定的**入口（entry）**出发，递归解析依赖图，把各类模块（JavaScript、TypeScript、样式、图片、字体等）按规则**转换、合并、拆分**，最终生成在浏览器或 Node 中可运行的**静态资源**。

与「在浏览器里逐个 `<script>` 引入」相比，Webpack 把「依赖关系」和「构建细节」收拢到配置与插件里，便于工程化与长期维护。

## 在构建流程中的位置

```mermaid
flowchart LR
  A[源码与资源] --> B[Webpack]
  B --> C[Loader 转换]
  C --> D[Plugin 处理]
  D --> E[Chunk / 输出文件]
  E --> F[部署或本地预览]
```

# Webpack 的主要功能

## 模块打包与依赖图

- 以**入口文件**为根，分析 `import` / `require` 等依赖，形成**依赖图（dependency graph）**。
- 将图上的模块打包成**一个或多个 bundle**（或由运行时加载的 chunk），减少 HTTP 请求、统一加载顺序。
- 支持 **ESM**、**CommonJS**、**AMD** 等多种模块风格（具体能力与版本、配置有关）。

## Loader：把「非 JS」变成 Webpack 能理解的模块

Loader 在模块被加入依赖图时**逐文件转换**，典型用途包括：

- **转译**：Babel（ES 新语法、JSX）、TypeScript。
- **样式**：CSS、Less、Sass；常与 `style-loader` / `MiniCssExtractPlugin` 等配合注入或抽离 CSS。
- **资源**：图片、字体、SVG 等——可转为 URL、`import` 或内联 **Data URL**。

一条常见认知：**Loader 负责「文件内容的转换」，在管线中链式执行。**

## Plugin：扩展整个构建生命周期

Plugin 基于 **Tapable** 的事件钩子，可在**打包前后**做更全局的事，例如：

- 清理输出目录、拷贝静态文件、注入环境变量。
- **代码压缩**、**作用域提升**、分离 CSS、生成 `manifest`、分析报告体积等。
- 与 **HtmlWebpackPlugin** 等配合生成 HTML 并插入打包后的脚本/样式链接。

**对比**：Loader 偏「单文件转换」，Plugin 偏「整次构建的流程与产物形状」。

## 代码拆分（Code Splitting）

- 把应用拆成多个 **chunk**，按需或按路由加载，缩短首屏时间。
- 常见方式：**动态 `import()`**、多入口、`SplitChunksPlugin` 提取公共依赖（如 `vendor`）。

## 开发与本地调试体验

- **webpack-dev-server**（及同类方案）提供本地 HTTP 服务、**热更新（HMR）**、代理 API 等，改代码后无需整页刷新即可看到变化（视模块类型与配置而定）。
- **Source Map** 可把打包后的代码映射回源码，便于断点与查错。

## 生产模式下的优化

- **`mode: 'production'`** 会默认开启例如**压缩**、**tree shaking**（配合 ES 模块与副作用标注）等优化，减小体积。
- 通过 **持久化缓存**、**并行构建**（如 `thread-loader`）、合理拆分 chunk，可进一步缩短构建时间。

## 资源模块与生态

- 较新版本支持 **Asset Modules**（`asset/resource`、`asset/inline` 等），减少对部分 file/url Loader 的依赖。
- 丰富的社区 Loader / Plugin 覆盖 React、Vue、微前端、PWA 等场景；也可与 **Vite**、**Rspack** 等工具按项目需求选型或迁移。

# 怎么用 Webpack 打包

下面是从零跑通一次**生产构建**的常见路径：装好 CLI → 写好 **`entry` / `output` / `mode`** → 按需加 **Loader、Plugin** → 用 **`npm scripts` 或 `npx`** 执行。

## 安装

在项目里把 Webpack 放进**开发依赖**（构建结果一般不随包发布到 registry）：

```bash
npm install --save-dev webpack webpack-cli
```

若要用本地开发服务器与 HMR，可再加 **`webpack-dev-server`**。执行打包时，习惯用 **`npx webpack`**，这样会用到当前项目 `node_modules` 里的版本，而不是本机全局安装的旧版。

## 配置文件放在哪、导出什么

默认会查找工程根目录的 **`webpack.config.js`**（也可用 **`webpack.config.cjs`** 避免与 type module 冲突）。模块需 **`module.exports = { ... }`**（或 ES 默认导出，视包类型而定），也可导出**函数** `(_env, argv) => ({ ... })`，便于按 `argv.mode` 分支。

一次完整构建至少要能回答三件事：**从哪几个文件进站**、**写到哪里**、**development 还是 production**。

## 最小可运行配置（纯 JS 入口）

只打单个 JS 入口、不转译 TS 时的形状如下（与下文「带 TS」相比只差 `module.rules`）：

```javascript
// webpack.config.cjs
const path = require('path');

module.exports = {
  mode: 'production',
  entry: path.resolve(__dirname, 'src/index.js'),
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: '[contenthash].js',
    clean: true,
  },
};
```

- **`entry`**：字符串表示单入口；对象可表示**多入口**（多页站点）。  
- **`output.path`**：绝对路径；**`filename`** 可用 `[name]`、`[contenthash]` 等占位符做缓存策略。  
- **`mode: 'production'`**：会启用内置压缩、tree shaking 等（**Webpack 5**）；开发阶段可改为 **`development`** 并配合 **`devtool: 'source-map'`** 便于调试。

在根目录执行：

```bash
npx webpack --config webpack.config.cjs
```

成功后，产物在 **`output.path`**（上例为 `dist/`）。

## 打包 TypeScript / 新语法时要额外配什么

Webpack **原生只期望能处理的标准 JS 与 JSON**（具体以版本文档为准）。要让 **`import './App.tsx'`** 或 **JSX / 装饰器** 之类过线，需要在 **`module.rules`** 里挂上 **`ts-loader`**（内部调 TypeScript）或 **`babel-loader` + 对应 preset**，例如：

```javascript
module.exports = {
  // ... entry / output / mode
  module: {
    rules: [
      {
        test: /\.tsx?$/,
        use: 'ts-loader',
        exclude: /node_modules/,
      },
    ],
  },
  resolve: { extensions: ['.tsx', '.ts', '.js'] },
};
```

同时要准备 **`tsconfig.json`**（`ts-loader` 会读）。很多团队还会单独跑 **`tsc --noEmit`** 做 CI 类型检查，与打包解耦。更细的「先 `tsc` 出 JS 再交给 Webpack」见下文**「先把 tsc 编译出的 JS 再打成一个文件」**一节。

**样式与静态资源**：CSS 需要 **`css-loader` + `style-loader`**（内联）或 **`MiniCssExtractPlugin`**（抽成独立 `.css`）；图片/字体可用 **`asset`** 规则或 `file-loader` 等，与第 2 节 Loader 叙述一致。

## 常用 `package.json` 脚本

```json
{
  "scripts": {
    "build": "webpack --mode production",
    "dev": "webpack serve --mode development"
  }
}
```

- **`webpack`**：单次构建，写完磁盘上的 `output`。  
- **`webpack serve`**（需安装 **webpack-dev-server**）：起本地服务，**默认在内存里**产出 bundle，适合开发；**上线前仍要跑 `build`**，用真实 `dist` 部署。

可通过 **`--config ./configs/webpack.prod.cjs`** 指定配置文件路径。

## 插件在「怎么打包」里典型做哪些事

配置里 **`plugins: [ ... ]`** 数组中的类多半是 **「new SomePlugin({...})」**。入门常见组合：

- **`HtmlWebpackPlugin`**：根据模板生成 **`index.html`**，并把打包出来的 `<script>` / `<link>` 自动插进去。  
- **`MiniCssExtractPlugin`**：生产环境把 CSS 从 JS 里抽成文件，利于缓存与并行下载。  
- 个别项目会用 **`DefinePlugin`** / **`EnvironmentPlugin`** 注入 `process.env.*`，区分测试与生产。

Loader 解决「**这个文件怎么变成模块**」，Plugin 解决「**整次构建的流程与最终目录长什么样**」——与前面功能章节一致，此处只拼进操作流程。

## 先把 tsc 编译出的 JS 再打成一个文件

场景：已经用 **`tsc`** 把 `.ts` 编成多份 `.js`（例如落在 **`outDir`** 里），希望再由 **Webpack** 从**编译产物**出发时输出**浏览器可用的单个 bundle**（或 Node 单文件）。

### 基本流程

1. **`tsc`**：在 `tsconfig.json` 里配好 **`outDir`**（如 `dist/tsc`）、**`rootDir`**（如 `src`），保证从入口起**所有被 `import` 的模块**都会出现在 `outDir` 中；**`module`** 要与 Webpack 后续如何解析依赖一致（打成浏览器包时，常见做法是让 `tsc` 输出 **`ES2015` / `ES2020` 等 ESM 语法**，由 Webpack 做最终合并与降级；若统一为 **`CommonJS`**，Webpack 同样能沿 `require` 建依赖图）。  
2. **Webpack**：**`entry`** 指向 **`tsc` 产物的入口 JS**（如 `dist/tsc/index.js`），**`output.filename`** 设成单个文件名（如 **`bundle.js`**）。  
3. **脚本顺序**：`package.json` 里先 **`tsc`** 再 **`webpack`**（例如 `"build": "tsc && webpack"`）。

### Webpack 配置示意（单文件输出）

假定 `tsc` 输出目录为 **`dist/tsc/`**，最终只产出一个 **`dist/bundle.js`**：

```javascript
// webpack.config.cjs
const path = require('path');

module.exports = {
  mode: 'production',
  entry: path.resolve(__dirname, 'dist/tsc/index.js'),
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: 'bundle.js',
    clean: true,
  },
  target: 'web',
  resolve: {
    extensions: ['.js', '.json'],
  },
};
```

- **物理上只有一个 JS 文件**：保持**单入口**，少用或不用**动态 `import()`**，必要时收紧 **`optimization.splitChunks`**，避免额外异步 chunk。  
- **Source Map**：可在 `tsconfig` 开 **`sourceMap`**，Webpack 设 **`devtool`**（如 `'source-map'`），便于从 bundle 回溯源码。

### 与「Webpack 直接编 TS」的对比

| 做法 | 说明 |
| --- | --- |
| **tsc 出 JS → Webpack 只打 JS** | 两阶段清晰，适合流程上**必须先 `tsc` 落盘**的场景；类型检查与 emit 用同一套 `tsconfig` 时需自己维护与 CI 一致。 |
| **Webpack + `ts-loader` / Babel / SWC 直接处理 `.ts`** | 前端更常见：打包器负责转译，**`tsc --noEmit`** 单独做类型门禁，往往不必先把 TS 写到 `outDir` 再给 Webpack。 |

若目标仅是「页面**只引一个 JS**」，多数 SPA 用 **Webpack 单入口**即可；**只有**在规范要求先全量 `tsc` 时，才需要**「先把 tsc 编译出的 JS 再打成一个文件」**一节中的两段式。

---

**小结**：Webpack 的核心价值是**可配置的模块打包管线**——用 **Loader** 统一各类资源的处理，用 **Plugin** 控制产物与流程，再配合**代码拆分**与**开发与生产优化**，把「源码仓库」变成「可上线的静态资源」。若项目已定型在其它打包器上，不必强行更换；新建项目可先对比维护成本、冷启动与生态再选型。**将 `tsc` 已编译的多文件 JS 打成单文件时**：把 **`entry`** 设为 `outDir` 中的入口，**`output.filename`** 设为单个 bundle，并协调 `module`、动态 import 与 `splitChunks`，避免意外多出 chunk。
