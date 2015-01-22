(delete-selection-mode 1)

;; Expand region
(global-set-key (kbd "s-e") 'er/expand-region)

(global-set-key (kbd "s-d") 'mc/mark-next-like-this)
(global-set-key (kbd "s-D") 'mc/mark-previous-like-this)
(global-set-key (kbd "C-s-d") 'mc/mark-all-like-this)

(global-set-key (kbd "H-SPC") 'set-rectangular-region-anchor)
