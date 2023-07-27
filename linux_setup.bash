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

echo "Creating bootstrap init file..."
emacs --script "tangle-bootstrap.el"

echo "Making link..."
ln -sf $(pwd)/bootstrap.el ~/.emacs

## Commenting this out for now
#echo "Installing git hooks..."
#cp hooks/* .git/hooks/
#chmod +x .git/hooks/*

echo "Installing fonts..."
find -E fonts -type f -regex ".*\.(otf|ttf)" -exec cp \{\} $font_dir \;
fc-cache -v 

echo "Touching local.el file"
touch local.el
