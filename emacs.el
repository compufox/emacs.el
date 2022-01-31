(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(backup-directory-alist '((".*" concat (getenv "HOME") "/.emacs.d/backups")))
 '(column-number-mode t)
 '(company-quickhelp-use-propertized-text t)
 '(custom-safe-themes
   '("1b8d67b43ff1723960eb5e0cba512a2c7a2ad544ddb2533a90101fd1852b426e" "82d2cac368ccdec2fcc7573f24c3f79654b78bf133096f9b40c20d97ec1d8016" "628278136f88aa1a151bb2d6c8a86bf2b7631fbea5f0f76cba2a0079cd910f7d" "bb08c73af94ee74453c90422485b29e5643b73b05e8de029a6909af6a3fb3f58" default))
 '(dired-use-ls-dired nil)
 '(flycheck-color-mode-line-face-to-color 'mode-line-buffer-id)
 '(frame-background-mode 'dark)
 '(global-emojify-mode t)
 '(inhibit-startup-screen t)
 '(make-backup-files nil)
 '(package-selected-packages
   '(marginalia lua-mode fennel-mode modus-themes swift-mode company-quickhelp company-box nova-theme color-theme-sanityinc-tomorrow subatomic-theme parinfer-rust-mode emojify frog-jump-buffer workgroups2 popwin request css-eldoc eros symon sly-asdf sly-quicklisp sly-named-readtables sly-macrostep counsel-projectile ivy-hydra counsel swiper fish-mode markdown-mode treemacs-magit treemacs-projectile macrostep macrostep-expand elcord company magit sly win-switch multiple-cursors poly-erb amx ido-completing-read+ rainbow-delimiters dimmer emr doom-themes prism projectile treemacs doom-modeline minions))
 '(save-place t nil (saveplace))
 '(show-paren-mode t)
 '(size-indication-mode t)
 '(tool-bar-mode nil)
 '(tool-bar-position 'left)
 '(vc-annotate-background nil)
 '(vc-annotate-very-old-color nil)
 '(window-divider-mode nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :stipple nil :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 113 :width normal :foundry "unknown" :family "Cartograph CF"))))
 '(font-lock-comment-face ((t (:slant italic :family "Cartograph CF")))))

;;;
;; BEGIN CUSTOM VARIABLES
;;;

(defvar enable-dark-theme t)
(defvar face-height 120)

;; got this disabled for now because (macos-theme) always returns dark if
;;  the system theme is set to auto :rolling-eyes:
(defvar auto-update-macos-theme nil)

;;;
;; END CUSTOM VARIABLES
;;;

;;;
;;  BEGIN CUSTOM MACROS
;;;

