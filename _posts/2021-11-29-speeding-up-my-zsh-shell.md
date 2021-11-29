---
layout: post
title: "Speeding Up My ZSH Shell"
date: 2021-11-29 10:21:20 +0000
tags:
- zsh
- shell
type: post
---

ZSH has been my shell for well over fifteen years with my configuration framework of choice being [prezto](https://github.com/sorin-ionescu/prezto) for the last eight years of those. In that time, I've tweaked my prompt and configuration as my needs have evolved and as I encountered performance issues, and it's those performance issues that drew me to dig into my ZSH configuration and prompt again.

### Pesky git status information

The biggest issue has been the fact I like git status information in my prompt - who doesn't. I'd been using the native ZSH VCS functions for a long time, which wasn't normally a problem on small repositories, but these functions perform terribly on very large repos, like the main GitHub.com repo (it's massive), and repos with lots of submodules, like the [Linguist repo](https://github.com/github/linguist). As a result, I've spent waaay too long digging into and dabbling with various methods of getting this information quickly and finally settled on using [gitstatusd](https://github.com/romkatv/gitstatus) a few years ago and then moved to using the [powerlevel10k](https://github.com/romkatv/powerlevel10k) prompt earlier this year when I discovered it whilst looking at methods of implementing an async prompt in an effort to speed things up, or at least give the appearance of things being faster, even more.

The switch to using gitstatusd was a massive win on those big repos. Pressing enter went from having a very noticeable delay to a barely noticeable delay, but things were still taking a little too long. So I went looking elsewhere.

### Try another shell

I briefly experimented with the Fish shell, which was quite an enjoyable experience, but it also suffered from a slow prompt on large repos which I didn't want to have to go investigating all over again. I also couldn't get used to the new syntax on the prompt - I didn't realise how much of my daily workflow involves adhoc bash/zsh scripts written on the fly, so back to ZSH I went.

### What about Oh My ZSH?

I now spend a lot of time using [GitHub Codespaces](https://github.com/features/codespaces) and using VS Code Remote Containers and both use Oh My ZSH as the default configuration framework for ZSH if you don't configure them to use your own dotfiles. This gave me the opportunity to take another look at Oh My ZSH. I'd experimented with it waaaay back when I started using prezto but hadn't looked at it again.

So was it any better? You tell me. 

Here's my prezto-based shell env using the powerlevel10k prompt (with gitstatusd) run in a VS Code Remote Container terminal (I know it has it's own performance issues, but this is where I spend a lot of time):

![Timing my prezto-based prompt](/img/dotfiles-prezto.png)

And this is Oh My ZSH:

![Timing my OMZ-based prompt](/img/dotfiles-oh-my-zsh.png)


Wow!! This is quite the improvement, and this is with Oh My ZSH using the ZSH VCS functions.

This told me something: this wasn't entirely my prompt at play as the repo in question isn't one of those known to perform badly. My framework (prezto) must be doing a lot more than I think it is. Time to fire up zprof.

### Profiling my ZSH framework

I've have this line at the top of my `.zshrc`:

```shell
[ -z "$ZPROF" ] || zmodload zsh/zprof
```

... and this at the end:

```shell
[ -z "$ZPROF" ] || zprof
```

This allows me to quickly profile my shell with a simple command: `ZPROF=1 zsh -i -c exit`. Running this was quite revealing:

![zprof of my prezto-based prompt](/img/prezto-zprof.png)

That `pmodload` is prezto's custom module loader, and it's been a very busy boy. I don't have that many modules enabled, and certainly none of the normal culprits that configure the likes of `rbenv`, `npmenv` etc, but I clearly have enough enabled for this to be the most prominant function call. Looking more closely at the profile output, I can see a lot of time was spent in compinit, which would be those modules pulling in their respective completions.

So I went digging into the `pmodload` function to see what it does and if I could improve it. It was then that I realised one of the downsides of using such a module system is pulling in each module is going to involve I/O but more importantly, repeated execution of the same few functions over and over and over again.

This got me thinking, what if I moved away from using a framework and smooshed my entire ZSH configuration down into a single file and optimise things to reduce I/O and repetition?

### Smoosh it all into one file

So down that rabbit hole I went. I dumped my entire ZSH environment into a single file and then started working my way through it removing things I didn't need, wasn't using, or didn't have a clue what they did. Things broke, big time. Why on earth did I think otherwise? 😝

Fixing this one file was going to take a very long time, so I took a step back and thought about starting from scratch and building things up again with performance measurement in mind. This seemed like a good idea as it would ultimately ensure I only had what I needed and would definitely end up with a fastest shell, but this would take a long time and I wanter fast things now so I went searching for examples of others moving away from a framework in favour of a "simplified approach" to see if someone had come up with a good approach. 

It was during this that I stumbled upon [this comment on Reddit](https://www.reddit.com/r/zsh/comments/ipw8ap/do_you_guys_still_use_frameworks_and_plugins/g4mhc59/) mentioning [zsh4humans](https://github.com/romkatv/zsh4humans/). Yes, it's a framework and not what I was looking for, but not one I'd seen before either, so I was intrigued. What's more, it's also from the same author of gitstatusd and powerlevel10k which I already use.

### ZSH for Humans

One Docker command later and I knew I was onto a winner. The default configuration looks a lot like my environment, pulls in gitstatusd and powerlevel10k and best of all, it's blazingly fast. Time to switch direction, stick with a framework, and move my configuration over from prezto.

A few days later and look at this:

![Timing my zsh4humans-based prompt](/img/dotfiles-zsh4humans.png)

That's a massive 87% improvement and my new shell environment 😁.

After all that effort, investigation and learning, it turns out I can have a fast shell environment with a framework: use ZSH For Humans.
