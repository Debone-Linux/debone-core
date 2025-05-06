---
layout: default
title: Preface
nav_order: 0
---

This is a bare-minimum *Printable Docs* template to create a printer-friendly Jekyll site that uses the [Just the Docs] and [Paged.js]. Just the Docs is a theme for generating static websites with Jekyll. You can write source files for your web pages using Markdown, the Liquid templating language, and HTML. Paged.js is a free and open source JavaScript library that paginates content in the browser to create PDF output from any HTML content. This means you can have browser-friendly documentation and for print (eg. books) using just HTML and CSS!

You can easily set the created site to be published on [GitHub Pages] – the [README] file explains how to do that, along with other details. [Jekyll] builds your site by converting all files that have front matter to HTML.

If Jekyll is installed on your computer, you can also build and preview the created site *locally*. This lets you test changes before committing them, and avoids waiting for GitHub Pages. And you will be able to deploy your local build to a different platform than GitHub Pages.

More specifically, the created site:

- uses a gem-based approach, i.e. uses a `Gemfile` and loads the `just-the-docs` gem
- uses the [GitHub Pages / Actions workflow] to build and publish the site on GitHub Pages

Other than that, you're free to customize sites that you create with this template, however you like. You can easily change the versions of `just-the-docs` and Jekyll it uses, as well as adding further plugins. Browse Just-the-Docs documentation to learn more about how to use this theme.

This *Printable Docs* includes a Preface and two sample Chapters to show how Markdown source files are structured. The CSS asset `print.css` contains formating for chapter, section, and sub-section levels, however, sub-section it is not tested. Please refer to Paged.js documentation on how to further customize it to your liking. 

*Printable Docs* is still under heavy development. It does not have any release just yet. However, feel free to fork, use, and improve it as you may see it fits.

[Just the Docs]: https://just-the-docs.github.io/just-the-docs/
[GitHub Pages]: https://docs.github.com/en/pages
[README]: https://github.com/just-the-docs/just-the-docs-template/blob/main/README.md
[Jekyll]: https://jekyllrb.com
[GitHub Pages / Actions workflow]: https://github.blog/changelog/2022-07-27-github-pages-custom-github-actions-workflows-beta/
[Paged.js]: https://pagedjs.org
