;; ensure that our PATH is set correctly if we're not on windows
(when (equal system-type 'darwin)
  (setenv "PATH"
          (concat (expand-file-name "~/bin") ":"
                  (expand-file-name "~/.roswell/bin") ":"
                  "/opt/homebrew/sbin:"
                  "/opt/homebrew/bin:"
                  "/usr/local/bin:"
                  "/System/Cryptexes/App/usr/bin:"
                  "/usr/bin:"
                  "/bin:"
                  "/usr/sbin:"
                  "/sbin:"
                  "/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:"
                  "/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:"
                  "/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin:"
                  "/Library/Apple/usr/bin:"
                  "/usr/local/MacGPG2/bin:"
                  "/Applications/iTerm.app/Contents/Resources/utilities"))
  (setq exec-path (string-split (getenv "PATH") path-separator)))

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
