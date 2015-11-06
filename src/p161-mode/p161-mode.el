(defvar p161-mode nil
  "Mode for Platform 161")

(make-variable-buffer-local 'p161-mode)

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

(defun toggle-p161 ()
  "Toggles p161 mode based on input parameters to the function to follow standard minor mode"
  (if (null arg)
      (if p161-mode
          (not p161-mode)
        (> (prefix-numeric-value arg) 0))))

(defun add-p161-mode-to-alist ()
  "Add the p161 mode to the minor mode alist if it is not there"
  (if (not (assq 'p161-mode minor-mode-alist))
      (setq minor-mode-alist
            (cons '(p161-mode " P161")
                  minor-mode-alist))))

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
      ((ticket-text "")
       (branch-name (concat ticket-number ".rafa." ticket-text)))
    (progn
      (shell-command-to-string (concat "git checkout -b" branch-name)))))

(defun add-shortcuts ()
  "Adds all shortcuts to mode"
  (progn
      (global-set-key (kbd "C-c p c") 'open-current-ticket-in-browser)
      (global-set-key (kbd "C-c p n") 'create-branch-for-ticket)))

(defun remove-shortcuts ()
  "Removes all shortcuts from mode"
  (progn
      (global-unset-key (kbd "C-c p c"))
      (global-unset-key (kbd "C-c p n"))))

(defun insert-pfm-in-commit-message ()
  "Inserts the PFM ticket name at the beginning of commit message"
  (interactive)
  (let*
      ((git-folder (car (projectile-get-project-directories)))
       (command (concat "git --git-dir=" git-folder ".git branch | sed -n '/* /s///p'"))
       (branch-name (shell-command-to-string command))
       (ticket-name (split-string branch-name "\\.")))
    (if ticket-name
      (insert ticket-name))))

(defun p161-mode (&optional arg)
  "Platform 161 mode"
  (interactive "P")
  (setq p161-mode (toggle-p161))
  (if p161-mode
      (progn
        (add-shortcuts)
        (add-hook 'git-commit-mode-hook 'insert-pfm-in-commit-message))
    (remove-shortcuts)) )
