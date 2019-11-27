;;; stuart-mode.el --- Stuart workflow custom mode
;;; Commentary:
;; Copyright 2018 Rafa de Castro

;; Author: Rafa de Castro <rafael@micubiculo.com>
;; URL: http://github.com/rafadc/emacs.d
;; Version: 0.0.1
;; Package-Requires: ((Emacs "24.4") (request "20170131.1747"))
;;; Code:
(require 'git-commit)

(defun stuart/current-ticket ()
  "Return the current ticket name based on brach name.  Return null in a ticketless branch."
  (let*
      ((command (concat "git --git-dir=" (git-folder) ".git branch | sed -n '/* /s///p'"))
       (branch-name (shell-command-to-string command))
       (ticket-name (car (split-string branch-name "\\."))))
    (if (string-match "POOL-" ticket-name)
      ticket-name)))

(defun stuart/open-current-ticket-in-browser ()
  "Opens the current ticket in a browser."
  (interactive)
  (let*
      ((ticket (stuart/current-ticket))
       (url (concat stuart/jira-url "/browse/" ticket))
       (command (concat "open " url)))
    (if (and ticket (string-match "POOL" ticket))
        (shell-command-to-string command)
      (message "Not in a ticket branch"))))

(defun stuart/create-branch-for-ticket (arg ticket-number)
  "Asks for a ticket and create a branch for it starting in the current branch."
  (interactive "P\nbTicket number: ")
  (let*
      ((ticket-text "sample-ticket-text")
       (branch-name (concat ticket-number ".rafa." ticket-text)))
    (progn
      (shell-command-to-string (concat "git checkout -b" branch-name)))))

(defun stuart/insert-pfm-in-commit-message ()
  "Insert the POOL ticket name at the beginning of commit message."
  (interactive)
  (let*
      ((command (concat "git --git-dir=" (projectile-project-root) ".git branch | sed -n '/* /s///p'"))
       (branch-name (shell-command-to-string command))
       (ticket-name (car (split-string branch-name "\\."))))
    (if (string-match-p (regexp-quote "POOL-") ticket-name)
        (insert (concat ticket-name " ")))))

(defun stuart/send-test-to-tmux ()
  "Send the currently open test to tmux."
  (interactive)
  (let*
      ((filename (replace-regexp-in-string (projectile-project-root) "" (current_buffer_file_name)))
       (command (concat "tmux send -t stuart 'bin/rspec " filename "'  ENTER")))
    (message command)
    (shell-command command)))

(defun stuart/on-enable-stuart-mode ()
  "On stuart mode enabling."
  (interactive)
  (add-hook 'git-commit-mode-hook 'stuart/insert-pfm-in-commit-message)
  )

(define-minor-mode stuart-mode
  "Stuart mode."
  :lighter " Stu"
  :global t
  :keymap (let ((map (make-sparse-keymap)))
            (define-key map (kbd "C-c t") 'stuart/send-test-to-tmux)
            (define-key map (kbd "C-c C-p c") 'stuart/create-branch-for-ticket)
            (define-key map (kbd "C-c C-p b") 'stuart/open-current-ticket-in-browser)
            map)
  (if stuart-mode
      (stuart/on-enable-stuart-mode))
  )

;;; (Features)

(provide 'stuart-mode)

;;; stuart-mode.el ends here
