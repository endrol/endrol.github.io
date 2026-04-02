+++
title = 'Stop Fighting PowerPoint — Make Slides in Markdown with Reveal.js'
date = 2026-04-03T00:00:00+09:00
tags = ["reveal.js", "markdown", "vite", "presentation", "tools"]
+++

You're preparing a technical presentation. You open PowerPoint. Ten minutes later you're adjusting a text box by 2 pixels and questioning your life choices.

There's a better way.

---

## Outline

1. What's the problem with normal slide tools?
2. The key idea — Markdown as slides
3. How the stack works (Reveal.js + Vite)
4. Writing slides: the actual syntax
5. Gotchas
6. Wrap-up

---

## 1) What's wrong with normal slide tools?

**PowerPoint / Keynote / Google Slides** are great for designers. For engineers, they're a tax:

- Click to position text boxes instead of just typing
- Versioning is a nightmare (which `presentation_v3_final_FINAL.pptx` is the real one?)
- Adding code blocks or math equations feels like defusing a bomb
- Collaboration means emailing files back and forth

What engineers actually want: write content in a text file, have it look great automatically, track changes in git.

![Markdown file transforms into a beautiful presentation](/images/reveal-markdown-slides/image-1.png)

---

## 2) The key idea

**[Reveal.js](https://revealjs.com/)** is a browser-based presentation framework. Your slides are a webpage — so layout, animation, and math just work.

The killer feature: the **Markdown plugin**. Instead of clicking through a GUI, you write your slides in a `.md` file:

```markdown
## My Slide Title

- Point one
- Point two

---

## Next Slide
```

That's it. Reveal.js turns it into a full-screen animated presentation.

---

## 3) How the stack works

Three pieces:

| Piece | What it does |
|-------|-------------|
| `reveal.js` | Renders slides in the browser |
| `vite` | Dev server — translates `import 'reveal.js'` and hot-reloads on save |
| `slides.md` | Your actual content |

**The flow:**

```
slides.md  →  Vite (dev server)  →  browser at localhost:3000
```

Edit `slides.md`, save, browser updates instantly. That's the whole loop.

![The three-piece stack: slides.md, Vite server, and browser showing the presentation](/images/reveal-markdown-slides/image-2.png)

### Setup

```bash
mkdir my-presentation && cd my-presentation
npm install reveal.js
npm install vite --save-dev
```

**`package.json`** — add the dev script:

```json
{
  "scripts": {
    "dev": "vite",
    "build": "vite build"
  },
  "dependencies": { "reveal.js": "^6.0.0" },
  "devDependencies": { "vite": "^8.0.3" }
}
```

**`main.js`** — import Reveal.js and its plugins:

```js
import Reveal from 'reveal.js';
import Markdown from 'reveal.js/plugin/markdown';
import Highlight from 'reveal.js/plugin/highlight';
import Notes from 'reveal.js/plugin/notes';
import Math from 'reveal.js/plugin/math';

import 'reveal.js/reset.css';
import 'reveal.js/reveal.css';
import 'reveal.js/theme/black.css';
import 'reveal.js/plugin/highlight/monokai.css';

Reveal.initialize({
  hash: true,
  plugins: [Markdown, Highlight, Notes, Math.KaTeX],
});
```

**`index.html`** — the shell. Point it at your `slides.md`:

```html
<!DOCTYPE html>
<html>
<head>
  <script type="module" src="/main.js"></script>
</head>
<body>
  <div class="reveal">
    <div class="slides">
      <section
        data-markdown="slides.md"
        data-separator="^---"
        data-separator-vertical="^--"
        data-separator-notes="^Note:"
      ></section>
    </div>
  </div>
</body>
</html>
```

Then run:

```bash
npm run dev
# open http://localhost:3000
```

---

## 4) Writing slides: the syntax

### Slide separators

```markdown
# Slide 1

---

# Slide 2  (→ right)

--

## Slide 2, sub-slide  (↓ down)

--

## Slide 2, another sub-slide
```

Use `---` for main sections (navigate right), `--` for detail slides within a section (navigate down). This gives your presentation a two-dimensional structure — the audience can follow the top-level story horizontally and drill into details vertically.

![Presentation navigation grid: horizontal main sections and vertical sub-slides](/images/reveal-markdown-slides/image-3.png)

### Fragments (click-to-reveal)

Add `<!-- .element: class="fragment" -->` after any line:

```markdown
- This is visible immediately
- This appears on click <!-- .element: class="fragment" -->
- So does this <!-- .element: class="fragment" -->
```

### Math

```markdown
Inline: $\theta = \arctan(u/f)$

Block:
$$E = mc^2$$
```

Requires the `Math.KaTeX` plugin (already in `main.js` above).

### Speaker notes

```markdown
## My slide

Content here.

Note: Only you see this in presenter view. Press S to open it.
```

### Slide-level settings (background, transition)

```markdown
<!-- .slide: data-background-color="#1a1a2e" data-transition="zoom" -->

## Dark background slide
```

### When Markdown isn't enough

For complex layouts — side-by-side columns, custom SVG diagrams — drop HTML directly into the `.md` file. Reveal.js handles it fine:

```markdown
## Comparison

<div style="display:flex; gap:1em;">
  <div>**Before:** lots of words</div>
  <div>**After:** one clear diagram</div>
</div>
```

---

## 5) Gotchas

**`npm run dev` is not magic** — it's just a shortcut. It works because `package.json` maps `"dev"` → `"vite"`, and npm automatically adds `node_modules/.bin/` to the PATH. So running `npm run dev` is the same as running `./node_modules/.bin/vite`.

**Don't let slides overflow.** Reveal.js clips content silently — if a slide has too much content, the bottom just disappears at normal window sizes. The fix is to split content across sub-slides (`--`) rather than stacking it all on one slide. One idea per slide is the right mental model.

**`node_modules/` is per-project.** Run `npm install` in each new presentation folder. The packages aren't global — they live alongside your slides.

**Hot reload doesn't work if Vite is backgrounded.** Always run `npm run dev` in a visible terminal tab. Stop it with `Ctrl+C` when done.

---

## 6) Wrap-up

The full workflow once everything is set up:

1. `npm run dev` — start the server
2. Edit `slides.md` — write content in Markdown
3. Browser at `localhost:3000` — updates live on every save
4. `Ctrl+C` — stop when done

No clicking text boxes. No version chaos. Just a text file, a terminal, and a browser.

For a paper discussion or technical talk, this setup genuinely beats PowerPoint — especially once you add math equations and code blocks that actually look good.

The project structure ends up being just five files:

```
my-presentation/
├── slides.md       ← edit this
├── index.html      ← shell (set once, forget)
├── main.js         ← reveal.js init (set once, forget)
├── package.json    ← npm scripts
└── node_modules/   ← don't touch
```

That's it. Go make something that doesn't involve dragging text boxes.
