---
layout: post
title: "Sort an Array of Strings by Severity in Ruby"
date: 2016-08-16 17:17:33 +0100
tags:
- ruby
- programming
type: post
published: true
---

I'm a bit of a pedant when it comes to ordering things and today I had the need to sort an array of strings that contain severity levels, in descending order of severity, that is in the order "CRITICAL", "HIGH", "MEDIUM", "LOW".

I'm a bit of a Ruby noob and had a general idea of how it could be done, but like everyone else, I turned to [Stackoverflow](https://stackoverflow.com/) and whilst a lot of the results were useful, none quite did what I wanted.  The useful ones did however give me enough to come up with my own solution.  

This is what I've got, how I did it, and what I ended up with.

I've got an array of strings which looks something like this:

```ruby
fixes = [
  "* **LOW** I am a low severity fix",
  "* **CRITICAL** I am a critical severity fix",
  "* **MEDIUM** I am a medium severity fix",
  "* **HIGH** I am a high severity fix",
  "* **CRITICAL** I am another critical severity fix",
  "* **LOW** I'm another low severity fix"
]
```

As you can see, they're not in any order, and yes, I could probably changed code elsewhere to store these in a multi-dimensional array or hash based on severity, but I didn't want to do that. I wanted to sort the list I'd been given.

After a fair amount of tatting in `irb`, I came up with this solution:

```ruby
levels = ["CRITICAL", "HIGH", "MEDIUM", "LOW"]
fixes.sort_by! { |f| levels.index f[/(CRITICAL|HIGH|MEDIUM|LOW)/] }
```

This gave me by desired ordering.

See it all in action in this `irb` session:

```
$ irb
>> fixes = [
?>   "* **LOW** I am a low severity fix",
?>   "* **CRITICAL** I am a critical severity fix",
?>   "* **MEDIUM** I am a medium severity fix",
?>   "* **HIGH** I am a high severity fix",
?>   "* **CRITICAL** I am another critical severity fix",
?>   "* **LOW** I'm another low severity fix"
>> ]
=> ["* **LOW** I am a low severity fix", "* **CRITICAL** I am a critical severity fix", "* **MEDIUM** I am a medium severity fix", "* **HIGH** I am a high severity fix", "* **CRITICAL** I am another critical severity fix", "* **LOW** I'm another low severity fix"]
>> levels = ["CRITICAL", "HIGH", "MEDIUM", "LOW"]
=> ["CRITICAL", "HIGH", "MEDIUM", "LOW"]
>> fixes.sort_by! { |f| levels.index f[/(CRITICAL|HIGH|MEDIUM|LOW)/] }
=> ["* **CRITICAL** I am a critical severity fix", "* **CRITICAL** I am another critical severity fix", "* **HIGH** I am a high severity fix", "* **MEDIUM** I am a medium severity fix", "* **LOW** I am a low severity fix", "* **LOW** I'm another low severity fix"]
>> puts fixes
* **CRITICAL** I am a critical severity fix
* **CRITICAL** I am another critical severity fix
* **HIGH** I am a high severity fix
* **MEDIUM** I am a medium severity fix
* **LOW** I am a low severity fix
* **LOW** I'm another low severity fix
=> nil
>>
```

If you're a hardcore long-life Ruby programmer, this may be easy or old new for you, but it was quite a discovery for me and I thought I'd document it so I can refer to it later and who knows, I may help someone else.
