---
title: How I Made This Site
description: An ill-advised adventure into static site generation
draft: true
tags: post
---

## The short version

I used markdown to write the posts. [Earmark]() to parse the markdown into html, [Makeup]() to syntax highlight the Elixir bits, inject that into an [EEx] template, which is then rendered into static html.

After all that, I use node/npm to give it styling with [TailwindCSS]().

I also wrote a [Plug]() server to help with development, and used [FileSystem]() to rebuild for a seemingly live experience.
