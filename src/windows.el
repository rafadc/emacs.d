(global-set-key (kbd "<C-x p>") 'other-window)

(defun other-window-previous (&optional n)
  "Moves to previous window"
  (interactive "p")
  (other-window (if n (- n) -1)))

(global-set-key (kbd "<C-x o>") 'other-window-previous)
