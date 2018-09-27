;;; contextual-autoloads.el --- automatically extracted autoloads
;;
;;; Code:

(add-to-list 'load-path (directory-file-name
                         (or (file-name-directory #$) (car load-path))))


;;;### (autoloads nil "contextual" "contextual.el" (0 0 0 0))
;;; Generated autoloads from contextual.el

(autoload 'contextual-mode "contextual" "\
Contextual is an Emacs global minor mode that enables customization
  variables to be changed and hooks to be run whenever a user changes
  her profile.

\(fn &optional ARG)" t nil)

(defvar contextual-global-mode nil "\
Non-nil if Contextual-Global mode is enabled.
See the `contextual-global-mode' command
for a description of this minor mode.
Setting this variable directly does not take effect;
either customize it (see the info node `Easy Customization')
or call the function `contextual-global-mode'.")

(custom-autoload 'contextual-global-mode "contextual" nil)

(autoload 'contextual-global-mode "contextual" "\
Toggle Contextual mode in all buffers.
With prefix ARG, enable Contextual-Global mode if ARG is positive;
otherwise, disable it.  If called from Lisp, enable the mode if
ARG is omitted or nil.

Contextual mode is enabled in all buffers where
`contextual-mode' would do it.
See `contextual-mode' for more information on Contextual mode.

\(fn &optional ARG)" t nil)

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "contextual" '("contextual-")))

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; coding: utf-8
;; End:
;;; contextual-autoloads.el ends here
