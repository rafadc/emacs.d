;; Binding F7 to open a personal_notes.org file in root of projectile
(require 'projectile)

(defun projectile-open-personal-notes ()
  "Opens a personal_notes.org file in project folder"
  (interactive)
  (let
      ((folder (car (projectile-get-project-directories))))
    (if folder
      (find-file (concat folder "personal_notes.org"))
      (message "No project folder found"))))

(global-set-key (kbd "<f7>") 'projectile-open-personal-notes)
