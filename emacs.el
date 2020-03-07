(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(backup-directory-alist (quote ((".*" concat (getenv "HOME") "/.emacs.d/backups"))))
 '(column-number-mode t)
 '(dired-use-ls-dired nil)
 '(fci-rule-character-color "#192028")
 '(inhibit-startup-screen t)
 '(make-backup-files nil)
 '(package-selected-packages
   (quote
    (sly-asdf sly-quicklisp sly-named-readtables sly-macrostep counsel-projectile ivy-hydra counsel swiper fish-mode markdown-mode treemacs-magit treemacs-projectile macrostep macrostep-expand elcord company magit sly win-switch multiple-cursors poly-erb amx ido-completing-read+ rainbow-delimiters dimmer emr doom-themes prism projectile treemacs doom-modeline minions)))
 '(save-place t nil (saveplace))
 '(show-paren-mode t)
 '(size-indication-mode t)
 '(tool-bar-mode nil)
 '(tool-bar-position (quote left)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :stipple nil :background "#14191f" :foreground "#dcdddd" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 113 :width normal :foundry "unknown" :family "Fira Mono")))))


;;;
;; BEGIN CUSTOM FUCTIONS
;;;

(defun horz-flip-buffers ()
  "Flips the open buffers between two windows"
  (interactive)
  (let ((c-buf (buffer-name))
	(o-buf (buffer-name (window-buffer (next-window)))))
    (switch-to-buffer o-buf nil t)
    (other-window 1)
    (switch-to-buffer c-buf)
    (other-window (- (length (window-list)) 1))))

(defun buffer-existp (buf-name)
  (setq buf-list (loop for i in (buffer-list) collect (buffer-name i)))
  (member buf-name buf-list))

(defun get-file-info ()
  (let* ((split (split-string buffer-file-name "\\/" t))
	 (path (remove (1- (length split)) split))
	 (ext (car (last (split-string (car (last split)) "\\.")))))
    `((path . ,path)
      (extension . ,ext))))

(defun init-cpp-file (includes)
  "Quickly and easily initializes a c++ file with main
INCLUDES is a space seperated list of headers to include"
  (interactive "Mincludes: ")
  (let ((path (concat "/" (string-join
			   (butlast
			    (cdr (assoc 'path (get-file-info)))) "/")
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

(defun mkstr (&rest args)
  "Make a string out of arbitrary list of objects"
  (with-output-to-string
    (dolist (a args) (princ a))))

(defun fox-me-up ()
  "FOX ME UP INSIDE"
  (interactive)
  (message 
"  _,-=._              /|_/|
  `-.}   `=._,.-=-._.,  @ @._,   <(reet)
     `._ _,-.   )      _,.-'
        `    G.m-\"^m`m'"))

;;;
;;  END CUSTOM FUCTIONS
;;;

;;;
;;  BEGIN CUSTOM MACROS
;;;

