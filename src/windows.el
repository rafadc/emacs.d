(global-set-key (kbd "<M-s-right>") 'other-window)

(defun other-window-previous (&optional n)
  "Moves to previous window"
  (interactive "p")
  (other-window (if n (- n) -1)))

(global-set-key (kbd "<M-s-left>") 'other-window-previous)
