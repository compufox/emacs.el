(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(backup-directory-alist (quote ((".*" . "/home/ztepps/.emacs.d/backups"))))
 '(column-number-mode t)
 '(custom-safe-themes
   (quote
    ("72085337718a3a9b4a7d8857079aa1144ea42d07a4a7696f86627e46ac52f50b" "98cc377af705c0f2133bb6d340bf0becd08944a588804ee655809da5d8140de6" "5e2dc1360a92bb73dafa11c46ba0f30fa5f49df887a8ede4e3533c3ab6270e08" "95db78d85e3c0e735da28af774dfa59308db832f84b8a2287586f5b4f21a7a5b" default)))
 '(custom-theme-load-path
   (quote
    ("/home/ztepps/.emacs.d/elpa/twilight-anti-bright-theme-20160622.148/" custom-theme-directory t)) t)
 '(fci-rule-character-color "#192028")
 '(inferior-lisp-program "sbcl" t)
 '(inhibit-startup-screen t)
 '(make-backup-files nil)
 '(package-selected-packages
   (quote
    (captain crystal-mode crystal-playground poly-erb poly-markdown win-switch virtualenvwrapper vala-mode use-package twilight-anti-bright-theme swiper spinner slime-company shut-up robe request rainbow-delimiters queue paredit origami org oauth2 names multiple-cursors multi-term markdown-mode magit lua-mode js2-mode jedi irony-eldoc go-stacktracer go-scratch go-gopath go-eldoc go-dlv go-complete go-autocomplete foggy-night-theme flymake-python-pyflakes flymake-go flycheck-irony fish-mode faceup f exec-path-from-shell enh-ruby-mode emojify elpy dash-functional csharp-mode contextual company-irony company-go cmake-mode cmake-ide cl-generic)))
 '(save-place t nil (saveplace))
 '(show-paren-mode t)
 '(slime-contribs (quote (slime-fancy slime-banner slime-autodoc)) t)
 '(tool-bar-mode nil)
 '(tool-bar-position (quote left))
 '(venv-location "/home/zac/programming/python/" t)
 '(yas-prompt-functions
   (quote
    (yas-ido-prompt yas-completing-prompt yas-maybe-ido-prompt yas-no-prompt))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :stipple nil :background "#14191f" :foreground "#dcdddd" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 113 :width normal :foundry "unknown" :family "Fira Mono")))))


;;;
;; BEGIN CUSTOM FUCTIONS
;;;

(defun send-shell-commands (commands-to-send &optional shell-buf)
  "Sends commands to the *shell* buffer
   
   COMMANDS-TO-SEND is a list of strings that are commands to be sent"
  (unless shell-buf
    (setq shell-buf "*shell*"))
  (set-buffer shell-buf)
  (loop for i in commands-to-send
	do
	(progn
	  (insert i)
	  (comint-send-input))))

(defun horz-flip-buffers ()
  "Flips the open buffers between two windows"
  (interactive)
  (let ((c-buf (buffer-name))
	(o-buf (buffer-name (window-buffer (next-window)))))
    (switch-to-buffer o-buf nil t)
    (other-window 1)
    (switch-to-buffer c-buf)
    (other-window (- (length (window-list)) 1))))

