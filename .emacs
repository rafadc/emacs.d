(load-file "~/.emacs.d/src/repositories.el")

(load-file "~/.emacs.d/src/visuals.el")
(load-file "~/.emacs.d/src/minibuffer.el")

(load-file "~/.emacs.d/src/backup-files.el")
(load-file "~/.emacs.d/src/spellcheck.el")

(load-file "~/.emacs.d/src/dash.el")

(load-file "~/.emacs.d/src/languages/clojure.el")
(load-file "~/.emacs.d/src/languages/markdown.el")º

;; Helm
(global-set-key (kbd "s-p") 'helm-find-files)

;; Magit
(global-set-key (kbd "<f6>") 'magit-status)

