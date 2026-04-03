---
title: PowerPoint との戦いはやめよう — Markdown と Reveal.js でスライド作成
emoji: 📊
type: tech
topics: [reveal.js, markdown, vite, presentation, tools]
published: true
---

技術プレゼンの準備中。PowerPoint を開く。10分後、テキストボックスを2ピクセル調整するために人生の選択を疑っている。

もっと良い方法がある。

---

## 目次

1. 通常のスライド作成ツールの問題点は？
2. キーアイデア — Markdown をスライドに
3. スタック全体の仕組み（Reveal.js + Vite）
4. スライド作成：実際の文法
5. 落とし穴
6. まとめ

---

## 1) 通常のスライド作成ツールの何が悪いのか？

**PowerPoint / Keynote / Google Slides** はデザイナー向けに優れている。エンジニアにとっては税金のようなものだ：

- テキストボックスをクリックして配置するのではなく、単に入力したい
- バージョン管理は悪夢（`presentation_v3_final_FINAL.pptx` のどれが本物？）
- コードブロックや数式の追加は爆弾解除のような感覚
- コラボレーションはメールでファイルを交換することになる

エンジニアが本当に欲しいもの：テキストファイルにコンテンツを書いて、自動的に素晴らしく見えるようにして、Git で変更を追跡したい。

![Markdown ファイルが美しいプレゼンテーションに変わる](/images/reveal-markdown-slides/image-1.png)

---

## 2) キーアイデア

**[Reveal.js](https://revealjs.com/)** はブラウザベースのプレゼンテーション フレームワーク。スライドは Web ページだから、レイアウト、アニメーション、数式が簡単に機能する。

キラー機能：**Markdown プラグイン**。GUI をクリックして進めるのではなく、`.md` ファイルでスライドを書く：

```markdown
## マイスライドタイトル

- ポイント1
- ポイント2

---

## 次のスライド
```

それだけだ。Reveal.js がそれを全画面のアニメーション プレゼンテーションに変える。

---

## 3) スタック全体の仕組み

3つのピース：

| ピース | 役割 |
|-------|------|
| `reveal.js` | ブラウザでスライドをレンダリング |
| `vite` | 開発サーバー — `import 'reveal.js'` を変換して保存時にホットリロード |
| `slides.md` | 実際のコンテンツ |

**フロー：**

```
slides.md  →  Vite（開発サーバー）  →  localhost:3000 のブラウザ
```

`slides.md` を編集して保存すれば、ブラウザはすぐに更新される。これが全てのループだ。

![3つのピースのスタック：slides.md、Vite サーバー、プレゼンテーションを表示するブラウザ](/images/reveal-markdown-slides/image-2.png)

### セットアップ

```bash
mkdir my-presentation && cd my-presentation
npm install reveal.js
npm install vite --save-dev
```

**`package.json`** — dev スクリプトを追加：

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

**`main.js`** — Reveal.js とそのプラグインをインポート：

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

**`index.html`** — シェル。`slides.md` をポイント：

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

その後実行：

```bash
npm run dev
# http://localhost:3000 を開く
```

---

## 4) スライド作成：文法

### スライド区切り

```markdown
# スライド 1

---

# スライド 2  (→ 右)

--

## スライド 2、サブスライド  (↓ 下)

--

## スライド 2、別のサブスライド
```

メインセクション用に `---` を使用（右へナビゲート）、セクション内のディテールスライド用に `--` を使用（下へナビゲート）。これはプレゼンテーションに2次元構造を与える — 視聴者は上位のストーリーを水平に追うことができ、詳細を垂直に掘り下げることができる。

![プレゼンテーション ナビゲーション グリッド：水平のメインセクションと垂直のサブスライド](/images/reveal-markdown-slides/image-3.png)

### フラグメント（クリック時に表示）

任意の行の後に `<!-- .element: class="fragment" -->` を追加：

```markdown
- これは即座に表示される
- これはクリック時に表示される <!-- .element: class="fragment" -->
- これも同様 <!-- .element: class="fragment" -->
```

### 数式

```markdown
インライン：$\theta = \arctan(u/f)$

ブロック：
$$E = mc^2$$
```

`Math.KaTeX` プラグインが必要（上記の `main.js` に既に含まれている）。

### スピーカーノート

```markdown
## マイスライド

コンテンツはここ。

Note: これはプレゼンターモードでのみ表示される。S キーを押すと開く。
```

### スライドレベルの設定（背景、トランジション）

```markdown
<!-- .slide: data-background-color="#1a1a2e" data-transition="zoom" -->

## ダークバックグラウンド スライド
```

### Markdown では不十分な場合

複雑なレイアウト — サイドバイサイドのカラム、カスタム SVG 図 — の場合は、HTML を `.md` ファイルに直接挿入する。Reveal.js はそれをうまく処理する：

```markdown
## 比較

<div style="display:flex; gap:1em;">
  <div>**Before（前）：** 長い言葉</div>
  <div>**After（後）：** 1つのクリアな図表</div>
</div>
```

---

## 5) 落とし穴

**`npm run dev` は魔法ではない** — 単なるショートカット。`package.json` が `"dev"` → `"vite"` にマップし、npm が自動的に `node_modules/.bin/` を PATH に追加するから機能する。`npm run dev` を実行することは `./node_modules/.bin/vite` を実行することと同じ。

**スライドがオーバーフローしないようにしよう。** Reveal.js はコンテンツをサイレントにクリップする — スライドに含まれるコンテンツが多すぎると、通常のウィンドウサイズで下部が消えるだけだ。修正は、サブスライド（`--`）全体にコンテンツを積み重ねるのではなく、複数のスライドに分割することだ。1スライド1アイデアが正しいメンタルモデル。

**`node_modules/` はプロジェクトごと。** 各新しいプレゼンテーション フォルダで `npm install` を実行。パッケージはグローバルではなく、スライドと一緒に置かれている。

**ホットリロードは Vite がバックグラウンド化されている場合は機能しない。** 常に目に見えるターミナル タブで `npm run dev` を実行。`Ctrl+C` で停止。

---

## 6) まとめ

セットアップが完了した後の全体的なワークフロー：

1. `npm run dev` — サーバーを起動
2. `slides.md` を編集 — Markdown でコンテンツを書く
3. `localhost:3000` のブラウザ — 保存するたびにリアルタイム更新
4. `Ctrl+C` — 完了時に停止

テキストボックスをクリックすることはない。バージョンの混乱もない。テキストファイル、ターミナル、ブラウザだけだ。

ペーパーディスカッション技術トークの場合、このセットアップは本当に PowerPoint に勝る — 特に数式とコードブロックを追加して実際に見栄えの良いものにしたら。

プロジェクト構造は5つのファイルで済む：

```
my-presentation/
├── slides.md       ← ここを編集
├── index.html      ← シェル（1回設定して忘れる）
├── main.js         ← reveal.js の初期化（1回設定して忘れる）
├── package.json    ← npm スクリプト
└── node_modules/   ← 触らない
```

それだけだ。テキストボックスのドラッグに関わらないものを作ろう。
