---
layout: post
title: "Using `&lt;details&gt;` on GitHub"
date: 2016-07-05 11:01:44 +0100
tags:
- GitHub
type: post
published: true
---

This is a cool and incredibly useful little trick I discovered I could use on GitHub today.

Suppose you're opening an issue or commenting on an issue and there's a metric boat load of information that _may_ be useful and pertinent to the issue, for example a full Ruby stack. Rather than wrecking readability, wrap it in a [`<details>`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/details) tag.

So something like:

```
<details>
 <summary>Stack Trace for `require('does.not.exist')`</summary>
 ```shell
 require('does.not.exist')
 Error: Cannot find module 'does.not.exist'
   at Function.Module._resolveFilename (module.js:336:15)
   at Function.Module._load (module.js:286:25)
   at Module.require (module.js:365:17)
   at require (module.js:384:17)
   at repl:1:1
   at REPLServer.defaultEval (repl.js:164:27)
   at bound (domain.js:250:14)
   at REPLServer.runBound [as eval] (domain.js:263:12)
   at REPLServer.<anonymous> (repl.js:393:12)
   at emitOne (events.js:82:20)
 ```
</details>
```

... will show up as follows on GitHub:

![&lt;details&gt; collapsed](/assets/details-collapsed.png)

... and clicking it will change it to reveal the full content:

![<&lt;details&gt; expanded](/assets/details-expanded.png)

This cool discovery is brought to you by [ericclemmons](https://gist.github.com/ericclemmons/b146fe5da72ca1f706b2ef72a20ac39d).
