(unless (file-exists-p (file-name-concat user-emacs-directory "init" "strapped.el"))
  (make-directory (file-name-concat user-emacs-directory "init") 'make-parents)
  (require 'org)
  (org-babel-tangle-file (file-name-concat
			  (file-name-directory (file-truename "~/.emacs"))
                          "config.org"))
  (restart-emacs))

(load (file-name-concat user-emacs-directory "init" "strapped.el"))
