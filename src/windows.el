(global-set-key (kbd "<M-s-right>") 'other-window)

(defun other-window-previous (&optional n)
  "Moves to previous window"
  (interactive "p")
  (if n
      (other-window (- n))
      (other-window -1)))

(global-set-key (kbd "<M-s-left>") 'other-window-previous)
