if test -f ~/.emacs
  mv ~/.emacs ~/.emacs.bak
end

if test -d ~/.emacs.d
  mv ~/.emacs.d ~/.emacs.d.bak
end

ln -s (pwd)/emacs.el ~/.emacs