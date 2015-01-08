(load-file "~/.emacs.d/src/repositories.el")

(load-file "~/.emacs.d/src/visuals.el")

;; Incremental search in minibuffer
(iswitchb-mode 1)

;; By default arrow keys do not work in iswitchb
;; This can solve it
(defun iswitchb-local-keys ()
  (mapc (lambda (K) 
	  (let* ((key (car K)) (fun (cdr K)))
	    (define-key iswitchb-mode-map (edmacro-parse-keys key) fun)))
	'(("<right>" . iswitchb-next-match)
	  ("<left>"  . iswitchb-prev-match)
	  ("<up>"    . ignore             )
	  ("<down>"  . ignore             ))))
(add-hook 'iswitchb-define-mode-map-hook 'iswitchb-local-keys)

(load-file "~/.emacs.d/src/backup-files.el")
(load-file "~/.emacs.d/src/spellcheck.el")

;; KEY-BINDINGS

(load-file "~/.emacs.d/src/dash.el")

(load-file "~/.emacs.d/src/languages/clojure.el")

;; Helm
(global-set-key (kbd "s-p") 'helm-find-files)

;; Magit
(global-set-key (kbd "<f6>") 'magit-status)

;; MARKDOWN
(autoload 'markdown-mode "markdown-mode"
  "Major mode for editing Markdown files" t)
(add-to-list 'auto-mode-alist '("\\.markdown\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))
