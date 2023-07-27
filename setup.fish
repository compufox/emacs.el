#!/bin/env fish
set -l font_dir "~/.fonts"

if string match -q "Darwin" (uname)
    set font_dir "~/Library/Fonts/"
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

echo "Creating bootstrap init file..."
emacs --script "tangle-bootstrap.el"

echo "Making link..."
ln -sf (pwd)/bootstrap.el ~/.emacs

echo "Installing git hooks..."
cp hooks/* .git/hooks/
chmod +x .git/hooks/*

echo "Installing fonts..."
find -E fonts -type f -regex ".*\.(otf|ttf)" -exec cp \{\} $font_dir \;

if not string match -q (which fc-cache)
  fc-cache -v
end

echo "Touching local.el file..."
touch local.el
