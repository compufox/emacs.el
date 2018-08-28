[[ -f ~/.emacs ]] ; mv ~/.emacs ~/.emacs.bak
[[ -d ~/.emacs.d ]] ; mv ~/.emacs.d ~/.emacs.d.bak

ln -s $(pwd)/emacs.el ~/.emacs
ln -s $(pwd)/emacs.d ~/.emacs.d
