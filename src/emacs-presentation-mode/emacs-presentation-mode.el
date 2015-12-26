(setq emacs-presentation-highlights
      '(("^#.*" . font-lock-function-name-face)))

(define-derived-mode emacs-presentation-mode fundamental-mode
  (setq font-lock-defaults '(emacs-presentation-highlights))
  (setq mode-name "emacs presentation"))

(add-to-list 'auto-mode-alist '("\\.ep\\'" . emacs-presentation-mode))

(defun slides ()
  "Gets the slides from the buffer text"
  (let* ((slide-texts (split-string (buffer-string) "\n#")))
    (mapcar 'slide-from-text slide-texts)))

(defun slide-from-text (text)
  "Builds a slide based on the text"
  '((:title . (car (split-string text "\n")))))

(defun buffer-from-slide (slide-definition)
  "Creates a buffer from a slide definition"
  (generate-new-buffer (assoc :title slide-definition)))

(defun start-emacs-presentation ()
  "Closes all buffers and starts the presentation"
  (interactive)
  (mapcar 'buffer-from-slide (slides)))

(defun emacs-presentation-keybindings ()
  "Keymaps for emacs presentation mode"
  (local-set-key (kbd "C-c C-c") 'start-emacs-presentation))

(add-hook 'emacs-presentation-mode-hook 'emacs-presentation-keybindings)

(provide 'emacs-presentation-mode)
