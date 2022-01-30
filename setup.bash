#!/bin/env bash
[[ -f ~/.emacs ]] ; mv ~/.emacs ~/.emacs.bak
[[ -d ~/.emacs.d ]] ; mv ~/.emacs.d ~/.emacs.d.bak

ln -sf $(pwd)/emacs.el ~/.emacs
cp hooks/* .git/hooks/
chmod +x .git/hooks/*
