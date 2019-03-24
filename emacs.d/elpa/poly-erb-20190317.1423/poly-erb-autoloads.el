;;; poly-erb-autoloads.el --- automatically extracted autoloads
;;
;;; Code:

(add-to-list 'load-path (directory-file-name
                         (or (file-name-directory #$) (car load-path))))


;;;### (autoloads nil "poly-erb" "poly-erb.el" (0 0 0 0))
;;; Generated autoloads from poly-erb.el
 (autoload 'poly-coffee+erb-mode "poly-erb")

(define-polymode poly-js+erb-mode poly-js-root-polymode :innermodes '(poly-erb-innermode))
 (autoload 'poly-html+erb-mode "poly-erb")

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "poly-erb" '("poly-")))

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; coding: utf-8
;; End:
;;; poly-erb-autoloads.el ends here
