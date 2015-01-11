(defun grab-line-down ()
  "Moves current line down"
  (interactive)
  (progn
   (forward-line 1)
   (transpose-lines 1)
   (forward-line -1)))

(defun grab-line-up ()
  "Moves current line up"
  (interactive)
  (progn
   (forward-line 1)
   (transpose-lines -1)
   (forward-line -2)))

(global-set-key (kbd "M-<down>") 'grab-line-down)
(global-set-key (kbd "M-<up>") 'grab-line-up)

(defun duplicate-line ()
  "Duplicates current line"
  (interactive)
  (let
      ((text-to-insert (thing-at-point 'line)))
    (forward-line 1)
    (insert text-to-insert)
    (forward-line -1)))

(global-set-key (kbd "s-D") 'duplicate-line)

