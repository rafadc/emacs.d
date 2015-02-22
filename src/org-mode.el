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

(require 'org-trello)

(setq trello-file "~/.trello/my-life.org")

(defun open-trello-file ()
  "Opens trello's org file"
  (interactive)
  (find-file "~/.trello/my-life.org")
  (org-trello-mode))

(global-set-key (kbd "C-<f7>") 'open-trello-file)

;; (custom-set-variables '(org-trello-files '("/Users/rafael/.trello/my-life.org")))
