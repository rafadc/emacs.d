;; Copy code as RTF to the clipboard. This is commonly used for 
;; presentations in keynote or such

(defun copy-as-rtf (start end)
  (interactive "r")
  (let* (
	(temp-file (make-temp-file "copy-as-rtf"))
	(file-format (file-name-extension (buffer-file-name)))
	(selected-text (buffer-substring start end))
	(command (concat "highlight --out-format=rtf --src-lang " file-format " -i " temp-file " | pbcopy "))
	)
    (append-to-file start end temp-file)
    (shell-command command)
    (message "RTF copied to clipboard")))
    
