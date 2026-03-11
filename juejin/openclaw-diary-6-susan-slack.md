+++
title = 'OpenClaw 日记第六篇：另一个 Agent Susan，以及我们在 Slack 里的沟通方式'
date = 2026-03-10T00:00:00+09:00
tags = ["AI", "openclaw", "slack", "blog"]
+++

OpenClaw 以前只有一个 Agent。现在有两个了。这篇文章讲的是 Susan 是如何加入团队的，以及为什么我的两个 Agent 至今仍然拒绝互相对话。

---

## 目录
1. Susan 是谁？
2. 配置 Slack（枯燥的部分）
3. 我怎么在 Slack 里跟 Agent 说话
4. Bot 互相回复的问题（以及防止混乱的那个配置项）
5. 我真正想要的：主动触发
6. 总结

---

## 1) Susan 是谁？

认识一下 **Susan** —— OpenClaw 的第二个 Agent，也是实际负责所有博客相关工作的那个。

她的职责是什么？博客写作，以及所有发布相关的 cron 任务：起草、定稿、翻译、发布——整条流水线都归她管。只要一篇博客文章存在（或者被创建出来），背后做事的就是 Susan。

第一个 Agent **Ada** 负责其余的一切。你可以把 Ada 看作通用大脑，Susan 则是住在内容目录里的专家。

取不同的名字、分不同的职责，让人更容易判断当前发生的事情归谁管——在 Slack 里 @ 哪一个，也不需要犹豫。

![Ada the robot holding a wrench and clipboard](/images/openclaw-diary-6-susan-slack/ada.png)

![Susan the robot holding a pencil and a stack of blog posts](/images/openclaw-diary-6-susan-slack/susan.png)

---

## 2) 配置 Slack（枯燥的部分）

在那些 @ 提及和 Agent 对话能跑起来之前，得先有人把 Slack 真正接进来。这个人是我。花的时间比应该花的要长。

完整配置流程，压缩版：

**第一步 —— 创建 workspace 和 Slack 应用**

首先需要一个 Slack workspace。有了之后，去 [api.slack.com/apps](https://api.slack.com/apps) 创建一个新应用。选择"From scratch"，给它起个名字，选择你的 workspace。这步很简单。

**第二步 —— 配置 OAuth 和权限（Bot User Token）**

大多数教程在这里开始讲不清楚。进入左侧导航栏的 **OAuth & Permissions**，往下滚到 **Bot Token Scopes**，添加你的 bot 实际需要的权限，比如 `chat:write`、`app_mentions:read`、`channels:history` 等。

Scope 设好之后，把应用安装到你的 workspace。Slack 会给你一个 **Bot User OAuth Token** —— 以 `xoxb-` 开头。Bot 用这个 token 发消息和读取频道。

**第三步 —— 获取 app-level token**

如果你想用 Socket Mode（让 bot 不需要公开的 HTTP 端点就能接收事件——对本地或自托管部署非常方便），仅靠 bot token 是不够的。你还需要一个 **app-level token**。

去 **Basic Information → App-Level Tokens**，生成一个带 `connections:write` scope 的 token，会得到一个以 `xapp-` 开头的字符串。两个 token 都要妥善保存。

**第四步 —— 启用 Socket Mode**

在 **Socket Mode** 里把开关打开。这告诉 Slack 用你的 app-level token 通过 WebSocket 连接推送事件，而不是推到某个 webhook URL。

**第五步 —— 订阅事件**

最后，在 **Event Subscriptions** 里开启事件，订阅你关心的那些。OpenClaw 用的是 `app_mention` —— 只有当有人真正 @ tag 了 bot，它才会响应。

做完这些，你就有了两个 token 和一个能监听并响应的 bot。OAuth 那部分我参考了[这个 YouTube 教程](https://www.youtube.com/watch?v=9QpSkGnfKMk)，Slack 控制台看起来像迷宫的时候，这个视频很救命。

![Slack 应用配置步骤流程图](/images/openclaw-diary-6-susan-slack/image-1.png)

---

## 3) 我怎么在 Slack 里跟 Agent 说话

目前的交互模式很简单：**我 @ 它们，它们回应我**。

```
@Susan — 帮我把 openclaw diary 6 那篇文章定稿
@Ada   — 流水线现在状态怎么样？
```

它们监听 Slack 频道，接到 @ 提及，处理任务，然后回复我。够简洁。

OpenClaw 里有一条重要规则：**bot 忽略其他 bot 发出的消息**。Susan 不会响应 Ada 说的话，Ada 也不会响应 Susan 的发言。它们只对我作出反应。

---

## 4) Bot 互相回复的问题

这是有意为之，不是偷懒。原因很简单：**死循环**。

没有任何限制的话，两个 bot 互相回复对方的消息，会愉快地螺旋进入一段永无止境且毫无用处的对话。两个 bot 不停地互相 @ tag，就是 AI 版的两面镜子相对而立——理论上无限，实际上没有任何意义。

![两个机器人面对面无限互相 @ tag 的循环图](/images/openclaw-diary-6-susan-slack/image-2.png)

OpenClaw 通过每个频道的 `allowBots` 配置项来解决这个问题，默认值是 `false`：

```json
{
  "channels": {
    "slack": {
      "channels": {
        "C0AKYTMK1QR": {
          "allowBots": true
        }
      }
    }
  }
}
```

把它改成 `true`，bot 就能读取彼此在该频道里发出的消息。但没有额外的保护措施——循环检测、消息去重，或者别的什么——这就是个定时炸弹。所以目前 `false` 不动。

---

## 5) 我真正想要的：主动触发

目前的方案是**被动响应**：我告诉 Agent 做什么，它去做。

我最终想要的是**主动触发**：Ada 发现有文章就绪了，通知 Susan，Susan 启动流水线——不需要人在中间。

这是自然的下一步。由状态变化触发的 Agent 间交接，而不是手动发命令。大概是这样：

```
Ada:   "Susan，检测到新文章。要开始定稿吗？"
Susan: "收到，马上来。"
```

但这不只是把 `allowBots` 改成 `true` 那么简单。需要完整的交接逻辑、循环防护，以及明确定义 Ada 交出去什么、Susan 接手什么。值得做——只是不是今天。

![Ada 检测到新文章，将接力棒传给 Susan，Susan 启动发布流程](/images/openclaw-diary-6-susan-slack/image-3.png)

---

## 6) 总结

两个 Agent 比一个好——前提是每个都有清晰的职责，而且不会意外地在循环里自顾自地对话。

Susan 负责博客，Ada 负责其余的一切。我 @ 我需要的那个。`allowBots` 这堵墙暂时维持着秩序。

下一步：让它们真正在没有我的情况下协调工作。那才是有意思的部分——也是未来某篇日记的主题。

敬请期待。Susan 已经在写了。
