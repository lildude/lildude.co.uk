---
layout: post
title: "HOWTO: Use Guzzle oauth-subscriber for OAuth 1.0a Three-legged OAuth Authentication"
date: 2015-12-23 17:26:50 +0000
tags:
-
type: post
published: true
---

Whilst updating [phpSmug](http://phpsmug.com) to use the latest and greatest [SmugMug API](https://api.smugmug.com/api/v2/doc/index.html), I decided to switch to using [Guzzle 6](http://guzzlephp.org/) for my HTTP requests rather than continuing maintaining my own code (Guzzle is used by a load of other projects and maintained by way smarter people than me).

As part of this update, I needed to implement the three-legged OAuth 1.0a procedure used by SmugMug, and many other sites, but I couldn't find a publicly documented procedure to so do.  I found [Guzzle oauth-subscriber](https://github.com/guzzle/oauth-subscriber) which seemed to tick all the boxes by I couldn't find how to use it for a three-legged OAuth authentication process.

Well, I'm pleased to say after a lot of code diving and testing, phpSmug now has a public implementation that others can follow and it goes along these lines...
