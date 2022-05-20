#!/bin/env fish
set -l font_dir "~/.fonts"

if string match -q "Darwin" (uname)
    set font_dir "~/Library/Fonts"
end

if not test -d $font_dir
    mkdir $font_dir
end

if test -f ~/.emacs
  mv ~/.emacs ~/.emacs.bak
end

if test -d ~/.emacs.d
  mv ~/.emacs.d ~/.emacs.d.bak
end

echo "Making link..."
ln -sf (pwd)/emacs.el ~/.emacs

echo "Installing git hooks..."
cp hooks/* .git/hooks/
chmod +x .git/hooks/*

echo "Installing fonts..."
cp fonts/* $font_dir
fc-cache -v
