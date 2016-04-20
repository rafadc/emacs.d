;;; p161-mode.el --- P161 workflow custom mode

;; Copyright 2016 Rafa de Castro

;; Author: Rafa de Castro <rafael@micubiculo.com>
;; URL: http://github.com/rafadc/emacs.d
;; Version: 0.0.1
;; Package-Requires: ()


(defun git-folder ()
  "Returns the folder for the project"
  (car (projectile-get-project-directories)))

(defun current-ticket ()
  "Returns the current ticket name based on brach name. Returns null in a ticketless branch."
  (let*
      ((command (concat "git --git-dir=" (git-folder) ".git branch | sed -n '/* /s///p'"))
       (branch-name (shell-command-to-string command))
       (ticket-name (car (split-string branch-name "\\."))))
    (if (string-match "PFM-" ticket-name)
      ticket-name)))

(defun open-current-ticket-in-browser ()
  "Opens the current ticket in a browser"
  (interactive)
  (let*
      ((ticket (current-ticket))
       (url (concat "https://jira.platform161.com/browse/" ticket))
       (command (concat "open " url)))
    (if (and ticket (string-match "PFM" ticket))
        (shell-command-to-string command)
      (message "Not in a ticket branch"))))

(defun create-branch-for-ticket (arg ticket-number)
  "Asks for a ticket and creates a branch for it starting in the current branch."
  (interactive "P\nbTicket number: ")
  (let*
      ((ticket-text "sample-ticket-text")
       (branch-name (concat ticket-number ".rafa." ticket-text)))
    (progn
      (shell-command-to-string (concat "git checkout -b" branch-name)))))

(defun insert-pfm-in-commit-message ()
  "Inserts the PFM ticket name at the beginning of commit message"
  (interactive)
  (let*
      ((git-folder (car (projectile-get-project-directories)))
       (command (concat "git --git-dir=" git-folder ".git branch | sed -n '/* /s///p'"))
       (branch-name (shell-command-to-string command))
       (ticket-name (car (split-string branch-name "\\."))))
    (if (string-match-p (regexp-quote "PFM-") ticket-name)
        (insert (concat ticket-name " ")))))

(defun send-test-to-tmux ()
  "Sends the currently open test to tmux"
  (interactive)
  (let*
      ((base_path (car (projectile-get-project-directories)))
       (filename (replace-regexp-in-string base_path "" (current_buffer_file_name)))
       (command (concat "tmux send -t platform161 'rspec -I spec/app " filename "'  ENTER")))
    (message command)
    (shell-command command)))


(define-minor-mode p161-mode
  "Platform 161 mode"
  :lighter " P161"
  :global t
  :keymap (let ((map (make-sparse-keymap)))
            (define-key map (kbd "C-c p c") 'create-branch-for-ticket)
            (define-key map (kbd "C-c p n") 'open-current-ticket-in-browser)
            map)
  (add-hook 'git-commit-mode-hook 'insert-pfm-in-commit-message)
;  (add-hook 'ruby-mode-hook (local-set-key (kbd "C-c C-t") 'send-test-to-tmux))
  )

(provide 'p161-mode)

;;; p161-mode.el ends here
