(defun grab-line-down ()
  "Moves current line down"
  (interactive)
  (progn
   (forward-line 1)
   (transpose-lines 1)
   (forward-line -1)))

(global-set-key (kbd "M-<down>") 'grab-line-down)


