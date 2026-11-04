# CLAUDE.md — Endrol Blog

A Hugo site (theme: PaperMod, git submodule in `themes/papermod`) published to GitHub Pages, plus Japanese translations for Zenn.

## Where things go

| What | Where |
| --- | --- |
| English post (the original) | `content/posts/<slug>.md`, TOML front matter: `title`, `date`, `tags` |
| Japanese translation for Zenn | `articles/<slug>.md`, Zenn YAML front matter (`title`, `emoji`, `type: tech`, `topics`, `published`) |
| Images | `images/<slug>/image-N.png`, referenced as `/images/<slug>/image-N.png` (`static/images` is a symlink to it) |
| Diagrams and interactive demos | Hugo shortcodes in `layouts/shortcodes/<name>.html`, used as `{{< name >}}` |
| Site-wide style tweaks | `assets/css/extended/*.css` (PaperMod loads them after its own CSS) |

`juejin/` holds old Chinese translations. Juejin is no longer published: don't add to it.

## Writing

Write the way a good, careful writer would: the way Claude writes when it's at its best.

- **Lead with the point.** The first paragraph says what the post is about and why it matters. No warm-up.
- **Clear and direct.** Plain words, concrete claims, real numbers. Cut anything that doesn't earn its place.
- **Natural voice.** Write like a person explaining something they understand and care about. Humour is fine when it comes naturally.
- **Structure for scanning.** Descriptive headings, short paragraphs, lists only for things that really are lists, code blocks for code, commands and paths.
- **Show, don't describe.** One good diagram, table or demo beats three paragraphs. Every visual has to explain something.
- **Check every fact** against the source (code, logs, docs) before stating it.

## Design

- Prefer clean typography and whitespace over decoration. No emoji headings.
- For architecture and flows, build an inline SVG or an interactive shortcode that works in light and dark mode (use PaperMod's CSS variables: `--primary`, `--secondary`, `--entry`, `--border`, `--code-bg`).
- Shortcode output is raw HTML/JS on the Hugo site only. Zenn can't run it, so the Zenn version replaces each shortcode with a `:::message` note linking to the English post.
- Images are optional, and only when they add something a diagram can't. If generated, `scripts/generate-images.sh [slug]` reads `scripts/state/image-prompts/<slug>.json` and writes missing files at 1K resolution. It only runs on the Linux blog server (generator and Gemini key under `/home/daming/.openclaw`).

## Publishing

1. Write the post in `content/posts/<slug>.md`.
2. Preview: `git submodule update --init` once, then `hugo server` → http://localhost:1313/.
3. Zenn: `bash scripts/translate-post.sh <slug>` writes `articles/<slug>.md` (rules in `scripts/prompts/translate-zenn.txt`) and records it in `articles/.published.json`. `bash scripts/run-translations.sh` does that for every post missing from that file; `bash scripts/zenn-publish.sh` just lists them. Review the result, and replace any shortcodes as above.
4. Commit and push only when LUO asks. Pushing to `main` deploys the site (`.github/workflows/hugo.yaml`) and publishes Zenn articles from `articles/`.
