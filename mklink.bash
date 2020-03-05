[[ -f ~/.emacs ]] ; mv ~/.emacs ~/.emacs.bak
[[ -d ~/.emacs.d ]] ; mv ~/.emacs.d ~/.emacs.d.bak

ln -sf $(pwd)/emacs.el ~/.emacs
