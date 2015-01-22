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

(global-set-key (kbd "s-*") 'duplicate-line)

(defun eval-and-replace ()
  "Replace the preceding sexp with its value."
  (interactive)
  (backward-kill-sexp)
  (condition-case nil
      (prin1 (eval (read (current-kill 0)))
             (current-buffer))
    (error (message "Invalid expression")
           (insert (current-kill 0)))))

(global-set-key (kbd "C-c C-e") 'eval-and-replace)
