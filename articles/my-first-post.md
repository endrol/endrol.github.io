---
title: "HugoブログをGitHub Pagesにデプロイする"
emoji: "🚀"
type: "tech"
topics: ["hugo", "github", "deployment", "tutorial"]
published: true
---

## はじめに

Hugoでブログを始める世界へようこそ! この記事を読んでいるということは、美しく効率的なブログを作ることに興味があるのでしょう。人気の静的サイトジェネレーターであるHugoと、GitHub Pagesの便利さを組み合わせることで、強力な組み合わせが実現します。このブログでは、Hugoを使ってブログを構築し、GitHub Pagesにデプロイするプロセスを順を追って説明します。

## ステップ1: Hugoのセットアップ

まず、コンピューターにHugoがインストールされていることを確認してください。インストールされていない場合は、[Hugoの公式ウェブサイト](https://gohugo.io/getting-started/installing/)からダウンロードできます。お使いのオペレーティングシステムに応じた手順に従ってください。

### 新しいHugoサイトの作成

1. ターミナルまたはコマンドプロンプトを開きます。
2. ブログを作成したいフォルダに移動します。
3. `hugo new site myblog`を実行します(`myblog`を希望するサイト名に置き換えてください)。
4. このコマンドにより、Hugoサイトの基本構造を持つ`myblog`という名前の新しいフォルダが作成されます。

## ステップ2: テーマの選択と適用

Hugoには豊富なテーマがあります。[Hugo Themes Showcase](https://themes.gohugo.io/)を閲覧して、あなたのスタイルに合うものを見つけてください。

### テーマの適用

1. テーマを選んだら、そのGitHub URLをメモします。
2. Hugoサイトのディレクトリ内で、テーマをサブモジュールとして追加します: `git submodule add [THEME URL] themes/[THEME NAME]`
3. テーマを使用するようにサイトの設定を更新します。`config.toml`を開いて`theme = "[THEME NAME]"`と設定します。

## ステップ3: ブログにコンテンツを追加

テーマが設定されたら、コンテンツを追加する時です。

### 新しい投稿の作成

1. `hugo new posts/my-first-post.md`を実行します。
2. これにより、`content/posts`にMarkdownファイルが作成され、そこに投稿を書くことができます。
3. ファイルをコンテンツで編集します。

## ステップ4: ローカルでサイトをプレビュー

デプロイする前に、サイトをプレビューします:

1. サイトディレクトリで`hugo server -D`を実行します。
2. ブラウザで`http://localhost:1313`にアクセスしてサイトを確認します。

## ステップ5: デプロイの準備

ブログをGitHub Pages用に準備します:

1. `config.toml`で`baseURL`を`https://[your-github-username].github.io/[repository-name]/`に設定します。
2. 変更をコミットします: `git add .`の後に`git commit -m "Initial commit"`。

## ステップ6: GitHub Pagesにデプロイ

### GitHubリポジトリのセットアップ

1. GitHubで新しいリポジトリを作成します。
2. まだであれば、Hugoサイトのルートディレクトリでgitリポジトリを初期化します(`git init`)。
3. GitHubリポジトリをリモートとして追加します: `git remote add origin [REPOSITORY URL]`

### サイトのデプロイ

1. サイトをGitHubにプッシュします: `git push -u origin master`
2. GitHubのリポジトリ設定に移動します。
3. 「GitHub Pages」の下で、ソースを`master`ブランチに設定します。
4. サイトが公開されました!

## まとめ

おめでとうございます! HugoブログをGitHub Pagesにセットアップしてデプロイしました。これは始まりに過ぎません。Hugoは広範なカスタマイズオプションを提供しており、ブログを心ゆくまで調整できます。ハッピーブロギング!

---

*注: このブログは、コマンドラインとGitの基本的な理解を前提としています。より詳細なガイダンスについては、お気軽にお尋ねいただくか、[Hugo Documentation](https://gohugo.io/documentation/)を参照してください。*