(defmacro when-on (os &rest type-names)
  "define a macro (named when-on-OS) to run code when SYSTEM-TYPE matches any symbol in TYPE-NAMES

OS is a symbol (or string) to be placed in the macro name
TYPE-NAMES is a list of symbols that correspond to values returned by system-type"
  `(defmacro ,(intern (mkstr "when-on-" os)) (&rest body)
     `(when (or ,@(mapcar (lambda (name) `(eq system-type ',name))
			  ',type-names))
	,@body)))

(when-on bsd berkeley-unix)
(when-on linux gnu/linux)
(when-on unix gnu/linux berkeley-unix)
(when-on windows windows-nt)

;;;
;;  END CUSTOM MACROS
;;;


;; adds the MELPA repo to my package archive list
(require 'package)
(package-initialize)
(add-to-list 'package-archives
	     '("melpa" . "http://melpa.org/packages/"))
(eval-when-compile
  (add-to-list 'load-path (mkstr (file-name-directory
				  (file-truename "~/.emacs"))
				 "use-package"))
  (require 'use-package))

;; remove slime stuff
(when (package-installed-p 'slime-company)
  (package-delete (cadr (assoc 'slime-company package-alist))))
(when (package-installed-p 'slime)
  (package-delete (cadr (assoc 'slime package-alist)))

  ;; this is needed because slime-lisp-mode-hook gets like auto
  ;; added into lisp-mode-hook when emacs loads
  (setq lisp-mode-hook
	(remove 'slime-lisp-mode-hook lisp-mode-hook)))

;; package loading and configuration
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

(use-package doom-themes
  :ensure t
  :config
  (setq doom-themes-enable-bold t
	doom-themes-enable-italic t
	doom-outrun-electric-brighter-modeline t
	doom-outrun-electric-comment-bg t
	doom-outrun-electric-brighter-comments t)
  (load-theme 'doom-outrun-electric t)
  (doom-themes-org-config))

(use-package emr
  :ensure t
  :bind (("M-RET" . emr-show-refactor-menu)))

;(use-package kaolin-themes
;  :ensure t
;  :config
;  (setq kaolin-themes-italic-comments t
;	kaolin-themes-distinct-fringe t)
;  (load-theme 'kaolin-galaxy t))

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

;(use-package ido
;  :ensure t
;  :init
;  (ido-mode)
;  (ido-everywhere))

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

(use-package go-autocomplete
  :disabled
  :init (ac-config-default))

(use-package go-complete
  :disabled)

(use-package go-mode
  :disabled
  :init
  (when-on-bsd (setq shell-file-name "/usr/local/bin/fish"))
  (when-on-linux (setq shell-file-name "/bin/fish"))
  (when (memq window-system '(mac ns x))
    (exec-path-from-shell-initialize)
    (exec-path-from-shell-copy-env "GOPATH"))
  (go-eldoc-setup))

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
  :bind ("C-x o" . win-switch-dispatch))

(use-package c++-mode
  :bind (:map c++-mode-map
	 ("C-c i" . init-cpp-file)))

(use-package eldoc-mode
  :hook emacs-lisp-mode)

(use-package macrostep
  :ensure t
  :bind (:map emacs-lisp-mode-map
	      ("C-c e" . macrostep-expand)))

(use-package visual-line-mode
  :hook text-mode)

(use-package sly
  :ensure t
  :bind (("s-l" . sly)
	 :map lisp-mode-map
	 ("C-c e" . macrostep-expand))
  :hook ((lisp-mode . sly-editing-mode))
  :config
  (setq slime-contribs '(sly-fancy sly-macrostep sly-quicklisp
			 sly-asdf sly-reply-ansi-color sly-named-readtables)
	inferior-lisp-program "ros run -Q"))

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

(use-package elpy
  :disabled
  :hook python-mode
  :config
  (setq venv-location (mkstr (getenv "HOME") "/programming/python/")))

;; run these options only when we're running in daemon mode
(when (daemonp)
  (setq doom-modeline-icon t)
  (global-set-key (kbd "C-x M-C-c") 'kill-emacs))

;; puts the line number in the left fringe
;(when (version<= "26.0.50" emacs-version)
;  (global-display-line-numbers-mode))

;; sets up my custom key bindings
(global-set-key (kbd "C-x M-f") 'horz-flip-buffers)

(setq display-time-24hr-format t)
(display-time-mode)

;; bsd specific loading
(when-on-bsd
 (setq ispell-dictionary "en_US")
 (setq ispell-program-name "aspell")
 (setq ispell-aspell-dict-dir "/usr/local/share/aspell/")
 (setq ispell-aspell-data-dir "/usr/local/lib/aspell-0.60/")
 (setq ispell-dictionary-keyword "american"))

;; linux specific loading
(when-on-linux
 (display-battery-mode)
 (setq ispell-program-name "hunspell"))

;; *nix specific loading
(when-on-unix
 (setq ispell-local-dictionary "en_US"))

 ;; (when (window-system)
 ;;   (set-default-font "Fira Code Light"))
 ;; (add-hook 'after-make-frame-functions (lambda (frame) (set-fontset-font t '(#Xe100 . #Xe16f) "Fira Code Symbol")))
 ;; ;; This works when using emacs without server/client
 ;; (set-fontset-font t '(#Xe100 . #Xe16f) "Fira Code Symbol")
 ;; ;; I haven't found one statement that makes both of the above situations work, so I use both for now
 
 ;; (defconst fira-code-font-lock-keywords-alist
 ;;   (mapcar (lambda (regex-char-pair)
 ;;             `(,(car regex-char-pair)
 ;;               (0 (prog1 ()
 ;;                    (compose-region (match-beginning 1)
 ;;                                    (match-end 1)
 ;;                                    ;; The first argument to concat is a string containing a literal tab
 ;;                                    ,(concat "	" (list (decode-char 'ucs (cadr regex-char-pair)))))))))
 ;;           '(("\\(www\\)"                   #Xe100)
 ;;             ("[^/]\\(\\*\\*\\)[^/]"        #Xe101)
 ;;             ("\\(\\*\\*\\*\\)"             #Xe102)
 ;;             ("\\(\\*\\*/\\)"               #Xe103)
 ;;             ("\\(\\*>\\)"                  #Xe104)
 ;;             ("[^*]\\(\\*/\\)"              #Xe105)
 ;;             ("\\(\\\\\\\\\\)"              #Xe106)
 ;;             ("\\(\\\\\\\\\\\\\\)"          #Xe107)
 ;;             ("\\({-\\)"                    #Xe108)
 ;;             ("\\(\\[\\]\\)"                #Xe109)
 ;;             ("\\(::\\)"                    #Xe10a)
 ;;             ("\\(:::\\)"                   #Xe10b)
 ;;             ("[^=]\\(:=\\)"                #Xe10c)
 ;;             ("\\(!!\\)"                    #Xe10d)
 ;;             ("\\(!=\\)"                    #Xe10e)
 ;;             ("\\(!==\\)"                   #Xe10f)
 ;;             ("\\(-}\\)"                    #Xe110)
 ;;             ("\\(--\\)"                    #Xe111)
 ;;             ("\\(---\\)"                   #Xe112)
 ;;             ("\\(-->\\)"                   #Xe113)
 ;;             ("[^-]\\(->\\)"                #Xe114)
 ;;             ("\\(->>\\)"                   #Xe115)
 ;;             ("\\(-<\\)"                    #Xe116)
 ;;             ("\\(-<<\\)"                   #Xe117)
 ;;             ("\\(-~\\)"                    #Xe118)
 ;;             ("\\(#{\\)"                    #Xe119)
 ;;             ("\\(#\\[\\)"                  #Xe11a)
 ;;             ("\\(##\\)"                    #Xe11b)
 ;;             ("\\(###\\)"                   #Xe11c)
 ;;             ("\\(####\\)"                  #Xe11d)
 ;;             ("\\(#(\\)"                    #Xe11e)
 ;;             ("\\(#\\?\\)"                  #Xe11f)
 ;;             ("\\(#_\\)"                    #Xe120)
 ;;             ("\\(#_(\\)"                   #Xe121)
 ;;             ("\\(\\.-\\)"                  #Xe122)
 ;;             ("\\(\\.=\\)"                  #Xe123)
 ;;             ("\\(\\.\\.\\)"                #Xe124)
 ;;             ("\\(\\.\\.<\\)"               #Xe125)
 ;;             ("\\(\\.\\.\\.\\)"             #Xe126)
 ;;             ("\\(\\?=\\)"                  #Xe127)
 ;;             ("\\(\\?\\?\\)"                #Xe128)
 ;;             ("\\(;;\\)"                    #Xe129)
 ;;             ("\\(/\\*\\)"                  #Xe12a)
 ;;             ("\\(/\\*\\*\\)"               #Xe12b)
 ;;             ("\\(/=\\)"                    #Xe12c)
 ;;             ("\\(/==\\)"                   #Xe12d)
 ;;             ("\\(/>\\)"                    #Xe12e)
 ;;             ("\\(//\\)"                    #Xe12f)
 ;;             ("\\(///\\)"                   #Xe130)
 ;;             ("\\(&&\\)"                    #Xe131)
 ;;             ("\\(||\\)"                    #Xe132)
 ;;             ("\\(||=\\)"                   #Xe133)
 ;;             ("[^|]\\(|=\\)"                #Xe134)
 ;;             ("\\(|>\\)"                    #Xe135)
 ;;             ("\\(\\^=\\)"                  #Xe136)
 ;;             ("\\(\\$>\\)"                  #Xe137)
 ;;             ("\\(\\+\\+\\)"                #Xe138)
 ;;             ("\\(\\+\\+\\+\\)"             #Xe139)
 ;;             ("\\(\\+>\\)"                  #Xe13a)
 ;;             ("\\(=:=\\)"                   #Xe13b)
 ;;             ("[^!/]\\(==\\)[^>]"           #Xe13c)
 ;;             ("\\(===\\)"                   #Xe13d)
 ;;             ("\\(==>\\)"                   #Xe13e)
 ;;             ("[^=]\\(=>\\)"                #Xe13f)
 ;;             ("\\(=>>\\)"                   #Xe140)
 ;;             ("\\(<=\\)"                    #Xe141)
 ;;             ("\\(=<<\\)"                   #Xe142)
 ;;             ("\\(=/=\\)"                   #Xe143)
 ;;             ("\\(>-\\)"                    #Xe144)
 ;;             ("\\(>=\\)"                    #Xe145)
 ;;             ("\\(>=>\\)"                   #Xe146)
 ;;             ("[^-=]\\(>>\\)"               #Xe147)
 ;;             ("\\(>>-\\)"                   #Xe148)
 ;;             ("\\(>>=\\)"                   #Xe149)
 ;;             ("\\(>>>\\)"                   #Xe14a)
 ;;             ("\\(<\\*\\)"                  #Xe14b)
 ;;             ("\\(<\\*>\\)"                 #Xe14c)
 ;;             ("\\(<|\\)"                    #Xe14d)
 ;;             ("\\(<|>\\)"                   #Xe14e)
 ;;             ("\\(<\\$\\)"                  #Xe14f)
 ;;             ("\\(<\\$>\\)"                 #Xe150)
 ;;             ("\\(<!--\\)"                  #Xe151)
 ;;             ("\\(<-\\)"                    #Xe152)
 ;;             ("\\(<--\\)"                   #Xe153)
 ;;             ("\\(<->\\)"                   #Xe154)
 ;;             ("\\(<\\+\\)"                  #Xe155)
 ;;             ("\\(<\\+>\\)"                 #Xe156)
 ;;             ("\\(<=\\)"                    #Xe157)
 ;;             ("\\(<==\\)"                   #Xe158)
 ;;             ("\\(<=>\\)"                   #Xe159)
 ;;             ("\\(<=<\\)"                   #Xe15a)
 ;;             ("\\(<>\\)"                    #Xe15b)
 ;;             ("[^-=]\\(<<\\)"               #Xe15c)
 ;;             ("\\(<<-\\)"                   #Xe15d)
 ;;             ("\\(<<=\\)"                   #Xe15e)
 ;;             ("\\(<<<\\)"                   #Xe15f)
 ;;             ("\\(<~\\)"                    #Xe160)
 ;;             ("\\(<~~\\)"                   #Xe161)
 ;;             ("\\(</\\)"                    #Xe162)
 ;;             ("\\(</>\\)"                   #Xe163)
 ;;             ("\\(~@\\)"                    #Xe164)
 ;;             ("\\(~-\\)"                    #Xe165)
 ;;             ("\\(~=\\)"                    #Xe166)
 ;;             ("\\(~>\\)"                    #Xe167)
 ;;             ("[^<]\\(~~\\)"                #Xe168)
 ;;             ("\\(~~>\\)"                   #Xe169)
 ;;             ("\\(%%\\)"                    #Xe16a)
 ;;             ;;("\\(x\\)"                     #Xe16b)
 ;;             ("[^:=]\\(:\\)[^:=]"           #Xe16c)
 ;;             ("[^\\+<>]\\(\\+\\)[^\\+<>]"   #Xe16d)
 ;;             ("[^\\*/<>]\\(\\*\\)[^\\*/<>]" #Xe16f))))
 
 ;; (defun add-fira-code-symbol-keywords ()
 ;;   (font-lock-add-keywords nil fira-code-font-lock-keywords-alist))
 
 ;; (add-hook 'prog-mode-hook
 ;;           #'add-fira-code-symbol-keywords))

;; check and recompile the init file
(eval-when (load)
  (byte-recompile-file (file-truename "~/.emacs")))
