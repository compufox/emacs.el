#!/bin/env fish
set -l font_dir "~/.fonts"

if string match -q "Darwin" (uname)
    set font_dir "~/Library/Fonts"
end

if test -f ~/.emacs
  mv ~/.emacs ~/.emacs.bak
end

if test -d ~/.emacs.d
  mv ~/.emacs.d ~/.emacs.d.bak
end

ln -sf (pwd)/emacs.el ~/.emacs
cp hooks/* .git/hooks/ 
chmod +x .git/hooks/*

cp fonts/* $font_dir
fc-cache -v