(defmacro when-on (os &rest type-names)
  "define a macro (named when-on-OS) to run code when SYSTEM-TYPE matches any symbol in TYPE-NAMES

OS is a symbol (or string) to be placed in the macro name
TYPE-NAMES is a list of symbols that correspond to values returned by system-type"
  `(defmacro ,(intern (mapconcat (lambda (x) (format "%s" x)) (list "when-on-" os) "")) (&rest body)
     `(when (or ,@(mapcar (lambda (name) `(eq system-type ',name))
			  ',type-names))
	,@body)))

(defmacro unless-on (os &rest type-names)
  "define a macro (named unless-on-OS) to run code when SYSTEM-TYPE matches any symbol in TYPE-NAMES

OS is a symbol (or string) to be placed in the macro name
TYPE-NAMES is a list of symbols that correspond to values returned by system-type"
  `(defmacro ,(intern (mapconcat (lambda (x) (format "%s" x)) (list "unless-on-" os) "")) (&rest body)
     `(unless (or ,@(mapcar (lambda (name) `(eq system-type ',name))
                            ',type-names))
	,@body)))

(defmacro os-cond (&rest forms)
  `(cond
    ,@(loop for f in forms
            if (eq (car f) t)
             collect `(t ,@(cdr f))
            else
             collect `((eq system-type ',(car f))
                       ,@(cdr f)))))

(when-on osx darwin)
(when-on bsd berkeley-unix)
(when-on linux gnu/linux)
(when-on unix gnu/linux berkeley-unix)
(when-on windows windows-nt)
(unless-on bsd berkeley-unix)
(unless-on windows windows-nt)
(unless-on bsdish darwin berkeley-unix) ;; you know, bsd enough to count lmao


;;;
;;  END CUSTOM MACROS
;;;

;;;
;; BEGIN CUSTOM FUNCTIONS
;;;

(when-on-bsd 
 ;; the built-in battery-bsd-apm function doesnt seem to work on freebsd
 ;;  it has an extra command line argument, and doesnt properly parse the
 ;;  command output. here's my updated version
 (defun battery-freebsd-apm ()
   "Get APM status information from BSD apm binary.
The following %-sequences are provided:
%L AC line status (verbose)
%B Battery status (verbose)
%b Battery status, empty means high, `-' means low,
 `!' means critical, and `+' means charging
%p Battery charge percentage
%s Remaining battery charge time in seconds
%m Remaining battery charge time in minutes
%h Remaining battery charge time in hours
%t Remaining battery charge time in the form `h:min'"
   (let* ((apm-cmd "/usr/sbin/apm -blta")
	  (apm-output (split-string (shell-command-to-string apm-cmd)))
	  ;; Battery status
	  (battery-status
	   (let ((stat (string-to-number (nth 1 apm-output))))
	     (cond ((eq stat 0) '("high" . ""))
		   ((eq stat 1) '("low" . "-"))
		   ((eq stat 2) '("critical" . "!"))
		   ((eq stat 3) '("charging" . "+"))
		   ((eq stat 4) '("absent" . nil)))))
	  ;; Battery percentage
	  (battery-percentage (nth 2 apm-output))
	  ;; Battery life
	  (battery-life (nth 3 apm-output))
	  ;; AC status
	  (line-status
	   (let ((ac (string-to-number (nth 0 apm-output))))
	     (cond ((eq ac 0) "disconnected")
		   ((eq ac 1) "connected")
		   ((eq ac 2) "backup power"))))
	  seconds minutes hours remaining-time)
     (unless (member battery-life '("unknown" "-1"))
       (setq seconds (string-to-number battery-life)
             minutes (truncate (/ seconds 60)))
       (setq hours (truncate (/ minutes 60))
	     remaining-time (format "%d:%02d" hours
				    (- minutes (* 60 hours)))))
     (list (cons ?L (or line-status "N/A"))
	   (cons ?B (or (car battery-status) "N/A"))
	   (cons ?b (or (cdr battery-status) "N/A"))
	   (cons ?p (if (string= battery-percentage "255")
		        "N/A"
		      battery-percentage))
	   (cons ?s (or (and seconds (number-to-string seconds)) "N/A"))
	   (cons ?m (or (and minutes (number-to-string minutes)) "N/A"))
	   (cons ?h (or (and hours (number-to-string hours)) "N/A"))
	   (cons ?t (or remaining-time "N/A"))))))

(defun emojofy ()
  "turns a string into a formatted string for shitposting

prompts for PREFIX and WORD
copies the resulting formatted string into the kill-ring and displays a message
 showing what was put there

ex: 
PREFIX=wide
WORD=test

RESULT: :wide_t::wide_e::wide_s::wide_t:"
  (interactive)
  (let* ((prefix (read-string "prefix: "))
	 (word (read-string "word: "))
         (result (mapconcat (lambda (letter)
                              (format ":%s_%c:" prefix letter))
                            word "\u200d")))
    (kill-new result)
    (message result)))

(defun horz-flip-buffers ()
  "Flips the open buffers between two windows"
  (interactive)
  (let ((c-buf (buffer-name))
	(o-buf (buffer-name (window-buffer (next-window)))))
    (switch-to-buffer o-buf nil t)
    (other-window 1)
    (switch-to-buffer c-buf)
    (other-window (- (length (window-list)) 1))))

(defun buffer-existsp (buf-name)
  "checks if buffer with BUF-NAME exists in (buffer-list)"
  (member buf-name (mapcar #'buffer-name (buffer-list))))

(defun get-file-info ()
  "returns an alist with path and extension under :PATH and :EXTENSION"
  (let* ((split (split-string buffer-file-name "\\/" t))
	 (path (remove (1- (length split)) split))
	 (ext (car (last (split-string (car (last split)) "\\.")))))
    `((:path . ,path)
      (:extension . ,ext))))

(defun init-cpp-file (includes)
  "Quickly and easily initializes a c++ file with main
INCLUDES is a space seperated list of headers to include"
  (interactive "Mincludes: ")
  (let ((path (concat "/" (string-join
			   (butlast
			    (cdr (assoc :path (get-file-info)))) "/")
		      "/"))
	(inc-list (split-string includes " "))
	point)
    (dolist (inc inc-list)
      (insert "#include ")
      (if (file-exists-p (concat path inc ".h"))
	  (insert (concat "\"" inc ".h\"\n"))
	(insert (concat "<" inc ">\n"))))
    (insert "using namespace std;\n\n")
    (insert "int main(int argc, char *argv[]) {\n")
    (insert "  ")
    (setq point (point))
    (insert "\n  return 0;\n")
    (insert "}\n")
    
    (goto-char point)))

(defun stringify (&rest args)
  "converts every value in ARGS into a string and merges them together"
  (mapconcat (lambda (x) (format "%s" x))  args ""))

(defun fox-me-up ()
  "FOX ME UP INSIDE"
  (interactive)
  (message 
"  _,-=._              /|_/|
  `-.}   `=._,.-=-._.,  @ @._,   <(reet)
     `._ _,-.   )      _,.-'
        `    G.m-\"^m`m'"))

(defun list-cl-sources ()
  "list files that depend on CL package
(these need to be changed to use cl-lib)"
  (interactive)
  (message (apply #'concat (file-dependents (feature-file 'cl)))))

(defun posframe-fallback (buffer-or-name arg-name value)
  (let ((info (list :internal-border-width 3
                    :background-color "dark violet")))
    (or (plist-get info arg-name) value)))

(defun sly-qlot (directory)
  (interactive (list (read-directory-name "Project directory: ")))
  (require 'sly)
  (sly-start :program "qlot"
             :program-args '("exec" "ros" "-S" "." "run")
             :directory directory
             :name 'qlot
             :env (list (concat "PATH=" (mapconcat 'identity exec-path ":")))))

(defun load-emacs-theme ()
  "loads custom themes based on enable-dark-theme

ensures disabling all prior loaded themes before changing"
  (mapcar #'disable-theme custom-enabled-themes)
  (if enable-dark-theme
      (load-theme 'challenger-deep t)
    (modus-themes-load-operandi)))

(defun blankp (string)
  "returns t if STRING is an empty string"
  (string= string ""))

(defun make-buffer (name)
  "creates and switches to a new buffer with name NAME"
  (interactive "Bname: ")
  (let ((buff (generate-new-buffer name)))
    (switch-to-buffer buff)))

(defun scratch ()
  "switches to the scratch buffer, creating it if needed"
  (interactive)
  (switch-to-buffer (get-buffer-create "*scratch*"))
  (when (blankp (buffer-string))
    (insert ";; This buffer is for text that is not saved, and for Lisp evaluation.\n")
    (insert ";; To create a file, visit it with C-x C-f and enter text in its buffer.\n\n")
    (goto-char (point-max)))
  (lisp-interaction-mode))

;;;
;;  END CUSTOM FUNCTIONS
;;;

;; this doesnt seem to be needed anymore? maybe its because of the
;;  build of emacs im using? going to leave it in just in case
;(when-on-osx
;  (setenv "PATH" (concat (getenv "PATH") ":/usr/local/bin")))

;; when we have ros installed go and include the path in the exec-path list
(when (executable-find "ros")
  (let* ((homedir (car (last (split-string (shell-command-to-string "ros version")
                                           "\n" t))))
         (path (concat (substring homedir 11 (1- (length homedir)))
                       "bin")))
    (setq exec-path (append exec-path (list path)))))

;; run these options only when we're running in daemon mode
(when (daemonp)
  (setq doom-modeline-icon t)
  (global-set-key (kbd "C-x M-C-c") 'kill-emacs))

;; sets up my custom key bindings
(global-set-key (kbd "C-x M-f") 'horz-flip-buffers)

;; puts the line number in the left fringe
(when (version<= "26.0.50" emacs-version)
  (global-display-line-numbers-mode))

;; ensures that we NEVER have tabs in our code. ANYWHERE
(setq-default indent-tabs-mode nil)

;; disable the scroll bar
(scroll-bar-mode 0)

;; set the time format to 24hr and enable time display
(setq display-time-24hr-format t)
(display-time-mode)

;; bsd specific loading
(when-on-bsd
 (setq ispell-dictionary "en_US")
 (setq ispell-program-name "aspell")
 (setq ispell-aspell-dict-dir "/usr/local/share/aspell/")
 (setq ispell-aspell-data-dir "/usr/local/lib/aspell-0.60/")
 (setq ispell-dictionary-keyword "american")
 (setq battery-status-function #'battery-freebsd-apm))

;; linux specific loading
(when-on-linux
 (setq ispell-program-name "hunspell"))

;; *nix specific loading
(when-on-unix
 (display-battery-mode)
 (setq ispell-local-dictionary "en_US"))

;; mac specific loading
(when-on-osx
 ;; this disables special character input in emacs when using the option key
 (setq mac-option-modifier 'meta)
 
 (defun macos-theme ()
   "gets the current macOS window theme

returns either 'dark or 'light"
   (let ((theme (shell-command-to-string "defaults read -g AppleInterfaceStyle")))
     (if (string= theme "Dark
")
         'dark
       'light)))

 (defun match-theme-to-system ()
   "checks the system theme and changes the emacs theme to match"
   (unless (eq enable-dark-theme (eq (macos-theme) 'dark))
     (setq enable-dark-theme (eq (macos-theme) 'dark))
     (load-emacs-theme)
     (set-face-attribute 'default nil :height face-height)))

 (add-hook 'window-setup-hook
           (lambda ()
             ;; because the damn mac screen is good,
             ;;  we need to bump the font size up a lil lmao
             ;; note: needs to be in window-setup-hook otherwise
             ;;       it doesnt get run for the initial frame
             (set-face-attribute 'default nil :height face-height)
             (when auto-update-macos-theme
               (run-with-timer 0 1 'match-theme-to-system)))))

;; loading a theme
(add-hook 'window-setup-hook 'load-emacs-theme)

;; sets shortcut for c++ mode
(require 'cc-mode)
(define-key c++-mode-map (kbd "C-c i") 'init-cpp-file)

;; loading loadhist package (required for cl-sources function)
(require 'loadhist)

;;;
;; PACKAGE LOADING
;;;

;; adds the MELPA repo to my package archive list
(require 'package)
(package-initialize)
(add-to-list 'package-archives
	     '("melpa" . "http://melpa.org/packages/"))
(eval-when-compile
  (add-to-list 'load-path (stringify (file-name-directory
				      (file-truename "~/.emacs"))
				     "use-package"))
  (require 'use-package))

;; allow for local, git-ignored configurations
(let ((local-filename (stringify (file-name-directory (file-truename "~/.emacs"))
                                 "local.el")))
  (unless (file-exists-p local-filename)
    ;; if the local file doesn't exist we create it
    (with-temp-file local-filename))
  (load local-filename))

;; remove slime stuff
(when (package-installed-p 'slime-company)
  (package-delete (cadr (assoc 'slime-company package-alist))))
(when (package-installed-p 'slime)
  (package-delete (cadr (assoc 'slime package-alist)))
  
  ;; this is needed because slime-lisp-mode-hook gets like auto
  ;; added into lisp-mode-hook when emacs loads
  (setq lisp-mode-hook
	(remove 'slime-lisp-mode-hook lisp-mode-hook)))

;;;;
;; package loading and configuration
;;;;

;; show function docstrings in the minibuffer
(use-package marginalia
  :ensure t
  :bind (("M-A" . marginalia-cycle)
         :map minibuffer-local-map
         ("M-A" . marginalia-cycle))
  :init (marginalia-mode))

(use-package parinfer-rust-mode
  :ensure t
  :hook ((emacs-lisp-mode . parinfer-rust-mode)
         (lisp-mode . parinfer-rust-mode))
  :init
  (setq parinfer-rust-library
        (os-cond
         (windows-nt "~/.emacs.d/parinfer-rust/parinfer_rust.dll")
         (t "~/.emacs.d/parinfer-rust/libparinfer_rust.so")))
  (unless-on-windows
   (setq parinfer-rust-auto-download t)))

(use-package lua-mode
  :ensure t)

(use-package fennel-mode
  :ensure t)

(use-package popwin
  :ensure t
  :init (popwin-mode t))

(use-package posframe
  :ensure t
  :config
  (setq posframe-arghandler #'posframe-fallback))

(use-package frog-jump-buffer
  :ensure t
  :bind ("C-;" . frog-jump-buffer)
  :config
  (dolist (regexp '("TAGS" "^\\*Compile-log" "-debug\\*$" "^\\:" "errors\\*$" "^\\*Backtrace" "-ls\\*$"
                    "stderr\\*$" "^\\*Flymake" "^\\*vc" "^\\*Warnings" "^\\*eldoc" "\\^*Shell Command"))
    (push regexp frog-jump-buffer-ignore-buffers)))

(use-package eros
  :ensure t
  :init (eros-mode t))

(use-package css-eldoc
  :ensure t
  :hook ((css-mode . turn-on-css-eldoc)))

(use-package request
  :ensure t)

;; this doesnt seem to work on Max Big Sur or BSD
(unless-on-bsdish
 (use-package symon
   :ensure t
   :config
   (setq symon-delay 20)
   (symon-mode)))

(use-package markdown-mode
  :ensure t)

(use-package eshell
  :bind ("C-x M-e" . eshell))

(use-package info-look
  :ensure t)

(use-package minions
  :ensure t
  :config (minions-mode 1))

(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1)
  :config
  (setq doom-modeline-buffer-encoding nil
	doom-modeline-minor-modes t
	doom-modeline-gnus-timer nil
	doom-modeline-bar-width 3)
  (when-on-windows
   (setq inihibit-compacting-font-caches t)))

(use-package projectile
  :ensure t
  :init (projectile-mode +1)
  :bind (:map projectile-mode-map
	      ("C-c p" . projectile-command-map)))

(use-package treemacs
  :ensure t
  :bind ([f8] . treemacs))

(use-package treemacs-projectile
  :after treemacs projectile
  :ensure t)

(use-package treemacs-magit
  :after treemacs magit
  :ensure t)

(use-package company
  :ensure t
  :init (global-company-mode))

(use-package company-quickhelp
  :ensure t
  :hook (company-mode . company-quickhelp-mode))

(use-package company-box
  :ensure t
  :hook (company-mode . company-box-mode))

(use-package fish-mode
  :ensure t)

(use-package hydra
  :ensure t)

(use-package ivy
  :ensure t
  :init (ivy-mode 1)
  :bind (:map ivy-minibuffer-map
	      ("RET" . ivy-alt-done))
  :config
  (setq ivy-use-virtual-buffers 'recentf))

(use-package ivy-hydra
  :ensure t
  :after ivy hydra)

(use-package counsel
  :ensure t
  :init (counsel-mode 1))

(use-package counsel-projectile
  :ensure t
  :after counsel projectile
  :init (counsel-projectile-mode))

(use-package swiper
  :ensure t
  :bind
  ("C-s" . swiper)
  ("C-r" . swiper))

;; only install elcord when discord is installed
(when (executable-find "discord")
  (use-package elcord
    :ensure t
    :hook ((lisp-mode . elcord-mode))))

(use-package prism
  :ensure t
  :hook ((lisp-mode . prism-mode)
	 (common-lisp-mode . prism-mode)
	 (ruby-mode . prism-mode)
	 (emacs-lisp-mode . prism-mode)))
  
(use-package emr
  :ensure t
  :bind (("M-RET" . emr-show-refactor-menu)))

(use-package dimmer
  :ensure t
  :config
  (setq dimmer-fraction 0.4)
  (dimmer-mode 1))

(use-package rainbow-delimiters
  :ensure t
  :hook ((lisp-mode . rainbow-delimiters-mode)
	 (emacs-lisp-mode . rainbow-delimiters-mode)
	 (sly-mode . rainbow-delimiters-mode)))

(use-package ido-completing-read+
  :ensure t
  :init (ido-ubiquitous-mode 1))

(use-package amx
  :ensure t
  :init (amx-mode))

;; make sure we only use magit WHEN WE HAVE GIT
(when (executable-find "git")
  (use-package magit
    :ensure t
    :bind ("C-x a" . magit-status)))

;; (use-package go-autocomplete
;;   :disabled
;;   :init (ac-config-default))

;; (use-package go-complete
;;   :disabled)

;; (use-package go-mode
;;   :disabled
;;   :init
;;   (when-on-unix (setq shell-file-name (executable-find "fish")))
;;   (when (memq window-system '(mac ns x))
;;     (exec-path-from-shell-initialize)
;;     (exec-path-from-shell-copy-env "GOPATH"))
;;   (go-eldoc-setup))

(use-package org
  :mode "\\.notes?"
  :hook (org-mode . (lambda ()
		      (when (or (executable-find "ispell")
				(executable-find "aspell"))
			(flyspell-mode)))))

(use-package poly-erb
  :ensure t
  :mode "\\.erb")

(use-package lisp-mode
  :mode "\\.stumpwmrc$")

(use-package multiple-cursors
  :ensure t
  :bind (("C->" . mc/mark-next-like-this)
	 ("C-<" . mc/mark-previous-like-this)
	 ("C-c C-<" . mc/mark-all-like-this)))

(use-package win-switch
  :ensure t
  :bind (("C-x o" . win-switch-dispatch)
	 ("C-c o" . win-switch-dispatch-once)))

(use-package eldoc
  :config
  (add-hook 'emacs-lisp-mode #'eldoc-mode))

(use-package macrostep
  :ensure t
  :bind (:map emacs-lisp-mode-map
	      ("C-c e" . macrostep-expand)))

(use-package text-mode
  :config
  (add-hook 'text-mode-hook #'visual-line-mode))

(use-package sly-macrostep
  :after sly
  :ensure t)

(use-package sly-named-readtables
  :after sly
  :ensure t)

(use-package sly-quicklisp
  :after sly
  :ensure t)

(use-package sly-asdf
  :after sly
  :ensure t)

(use-package sly
  :ensure t
  :bind (("s-l" . sly)
	 :map lisp-mode-map
	 ("C-c e" . macrostep-expand))
  :hook ((lisp-mode . sly-editing-mode))
  :config
  (setq slime-contribs '(sly-fancy sly-macrostep sly-quicklisp
                                   sly-asdf sly-reply-ansi-color sly-named-readtables)
	inferior-lisp-program (os-cond
                               (darwin "/usr/local/bin/ros run -Q")
                               (t "ros run -Q"))))

(use-package elpy
  :disabled
  :hook python-mode
  :config
  (setq venv-location (stringify (getenv "HOME") "/programming/python/")))

(use-package emojify
  :ensure t
  :hook (after-init . global-emojify-mode)
  :config
  (setq emojify-display-style
        (os-cond
         (windows-nt 'image)
         (gnu/linux 'unicode)
         (darwin 'unicode)
         (t 'image))))
  
;;;
;; END PACKAGE LOADING
;;;

;;;
;; BEGIN THEME LOADING
;;;

;; dark theme 
(use-package challenger-deep-theme
  :ensure t
  :init
  (when enable-dark-theme (load-theme 'challenger-deep t)))

;; light theme
(use-package modus-themes
   :ensure t
   :init
   (setq modus-themes-slanted-constructs t
         modus-themes-bold-constructs nil
         modus-themes-region 'no-extend
         modus-themes-mode-line 'accented
         modus-themes-syntax 'alt-syntax
         modus-themes-paren-match 'intense)
   (unless enable-dark-theme (modus-themes-load-themes)))

;; (use-package nova-theme
;;   :ensure t
;;   :init
;;   (load-theme 'nova t))

 ;; (use-package color-theme-sanityinc-tomorrow
 ;;   :ensure t
 ;;   :init
 ;;   (color-theme-sanityinc-tomorrow-blue))

;; (use-package doom-themes
;;   :ensure t
;;   :config
;;   (setq doom-themes-enable-bold t
;; 	doom-themes-enable-italic t
;; 	doom-outrun-electric-brighter-modeline t
;; 	doom-outrun-electric-comment-bg t
;; 	doom-outrun-electric-brighter-comments t)
;;   (if enable-dark-theme
;;       (load-theme 'doom-outrun-electric t)
;;     (load-theme 'doom-acario-light t))
;;   (doom-themes-org-config))

;; (use-package subatomic-theme
;;   :ensure t
;;   :init
;;   (setq subatomic-more-visible-comment-delimiters t)
;;   (load-theme 'subatomic t))


;; kaolin themes has a better light theme than the doom theme-set
;;  (use-package kaolin-themes
;;    :ensure t
;;    :config
;;    (setq kaolin-themes-italic-comments t
;;	  kaolin-themes-distinct-fringe t)
;;    (load-theme 'kaolin-light t))

;;;
;; END THEME LOADING
;;;

;; check and recompile the init file
(cl-eval-when (load)
  (byte-compile-file (file-truename "~/.emacs")))

;; enable 'list-timers function
(put 'list-timers 'disabled nil)
