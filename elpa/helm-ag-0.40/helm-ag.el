;;; helm-ag.el --- the silver searcher with helm interface -*- lexical-binding: t; -*-

;; Copyright (C) 2015 by Syohei YOSHIDA

;; Author: Syohei YOSHIDA <syohex@gmail.com>
;; URL: https://github.com/syohex/emacs-helm-ag
;; Package-Version: 0.40
;; Version: 0.40
;; Package-Requires: ((helm "1.5.6") (cl-lib "0.5"))

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;;; Code:

(eval-when-compile
  (require 'grep)
  (defvar helm-help-message))

(require 'cl-lib)
(require 'helm)
(require 'helm-grep)
(require 'helm-utils)
(require 'compile)

(declare-function helm-read-file-name "helm-mode")
(declare-function helm-grep-get-file-extensions "helm-grep")
(declare-function helm-help "helm-help")

(defgroup helm-ag nil
  "the silver searcher with helm interface"
  :group 'helm)

(defsubst helm-ag--windows-p ()
  (memq system-type '(ms-dos windows-nt)))

(defcustom helm-ag-base-command
  (if (helm-ag--windows-p)
      "ag --nocolor --nogroup --line-numbers"
    "ag --nocolor --nogroup")
  "Base command of `ag'"
  :type 'string
  :group 'helm-ag)

(defcustom helm-ag-command-option nil
  "Command line option of `ag'. This is appended after `helm-ag-base-command'"
  :type 'string
  :group 'helm-ag)

(defcustom helm-ag-insert-at-point nil
  "Insert thing at point as search pattern.
   You can set value same as `thing-at-point'"
  :type 'symbol
  :group 'helm-ag)

(defcustom helm-ag-source-type 'one-line
  "Style of candidates"
  :type '(choice (const :tag "Show file:line number:content in one line" one-line)
                 (const :tag "Helm file-line style" file-line))
  :group 'helm-ag)

(defcustom helm-ag-ignore-patterns nil
  "Ignore patterns for `ag'. This parameters are specified as --ignore"
  :type '(repeat string)
  :group 'helm-ag)

(defcustom helm-ag-use-grep-ignore-list nil
  "Use `grep-find-ignored-files' and `grep-find-ignored-directories' as ignore pattern.
They are specified to `--ignore' options."
  :type 'boolean
  :group 'helm-ag)

(defcustom helm-ag-always-set-extra-option nil
  "Always set `ag' options of `helm-do-ag'."
  :type 'boolean
  :group 'helm-ag)

(defcustom helm-ag-fuzzy-match nil
  "Enable fuzzy match"
  :type 'boolean
  :group 'helm-ag)

(defcustom helm-ag-edit-save t
  "Save buffers you edit at completed."
  :type 'boolean
  :group 'helm-ag)

(defcustom helm-ag-use-emacs-lisp-regexp nil
  "[Experimental] Use Emacs Lisp regexp instead of PCRE."
  :type 'boolean
  :group 'helm-ag)

(defcustom helm-ag-use-agignore nil
  "Use .agignore where is at project root if it exists."
  :type 'boolean
  :group 'helm-ag)

(defvar helm-ag--command-history '())
(defvar helm-ag--context-stack nil)
(defvar helm-ag--default-directory nil)
(defvar helm-ag--last-default-directory nil)
(defvar helm-ag--last-query nil)
(defvar helm-ag--elisp-regexp-query nil)
(defvar helm-ag--valid-regexp-for-emacs nil)
(defvar helm-ag--extra-options nil)
(defvar helm-ag--extra-options-history nil)
(defvar helm-ag--original-window nil)
(defvar helm-ag--search-this-file-p nil)
(defvar helm-ag--default-target nil)
(defvar helm-ag--buffer-search nil)
(defvar helm-ag--command-feature nil)
(defvar helm-do-ag--extensions nil)

(defun helm-ag--save-current-context ()
  (let ((curpoint (with-helm-current-buffer
                    (point))))
    (helm-aif (buffer-file-name helm-current-buffer)
        (push (list :file it :point curpoint) helm-ag--context-stack)
      (push (list :buffer helm-current-buffer :point curpoint) helm-ag--context-stack))))

(defsubst helm-ag--insert-thing-at-point (thing)
  (helm-aif (thing-at-point thing)
      (substring-no-properties it)
    ""))

(defun helm-ag--searched-word ()
  (if helm-ag-insert-at-point
      (helm-ag--insert-thing-at-point helm-ag-insert-at-point)
    ""))

(defun helm-ag--construct-ignore-option (pattern)
  (concat "--ignore=" pattern))

(defun helm-ag--grep-ignore-list-to-options ()
  (require 'grep)
  (cl-loop for ignore in (append grep-find-ignored-files
                                 grep-find-ignored-directories)
           collect (helm-ag--construct-ignore-option ignore)))

(defun helm-ag--parse-query (input)
  (with-temp-buffer
    (insert input)
    (let (end options)
      (goto-char (point-min))
      (when (re-search-forward "\\s-*--\\s-+" nil t)
        (setq end (match-end 0)))
      (goto-char (point-min))
      (while (re-search-forward "\\(?:^\\|\\s-+\\)\\(-\\S-+\\)\\s-+" end t)
        (push (match-string-no-properties 1) options)
        (when end
          (cl-decf end (- (match-end 0) (match-beginning 0))))
        (replace-match ""))
      (let ((query (buffer-string)))
        (when helm-ag-use-emacs-lisp-regexp
          (setq query (helm-ag--elisp-regexp-to-pcre query)))
        (setq helm-ag--last-query query
              helm-ag--elisp-regexp-query (helm-ag--pcre-to-elisp-regexp query))
        (setq helm-ag--valid-regexp-for-emacs
              (helm-ag--validate-regexp helm-ag--elisp-regexp-query))
        (if (not options)
            (list query)
          (nconc (nreverse options) (list query)))))))

(defsubst helm-ag--file-visited-buffers ()
  (cl-loop for buf in (buffer-list)
           when (buffer-file-name buf)
           collect (buffer-file-name buf)))

(defun helm-ag--construct-targets (targets)
  (cl-loop for target in targets
           collect (file-relative-name target)))

(defun helm-ag--root-agignore ()
  (let ((root (helm-ag--project-root)))
    (when root
      (let ((default-directory root))
        (when (file-exists-p ".agignore")
          (expand-file-name (concat default-directory ".agignore")))))))

(defun helm-ag--construct-command (this-file)
  (let* ((commands (split-string helm-ag-base-command nil t))
         (command (car commands))
         (args (cdr commands)))
    (when helm-ag-command-option
      (let ((ag-options (split-string helm-ag-command-option nil t)))
        (setq args (append args ag-options))))
    (when helm-ag-use-agignore
      (helm-aif (helm-ag--root-agignore)
          (setq args (append args (list "-p" it)))))
    (when helm-ag-ignore-patterns
      (setq args (append args (mapcar 'helm-ag--construct-ignore-option
                                      helm-ag-ignore-patterns))))
    (when helm-ag-use-grep-ignore-list
      (setq args (append args (helm-ag--grep-ignore-list-to-options))))
    (setq args (append args (helm-ag--parse-query helm-ag--last-query)))
    (when this-file
      (setq args (append args (list this-file))))
    (when helm-ag--buffer-search
      (setq args (append args (helm-ag--file-visited-buffers))))
    (when helm-ag--default-target
      (setq args (append args (helm-ag--construct-targets helm-ag--default-target))))
    (cons command args)))

(defun helm-ag--init ()
  (let ((buf-coding buffer-file-coding-system))
    (helm-attrset 'recenter t)
    (with-current-buffer (helm-candidate-buffer 'global)
      (let* ((default-directory (or helm-ag--default-directory
                                    default-directory))
             (cmds (helm-ag--construct-command (helm-attr 'search-this-file)))
             (coding-system-for-read buf-coding)
             (coding-system-for-write buf-coding))
        (let ((ret (apply 'process-file (car cmds) nil t nil (cdr cmds))))
          (if (zerop (length (buffer-string)))
              (error "No output: '%s'" helm-ag--last-query)
            (unless (zerop ret)
              (unless (executable-find (car cmds))
                (error "'ag' is not installed."))
              (error "Failed: '%s'" helm-ag--last-query))))
        (helm-ag--save-current-context)))))

(defun helm-ag--search-only-one-file-p ()
  (when (and helm-ag--default-target (= (length helm-ag--default-target) 1))
    (let ((target (car helm-ag--default-target)))
      (unless (file-directory-p target)
        target))))

(defun helm-ag--find-file-action (candidate find-func this-file &optional persistent)
  (let* ((elems (split-string candidate ":"))
         (filename (or this-file (cl-first elems)))
         (line (if this-file
                   (cl-first elems)
                 (cl-second elems)))
         (default-directory (or helm-ag--default-directory
                                helm-ag--last-default-directory
                                default-directory)))
    (unless persistent
      (setq helm-ag--last-default-directory default-directory))
    (funcall find-func filename)
    (goto-char (point-min))
    (when line
      (forward-line (1- (string-to-number line))))))

(defun helm-ag--persistent-action (candidate)
  (helm-ag--find-file-action candidate 'find-file (helm-attr 'search-this-file) t)
  (helm-highlight-current-line))

(defun helm-ag--validate-regexp (regexp)
  (condition-case nil
      (progn
        (string-match-p regexp "")
        t)
    (invalid-regexp nil)))

(defun helm-ag--pcre-to-elisp-regexp (pcre)
  ;; This is very simple conversion
  (with-temp-buffer
    (insert pcre)
    (goto-char (point-min))
    ;; convert (, ), {, }, |
    (while (re-search-forward "[(){}|]" nil t)
      (backward-char 1)
      (cond ((looking-back "\\\\\\\\" nil))
            ((looking-back "\\\\" nil)
             (delete-char -1))
            (t
             (insert "\\")))
      (forward-char 1))
    ;; convert \s and \S -> \s- \S-
    (goto-char (point-min))
    (while (re-search-forward "\\(\\\\s\\)" nil t)
      (unless (looking-back "\\\\\\\\s" nil)
        (insert "-")))
    (buffer-string)))

(defun helm-ag--elisp-regexp-to-pcre (regexp)
  (with-temp-buffer
    (insert regexp)
    (goto-char (point-min))
    (while (re-search-forward "[(){}|]" nil t)
      (backward-char 1)
      (cond ((looking-back "\\\\\\\\" nil))
            ((looking-back "\\\\" nil)
             (delete-char -1))
            (t
             (insert "\\")))
      (forward-char 1))
    (buffer-string)))

(defun helm-ag--highlight-candidate (candidate)
  (let ((limit (1- (length candidate)))
        (last-pos 0))
    (when helm-ag--valid-regexp-for-emacs
      (while (and (< last-pos limit)
                  (string-match helm-ag--elisp-regexp-query candidate last-pos))
        (let ((start (match-beginning 0))
              (end (match-end 0)))
          (if (= start end)
              (cl-incf last-pos)
            (put-text-property start end 'face 'helm-match candidate)
            (setq last-pos (1+ (match-end 0)))))))
    candidate))

(defun helm-ag--candidate-transform-for-this-file (candidate)
  (when (string-match "\\`\\([^:]+\\):\\(.*\\)" candidate)
    (format "%s:%s"
            (propertize (match-string 1 candidate) 'face 'helm-grep-lineno)
            (helm-ag--highlight-candidate (match-string 2 candidate)))))

(defun helm-ag--candidate-transform-for-files (candidate)
  (when (string-match "\\`\\([^:]+\\):\\([^:]+\\):\\(.*\\)" candidate)
    (format "%s:%s:%s"
            (propertize (match-string 1 candidate) 'face 'helm-moccur-buffer)
            (propertize (match-string 2 candidate) 'face 'helm-grep-lineno)
            (helm-ag--highlight-candidate (match-string 3 candidate)))))

(defun helm-ag--candidate-transformer (candidate)
  (or (if (helm-attr 'search-this-file)
          (helm-ag--candidate-transform-for-this-file candidate)
        (helm-ag--candidate-transform-for-files candidate))
      candidate))

(defun helm-ag--search-this-file-p ()
  (if (eq (helm-get-current-source) 'helm-source-do-ag)
      (helm-ag--search-only-one-file-p)
    (helm-attr 'search-this-file)))

(defun helm-ag--action-find-file (candidate)
  (helm-ag--find-file-action candidate 'find-file (helm-ag--search-this-file-p)))

(defun helm-ag--action--find-file-other-window (candidate)
  (helm-ag--find-file-action candidate 'find-file-other-window (helm-ag--search-this-file-p)))

(defvar helm-ag--actions
  '(("Open file" . helm-ag--action-find-file)
    ("Open file other window" . helm-ag--action--find-file-other-window)
    ("Save results in buffer" . helm-ag--action-save-buffer)))

(defvar helm-ag-source
  (helm-build-in-buffer-source "The Silver Searcher"
    :init 'helm-ag--init
    :real-to-display 'helm-ag--candidate-transformer
    :persistent-action 'helm-ag--persistent-action
    :fuzzy-match helm-ag-fuzzy-match
    :action helm-ag--actions))

(defvar helm-ag-source-grep
  '((name . "The Silver Searcher")
    (init . helm-ag--init)
    (candidates-in-buffer)
    (type . file-line)
    (candidate-number-limit . 9999)))

;;;###autoload
(defun helm-ag-pop-stack ()
  (interactive)
  (let ((context (pop helm-ag--context-stack)))
    (unless context
      (error "Context stack is empty !"))
    (helm-aif (plist-get context :file)
        (find-file it)
      (let ((buf (plist-get context :buffer)))
        (if (buffer-live-p buf)
            (switch-to-buffer buf)
          (error "The buffer is already killed."))))
    (goto-char (plist-get context :point))))

;;;###autoload
(defun helm-ag-clear-stack ()
  (interactive)
  (setq helm-ag--context-stack nil))

(defun helm-ag--select-source ()
  (if (eq helm-ag-source-type 'file-line)
      'helm-ag-source-grep
    'helm-ag-source))

(defsubst helm-ag--marked-input ()
  (when (use-region-p)
    (buffer-substring-no-properties (region-beginning) (region-end))))

(defun helm-ag--query ()
  (let* ((searched-word (helm-ag--searched-word))
         (marked-word (helm-ag--marked-input))
         (query (read-string "Pattern: " (or marked-word searched-word) 'helm-ag--command-history)))
    (when (string= query "")
      (error "Input is empty!!"))
    (setq helm-ag--last-query query)))

(defsubst helm-ag--clear-variables ()
  (setq helm-ag--last-default-directory nil))

;;;###autoload
(defun helm-ag-this-file ()
  (interactive)
  (helm-ag--clear-variables)
  (let ((filename (file-name-nondirectory (buffer-file-name))))
    (helm-ag--query)
    (let ((source (helm-ag--select-source)))
      (helm-attrset 'search-this-file (buffer-file-name) (symbol-value source))
      (helm-attrset 'name (format "Search at %s" filename) (symbol-value source))
      (helm :sources (list source) :buffer "*helm-ag*"))))

(defun helm-ag--get-default-directory ()
  (let ((prefix-val (and current-prefix-arg (abs (prefix-numeric-value current-prefix-arg)))))
    (cond ((not prefix-val) default-directory)
          ((= prefix-val 4)
           (file-name-as-directory
            (read-directory-name "Search directory: " nil nil t)))
          ((= prefix-val 16)
           (let ((dirs (list (read-directory-name "Search directory: " nil nil t))))
             (while (y-or-n-p "More directories ?")
               (push (read-directory-name "Search directory: " nil nil t) dirs))
             (reverse dirs))))))

(defsubst helm-ag--helm-header (dir)
  (if helm-ag--buffer-search
      "Search Buffers"
    (concat "Search at " (abbreviate-file-name dir))))

(defun helm-ag--run-other-window-action ()
  (interactive)
  (with-helm-alive-p
    (helm-quit-and-execute-action 'helm-ag--action--find-file-other-window)))

(defsubst helm-ag--kill-edit-buffer ()
  (kill-buffer (get-buffer "*helm-ag-edit*")))

(defun helm-ag--edit-commit ()
  (interactive)
  (goto-char (point-min))
  (let ((read-only-files 0)
        (default-directory helm-ag--default-directory))
    (while (re-search-forward "^\\([^:]+\\):\\([1-9][0-9]*\\):\\(.*\\)$" nil t)
      (let ((file (match-string-no-properties 1))
            (line (string-to-number (match-string-no-properties 2)))
            (body (match-string-no-properties 3)))
        (with-current-buffer (find-file-noselect file)
          (if buffer-read-only
              (cl-incf read-only-files)
            (goto-char (point-min))
            (forward-line (1- line))
            (delete-region (line-beginning-position) (line-end-position))
            (insert body)
            (when helm-ag-edit-save
              (save-buffer))))))
    (select-window helm-ag--original-window)
    (helm-ag--kill-edit-buffer)
    (if (not (zerop read-only-files))
        (message "%d files are read-only and not editable." read-only-files)
      (message "Success update"))))

(defun helm-ag--edit-abort ()
  (interactive)
  (when (y-or-n-p "Discard changes ?")
    (select-window helm-ag--original-window)
    (helm-ag--kill-edit-buffer)
    (message "Abort edit")))

(defvar helm-ag-edit-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "C-c C-c") 'helm-ag--edit-commit)
    (define-key map (kbd "C-c C-k") 'helm-ag--edit-abort)
    map))

(defun helm-ag--edit (_candidate)
  (let ((default-directory helm-ag--default-directory))
    (with-current-buffer (get-buffer-create "*helm-ag-edit*")
      (erase-buffer)
      (setq-local helm-ag--default-directory helm-ag--default-directory)
      (let (buf-content)
        (with-current-buffer (get-buffer "*helm-ag*")
          (goto-char (point-min))
          (forward-line 1)
          (let* ((body-start (point))
                 (marked-lines (cl-loop for ov in (overlays-in body-start (point-max))
                                        when (eq 'helm-visible-mark (overlay-get ov 'face))
                                        return (helm-marked-candidates))))
            (if (not marked-lines)
                (setq buf-content (buffer-substring-no-properties
                                   body-start (point-max)))
              (setq buf-content (concat (mapconcat 'identity marked-lines "\n") "\n")))))
        (insert buf-content)
        (add-text-properties (point-min) (point-max)
                             '(read-only t rear-nonsticky t front-sticky t))
        (let ((inhibit-read-only t))
          (setq header-line-format
                (format "[%s] C-c C-c: Commit, C-c C-k: Abort"
                        (abbreviate-file-name helm-ag--default-directory)))
          (goto-char (point-min))
          (while (re-search-forward "^\\(\\(?:[^:]+:\\)\\{1,2\\}\\)\\(.*\\)$" nil t)
            (let ((file-line-begin (match-beginning 1))
                  (file-line-end (match-end 1))
                  (body-begin (match-beginning 2))
                  (body-end (match-end 2)))
              (add-text-properties file-line-begin file-line-end
                                   '(face font-lock-function-name-face
                                          intangible t))
              (remove-text-properties body-begin body-end '(read-only t))
              (set-text-properties body-end (1+ body-end)
                                   '(read-only t rear-nonsticky t))))))))
  (other-window 1)
  (switch-to-buffer (get-buffer "*helm-ag-edit*"))
  (goto-char (point-min))
  (setq next-error-function 'compilation-next-error-function)
  (setq-local compilation-locs (make-hash-table :test 'equal :weakness 'value))
  (use-local-map helm-ag-edit-map))

(defun helm-ag-edit ()
  (interactive)
  (helm-quit-and-execute-action 'helm-ag--edit))

(defconst helm-ag--help-message
  "\n* Helm Ag\n

\n** Specific commands for Helm Ag:\n
\\<helm-ag-map>
\\[helm-ag--run-other-window-action]\t\t-> Open result in other buffer
\\[helm-ag--up-one-level]\t\t-> Search in parent directory.
\\[helm-ag-edit]\t\t-> Edit search results.
\\[helm-ag-help]\t\t-> Show this help.
\n** Helm Ag Map\n
\\{helm-map}")

(defun helm-ag-help ()
  (interactive)
  (let ((helm-help-message helm-ag--help-message))
    (helm-help)))

(defun helm-ag-mode-jump ()
  (interactive)
  (let ((line (helm-current-line-contents)))
    (helm-ag--find-file-action line 'find-file helm-ag--search-this-file-p)))

(defun helm-ag-mode-jump-other-window ()
  (interactive)
  (let ((line (helm-current-line-contents)))
    (helm-ag--find-file-action line 'find-file-other-window helm-ag--search-this-file-p)))

(defvar helm-ag-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "RET") 'helm-ag-mode-jump)
    (define-key map (kbd "C-o") 'helm-ag-mode-jump-other-window)
    map))

;;;###autoload
(define-derived-mode helm-ag-mode special-mode "helm-ag"
  "Major mode to provide actions in helm grep saved buffer.

Special commands:
\\{helm-ag-mode-map}")

(defun helm-ag--save-results (_unused)
  (let ((default-directory helm-ag--default-directory)
        (buf "*helm ag results*")
        search-this-file-p)
    (when (buffer-live-p (get-buffer buf))
      (kill-buffer buf))
    (with-current-buffer (get-buffer-create buf)
      (setq buffer-read-only t)
      (let ((inhibit-read-only t))
        (erase-buffer)
        (insert "-*- mode: helm-ag -*-\n\n"
                (format "Ag Results for `%s':\n\n" helm-ag--last-query))
        (save-excursion
          (insert (with-current-buffer helm-buffer
                    (goto-char (point-min))
                    (forward-line 1)
                    (setq search-this-file-p (helm-attr 'search-this-file))
                    (buffer-substring (point) (point-max))))))
      (setq-local helm-ag--search-this-file-p search-this-file-p)
      (setq-local helm-ag--default-directory helm-ag--default-directory)
      (helm-ag-mode)
      (pop-to-buffer buf))
    (message "Helm Ag Results saved in `%s' buffer" buf)))

(defun helm-ag--action-save-buffer (arg)
  (helm-ag--save-results arg))

(defun helm-ag--run-save-buffer ()
  (interactive)
  (with-helm-alive-p
    (helm-quit-and-execute-action 'helm-ag--save-results)))

(defvar helm-ag-map
  (let ((map (make-sparse-keymap)))
    (set-keymap-parent map helm-map)
    (define-key map (kbd "C-c o") 'helm-ag--run-other-window-action)
    (define-key map (kbd "C-l") 'helm-ag--up-one-level)
    (define-key map (kbd "C-c C-e") 'helm-ag-edit)
    (define-key map (kbd "C-x C-s") 'helm-ag--run-save-buffer)
    (define-key map (kbd "C-c ?") 'helm-ag-help)
    map)
  "Keymap for `helm-ag'.")

(defsubst helm-ag--root-directory-p ()
  (cl-loop for dir in '(".git/" ".hg/")
           thereis (file-directory-p dir)))

(defun helm-ag--up-one-level ()
  (interactive)
  (if (or (not (helm-ag--root-directory-p))
          (y-or-n-p "Current directory might be the project root. \
Continue searching the parent directory? "))
      (let ((parent (file-name-directory (directory-file-name default-directory))))
        (helm-run-after-quit
         (lambda ()
           (let ((default-directory parent)
                 (source (helm-ag--select-source)))
             (setq helm-ag--last-default-directory default-directory)
             (helm-attrset 'name (helm-ag--helm-header default-directory)
                           (symbol-value source))
             (helm :sources (list source) :buffer "*helm-ag*"
                   :keymap helm-ag-map)))))
    (message nil)))

;;;###autoload
(defun helm-ag (&optional basedir)
  (interactive)
  (setq helm-ag--original-window (selected-window))
  (helm-ag--clear-variables)
  (let ((dir (helm-ag--get-default-directory))
        targets)
    (when (listp dir)
      (setq basedir default-directory
            targets dir))
    (let ((helm-ag--default-directory (or basedir dir))
          (helm-ag--default-target targets))
      (helm-ag--query)
      (let ((source (helm-ag--select-source)))
        (helm-attrset 'search-this-file nil
                      (symbol-value source))
        (helm-attrset 'name (helm-ag--helm-header helm-ag--default-directory)
                      (symbol-value source))
        (helm :sources (list source) :buffer "*helm-ag*"
              :keymap helm-ag-map)))))

(defun helm-ag--join-patterns (input)
  (let ((patterns (split-string input)))
    (if (= (length patterns) 1)
        (car patterns)
      (cl-case helm-ag--command-feature
        (pt input)
        (pt-regexp (mapconcat 'identity patterns ".*"))
        (otherwise (mapconcat (lambda (s) (concat "(?=.*" s ".*)")) patterns ""))))))

(defun helm-ag--do-ag-highlight-patterns (input)
  (if helm-ag--command-feature
      (list (helm-ag--join-patterns input))
    (cl-loop with regexp = (helm-ag--pcre-to-elisp-regexp input)
             for pattern in (split-string regexp)
             when (helm-ag--validate-regexp pattern)
             collect pattern)))

(defun helm-ag--do-ag-propertize ()
  (with-helm-window
    (goto-char (point-min))
    (let ((patterns (helm-ag--do-ag-highlight-patterns helm-input)))
      (cl-loop with one-file-p = (helm-ag--search-only-one-file-p)
               while (not (eobp))
               do
               (progn
                 (let ((start (point))
                       (bound (line-end-position))
                       file-end line-end)
                   (when (or one-file-p (search-forward ":" bound t))
                     (setq file-end (1- (point)))
                     (when (search-forward ":" bound t)
                       (setq line-end (1- (point)))
                       (unless one-file-p
                         (set-text-properties start file-end '(face helm-moccur-buffer)))
                       (set-text-properties (1+ file-end) line-end
                                            '(face helm-grep-lineno))

                       (let ((curpoint (point)))
                         (dolist (pattern patterns)
                           (let ((last-point (point)))
                             (while (re-search-forward pattern bound t)
                               (set-text-properties (match-beginning 0) (match-end 0)
                                                    '(face helm-match))
                               (when (= last-point (point))
                                 (forward-char 1))
                               (setq last-point (point)))
                             (goto-char curpoint)))))))
                 (forward-line 1))))
    (goto-char (point-min))
    (helm-display-mode-line (helm-get-current-source))))

(defun helm-ag--construct-extension-options ()
  (cl-loop for ext in helm-do-ag--extensions
           unless (string= ext "*")
           collect
           (concat "-G" (replace-regexp-in-string
                         "\\*" ""
                         (replace-regexp-in-string "\\." "\\\\." ext)))))

(defun helm-ag--construct-do-ag-command (pattern)
  (let ((cmds (split-string helm-ag-base-command nil t)))
    (when helm-ag-command-option
      (setq cmds (append cmds (split-string helm-ag-command-option nil t))))
    (when helm-ag--extra-options
      (setq cmds (append cmds (split-string helm-ag--extra-options))))
    (when helm-ag-use-agignore
      (helm-aif (helm-ag--root-agignore)
          (setq cmds (append cmds (list "-p" it)))))
    (when helm-do-ag--extensions
      (setq cmds (append cmds (helm-ag--construct-extension-options))))
    (setq cmds (append cmds (list "--" (helm-ag--join-patterns pattern))))
    (when helm-ag--buffer-search
      (setq cmds (append cmds (helm-ag--file-visited-buffers))))
    (if helm-ag--default-target
        (append cmds (helm-ag--construct-targets helm-ag--default-target))
      cmds)))

(defun helm-ag--do-ag-candidate-process ()
  (let* ((default-directory (or helm-ag--default-directory default-directory))
         (proc (apply 'start-file-process "helm-do-ag" nil
                      (helm-ag--construct-do-ag-command helm-pattern))))
    (prog1 proc
      (set-process-sentinel
       proc
       (lambda (process event)
         (helm-process-deferred-sentinel-hook
          process event (helm-default-directory))
         (when (string= event "finished\n")
           (helm-ag--do-ag-propertize)))))))

(defconst helm-do-ag--help-message
  "\n* Helm Do Ag\n

\n** Specific commands for Helm Ag:\n
\\<helm-do-ag-map>
\\[helm-ag--run-other-window-action]\t\t-> Open result in other buffer
\\[helm-ag--do-ag-up-one-level]\t\t-> Search in parent directory.
\\[helm-ag-edit]\t\t-> Edit search results.
\\[helm-ag--do-ag-help]\t\t-> Show this help.
\n** Helm Ag Map\n
\\{helm-map}")

(defun helm-ag--do-ag-help ()
  (interactive)
  (let ((helm-help-message helm-do-ag--help-message))
    (helm-help)))

(defvar helm-do-ag-map
  (let ((map (make-sparse-keymap)))
    (set-keymap-parent map helm-ag-map)
    (define-key map (kbd "C-l") 'helm-ag--do-ag-up-one-level)
    (define-key map (kbd "C-c ?") 'helm-ag--do-ag-help)
    map)
  "Keymap for `helm-do-ag'.")

(defvar helm-source-do-ag
  `((name . "The Silver Searcher")
    (candidates-process . helm-ag--do-ag-candidate-process)
    (persistent-action . helm-ag--persistent-action)
    (action . ,helm-ag--actions)
    (no-matchplugin)
    (nohighlight)
    (requires-pattern . 3)
    (candidate-number-limit . 9999)))

(defun helm-ag--do-ag-up-one-level ()
  (interactive)
  (if (or (not (helm-ag--root-directory-p))
          (y-or-n-p "Current directory might be the project root. \
Continue searching the parent directory? "))
      (let ((parent (file-name-directory (directory-file-name default-directory)))
            (initial-input helm-input))
        (helm-run-after-quit
         (lambda ()
           (let ((default-directory parent))
             (setq helm-ag--last-default-directory default-directory)
             (helm-attrset 'name (helm-ag--helm-header parent)
                           helm-source-do-ag)
             (helm :sources '(helm-source-do-ag) :buffer "*helm-ag*"
                   :input initial-input :keymap helm-do-ag-map)))))
    (message nil)))

(defun helm-ag--set-do-ag-option ()
  (when (or (< (prefix-numeric-value current-prefix-arg) 0)
            helm-ag-always-set-extra-option)
    (let ((option (read-string "Extra options: " (or helm-ag--extra-options "")
                               'helm-ag--extra-options-history)))
      (setq helm-ag--extra-options option))))

(defun helm-ag--set-command-feature ()
  (setq helm-ag--command-feature
        (when (string-prefix-p "pt" helm-ag-base-command)
          (if (string-match-p "-e" helm-ag-base-command)
              'pt-regexp
            'pt))))

(defun helm-ag--do-ag-searched-extensions ()
  (when (and current-prefix-arg (= (abs (prefix-numeric-value current-prefix-arg)) 4))
    (helm-grep-get-file-extensions helm-ag--default-target)))

(defsubst helm-do-ag--is-target-one-directory-p (targets)
  (and (listp targets) (= (length targets) 1) (file-directory-p (car targets))))

(defsubst helm-do-ag--helm ()
  (helm :sources '(helm-source-do-ag) :buffer "*helm-ag*"
        :input (helm-ag--insert-thing-at-point helm-ag-insert-at-point)
        :keymap helm-do-ag-map))

;;;###autoload
(defun helm-do-ag-this-file ()
  (interactive)
  (helm-aif (buffer-file-name)
      (helm-do-ag default-directory it)
    (error "Error: This buffer is not visited file.")))

;;;###autoload
(defun helm-do-ag (&optional basedir this-file)
  (interactive)
  (require 'helm-mode)
  (setq helm-ag--original-window (selected-window))
  (helm-ag--clear-variables)
  (let* ((helm-ag--default-directory (or basedir default-directory))
         (helm-ag--default-target (cond (this-file (list this-file))
                                        ((and (helm-ag--windows-p) basedir) (list basedir))
                                        (t
                                         (when (and (not basedir) (not helm-ag--buffer-search))
                                           (helm-read-file-name
                                            "Search in file(s): "
                                            :default default-directory
                                            :marked-candidates t :must-match t)))))
         (helm-do-ag--extensions (helm-ag--do-ag-searched-extensions))
         (one-directory-p (helm-do-ag--is-target-one-directory-p
                           helm-ag--default-target)))
    (helm-ag--set-do-ag-option)
    (helm-ag--set-command-feature)
    (helm-ag--save-current-context)
    (helm-attrset 'search-this-file this-file helm-source-do-ag)
    (helm-attrset 'name (helm-ag--helm-header helm-ag--default-directory)
                  helm-source-do-ag)
    (if (or (helm-ag--windows-p) (not one-directory-p)) ;; Path argument must be specified on Windows
        (helm-do-ag--helm)
      (let* ((helm-ag--default-directory
              (file-name-as-directory (car helm-ag--default-target)))
             (helm-ag--default-target nil))
        (helm-do-ag--helm)))))

(defun helm-ag--project-root ()
  (cl-loop for dir in '(".git/" ".hg/" ".svn/")
           when (locate-dominating-file default-directory dir)
           return it))

;;;###autoload
(defun helm-ag-project-root ()
  (interactive)
  (let ((rootdir (helm-ag--project-root)))
    (unless rootdir
      (error "Could not find the project root. Create a git, hg, or svn repository there first. "))
    (helm-ag rootdir)))

;;;###autoload
(defun helm-do-ag-project-root ()
  (interactive)
  (let ((rootdir (helm-ag--project-root)))
    (unless rootdir
      (error "Could not find the project root. Create a git, hg, or svn repository there first. "))
    (helm-do-ag rootdir)))

;;;###autoload
(defun helm-ag-buffers ()
  (interactive)
  (let ((helm-ag--buffer-search t))
    (helm-ag)))

;;;###autoload
(defun helm-do-ag-buffers ()
  (interactive)
  (let ((helm-ag--buffer-search t))
    (helm-do-ag)))

(provide 'helm-ag)

;;; helm-ag.el ends here
