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
 '(inhibit-startup-screen t)
 '(make-backup-files nil)
 '(package-selected-packages
   (quote
    (csharp-mode fish-mode exec-path-from-shell js2-mode vala-mode cmake-ide cmake-mode company-irony flycheck-irony irony irony-eldoc enh-ruby-mode emojify robe win-switch virtualenvwrapper twilight-anti-bright-theme swiper slime-company slime request rainbow-delimiters paredit origami org oauth2 multiple-cursors multi-term markdown-mode magit jedi go-stacktracer go-scratch go-gopath go-eldoc go-dlv go-complete go-autocomplete foggy-night-theme flymake-python-pyflakes flymake-go elpy contextual company-go)))
 '(save-place t nil (saveplace))
 '(show-paren-mode t)
 '(tool-bar-mode nil)
 '(tool-bar-position (quote left))
 '(yas-prompt-functions
   (quote
    (yas-ido-prompt yas-completing-prompt yas-maybe-ido-prompt yas-no-prompt))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :stipple nil :background "#14191f" :foreground "#dcdddd" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 113 :width normal :foundry "unknown" :family "Fira Mono")))))

;; adds the MELPA repo to my package archive list
(require 'package)
(package-initialize)
(add-to-list 'package-archives
	     '("melpa" . "http://melpa.org/packages/"))

;; glorious package loading
(require 'lua-mode)
(require 'elpy)
(require 'info-look)
(require 'ido)
(require 'erc)
(require 'go-mode)
(require 'rainbow-delimiters)
(require 'origami)
(require 'yasnippet)
(require 'go-autocomplete)
(require 'go-complete)
(require 'multiple-cursors)
(require 'robe)
(require 'emojify)
(require 'irony)
(require 'company-irony)
(require 'vala-mode)
(require 'magit)

;; settings for yasnippet
(global-set-key (kbd "C-c s") 'yas-insert-snippet)

;; setting up autocomplete
(ac-config-default)

;; copy my envvars
(when (memq window-system '(mac ns x))
  (exec-path-from-shell-initialize)
  (exec-path-from-shell-copy-env "GOPATH"))

;; sets ruby-mode equal to enh-ruby-mode
(add-to-list 'auto-mode-alist
	     '("\\.notes?" . org-mode))
(add-to-list 'auto-mode-alist
	     '("\\.stumpwmrc$" . lisp-mode))

;; load rainbow-delim and paredit for programming
(add-hook 'prog-mode-hook (lambda ()
			    (rainbow-delimiters-mode)
			    (origami-mode)))

;; load spell checking for org mode
(add-hook 'org-mode-hook (lambda ()
		      (flyspell-mode)))

;; set up multi-cursor mode vars
(global-set-key (kbd "C->") 'mc/mark-next-like-this)
(global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
(global-set-key (kbd "C-c C-<") 'mc/mark-all-like-this)

;; basic erc config
(setq erc-kill-buffer-on-part t)
(setq erc-kill-server-buffer-on-quit t)
(setq erc-kill-queries-on-part t)
(setq erc-autojoin-channels-list '(("freenode.net" "#archlinux-offtopic")))

;; setting up go-mode
(add-hook 'go-mode-hook (lambda ()
			  (go-eldoc-setup)
			  (yas-minor-mode)
			  (flycheck-mode)))

;; setting stuff up for c++ dev
(setq-default irony-cdb-compilation-databases '(irony-cdb-libclang irony-cdb-clang-complete))
(add-hook 'irony-mode-hook 'irony-cdb-autosetup-compile-options)
(add-to-list 'company-backends 'company-irony)
(add-hook 'irony-mode-hook 'irony-eldoc)
(add-hook 'flycheck-mode-hook 'flycheck-irony-setup)

(add-hook 'c++-mode-hook (lambda ()
			  (local-set-key (kbd "C-c i") 'init-cpp-file)
			  (irony-mode)
			  (flycheck-mode)
			  (company-mode)))

;; emacs config stuff
(display-time-mode)
(display-battery-mode)

;; setup ido mode
(ido-mode)
(ido-everywhere)

;; setup and initialize SLIME
(setq inferior-lisp-program "sbcl")
(setq slime-contribs '(slime-fancy slime-banner slime-autodoc))
(require 'slime)

;; sets up stuff for flyspell
(setq ispell-program-name "hunspell")
(setq ispell-local-dictionary "en_US")

;;;
;; BEGIN CUSTOM FUCTIONS
;;;

(defvar *class-home* (concat (getenv "HOME") "/Documents/Fall" (format-time-string "%Y")))

(defun create-notes-org-file (class)
  "creates an empty notes file for the class thats specified by CLASS"
  (interactive "Mwhat class: ")
  (setq cur-file (concat *class-home* "/" class "/notes_" (format-time-string "%m%d%y") ".org"))
  (write-region "" nil cur-file)
  (find-file cur-file))

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

(defun deploy-code ()
  "Deploys code to the robot automatically from a shell inside Emacs

   Starts a shell if there isn't already one open"
  (interactive)
  (unless (buffer-existp "*frc*")
    (create-shell "*frc*")
    (setq file-names (split-string (buffer-file-name (get-buffer "robot.py")) "/" t))
    (send-shell-commands `(,(format "cd /home/ztepps/Documents/python/%s"
				    (nth 4 file-names))
					; ^ dynamically builds the file path
			   "source bin/activate")
			 "*frc*"))
  (send-shell-commands '("python robot.py deploy"
				 "y"
				 "y")
		       "*frc*"))

(defun in-list (containing-list obj)
  "Checks to see if OBJ is in CONTAININNG-LIST

   Returns T if it OBJ is there, otherwise returns NIL"
  (loop for i in containing-list do (when (equal i obj) (return t))))

(defun create-shell (&optional name)
  "creates a shell with a given name"
  (interactive);; "Prompt\n shell name:")
  (if name
      (shell name)
    (let ((shell-name (read-string "shell name: " nil)))
      (shell (concat "*" shell-name "*")))))

(defun multi-term-dedicated-find-dedicated-open ()
  (interactive)
  "Sees if a dedicated multi-term window is open

If there is one then it changes to it, otherwise
 it opens one"
  (if (buffer-existp "*MULTI-TERM-DEDICATED*")
      (switch-to-buffer "*MULTI-TERM-DEDICATED*")
    (progn
      (multi-term-dedicated-open))))

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
		    `(or ,@(loop for name in sys-name
			    collect `(string-equal system-type ,name)))
		  `(string-equal system-type ,sys-name))
	   ,@body)))))

(when-on 'bsd "berkeley-unix")
(when-on 'linux "gnu/linux")

;;;
;;  END CUSTOM MACROS
;;;

;; i don't remember what this does
(info-lookup-add-help
 :mode 'python-mode
 :regexp "[[:alnum:]_]+"
 :doc-spec
 '(("(python)Index" nil "")))

;; sets up completions for ruby
(add-hook 'enh-ruby-mode-hook 'robe-start)
(add-hook 'enh-ruby-mode-hook 'robe-mode)
(add-hook 'enh-ruby-mode-hook 'company-mode)
(eval-after-load 'company
  '(push 'company-robe company-backends))

;; sets up virtual envs and elpy mode
(setq venv-location "/home/ztepps/Documents/python/")
(add-hook 'python-mode-hook
	  (lambda ()
	    (elpy-mode)))

(add-hook 'find-file-hook
	  (lambda ()
	    (when (string= (buffer-name) "robot.py")
	      (local-set-key (kbd "C-c d c") 'deploy-code)
	      (local-set-key (kbd "C-c p") 'git-push))))

;; sets up my custom key bindings
(global-set-key (kbd "C-x o") 'win-switch-dispatch)
(global-set-key (kbd "C-x M-f") 'horz-flip-buffers)
(global-set-key (kbd "s-l") 'slime)
(global-set-key (kbd "C-c e f") (lambda () (interactive)
				(erc :server "irc.freenode.net"
				     :port "6667"
				     :nick "theZacAttack"
				     :password "supersecretpass13")))
(global-set-key (kbd "C-c n f") 'origami-next-fold)
(global-set-key (kbd "C-c n M-f") 'origami-previous-fold)
(global-set-key (kbd "C-c n TAB") 'origami-toggle-node)
(global-set-key (kbd "C-c n M-TAB") 'origami-show-only-node)
(global-set-key (kbd "C-c n C-M-TAB") 'origami-open-all-nodes)
(global-set-key (kbd "C-c n C-TAB") 'origami-close-all-nodes)

;; adds the visual line wrapping mode into text mode
(add-hook 'text-mode-hook 'visual-line-mode)
(add-hook 'erc-mode-hook 'visual-line-mode)
(add-hook 'emacs-lisp-mode-hook 'eldoc-mode)
(add-hook 'python-mode-hook 'flyspell-prog-mode)

;; sets up EXWM
;(require 'exwm)
;(require 'exwm-randr)
;(require 'exwm-config)
;(require 'exwm-systemtray)
;(exwm-config-default)
;(exwm-systemtray-enable)
;(exwm-layout-hide-mode-line)
;(setq exwm-randr-workspace-output-plist '(0 "HDMI1"))
;(add-hook 'exwm-randr-screen-change-hook
;	  (lambda ()
;	    (start-process-shell-command
;	     "xrandr" nil "xrandr --output HDMI1 --left-of eDPI --auto")))
;(exwm-randr-enable)

;; sets the speedbar to open when emacs opens and
;;  gets everything to the right size
;(when (window-system)
;    (let ((main-win (car (frame-list)))
;	  (speed-win nil))
;      (speedbar)
;      (setq speed-win (car (frame-list)))
;      (set-frame-position speed-win 0 0)
;      (set-frame-position main-win (* (frame-width speed-win) 11) 0)
;      (set-frame-size main-win 124 80)
;      (select-frame-set-input-focus main-win)))

(load-theme 'twilight-anti-bright)

(require 'multi-term)
(setq multi-term-program "/usr/bin/fish")
(global-set-key (kbd "s-s") 'multi-term)
(global-set-key (kbd "s-C-s") 'multi-term-dedicated-find-dedicated-open)
(global-set-key (kbd "s-n") 'multi-term-next)
(global-set-key (kbd "s-p") 'multi-term-prev)

(add-hook 'term-mode-hook (lambda ()
			    (define-key term-raw-map (kbd "C-j") 'term-line-mode)
			    (define-key term-mode-map (kbd "C-M-j") 'term-char-mode)))

;;; Fira code font and ligatures
(when-on-linux
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

(setq debug-on-error t)

;; perform different tasks on different machines
;;  TODO: check hostname
(global-set-key (kbd "C-s-l") (lambda ()
				(interactive)
				(slime-connect "127.0.0.1" 4004)))
