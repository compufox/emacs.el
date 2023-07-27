(let ((file (file-name-directory load-file-name)))
  (require 'org)
  (org-babel-tangle-file (file-name-concat file "config" "0-bootstrap.org")
                         (file-name-concat file "bootstrap.el")
                         (rx string-start
                             (or "emacs-lisp" "emacs")
                             string-end)))
