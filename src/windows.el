(global-set-key (kbd "<M-s-right>") 'other-window)

(defun other-window-previous (n)
  "Moves to previous window"
  (interactive "p")
  (other-window (- n))

(global-set-key (kbd "<M-s-left>") 'other-window-previous)
