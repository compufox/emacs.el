;;; mastodon-autoloads.el --- automatically extracted autoloads
;;
;;; Code:

(add-to-list 'load-path (directory-file-name
                         (or (file-name-directory #$) (car load-path))))


;;;### (autoloads nil "mastodon" "mastodon.el" (0 0 0 0))
;;; Generated autoloads from mastodon.el

(autoload 'mastodon "mastodon" "\
Connect Mastodon client to `mastodon-instance-url' instance.

\(fn)" t nil)

(autoload 'mastodon-toot "mastodon" "\
Update instance with new toot. Content is captured in a new buffer.

If USER is non-nil, insert after @ symbol to begin new toot.
If REPLY-TO-ID is non-nil, attach new toot to a conversation.

\(fn &optional USER REPLY-TO-ID)" t nil)

(add-hook 'mastodon-mode-hook (lambda nil (when (require 'emojify nil :noerror) (emojify-mode t))))

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "mastodon" '("mastodon-")))

;;;***

;;;### (autoloads nil "mastodon-auth" "mastodon-auth.el" (0 0 0 0))
;;; Generated autoloads from mastodon-auth.el

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "mastodon-auth" '("mastodon-auth-")))

;;;***

;;;### (autoloads nil "mastodon-client" "mastodon-client.el" (0 0
;;;;;;  0 0))
;;; Generated autoloads from mastodon-client.el

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "mastodon-client" '("mastodon-client")))

;;;***

;;;### (autoloads nil "mastodon-http" "mastodon-http.el" (0 0 0 0))
;;; Generated autoloads from mastodon-http.el

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "mastodon-http" '("mastodon-http--")))

;;;***

;;;### (autoloads nil "mastodon-inspect" "mastodon-inspect.el" (0
;;;;;;  0 0 0))
;;; Generated autoloads from mastodon-inspect.el

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "mastodon-inspect" '("mastodon-inspect--")))

;;;***

;;;### (autoloads nil "mastodon-media" "mastodon-media.el" (0 0 0
;;;;;;  0))
;;; Generated autoloads from mastodon-media.el

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "mastodon-media" '("mastodon-media--")))

;;;***

;;;### (autoloads nil "mastodon-notifications" "mastodon-notifications.el"
;;;;;;  (0 0 0 0))
;;; Generated autoloads from mastodon-notifications.el

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "mastodon-notifications" '("mastodon-notifications--")))

;;;***

;;;### (autoloads nil "mastodon-profile" "mastodon-profile.el" (0
;;;;;;  0 0 0))
;;; Generated autoloads from mastodon-profile.el

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "mastodon-profile" '("mastodon-profile-")))

;;;***

;;;### (autoloads nil "mastodon-tl" "mastodon-tl.el" (0 0 0 0))
;;; Generated autoloads from mastodon-tl.el

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "mastodon-tl" '("mastodon-tl--")))

;;;***

;;;### (autoloads nil "mastodon-toot" "mastodon-toot.el" (0 0 0 0))
;;; Generated autoloads from mastodon-toot.el

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "mastodon-toot" '("mastodon-toot-")))

;;;***

;;;### (autoloads nil nil ("mastodon-pkg.el") (0 0 0 0))

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; coding: utf-8
;; End:
;;; mastodon-autoloads.el ends here
