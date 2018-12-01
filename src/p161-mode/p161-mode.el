;;; p161-mode.el --- P161 workflow custom mode

;; Copyright 2016 Rafa de Castro

;; Author: Rafa de Castro <rafael@micubiculo.com>
;; URL: http://github.com/rafadc/emacs.d
;; Version: 0.0.1
;; Package-Requires: ((emacs "24.4") (request "20170131.1747"))
(require 'git-commit)

(defun p161/current-ticket ()
  "Returns the current ticket name based on brach name. Returns null in a ticketless branch."
  (let*
      ((command (concat "git --git-dir=" (git-folder) ".git branch | sed -n '/* /s///p'"))
       (branch-name (shell-command-to-string command))
       (ticket-name (car (split-string branch-name "\\."))))
    (if (string-match "PFM-" ticket-name)
      ticket-name)))

(defun p161/open-current-ticket-in-browser ()
  "Opens the current ticket in a browser"
  (interactive)
  (let*
      ((ticket (p161/current-ticket))
       (url (concat "https://jira.platform161.com/browse/" ticket))
       (command (concat "open " url)))
    (if (and ticket (string-match "PFM" ticket))
        (shell-command-to-string command)
      (message "Not in a ticket branch"))))

(defun p161/create-branch-for-ticket (arg ticket-number)
  "Asks for a ticket and creates a branch for it starting in the current branch."
  (interactive "P\nbTicket number: ")
  (let*
      ((ticket-text "sample-ticket-text")
       (branch-name (concat ticket-number ".rafa." ticket-text)))
    (progn
      (shell-command-to-string (concat "git checkout -b" branch-name)))))

(defun p161/insert-pfm-in-commit-message ()
  "Inserts the PFM ticket name at the beginning of commit message"
  (interactive)
  (let*
      ((command (concat "git --git-dir=" (projectile-project-root) ".git branch | sed -n '/* /s///p'"))
       (branch-name (shell-command-to-string command))
       (ticket-name (car (split-string branch-name "\\."))))
    (if (string-match-p (regexp-quote "PFM-") ticket-name)
        (insert (concat ticket-name " ")))))

(defun p161/send-test-to-tmux ()
  "Sends the currently open test to tmux"
  (interactive)
  (let*
      ((filename (replace-regexp-in-string (projectile-project-root) "" (current_buffer_file_name)))
       (command (concat "tmux send -t platform161 'rspec -I spec/app " filename "'  ENTER")))
    (message command)
    (shell-command command)))

(defun p161/on-enable-p161-mode ()
  "On P161 mode enabling"
  (interactive)
  (add-hook 'git-commit-mode-hook 'p161/insert-pfm-in-commit-message)
  )

(define-minor-mode p161-mode
  "Platform 161 mode"
  :lighter " P161"
  :global t
  :keymap (let ((map (make-sparse-keymap)))
            (define-key map (kbd "C-c t") 'p161/send-test-to-tmux)
            (define-key map (kbd "C-c C-p c") 'p161/create-branch-for-ticket)
            (define-key map (kbd "C-c C-p b") 'p161/open-current-ticket-in-browser)
            map)
  (if p161-mode
      (p161/on-enable-p161-mode))
  )

;;; (Features)

(provide 'p161-mode)

;;; p161-mode.el ends here
