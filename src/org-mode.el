;; Binding F7 to open a TODO.org file in root of projectile
(require 'projectile)

(defun open-todoorg ()
  "Opens a TODO.org file in project folder"
  (interactive)
  (let
      ((folder (first (projectile-get-project-directories))))
    (if folder
      (find-file (concat folder "personal_notes.org"))
      (message "No project folder found"))))

(global-set-key (kbd "<f7>") 'open-todoorg)
