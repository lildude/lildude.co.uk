---
layout: post
title: "Cool Weather Report in Your Terminal"
date: 2016-02-18 10:56:03 +0000
tags:
- weather
- cli
type: post
published: true
---

I spend so much of my life in my terminal (iTerm2) and have become quite the CLI nerd.  Imagine my delight when I discovered I can get a pretty cool looking weather forecast with a single command: `curl wttr.in`:

![wttr.in](/assets/wttr.in.png)

By default, it shows you the weather based on your current location, determined by your IP address - I'm nowhere near Northampton :smile: - but you can specify a location by appending it to the end, eg `curl wttr.in/London`.

Run `curl wttr.in/:help` to get more usage info and check out the [repo](https://github.com/chubin/wttr.in) if you want to take a peek at the code behind it.
