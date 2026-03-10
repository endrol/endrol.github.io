# CLAUDE.md — Blog Writing Instructions

This is the standard guide for writing and translating all blog posts across Zenn, Juejin, and any future platforms. Follow it every time.

---

## ✍️ Voice & Tone

- **Precise** — say exactly what you mean. No vague hand-waving.
- **Easy to understand** — write like you're explaining to a smart friend, not a textbook reader. If a simpler word works, use it.
- **Funny** — light humor is welcome. A well-placed joke, a relatable analogy, a self-aware comment. Don't force it, but don't be a robot either.
- Write like a professional who actually enjoys what they're writing about.
- Avoid over-explaining basics, but don't assume deep expertise.

---

## 🗺️ Structure: Outline First

Before writing the body, **always define the outline**. The outline is the skeleton — writing happens inside it.

### Outline format:
```
## Outline
1. What problem are we solving? (hook + context)
2. The key idea / concept
3. How it works (the meat)
4. Real example or demo
5. Gotchas / things to watch out for
6. Wrap-up
```

Adjust sections to fit the topic, but **follow the outline during writing** — don't drift.

---

## 🖼️ Images

When a concept is hard to visualize, or when a picture would make it funnier or clearer — **add an image note**.

### Format:
```
<!-- IMAGE: <description of what the image should show> -->
<!-- PROMPT: <image generation prompt> -->
```

### Example:
```
<!-- IMAGE: A diagram showing how a request flows through middleware layers -->
<!-- PROMPT: Flat design, minimalist illustration, soft pastel colors, clean lines, white background, warm color palette. A simple flowchart showing layered boxes labeled "Request → Middleware A → Middleware B → Handler → Response", connected by arrows. Cute and clean, no gradients. -->
```

### When to add images:
- Complex architecture or flow diagrams
- Before/after comparisons
- Funny or relatable moments (the classic "this is fine" situation)
- Anything where a visual would cut 200 words of explanation

### ⚠️ Don't over-image. One good image beats five mediocre ones.

### 📐 Image size
Always generate at **1K resolution** (`--resolution 1K`). Keep files lean — no one needs a 4K illustration of a middleware diagram.

---

## 🎨 Image Prompt Style (Consistent Across All Posts)

Every image prompt must start with this style preamble:

> **Flat design, minimalist illustration, soft pastel colors, clean lines, white background, warm color palette.**

Then describe the specific content of the image. Keep it concrete and simple. No photorealism. No gradients. No dark themes.

### 📁 Image storage
Generated images live in `images/<slug>/image-N.png`. Reference them in all posts (English, Zenn, Juejin) as:
```
![description](/images/<slug>/image-N.png)
```
This is the **single source of truth** — never copy images elsewhere.

---

## 🖼️ Image Finalizer State

After creating or updating a blog post that contains `<!-- IMAGE -->` placeholders, **always add or update the post's entry** in `scripts/state/image-finalizer.json`.

This file is the trigger record for the image generation pipeline. If a post is missing from it, images will never be generated.

### Schema:
```json
{
  "posts": {
    "<slug>": {
      "path": "content/posts/<slug>.md",
      "status": "pending",
      "updatedAt": "<ISO8601 timestamp>",
      "finalizedAt": null,
      "images": {
        "generated": 0
      },
      "lastError": null
    }
  }
}
```

### Rules:
- **slug** = the filename without `.md` (e.g. `openclaw-diary-6-susan-slack`)
- **status** = `"pending"` for a new post that needs images generated; `"done"` once all images are in place
- **updatedAt** = current timestamp in ISO8601 with timezone (e.g. `2026-03-10T00:00:00.000000+09:00`)
- **finalizedAt** = `null` until the pipeline runs and fills it in
- **images.generated** = `0` for a new entry; the pipeline updates this after generating
- Never remove existing entries — only add or update

---

## 📐 Formatting Rules

- Use headers (`##`, `###`) to break up sections — follow the outline
- Use bullet points for lists, not walls of text
- Use **bold** for key terms on first use
- Use code blocks for all code, commands, and file paths
- Keep paragraphs short — 3-4 sentences max
- One idea per paragraph


