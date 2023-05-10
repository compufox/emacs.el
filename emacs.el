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
 '(global-emojify-mode t)
 '(inhibit-startup-screen t)
 '(make-backup-files nil)
 '(package-selected-packages
   '(org-roam-ui org-roam solo-jazz-theme twilight-bright-theme twilight-bright marginalia lua-mode fennel-mode modus-themes swift-mode company-quickhelp company-box nova-theme color-theme-sanityinc-tomorrow subatomic-theme parinfer-rust-mode emojify frog-jump-buffer workgroups2 popwin request css-eldoc eros symon sly-asdf sly-quicklisp sly-named-readtables sly-macrostep counsel-projectile ivy-hydra counsel swiper fish-mode markdown-mode treemacs-magit treemacs-projectile macrostep macrostep-expand elcord company magit sly win-switch multiple-cursors poly-erb amx ido-completing-read+ rainbow-delimiters dimmer emr doom-themes prism projectile treemacs doom-modeline minions))
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

;; cache the path to our configuration root
(eval-and-compile
  (defvar *config-root* (file-name-directory (file-truename "~/.emacs"))))

;; allow for local, git-ignored configurations
(defvar local-file (concat *config-root* "local.el"))

;; theme selection
(defvar *light-mode-theme* 'solo-jazz)
(defvar *dark-mode-theme* 'challenger-deep)

(defvar enable-dark-theme t)
(defvar face-height 120)
(defvar auto-update-macos-theme t)

;;;
;; END CUSTOM VARIABLES
;;;

;;;
;;  BEGIN CUSTOM MACROS
;;;

(defun get-system-arch ()
  "gets the system architecture based off of the results of uname -a"
  (car (last (split-string (shell-command-to-string "uname -a") nil t))))

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
    ,@(cl-loop for f in forms
               if (eq (car f) t)
                 collect `(t ,@(cdr f))
               else
                 collect `((eq system-type ',(car f))
                           ,@(cdr f)))))

(when-on macos darwin)
(when-on bsd berkeley-unix)
(when-on linux gnu/linux)
(when-on unix gnu/linux berkeley-unix)
(when-on windows windows-nt)
(unless-on macos darwin)
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
                              (if (memq (get-char-code-property letter 'general-category)
                                        '(Ll Lu))
                                  (format ":%s_%c:" prefix letter)
                                (format "%c" letter)))
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

(defun ensure-list (lst)
  "ensures that LST is a list"
  (cl-typecase lst
    (list lst)
    (t (list lst))))

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
  (cl-flet ((load-themes (x)
              (load-theme x t)))
    (mapc #'disable-theme custom-enabled-themes)
    (if enable-dark-theme
        (mapc #'load-themes (ensure-list *dark-mode-theme*))
      (mapc #'load-themes (ensure-list *light-mode-theme*)))))

(defun blankp (string)
  "returns t if STRING is an empty string"
  (string= string ""))

(defun make-buffer (name)
  "creates and switches to a new buffer with name NAME"
  (interactive "Bname: ")
  (let ((buff (generate-new-buffer name)))
    (switch-to-buffer buff)
    (text-mode)))

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
;(when-on-macos
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
(when-on-macos
 ;; this disables special character input in emacs when using the option key
 ;; and ensures that the command key sends meta keypresses
 (setq mac-option-modifier 'meta
       mac-command-modifier 'meta

       ;; turns off dark mode as default
       enable-dark-theme nil)

 ;; if we're using a version of emacs with a certain patch
 ;; we dont need to do all the homegrown stuff, and can just
 ;; hook into ns-system-appearance-change-functions
 (if (boundp 'ns-system-appearance)
     (add-hook 'ns-system-appearance-change-functions
               (lambda (style)
                 (mapc #'disable-theme custom-enabled-themes)
                 (if (eq style 'light)
                     (load-theme *light-mode-theme* t)
                   (load-theme *dark-mode-theme* t))))
   (progn
     (defvar *current-theme* nil)

     ;; define a function that runs a custom applescript script that
     ;; checks our theme and returns 'dark or 'light
     (defun macos-theme ()
       "gets the current macOS window theme

returns either 'dark or 'light"
       (let ((theme (shell-command-to-string (concat "osascript " *config-root* "CheckSystemTheme.scpt"))))
         (if (string= theme (concat "true" (char-to-string ?\n)))
             'dark
           'light)))

     ;; defines a function that checks the system theme
     ;; and changes our emacs theme to match it
     (defun match-theme-to-system ()
       "checks the system theme and changes the emacs theme to match"
       (unless (equal *current-theme* (macos-theme))
         (setq *current-theme* (macos-theme))
         (setq enable-dark-theme (eq *current-theme* 'dark))
         (load-emacs-theme)
         (set-face-attribute 'default nil :height face-height)))

     ;; sets up a hook that will run every 5 seconds to
     ;; match the themes
     (add-hook 'window-setup-hook
               (lambda ()
                 ;; because the damn mac screen is good,
                 ;;  we need to bump the font size up a lil lmao
                 ;; note: needs to be in window-setup-hook otherwise
                 ;;       it doesnt get run for the initial frame
                 (set-face-attribute 'default nil :height face-height)
                 (when auto-update-macos-theme
                   (run-with-timer 0 5 'match-theme-to-system)))))))

;; loading a theme
(unless-on-macos
 (add-hook 'window-setup-hook 'load-emacs-theme))

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

;; ...and then use that to download use-package 
(straight-use-package 'use-package)

;; commented out the following lines since
;; its been years since my migration to SLY over SLIME
;;; remove slime stuff
;(when (package-installed-p 'slime-company)
;  (package-delete (cadr (assoc 'slime-company package-alist))))
;(when (package-installed-p 'slime)
;  (package-delete (cadr (assoc 'slime package-alist)))
;  
;  ;; this is needed because slime-lisp-mode-hook gets like auto
;  ;; added into lisp-mode-hook when emacs loads
;  (setq lisp-mode-hook
;	(remove 'slime-lisp-mode-hook lisp-mode-hook)))

;;;;
;; package loading and configuration
;;;;

(use-package swift-mode
  :ensure t)

(use-package org-roam
  :ensure t
  :init (setq org-roam-v2-ack t)
  :bind (("C-c n l" . org-roam-buffer-toggle)
         ("C-c n f" . org-roam-node-find)
         ("C-c n i" . org-roam-node-insert)
         ("C-c n c" . org-roam-capture))
  :custom
  (org-roam-directory
   (os-cond
     (windows-nt (concat (getenv "USERPROFILE") "\\Syncthing\\Notes"))
     (t "~/Syncthing/Notes")))
  :config
  (when-on-windows
    (unless (version<= "29.0.0" emacs-version)
      (message "SQLite support is built into Emacs v29+ and is recommended for org-roam...")
      (sleep-for 2.5)))
  
  (org-roam-setup))

(use-package org-roam-ui
  :straight
    (:host github :repo "org-roam/org-roam-ui" :branch "main" :files ("*.el" "out"))
  :after org-roam
  :custom
  ((org-roam-ui-sync-theme t)
   (org-roam-ui-follow t)   
   (org-roam-ui-update-on-save t)
   (org-roam-ui-open-on-start t)))

;; show function docstrings in the minibuffer
(use-package marginalia
  :ensure t
  :bind (("M-A" . marginalia-cycle)
         :map minibuffer-local-map
         ("M-A" . marginalia-cycle))
  :init (marginalia-mode))

(use-package parinfer-rust-mode
  :ensure t
  :unless (string= "arm64" (get-system-arch))
  :hook
  (lisp-mode . parinfer-rust-mode)
    
  :custom
  (parinfer-rust-library
   (os-cond
    (windows-nt "~/.emacs.d/parinfer-rust/parinfer_rust.dll")
    (t "~/.emacs.d/parinfer-rust/libparinfer_rust.so")))
    
  :init
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
  :custom
  (posframe-arghandler #'posframe-fallback))

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
  :custom
  ((doom-modeline-buffer-encoding nil)
   (doom-modeline-minor-modes t)
   (doom-modeline-gnus-timer nil)
   (doom-modeline-bar-width 3)
   (doom-modeline-icon (unless (daemonp) t))
   (inhibit-compacting-font-caches (when-on-windows t))))

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
  :custom
  (ivy-use-virtual-buffers 'recentf))

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
(use-package elcord
  :ensure t
  :when (executable-find "discord")
  :hook ((lisp-mode . elcord-mode)))

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
  :custom
  (dimmer-fraction 0.4)
  
  :config
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

;; make sure we only use magit WHEN WE HAVE GIT :facepalm:
(use-package magit
  :ensure t
  :when (executable-find "git")
  :bind ("C-x a" . magit-status))

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
  :mode ("\\.notes?$" . org-mode)
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
  :ensure t
  :hook (emacs-lisp-mode . eldoc-mode))

(use-package macrostep
  :ensure t
  :bind (:map emacs-lisp-mode-map
	 ("C-c e" . macrostep-expand)))

(use-package text-mode
  :hook ((text-mode . visual-line-mode)
         (text-mode . turn-on-orgtbl)))

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
  
  :custom
  ((slime-contribs '(sly-fancy sly-macrostep sly-quicklisp sly-asdf
                     sly-reply-ansi-color sly-named-readtables))
   (inferior-lisp-program "ros run -Q")))

(use-package elpy
  :disabled
  :hook python-mode
  :custom
  (venv-location (stringify (getenv "HOME") "/programming/python/")))

(use-package emojify
  :ensure t
  :hook (after-init . global-emojify-mode)
  :custom
  (emojify-display-style
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
  :ensure t)

;; light theme
(use-package twilight-bright-theme
   :ensure t)

(use-package solo-jazz-theme
   :ensure t)

;;;
;; END THEME LOADING
;;;

(unless (file-exists-p local-file)
  ;; if the local file doesn't exist we create it
  (with-temp-file local-file))
(load local-file)

;; check and recompile the init file
(cl-eval-when (load)
  (byte-compile-file (file-truename "~/.emacs")))

;; enable 'list-timers function
(put 'list-timers 'disabled nil)
