;;; copy-rtf.el --- Copies code as RTF

;; Copy code as RTF to the clipboard. This is commonly used for
;; presentations in keynote or such
;;
;; This is compatible only with MacOSX
;;
;; You need to first: brew install highlight
;;
;; To change theme you just need to
;; (setq copy-as-rtf-theme "theme")
;;
;; Themes are: andes, breeze, candy, fine-blue, matrix, moria, seashell
;;             vampire, zellner, zenburn

(setq copy-as-rtf-theme "zenburn")

(defun copy-as-rtf (start end)
  (interactive "r")
  (copy-as "rtf" start end ""))

(defun copy-as-html (start end)
  (interactive "r")
  (copy-as "html" start end "--include-style"))

(defun copy-as (format start end extra-options)
  (let* (
	(temp-file (make-temp-file "copy-as-rtf"))
	(file-format (file-name-extension (buffer-file-name)))
	(selected-text (buffer-substring start end))
	(common-options (concat "--out-format=" format " --src-lang " file-format " --style " copy-as-rtf-theme " "))
	(command (concat "highlight " common-options extra-options " -i " temp-file " | pbcopy "))
	)
    (append-to-file start end temp-file)
    (shell-command command)
    (deactivate-mark)
    (message "RTF copied to clipboard")))

(provide 'copy-rtf)

;;; copy-rtf.el ends here
