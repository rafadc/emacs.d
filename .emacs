(load-file "~/.emacs.d/src/repositories.el")

(setq-default indent-tabs-mode nil)
(load-file "~/.emacs.d/src/visuals.el")
(load-file "~/.emacs.d/src/minibuffer.el")
(load-file "~/.emacs.d/src/keyboard.el")
(load-file "~/.emacs.d/src/manipulating-text.el")
(load-file "~/.emacs.d/src/windows.el")
(load-file "~/.emacs.d/src/undo.el")
(load-file "~/.emacs.d/src/selecting.el")
(load-file "~/.emacs.d/src/search.el")
(load-file "~/.emacs.d/src/open-in-external.el")

(add-hook 'before-save-hook 'delete-trailing-whitespace)

(load-file "~/.emacs.d/src/midnight.el")
(load-file "~/.emacs.d/src/backup-files.el")
(load-file "~/.emacs.d/src/spellcheck.el")

(load-file "~/.emacs.d/src/org-mode.el")

(load-file "~/.emacs.d/src/helm.el")
(defalias 'helm-buffer-match-major-mode 'helm-buffers-list--match-fn)

(load-file "~/.emacs.d/src/company-mode.el")
(load-file "~/.emacs.d/src/snippets.el")

(load-file "~/.emacs.d/src/languages/clojure.el")
(load-file "~/.emacs.d/src/languages/markdown.el")
(load-file "~/.emacs.d/src/languages/haskell.el")
(load-file "~/.emacs.d/src/languages/htmlcss.el")
(load-file "~/.emacs.d/src/languages/ruby.el")

(load-file "~/.emacs.d/src/git.el")
(load-file "~/.emacs.d/src/unmanaged.el")
(load-file "~/.emacs.d/src/dash.el")

(put 'dired-find-alternate-file 'disabled nil)

(load-file "~/.emacs.d/src/copy-rtf/copy-rtf.el")

(setq guide-key/guide-key-sequence t)
(guide-key-mode 1)

(load-file "~/.emacs.d/src/neotree.el")

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   (quote
    ("756597b162f1be60a12dbd52bab71d40d6a2845a3e3c2584c6573ee9c332a66e" "6a37be365d1d95fad2f4d185e51928c789ef7a4ccf17e7ca13ad63a8bf5b922f" default))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
