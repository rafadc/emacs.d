(defalias 'helm-buffer-match-major-mode 'helm-buffers-match-function)

(global-set-key (kbd "M-x") 'helm-M-x) ; Helm for emacs commands

(global-set-key (kbd "C-x b") 'helm-buffers-list) ; Helm for buffer list

(global-set-key (kbd "M-y") 'helm-show-kill-ring) ; Helm for kill ring

(global-set-key (kbd "s-p") 'helm-projectile)

(global-set-key (kbd "s-F") 'helm-do-ag)
