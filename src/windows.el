(global-set-key (kbd "<M-s-right>") 'other-window)

(defun other-window-previous ()
  "Moves to previous window"
  (interactive)
  (other-window -1))

(global-set-key (kbd "<M-s-left>") 'other-window-previous)
