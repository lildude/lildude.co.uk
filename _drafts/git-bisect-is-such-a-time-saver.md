---
layout: post
title: "'git bisect' is Such a Timesaver"
date: 2017-05-24 15:13:23 +0100
tags:
- git
- shorts
type: post
published: true
---

Today I finally took the time to learn and use [`git bisect`](https://git-scm.com/docs/git-bisect) to find the commit that introduced a change in behaviour I wasn't expecting. Oh man, what a timesaver. I had my bad commit within ten steps out of a possible 89 commits. The offending commit wasn't obviously the cause from the commit message either. Can't believe it took me this long, but it'll definitely be coming up often from here on out.
