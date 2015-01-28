(load-file "~/.emacs.d/src/repositories.el")

(load-file "~/.emacs.d/src/visuals.el")
(load-file "~/.emacs.d/src/minibuffer.el")
(load-file "~/.emacs.d/src/keyboard.el")
(load-file "~/.emacs.d/src/manipulating-text.el")
(load-file "~/.emacs.d/src/windows.el")
(load-file "~/.emacs.d/src/undo.el")
(load-file "~/.emacs.d/src/selecting.el")

(load-file "~/.emacs.d/src/midnight.el")
(load-file "~/.emacs.d/src/backup-files.el")
(load-file "~/.emacs.d/src/spellcheck.el")

(load-file "~/.emacs.d/src/org-mode.el")

(load-file "~/.emacs.d/src/helm.el")

(load-file "~/.emacs.d/src/company-mode.el")
(load-file "~/.emacs.d/src/snippets.el")

(load-file "~/.emacs.d/src/languages/clojure.el")
(load-file "~/.emacs.d/src/languages/markdown.el")
(load-file "~/.emacs.d/src/languages/haskell.el")
(load-file "~/.emacs.d/src/languages/ruby.el")

;; Magit
(global-set-key (kbd "<f6>") 'magit-status)

(load-file "~/.emacs.d/src/unmanaged.el")
(load-file "~/.emacs.d/src/dash.el")

(put 'dired-find-alternate-file 'disabled nil)

(load-file "~/.emacs.d/src/copy-rtf/copy-rtf.el")

(setq guide-key/guide-key-sequence t)
(guide-key-mode 1)
