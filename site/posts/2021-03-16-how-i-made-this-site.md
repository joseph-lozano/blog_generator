---
title: How I Made This Site
description: An ill-advised adventure into static site generation
tags: post
---

### The Short Version

I used [11ty](https://11ty.dev), specifically the [eleventy-tailwindcss-alpinejs-starter by Greg Wolanski](https://github.com/gregwolanski/eleventy-tailwindcss-alpinejs-starter).

Why did I chose this? Well, I know I wanted to to the styling with [Tailwind](https://tailwindcss.com), and while there isn't AlpineJS flair just yet, I think I might want that someday (as opposed to a heavier framework, like Vue).
So this starter framework was a great place to start.

Greg vary graciously made a blog post outline how the steps. I followed that, rather than just clone the starter outright. After that, it was just a matter of figuring out the templating language (Nunjucks), and I was pretty much good to go.
Everything was very intuitive.

I thought the robot avatars for each post might give it a bit more flair. You can find the source code and git history for this site [here](https://github.com/joseph-lozano/blog).

In my last post, I talked about how I was an Elixir developer, and I was going to leverage that in writing my blogs... why didn't I just write this blog in Elixir? A previous version actually was, using the NimblePublisher library. I actually quite liked it. What I didn't like was paying 7 bucks a month for hosting it. By using a static site generator, I get free hosting. The site is currently hosted on [render](https://render.com) and I pay exactly nothing to host it.

Maybe one day I'll find the killer Elixir static site generator. Or maybe I'll write my own, and blog about it. But until then, I wanted to get started quickly, and 11ty enabled me to do exactly that.

Thanks for reading
