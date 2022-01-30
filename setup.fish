#!/bin/env fish
if test -f ~/.emacs
  mv ~/.emacs ~/.emacs.bak
end

if test -d ~/.emacs.d
  mv ~/.emacs.d ~/.emacs.d.bak
end

ln -sf (pwd)/emacs.el ~/.emacs
cp hooks/* .git/hooks/ 
chmod +x .git/hooks/*

