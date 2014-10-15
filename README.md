lildude.co.uk
=============

This is the source repository for [lildude.co.uk](http://lildude.co.uk).

This is really of no interest to anyone other than me and is for the moment a scratchpad documenting my migration of this site from Habari to Jekyll and then possibly on to GitHub Pages.



## How I deploy to my own server

- Add a new remote that is on my hosting server:
  `git add remote deploy user@hosting.srv`
- Add the following `post-receive` hook to it:

  ```
  #!/bin/sh
  PUBLIC_WWW=${HOME}/www/lildude
  rm -rf ${PUBLIC_WWW}/*
  git archive gh-pages | tar -x -C ${PUBLIC_WWW}
  exit
  ```
- deploy using: `git push deploy gh-pages --force`

## Todos

- [ ] Find a theme I like and customise it
