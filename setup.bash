#!/bin/env bash
font_dir = "~/.fonts"

if [ "$(uname)" == "Darwin" ] ; then
    font_dir = "~/Library/Fonts"
fi

if [ ! -d $font_dir ] ; then
    mkdir $font_dir
fi

[[ -f ~/.emacs ]] ; mv ~/.emacs ~/.emacs.bak
[[ -d ~/.emacs.d ]] ; mv ~/.emacs.d ~/.emacs.d.bak

echo "Making link..."
ln -sf $(pwd)/emacs.el ~/.emacs

echo "Installing git hooks..."
cp hooks/* .git/hooks/
chmod +x .git/hooks/*

echo "Installing fonts..."
cp fonts/* $font_dir
fc-cache -v 
