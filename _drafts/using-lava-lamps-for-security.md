---
layout: post
title: "Using Lava Lamps for Security"
date: 2017-11-07 14:50:35 -0800
tags:
- Security
type: post
published: true
---

If you use the internet, you've almost certainly traversed through Cloudflare's servers at some point in your daily travels. I know I certainly have. What I didn't know, and have since learnt, is they use one of the coolest and most ingenious methods of generating entropy: the wall of lava lamps in the lobby of their San Francisco office.

> LavaRand is a system that uses lava lamps as a secondary source of randomness for our production servers. A wall of lava lamps in the lobby of our San Francisco office provides an unpredictable input to a camera aimed at the wall. A video feed from the camera is fed into a CSPRNG, and that CSPRNG provides a stream of random values that can be used as an extra source of randomness by our production servers. Since the flow of the “lava” in a lava lamp is very unpredictable,1 “measuring” the lamps by taking footage of them is a good way to obtain unpredictable randomness. Computers store images as very large numbers, so we can use them as the input to a CSPRNG just like any other number.
>
> We're not the first ones to do this. Our LavaRand system was inspired by a similar system first [proposed and built](https://en.wikipedia.org/wiki/Lavarand) by Silicon Graphics and [patented](https://www.google.com/patents/US5732138) in 1996 (the patent has since expired).  
— <cite>[Randomness 101: LavaRand in Production](https://blog.cloudflare.com/randomness-101-lavarand-in-production/)

I didn't know this has been done before either.

[Randomness 101: LavaRand in Production](https://blog.cloudflare.com/randomness-101-lavarand-in-production/) gives a good low-tech explanation. If you want to get your hands dirty, [LavaRand in Production: The Nitty-Gritty Technical Details](https://blog.cloudflare.com/lavarand-in-production-the-nitty-gritty-technical-details) has what you want. And if you're a fan of videos...

{% include video id="1cUUfMeOijg" provider="youtube" %}
