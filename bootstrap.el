(let ((strap-file (file-name-concat user-emacs-directory "init" "strapped.el")))
  ;; checks for our tangled bootstrap elisp file
  ;; if it doesnt exist, we create the emacs.d/init directory
  ;; loads org, tangles our config and finally restarts the editor
  (unless (file-exists-p strap-file)
    (make-directory (file-name-concat user-emacs-directory "init") 'make-parents)
    (require 'org)
    (org-babel-tangle-file (file-name-concat
			    (file-name-directory (file-truename "~/.emacs"))
                            "config.org"))
    (restart-emacs))

  ;; if the file exists, we go ahead and load it.
  ;; it will automatically tangle the config file
  ;; and recreate itself as needed
  (load strap-file nil 'no-message))
