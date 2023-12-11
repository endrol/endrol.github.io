+++
title = 'Deploy hugo blog on github'
date = 2023-12-11T11:07:45+09:00
+++

## Introduction

Welcome to the exciting world of blogging with Hugo! If you're reading this, you're likely interested in creating a blog that's both beautiful and efficient. Hugo, a popular static site generator, combined with the convenience of GitHub Pages, makes for a powerful duo. In this blog, we'll walk through the process of building a blog using Hugo and deploying it on GitHub Pages.

## Step 1: Setting Up Hugo

Before diving in, ensure you have Hugo installed on your computer. If not, you can download it from [Hugo's official website](https://gohugo.io/getting-started/installing/). Follow the instructions specific to your operating system.

### Creating Your New Hugo Site

1. Open your terminal or command prompt.
2. Navigate to the folder where you want to create your blog.
3. Run `hugo new site myblog` (replace `myblog` with your desired site name).
4. This command creates a new folder named `myblog` with the basic structure of a Hugo site.

## Step 2: Choosing and Applying a Theme

Hugo has a plethora of themes to choose from. Browse the [Hugo Themes Showcase](https://themes.gohugo.io/) to find one that suits your style.

### Applying the Theme

1. Once you've chosen a theme, note its GitHub URL.
2. Inside your Hugo site's directory, add the theme as a submodule: `git submodule add [THEME URL] themes/[THEME NAME]`.
3. Update your site's configuration to use the theme. Open `config.toml` and set `theme = "[THEME NAME]"`.

## Step 3: Adding Content to Your Blog

With your theme set, it's time to add content.

### Creating a New Post

1. Run `hugo new posts/my-first-post.md`.
2. This creates a Markdown file in `content/posts` where you can write your post.
3. Edit the file with your content.

## Step 4: Previewing Your Site Locally

Before deploying, preview your site:

1. Run `hugo server -D` in your site directory.
2. Visit `http://localhost:1313` in your browser to see your site.

## Step 5: Preparing for Deployment

Ensure your blog is ready for GitHub Pages:

1. In `config.toml`, set `baseURL` to `https://[your-github-username].github.io/[repository-name]/`.
2. Commit your changes: `git add .` then `git commit -m "Initial commit"`.

## Step 6: Deploying on GitHub Pages

### Setting Up a GitHub Repository

1. Create a new repository on GitHub.
2. Initialize a Git repository in your Hugo site's root directory if you haven't already (`git init`).
3. Add the GitHub repository as a remote: `git remote add origin [REPOSITORY URL]`.

### Deploying Your Site

1. Push your site to GitHub: `git push -u origin master`.
2. Go to your repository settings on GitHub.
3. Under "GitHub Pages", set the source to the `master` branch.
4. Your site is now live!

## Conclusion

Congratulations! You've just set up and deployed your Hugo blog on GitHub Pages. This is just the beginning. Hugo offers extensive customization options, allowing you to tweak your blog to your heart's content. Happy blogging!

---

*Note: This blog assumes a basic understanding of the command line and Git. For more detailed guidance, feel free to ask or consult the [Hugo Documentation](https://gohugo.io/documentation/).*
