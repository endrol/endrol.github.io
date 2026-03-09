+++
title = 'A Tiny AI Blog Pipeline: From English Draft to Zenn + Juejin (Mostly) Automatically'
date = 2026-03-10T00:00:00+09:00
tags = ["AI", "openclaw", "blog"]
+++

If you’ve ever finished writing a post and then immediately lost the will to:

- translate it,
- move files around,
- generate images,
- publish to multiple platforms,

…congrats, you are a normal human.

This post explains the small auto-pipeline I built with **OpenClaw**: write once (in English), then let cron jobs handle the boring parts—**image generation**, **Zenn publishing (JP)**, and **Juejin staging (CN)**.

---

## Outline
1. What problem are we solving?
2. The pipeline (high level)
3. How “finalization” works (turn image notes into real images)
4. Zenn + Juejin distribution
5. Gotchas
6. Wrap-up

---

## 1) What problem are we solving?

Writing is fun. “Operational blogging” is not.

The annoying parts usually show up *after* the draft is done:

- “I should add a diagram here… but ugh.”
- “I should translate this… later.” (Narrator: never.)
- “Did I already publish this to Zenn? Did I stage the Juejin version?”

So the goal is simple:

> **Keep the creative work manual, automate the repetitive work.**

---

## 2) The pipeline (high level)

You write an English post in Hugo (`content/posts/*.md`). In the post, you can leave **image placeholders** where a diagram or illustration would help.

Then the automation kicks in:

1. **Post Finalizer** (8:00 AM)
   - Finds new posts that contain image placeholders
   - Generates the images with an AI image model
   - Inserts real image links into the markdown
2. **Zenn Publisher** (9:00 AM)
   - Translates the post to Japanese
   - Publishes it to Zenn via repo automation
3. **Juejin Publisher** (9:00 AM)
   - Translates the post to Simplified Chinese
   - Saves a ready-to-publish markdown file in the repo (manual publish later)

<!-- IMAGE: A simple three-stage pipeline diagram (Write → Finalize Images → Distribute to Zenn/Juejin), with small clock icons showing 8:00 and 9:00 -->
<!-- PROMPT: Flat design, minimalist illustration, soft pastel colors, clean lines, white background, warm color palette. A clean horizontal flow diagram with three rounded boxes labeled “Write (English)”, “Finalize Images (8:00)”, “Distribute (9:00)”. Arrows between boxes. Small cute clock icons above the second and third boxes showing “8:00” and “9:00”. Simple, friendly, tech blog style. -->

The key idea: **the English post is the source of truth**. Everything else is derived from it.

---

## 3) What “finalized” means

“Finalized” means:

- the text is done (enough), and
- all image placeholders have been replaced with real images.

In the draft, I add image notes like this:

```md
<!-- IMAGE: what the reader should see -->
<!-- PROMPT: the exact prompt to generate it -->
```

The post-finalizer job will:

- generate `static/images/<slug>/image-N.png` at **1K resolution**, and
- replace the placeholder block with:

```md
![description](/images/<slug>/image-N.png)
```

That gives me a single, consistent image location that works with Hugo.

---

## 4) Zenn + Juejin distribution

After images are real, translating becomes much less painful because:

- the outline is already solid,
- the structure is stable,
- images are already referenced in the text.

So the translators just do what translators should do:

- keep code blocks and filenames intact,
- translate prose naturally,
- keep the post readable.

Zenn gets a published Japanese version. Juejin gets a Chinese markdown file committed to the repo, ready for manual upload.

---

## 5) Gotchas (a.k.a. reality)

A few things I’m watching during the test:

- **Timing:** image generation can be slow, so finalizer runs earlier.
- **Idempotency:** every job tracks state with a JSON file so it doesn’t repeat work.
- **Images across platforms:** Hugo loves `static/`. Other platforms may have their own expectations.

<!-- IMAGE: A sleepy robot holding an alarm clock labeled “8:00”, looking determined but slightly tired -->
<!-- PROMPT: Flat design, minimalist illustration, soft pastel colors, clean lines, white background, warm color palette. A cute small robot with sleepy eyes holding an alarm clock that reads “8:00”. The robot looks determined but a bit tired. Minimal shading, clean outlines, friendly tech vibe. -->

---

## 6) Wrap-up

This pipeline doesn’t try to “fully automate writing.” It does something more useful:

- **protects writing time**, and
- **removes the follow-up chores** that usually kill consistency.

If you want to build something similar, start with two rules:

1. Put your style rules in one place (for me, it’s `CLAUDE.md`).
2. Automate everything that feels like “copy/paste, but with extra steps.”

Now excuse me while I let cron do its job—because my best productivity hack is still: *being asleep when automation runs.*
