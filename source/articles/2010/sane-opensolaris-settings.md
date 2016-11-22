---
title: Sane Opensolaris Settings
author: Holger Just
date: 2010-02-05 12:46 UTC
lang: :en
tags: Technology
cover: 2010/sane-opensolaris-settings/cover.jpg
cover_license: 'Cover Image ["Sunset in the Park"](https://unsplash.com/photos/ocwmWiNAWGs) by [Jake Givens](https://unsplash.com/@jakegivens), [CC Zero 1.0](https://unsplash.com/license)'
layout: post
---

Opensolaris has done some huge steps towards being usable by a normal person. Sadly there are still some things lacking sane defaults which I try to provide here. I will try to update this post if I stumble over more of these hiccups.

READMORE

## Correct colors on exit of an ncurses program

If an ncurses program (like `nano`) exits, the default xterm-color does not properly restore the colors of the terminal. The background color is shown in a dark gray. For a quick relieve you can issue a short

```bash
tput rs1
```

As this is rather cumbersome, I think it is better to adjust out terminfo definitions.

```bash
TERM=xterm-color infocmp > /tmp/xterm-color.src
sed -i -e 's/op=\\E\[100m,/op=\\E\[m,/' /tmp/xterm-color.src
pfexec tic -v /tmp/xterm-color.src
rm /tmp/xterm-color.src
```

The solution is from the [Opensolaris Bug](http://bugs.opensolaris.org/bugdatabase/view_bug.do?bug_id=6902588), the rough steps from [Peter Harvey](http://blogs.sun.com/peteh/entry/fixing_terminfo_so_that_terminal).

## Fixing some key bindings

By default some essential key bindings do not work properly. This can be fixed by just reassigning them. The following statement has to be run as root.

```bash
cat >> /etc/profile <<BASH
# home key
bind '"\e[1~":beginning-of-line'
# del key
bind '"\e[3~":delete-char'
# end key
bind '"\e[4~":end-of-line'
# pgup key
bind '"\e[5~":history-search-forward'
# pgdn key
bind '"\e[6~":history-search-backward'
BASH
```

You have to logout and login again for these settings to take effect. Alternatively you could just enter the individual `bind` statements into your current terminal.

The bindings are from [Epiphanic Networks' Wikka](http://wiki.epiphanic.org/MiscOpenSolaris).