(defun git-push ()
  "Pushes code changes automatically so I don't have to type everything
I'm lazy
#TeamZac"
  (interactive)
  (when (buffer-existp "*frc*")
    (send-shell-commands `(,(concat "git commit -a -m \""
				   (read-string "git commit message: ")
				   "\"")
			   "git push")
			 "*frc*")))

(defun buffer-existp (buf-name)
  (setq buf-list (loop for i in (buffer-list) collect (buffer-name i)))
  (in-list buf-list buf-name))

(defun in-list (containing-list obj)
  "Checks to see if OBJ is in CONTAININNG-LIST

   Returns T if it OBJ is there, otherwise returns NIL"
  (loop for i in containing-list do (when (equal i obj) (return t))))

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

;;;
;;  END CUSTOM FUCTIONS
;;;

;;;
;;  BEGIN CUSTOM MACROS
;;;

(defun when-on (os type-names)
  "define a macro (named when-on-OS) to run code when SYSTEM-TYPE matches any string in TYPE-NAMES

OS is a symbol (or string) to be placed in the macro name
TYPE-NAMES is either a single string or a list of strings which represent the system-type string"
  (eval
   `(defmacro ,(intern (mkstr "when-on-" os)) (&rest body)
      (let ((sys-name ,(if (listp type-names)
			   `(quote ,type-names)
			 type-names)))
	`(when ,(if (listp sys-name)
		    `(or ,@(cl-loop for name in sys-name
			    collect `(string-equal system-type ,name)))
		  `(string-equal system-type ,sys-name))
	   ,@body)))))

(when-on 'bsd "berkeley-unix")
(when-on 'linux "gnu/linux")
(when-on 'linux-or-bsd '("gnu/linux" "berkeley-unix"))

;;;
;;  END CUSTOM MACROS
;;;


;; adds the MELPA repo to my package archive list
(require 'package)
(package-initialize)
(add-to-list 'package-archives
	     '("melpa" . "http://melpa.org/packages/"))


(require 'use-package)

;; glorious package loading
(require 'info-look)
(require 'irony)
(require 'company-irony)

(use-package yasnippet
  :bind ("C-c s" . yas-insert-snippet))

(use-package magit
  :bind ("C-x a" . magit-status))

(use-package ido
  :init
  (ido-mode)
  (ido-everywhere))

(use-package go-autocomplete
  :init (ac-config-default))

(use-package go-complete)

(use-package go-mode
  :hook (go-mode . flyspell-mode)
  :init
  (when-on-bsd (setq shell-file-name "/usr/local/bin/fish"))
  (when-on-linux (setq shell-file-name "/bin/fish"))
  (when (memq window-system '(mac ns x))
    (exec-path-from-shell-initialize)
    (exec-path-from-shell-copy-env "GOPATH"))
  (go-eldoc-setup))

(use-package origami-mode
  :hook prog-mode
  :bind (([C-tab] . origami-toggle-node)
	 ([C-s-tab] . origami-toggle-all-nodes)))

(use-package org
  :mode "\\.notes?"
  :hook (org-mode . flyspell-mode))

(use-package poly-erb
  :mode "\\.erb")

(use-package lisp
  :mode "\\.stumpwmrc$")

(use-package crystal-mode)

(use-package multiple-cursors-mode
  :bind (("C->" . mc/mark-next-like-this)
	 ("C-<" . mc/mark-previous-like-this)
	 ("C-c C-<" . mc/mark-all-like-this)))

(use-package multi-term
  :disabled
  :init
  (setq multi-term-program "/usr/bin/fish"))

(use-package win-switch
  :bind ("C-x o" . win-switch-dispatch))

(use-package slime
  :bind ("s-l" . slime)
  :custom
  (slime-contribs '(slime-fancy slime-banner slime-autodoc))
  (inferior-lisp-program "sbcl"))
(global-set-key (kbd "C-s-l") (lambda ()
				(interactive)
				(slime-connect "127.0.0.1" 4004)))

(use-package elpy
  :hook python-mode
  :custom
  (venv-location (mkstr (getenv "HOME") "/programming/python/")))

(use-package irony
  :hook c++-mode
  :init
  (add-hook 'irony-mode 'irony-cdb-autosetup-compile-options)
  (add-hook 'irony-mode 'irony-eldoc)
  (setq-default irony-cdb-compilation-databases '(irony-cdb-libclang irony-cdb-clang-complete)))

(use-package company-irony
  :init (add-to-list 'company-backends 'company-irony))

(use-package flycheck-mode
  :hook c++-mode
  :init
  (add-hook 'flycheck-mode-hook 'flycheck-irony-setup))

(use-package captain
  :init
  (global-captain-mode)
  (setq captain-predicate
	(lambda ()
	  (nth 8 (syntax-ppss (point)))))
  (add-hook 'text-mode-hook
	    (lambda ()
	      (setq captain-predicate
		    (lambda () t))))
  (add-hook 'org-mode-hook
	    (lambda ()
	      (setq captain-predicate
		    (lambda () t)))))

;; setting stuff up for c++ dev
(add-hook 'c++-mode-hook (lambda ()
			  (local-set-key (kbd "C-c i") 'init-cpp-file)))


;; sets up my custom key bindings
(global-set-key (kbd "C-x M-f") 'horz-flip-buffers)

;; adds the visual line wrapping mode into text mode
(add-hook 'text-mode-hook 'visual-line-mode)
(add-hook 'emacs-lisp-mode-hook 'eldoc-mode)
(add-hook 'python-mode-hook 'flyspell-prog-mode)

;; if we're running under X load a theme
(when window-system
  (load-theme 'twilight-anti-bright))

(add-hook 'term-mode-hook (lambda ()
			    (define-key term-raw-map (kbd "C-j") 'term-line-mode)
			    (define-key term-mode-map (kbd "C-M-j") 'term-char-mode)))

(when-on-bsd
 (setq ispell-dictionary "en_US")
 (setq ispell-program-name "aspell")
 (setq ispell-aspell-dict-dir "/usr/local/share/aspell/")
 (setq ispell-aspell-data-dir "/usr/local/lib/aspell-0.60/")
 (setq ispell-dictionary-keyword "american"))

(when-on-linux-or-bsd
 (display-time-mode)
 (setq ispell-local-dictionary "en_US"))

;;; Fira code font and ligatures
(when-on-linux
 (display-battery-mode)
 (setq ispell-program-name "hunspell")
 (when (window-system)
   (set-default-font "Fira Code Light"))
 (add-hook 'after-make-frame-functions (lambda (frame) (set-fontset-font t '(#Xe100 . #Xe16f) "Fira Code Symbol")))
 ;; This works when using emacs without server/client
 (set-fontset-font t '(#Xe100 . #Xe16f) "Fira Code Symbol")
 ;; I haven't found one statement that makes both of the above situations work, so I use both for now
 
 (defconst fira-code-font-lock-keywords-alist
   (mapcar (lambda (regex-char-pair)
             `(,(car regex-char-pair)
               (0 (prog1 ()
                    (compose-region (match-beginning 1)
                                    (match-end 1)
                                    ;; The first argument to concat is a string containing a literal tab
                                    ,(concat "	" (list (decode-char 'ucs (cadr regex-char-pair)))))))))
           '(("\\(www\\)"                   #Xe100)
             ("[^/]\\(\\*\\*\\)[^/]"        #Xe101)
             ("\\(\\*\\*\\*\\)"             #Xe102)
             ("\\(\\*\\*/\\)"               #Xe103)
             ("\\(\\*>\\)"                  #Xe104)
             ("[^*]\\(\\*/\\)"              #Xe105)
             ("\\(\\\\\\\\\\)"              #Xe106)
             ("\\(\\\\\\\\\\\\\\)"          #Xe107)
             ("\\({-\\)"                    #Xe108)
             ("\\(\\[\\]\\)"                #Xe109)
             ("\\(::\\)"                    #Xe10a)
             ("\\(:::\\)"                   #Xe10b)
             ("[^=]\\(:=\\)"                #Xe10c)
             ("\\(!!\\)"                    #Xe10d)
             ("\\(!=\\)"                    #Xe10e)
             ("\\(!==\\)"                   #Xe10f)
             ("\\(-}\\)"                    #Xe110)
             ("\\(--\\)"                    #Xe111)
             ("\\(---\\)"                   #Xe112)
             ("\\(-->\\)"                   #Xe113)
             ("[^-]\\(->\\)"                #Xe114)
             ("\\(->>\\)"                   #Xe115)
             ("\\(-<\\)"                    #Xe116)
             ("\\(-<<\\)"                   #Xe117)
             ("\\(-~\\)"                    #Xe118)
             ("\\(#{\\)"                    #Xe119)
             ("\\(#\\[\\)"                  #Xe11a)
             ("\\(##\\)"                    #Xe11b)
             ("\\(###\\)"                   #Xe11c)
             ("\\(####\\)"                  #Xe11d)
             ("\\(#(\\)"                    #Xe11e)
             ("\\(#\\?\\)"                  #Xe11f)
             ("\\(#_\\)"                    #Xe120)
             ("\\(#_(\\)"                   #Xe121)
             ("\\(\\.-\\)"                  #Xe122)
             ("\\(\\.=\\)"                  #Xe123)
             ("\\(\\.\\.\\)"                #Xe124)
             ("\\(\\.\\.<\\)"               #Xe125)
             ("\\(\\.\\.\\.\\)"             #Xe126)
             ("\\(\\?=\\)"                  #Xe127)
             ("\\(\\?\\?\\)"                #Xe128)
             ("\\(;;\\)"                    #Xe129)
             ("\\(/\\*\\)"                  #Xe12a)
             ("\\(/\\*\\*\\)"               #Xe12b)
             ("\\(/=\\)"                    #Xe12c)
             ("\\(/==\\)"                   #Xe12d)
             ("\\(/>\\)"                    #Xe12e)
             ("\\(//\\)"                    #Xe12f)
             ("\\(///\\)"                   #Xe130)
             ("\\(&&\\)"                    #Xe131)
             ("\\(||\\)"                    #Xe132)
             ("\\(||=\\)"                   #Xe133)
             ("[^|]\\(|=\\)"                #Xe134)
             ("\\(|>\\)"                    #Xe135)
             ("\\(\\^=\\)"                  #Xe136)
             ("\\(\\$>\\)"                  #Xe137)
             ("\\(\\+\\+\\)"                #Xe138)
             ("\\(\\+\\+\\+\\)"             #Xe139)
             ("\\(\\+>\\)"                  #Xe13a)
             ("\\(=:=\\)"                   #Xe13b)
             ("[^!/]\\(==\\)[^>]"           #Xe13c)
             ("\\(===\\)"                   #Xe13d)
             ("\\(==>\\)"                   #Xe13e)
             ("[^=]\\(=>\\)"                #Xe13f)
             ("\\(=>>\\)"                   #Xe140)
             ("\\(<=\\)"                    #Xe141)
             ("\\(=<<\\)"                   #Xe142)
             ("\\(=/=\\)"                   #Xe143)
             ("\\(>-\\)"                    #Xe144)
             ("\\(>=\\)"                    #Xe145)
             ("\\(>=>\\)"                   #Xe146)
             ("[^-=]\\(>>\\)"               #Xe147)
             ("\\(>>-\\)"                   #Xe148)
             ("\\(>>=\\)"                   #Xe149)
             ("\\(>>>\\)"                   #Xe14a)
             ("\\(<\\*\\)"                  #Xe14b)
             ("\\(<\\*>\\)"                 #Xe14c)
             ("\\(<|\\)"                    #Xe14d)
             ("\\(<|>\\)"                   #Xe14e)
             ("\\(<\\$\\)"                  #Xe14f)
             ("\\(<\\$>\\)"                 #Xe150)
             ("\\(<!--\\)"                  #Xe151)
             ("\\(<-\\)"                    #Xe152)
             ("\\(<--\\)"                   #Xe153)
             ("\\(<->\\)"                   #Xe154)
             ("\\(<\\+\\)"                  #Xe155)
             ("\\(<\\+>\\)"                 #Xe156)
             ("\\(<=\\)"                    #Xe157)
             ("\\(<==\\)"                   #Xe158)
             ("\\(<=>\\)"                   #Xe159)
             ("\\(<=<\\)"                   #Xe15a)
             ("\\(<>\\)"                    #Xe15b)
             ("[^-=]\\(<<\\)"               #Xe15c)
             ("\\(<<-\\)"                   #Xe15d)
             ("\\(<<=\\)"                   #Xe15e)
             ("\\(<<<\\)"                   #Xe15f)
             ("\\(<~\\)"                    #Xe160)
             ("\\(<~~\\)"                   #Xe161)
             ("\\(</\\)"                    #Xe162)
             ("\\(</>\\)"                   #Xe163)
             ("\\(~@\\)"                    #Xe164)
             ("\\(~-\\)"                    #Xe165)
             ("\\(~=\\)"                    #Xe166)
             ("\\(~>\\)"                    #Xe167)
             ("[^<]\\(~~\\)"                #Xe168)
             ("\\(~~>\\)"                   #Xe169)
             ("\\(%%\\)"                    #Xe16a)
             ;;("\\(x\\)"                     #Xe16b)
             ("[^:=]\\(:\\)[^:=]"           #Xe16c)
             ("[^\\+<>]\\(\\+\\)[^\\+<>]"   #Xe16d)
             ("[^\\*/<>]\\(\\*\\)[^\\*/<>]" #Xe16f))))
 
 (defun add-fira-code-symbol-keywords ()
   (font-lock-add-keywords nil fira-code-font-lock-keywords-alist))
 
 (add-hook 'prog-mode-hook
           #'add-fira-code-symbol-keywords))

;; check and recompile the init file and also the emacs.d dir
(byte-recompile-file (concat (getenv "HOME") "/.emacs"))
(byte-recompile-directory (concat (getenv "HOME") "/.emacs.d/"))
