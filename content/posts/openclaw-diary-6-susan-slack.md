+++
title = 'OpenClaw Diary 6: Another Agent Susan and How We Talk in Slack'
date = 2026-03-10T00:00:00+09:00
tags = ["AI", "openclaw", "slack", "blog"]
+++

OpenClaw used to have one agent. Now it has two. This is the story of how Susan joined the team, and why my agents still refuse to talk to each other.

---

## Outline
1. Who is Susan?
2. Setting up Slack (the unglamorous part)
3. How I talk to my agents in Slack
4. The bot-to-bot problem (and the setting that prevents chaos)
5. What I actually want: active triggering
6. Wrap-up

---

## 1) Who is Susan?

Meet **Susan** — OpenClaw's second agent, and the one actually responsible for anything blog-related.

Her job? She handles blog writing and all the post-related cron jobs: drafting, finalizing, translating, publishing — the whole pipeline. If a blog post exists (or gets created), it's Susan doing the work.

The first agent, **Ada**, handles the rest. Think of Ada as the general-purpose brain, and Susan as the specialist living in the content folder.

Distinct names and responsibilities make it easier to reason about what's happening — and to @ the right one in Slack without second-guessing yourself.

![Ada the robot holding a wrench and clipboard](/images/openclaw-diary-6-susan-slack/ada.png)

![Susan the robot holding a pencil and a stack of blog posts](/images/openclaw-diary-6-susan-slack/susan.png)

---


## 2) Setting up Slack (the unglamorous part)

Before any of the @ mentions and agent conversations can happen, someone has to actually wire up Slack. That someone was me. It took longer than it should have.

Here's the full setup, condensed:

**Step 1 — Create a workspace and a Slack app**

First, you need a Slack workspace to work with. Once that exists, head to [api.slack.com/apps](https://api.slack.com/apps) and create a new app. Choose "From scratch", give it a name, and select your workspace. That's the easy part.

**Step 2 — Configure OAuth & permissions (bot user token)**

This is where most tutorials lose people. Navigate to **OAuth & Permissions** in the sidebar. Scroll down to **Bot Token Scopes** and add the permissions your bot actually needs — things like `chat:write`, `app_mentions:read`, `channels:history`, etc.

Once scopes are set, install the app to your workspace. Slack will hand you a **Bot User OAuth Token** — it starts with `xoxb-`. This is the token your bot uses to post messages and read channels.

**Step 3 — Get an app-level token**

Bot tokens aren't enough if you want to use Socket Mode (which lets your bot receive events without a public HTTP endpoint — very handy for a local or self-hosted setup). For that, you need an **app-level token**.

Go to **Basic Information → App-Level Tokens**, generate a token with the `connections:write` scope, and you'll get a token starting with `xapp-`. Store both tokens somewhere safe.

**Step 4 — Enable Socket Mode**

Under **Socket Mode**, flip the toggle on. This tells Slack to deliver events over a WebSocket connection using your app-level token instead of pushing to a webhook URL.

**Step 5 — Subscribe to events**

Finally, under **Event Subscriptions**, enable events and subscribe to the ones you care about. For OpenClaw, that's `app_mention` — so the bots only wake up when someone actually @ tags them.

After all that, you have two tokens and a bot that can listen and respond. I followed [this YouTube tutorial](https://www.youtube.com/watch?v=9QpSkGnfKMk) to get through the OAuth setup without losing my mind — worth watching if the Slack dashboard starts looking like a maze.

![Slack app setup steps flowchart](/images/openclaw-diary-6-susan-slack/image-1.png)

---

## 3) How I talk to them in Slack

The current interaction model is simple: **I @ them, they respond to me**.

```
@Susan — hey, finalize the openclaw diary 6 post
@Ada   — what's the status on the pipeline?
```

They listen on a Slack channel, pick up mentions, do their thing, and reply back. Clean enough.

One important rule baked into OpenClaw: **bots ignore messages from other bots**. Susan won't react if Ada says something. Ada won't react if Susan does. They only respond to me.

---

## 4) The bot-to-bot problem

This is intentional, not lazy. The reason is simple: **infinite loops**.

Without some guardrail, two bots replying to each other's messages will happily spiral into a conversation that lasts forever and does absolutely nothing useful. Two bots endlessly tagging each other is the AI equivalent of two mirrors facing each other — technically infinite, entirely pointless.

![Two robots endlessly tagging each other in an infinite loop](/images/openclaw-diary-6-susan-slack/image-2.png)

OpenClaw solves this with an `allowBots` setting per channel, which defaults to `false`:

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

Flip it to `true` and bots can read each other's messages in that channel. But without extra safeguards — loop detection, message deduplication, something — it's a footgun. So for now, `false` stays.

---

## 5) What I actually want: active triggering

The current setup is **reactive**: I tell an agent to do something, it does it.

What I want eventually is **proactive**: Ada notices a post is ready, pings Susan, Susan starts the pipeline — no human in the middle.

That's the natural next step. Agent-to-agent handoffs, triggered by state changes rather than manual commands. Something like:

```
Ada:   "Hey Susan, new post detected. Finalize?"
Susan: "On it."
```

But that requires more than flipping `allowBots`. It needs proper handoff logic, loop prevention, and a clear contract between what Ada hands off and what Susan picks up. Worth doing — just not today.

![Ada handing off a new post to Susan who runs the publishing pipeline](/images/openclaw-diary-6-susan-slack/image-3.png)

---

## 6) Wrap-up

Two agents are better than one, as long as they each have a clear job and aren't accidentally talking to each other in circles.

Susan handles the blog. Ada handles the rest. I @ whichever one I need. The `allowBots` wall keeps things sane for now.

Next up: getting them to actually coordinate without me in the middle. That's the interesting part — and a future diary entry.

Stay tuned. Susan is already writing it.
