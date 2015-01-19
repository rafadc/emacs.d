(load-file "~/.emacs.d/src/repositories.el")

(delete-selection-mode 1)

(load-file "~/.emacs.d/src/visuals.el")
(load-file "~/.emacs.d/src/minibuffer.el")
(load-file "~/.emacs.d/src/keyboard.el")
(load-file "~/.emacs.d/src/moving_text.el")
(load-file "~/.emacs.d/src/windows.el")
(load-file "~/.emacs.d/src/undo.el")

(load-file "~/.emacs.d/src/midnight.el")
(load-file "~/.emacs.d/src/backup-files.el")
(load-file "~/.emacs.d/src/spellcheck.el")

(load-file "~/.emacs.d/src/helm.el")
(load-file "~/.emacs.d/src/dash.el")

(load-file "~/.emacs.d/src/languages/clojure.el")
(load-file "~/.emacs.d/src/languages/markdown.el")
(load-file "~/.emacs.d/src/languages/haskell.el")

;; Magit
(global-set-key (kbd "<f6>") 'magit-status)

(load-file "~/.emacs.d/src/unmanaged.el")

(put 'dired-find-alternate-file 'disabled nil)
