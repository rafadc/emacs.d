;; Adding file types with no rb extension
(add-to-list 'auto-mode-alist
	     '("\\.\\(?:gemspec\\|irbrc\\|gemrc\\|rake\\|rb\\|ru\\|thor\\)\\'" . ruby-mode))

(add-to-list 'auto-mode-alist
               '("\\(Capfile\\|Gemfile\\(?:\\.[a-zA-Z0-9._-]+\\)?\\|[rR]akefile\\)\\'" . ruby-mode))


;; Adding syntax checking
(add-hook 'ruby-mode-hook 'flymake-ruby-load)
(add-hook 'ruby-mode-hook 'flymake-cursor-mode)
(add-hook 'ruby-mode-hook 'yafolding-mode)

(add-to-list 'auto-mode-alist '("\\.erb\\'" . web-mode))
