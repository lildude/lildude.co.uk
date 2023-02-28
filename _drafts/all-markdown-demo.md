---
layout: post
title: "All Markdown demo"
date: 2016-01-20 15:36:36 -0700
tags:
- markdown
- ano-tag
- another
type: post
published: true
expected_markdown: kramdown
---

This is a "test" post with all the markdown and HTML I'm likely to use in my writing.  This is so I can easily see and test all styling in a single post.  This post must remain draft as it's not very interesting as content.

- Current Markdown engine: {{ site.markdown }}
- Expected Markdown engine: {{ page.expected_markdown }}

If these two don't match, there will be :warning: for those items that are known to be {{ page.expected_markdown }}-specific or known to be specific to another engine, eg RedCarpet (Denoted :red_circle:)

[Kramdown quick ref](https://kramdown.gettalong.org/quickref.html)

# Syntax

## Strong and Emphasize

- **strong** or __strong__ ( Cmd + B )

- *emphasize* or _emphasize_ ( Cmd + I )

- **Sometimes I want a lot of text to be bold.
  Like, seriously, a _LOT_ of text**

- *I'm italic,  **we're not**, we are*.

### Blockquotes

- > Right angle brackets &gt; are used for block quotes.

### Links and Email

- An email <example@example.com> link.

- Simple inline link <https://chenluois.com>, another inline link [Smaller](https://smallerapp.com), one more inline link with title [Resize](https://resizesafari.com "a Safari extension").

- A [reference style][id] link. Input id, then anywhere in the doc, define the link with corresponding id:

  [id]: https://mouapp.com "Markdown editor on Mac OS X"

  Titles/tool tips in the links are optional.

- {% if site.markdown != "redcarpet" %}:red_circle: **Requires `autolink` Redcarpet extension.**{% endif %} Autolinked? => https://colinseymour.co.uk

## Images

- An inline image ![Smaller icon](https://smallerapp.com/favicon.ico "Title here"), title is optional.

- A ![Resize icon][2] reference style image.

  [2]: https://resizesafari.com/favicon.ico "Title"

- {% if site.markdown != "kramdown" %}:warning:{% endif %} A resized centre-aligned image using kramdown syntax:
  `![Bigger centered](/img/profile.png){:height="200" width="200" class="center"}`

  ![Bigger centered](/img/profile.png){:height="200" width="200" class="center"}

## Inline code and Block code

- Inline code are surround by `backtick` key. To create a block code:

      Indent each line by at least 1 tab, or 4 spaces.
        var Mou = exactlyTheAppIwant;

##  Ordered Lists

Ordered lists are created using "1." + Space:

1. Ordered list item
2. Ordered list item
3. Ordered list item

- Nested ordered lists:

  1. Order list item
  1. Order list item
  1. Order list item

## Unordered Lists

Unordered list are created using "*" + Space:

* Unordered list item
* Unordered list item
* Unordered list item

- Nested unordered "*" list:

  * Unordered list item
  * Unordered list item
  * Unordered list item

Or using "-" + Space:

- Unordered list item
- Unordered list item
- Unordered list item

- Nested unordered "-" list:

  - Unordered list item
  - Unordered list item
  - Unordered list item


## Hard Linebreak

End a line with two or more spaces will create a hard linebreak, called `<br />` in HTML. ( Control + Return )
Above line ended with 2 spaces.

## Horizontal Rules

Three or more asterisks or dashes:

Asterisks:

***

Dashes:

---

Spaced dashes:

- - - -

## Headers

- ### _Setext-style:_

  This is H1
  ==========

  This is H2
  ----------

- ### _ATX-style:_

  # This is H1

  ## This is H2

  ### This is H3

  #### This is H4

  ##### This is H5

  ###### This is H6

---

## Extra Syntax

### Footnotes
{% if site.markdown != "redcarpet" and site.markdown != "kramdown" %}:red_circle::warning: **Requires `footnotes` Redcarpet extension or Kramdown w/ GFM**{% endif %}

Footnotes work mostly like reference-style links. A footnote is made of two things: a marker in the text that will become a superscript number; a footnote definition that will be placed in a list of footnotes at the end of the document. A footnote looks like this:

That's some text with a footnote.[^1]

[^1]: And that's the footnote.

### Strikethrough
{% if site.markdown != "redcarpet" %}:red_circle: **Requires `strikethrough` Redcarpet extension.**{% endif %}

Wrap with 2 tilde characters:

~~Strikethrough~~

### Fenced Code Blocks

Start with a line containing 3 or more backticks, and ends with the first line with the same number of backticks:

```
Fenced code blocks are like Standard Markdown's regular code
blocks, except that they're not indented and instead rely on
a start and end fence lines to delimit the code block.
```

### Tables
{% if site.markdown != "redcarpet" and site.markdown != "kramdown" %}:red_circle::warning: *Requires `tables` Redcarpet extension or Kramdown w/ GFM.* {% endif %}

A simple table looks like this:

First Header | Second Header | Third Header
------------ | ------------- | ------------
Content Cell | Content Cell  | Content Cell
Content Cell | Content Cell  | Content Cell

If you wish, you can add a leading and tailing pipe to each line of the table:

| First Header | Second Header | Third Header |
| ------------ | ------------- | ------------ |
| Content Cell | Content Cell  | Content Cell |
| Content Cell | Content Cell  | Content Cell |

Specify alignment for each column by adding colons to separator lines:

First Header | Second Header | Third Header
:----------- | :-----------: | -----------:
Left         | Center        | Right
Left         | Center        | Right

---

### Superscript
{% if site.markdown != "redcarpet" %}:red_circle: **Requires `superscript` Redcarpet extension.**{% endif %}

This is the 2^(nd) time I've done this, not the 3^rd.

---

## Plugin rendered content

### Emoji

{% unless site.gems contains "jemoji" or site.gems contains "twemoji" or site.gems contains "jekyll-emoji" %}
:exclamation: **An emoji plugin like, `jemoji`, `twemoji` or `keyll-emoji` is required.**
{% endunless %}
:smile: :kissing_heart: :poop: :cyclone: :octocat: :+1: :us: :gb:

---

## Additional HTML

### Colours

_This is only used by colinseymour.co.uk at the moment._

<div class="color_blocks">
 <span class="primary_color"></span>
 <span class="primary_color_15"></span>
 <span class="primary_color_10"></span>
 <span class="primary_color_lighten_30"></span>
 <span class="primary_color_darken_10"></span>
</div>

### Stretched image

_This is only used by colinseymour.co.uk at the moment._


<img src="/img/profile.png" class="stretch" alt="Stretched img" />

### Image alignment

<img src="/img/profile.png" class="alignleft" alt="left image" /> Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur ac ligula ex. Nam ut justo in erat porta suscipit. Duis pretium ligula id arcu dictum, quis egestas felis tempor. Duis molestie nunc tristique ante vehicula tincidunt. Aenean nec felis rutrum, placerat dolor id, placerat lectus. Curabitur nunc enim, pharetra in tempor nec, semper ac velit. Aliquam eleifend, urna varius euismod lobortis, justo tellus consequat arcu, in pellentesque ligula nisl a dolor.

<img src="/img/profile.png" class="alignright" alt="right image" /> Fusce sem lacus, luctus vel dui ut, lobortis rhoncus velit. Nulla facilisi. Donec et erat accumsan purus dapibus vulputate sit amet sit amet tortor. Vestibulum eu vehicula felis. Suspendisse a enim at justo porttitor luctus. Proin ac urna sapien. Curabitur non aliquam neque. Donec tincidunt, nisi sit amet ullamcorper interdum, magna mi imperdiet lorem, sit amet sagittis neque nulla at enim. Morbi efficitur viverra nibh at tempus. Suspendisse molestie commodo posuere. Fusce aliquam fringilla dictum. Mauris viverra eleifend quam, sit amet vehicula est sagittis sit amet. Praesent lobortis nisi non tellus egestas porttitor.

<img src="https://colinseymour.smugmug.com/photos/274240894_PWUna-S.jpg" class="center stretch" alt="center image" />

---

## Syntax Highlighting

### Using Liquid tags

{% highlight ruby %}
class Post < ActiveRecord::Base
  DEFAULT_LIMIT = 15

  acts_as_taggable

  has_many                :comments, :dependent => :destroy
  has_many                :approved_comments, :class_name => 'Comment'

  before_validation       :generate_slug
  before_validation       :set_dates
  before_save             :apply_filter

  validates_presence_of   :title, :slug, :body

  validate                :validate_published_at_natural

  def validate_published_at_natural
    errors.add("published_at_natural", "Unable to parse time") unless published?
  end

  attr_accessor :minor_edit
  def minor_edit
    @minor_edit ||= "1"
  end

  def minor_edit?
    self.minor_edit == "1"
  end

  def published?
    published_at?
  end

  attr_accessor :published_at_natural
  def published_at_natural
    @published_at_natural ||= published_at.send_with_default(:strftime, 'now', "%Y-%m-%d %H:%M")
  end
end
{% endhighlight %}

### Using codeblock

```php
<?php
echo "PHPINFO";
phpinfo();
?>
```
