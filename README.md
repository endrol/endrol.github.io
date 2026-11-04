# Endrol Blog

The source of https://endrol.github.io: a [Hugo](https://gohugo.io/) site using the [PaperMod](https://github.com/adityatelange/hugo-PaperMod) theme (git submodule in `themes/papermod`), deployed to GitHub Pages. Posts are written in English. Japanese translations in `articles/` are published to Zenn (account `daming_cafe`) through Zenn's GitHub integration.

## Layout

| Path | What it holds |
| --- | --- |
| `content/posts/` | English posts, one `<slug>.md` each |
| `articles/` | Japanese translations for Zenn, same slugs; `.published.json` records which posts have one |
| `images/` | Post images in `images/<slug>/`, referenced as `/images/<slug>/image-N.png` (`static/images` is a symlink to it) |
| `layouts/shortcodes/` | Hugo shortcodes for diagrams and interactive demos |
| `assets/css/extended/` | Site CSS tweaks that PaperMod loads after its own |
| `scripts/` | Zenn translation scripts and the manual image generator |
| `juejin/` | Old Chinese translations. Juejin is no longer used. |

## Preview locally

```bash
git submodule update --init   # once, to fetch the theme
hugo server                   # http://localhost:1313/
```

## Publish

- **Site:** pushing to `main` runs `.github/workflows/hugo.yaml`, which builds with Hugo and deploys to GitHub Pages.
- **Zenn:** `bash scripts/translate-post.sh <slug>` translates one post into `articles/<slug>.md`. `bash scripts/run-translations.sh` does the same for every post missing from `articles/.published.json`. Shortcodes don't work on Zenn, so the translation links to the English post instead. Zenn publishes articles with `published: true` after the push to `main`.

Writing and design guidelines are in [`CLAUDE.md`](CLAUDE.md).
