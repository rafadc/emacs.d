(require 'package)
(add-to-list 'package-archives
             '("melpa-stable" . "http://stable.melpa.org/packages/") t)
(add-to-list 'package-archives 
	     '("marmalade" .
	       "http://marmalade-repo.org/packages/"))
(package-initialize)

;; Base16 theme
(load-file "~/.emacs.d/themes/base16-emacs/base16-default-theme.el")

;; Disable menu and icon bar
(menu-bar-mode -1)
(tool-bar-mode -1)

;; Show line numbers
(global-linum-mode t)

;; Paren highlight
(show-paren-mode 1)
(setq show-paren-delay 0)

;; Font
(set-face-attribute 'default nil
                    :family "M+ 2m" :height 180 :weight 'light)

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

;; Backups
(setq
   backup-by-copying t      ; don't clobber symlinks
   backup-directory-alist
    '(("." . "~/.emacs-saves"))    ; don't litter my fs tree
   delete-old-versions t
   kept-new-versions 6
   kept-old-versions 2
   version-control t)       ; use versioned backups

(load-file "~/.emacs.d/src/spellcheck.el")

;; KEY-BINDINGS

;; Send to Dash
(add-to-list 'load-path "~/.emacs.d/scripts/")
(autoload 'dash-at-point "dash-at-point"
  "Search the word at point with Dash." t nil)
(global-set-key "\C-cd" 'dash-at-point)
(global-set-key "\C-ce" 'dash-at-point-with-docset)

;; CLOJURE

;; Hide cider special buffers
(setq nrepl-hide-special-buffers t)

;; Print a maximum of 100 items per collection
(setq cider-repl-print-length 100)

(setq cider-repl-result-prefix ";; => ")
(setq cider-interactive-eval-result-prefix ";; => ")

;; Helm
(global-set-key (kbd "s-p") 'helm-find-files)

;; Magit
(global-set-key (kbd "<f6>") 'magit-status)

;; MARKDOWN
(autoload 'markdown-mode "markdown-mode"
  "Major mode for editing Markdown files" t)
(add-to-list 'auto-mode-alist '("\\.markdown\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))
