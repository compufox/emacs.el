;; download and setup straight.el...
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 6))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; ...and then use that to download use-package & org-mode
(straight-use-package 'org)

(defun focks/tangle-and-load-file (file)
  "tangles our configs to a specific location and then loads them (keeps config dir clean)"
  (unless (file-directory-p "~/.emacs.d/init/")
    (make-directory "~/.emacs.d/init/"))
  (let ((tangled-file (concat "~/.emacs.d/init/" (file-name-base file) ".el")))
    (org-babel-tangle-file file
                           tangled-file
                           (rx string-start
                               (or "emacs-lisp" "emacs")
                               string-end))
    (load tangled-file nil 'no-message)))

;; then we iterate thru our list of config files and
;; let org-babel detangle and load them
(let ((config-dir (concat (file-name-directory (file-truename "~/.emacs"))
			  "config/")))
  (mapcar #'focks/tangle-and-load-file
	  (cl-remove-if #'file-directory-p
		        (directory-files config-dir 'full ".org"))))
