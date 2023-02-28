---
layout: post
title: "Pridify Your GitHub Contributions Graph"
date: 2015-06-27 19:17:41 +0100 2015-06-27 19:03:38 +0100
tags:
- GitHub
- javascript
- pride
type: post
published: true
---
I saw this Tweet...

<blockquote class="twitter-tweet tw-align-center " data-partner="tweetdeck"><p lang="en" dir="ltr">Saw today&#39;s <a href="https://twitter.com/hashtag/Github?src=hash">#Github</a> logo and wanted my contribution graph to match with it... <a href="https://t.co/fzAlzP1474">https://t.co/fzAlzP1474</a> <a href="https://t.co/7FwZ0OlIdr">pic.twitter.com/7FwZ0OlIdr</a></p>&mdash; Noel Delgado (@pixelia_me) <a href="https://twitter.com/pixelia_me/status/614533965194530816">June 26, 2015</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

... and thought I wanted some of that too. So here you go, my "pridified" GitHub contributions graph:

![Pridified GitHub contributions graph](/img/pridified_contributions.png)

For those who want to it too, and don't want to follow another link to the [Gist](https://gist3.github.com/noeldelgado/62cdf5efd985fa4f52ff), open up the Developer Tools in your favourite browser and paste this code into the Javascript console:

```javascript
var GH = ['#EEEEEE', '#D6E685', '#8CC665', '#44A340', '#1E6823'];
var CO = ['#EF4B4D', '#F89B47', '#FAEA20', '#7DC242', '#5D94CE', '#855CA7'];

var graph = document.getElementsByClassName('js-calendar-graph-svg')[0];
var days = [].slice.call(graph.getElementsByTagName('rect'), 0);

days.forEach(function(rect) {
    switch(rect.getAttribute('fill').toUpperCase()) {
        case GH[0]: rect.setAttribute('fill', CO[2]); break; // yellow
        case GH[1]: rect.setAttribute('fill', CO[Math.floor(Math.random() * 2)]); break; // red || orange
        case GH[2]: rect.setAttribute('fill', CO[3]); break; // green
        case GH[3]: rect.setAttribute('fill', CO[4]); break; // blue
        case GH[4]: rect.setAttribute('fill', CO[5]); break; // purple
    }
});
```
