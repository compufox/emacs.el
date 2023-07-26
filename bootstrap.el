(defvar *tangled-configs*
  '("custom" "variables" "macros"
    "functions" "interactive-functions"
    ;; TODO: replace misc with os-specific files
    "misc" "packages"
    "theme" "lastly")
  "list of all custom configuration filenames, in loading order")

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

;; then we iterate thru our list of config files and
;; let org-babel detangle and load them
(let ((config-dir (concat (file-name-directory (file-truename "~/.emacs"))
			  "config/")))
  (mapcar #'org-babel-load-file
	  (mapcar #'(lambda (filename)
		      (concat config-dir filename ".org"))
		  *tangled-configs*)))
