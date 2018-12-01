;;; gif-me.el --- Just some random gif fun

;;; Commentary:

;;; A weird package to have fun with gif files.  Just a toy

;;; Code:
(require 'json)
(require 'url)

(defun get-json (url)
  "Retrieves a json from a given URL."
  (let ((buffer (url-retrieve-synchronously url))
        (json nil))
    (with-current-buffer buffer
      (goto-char (point-min))
      (re-search-forward "^$" nil 'move)
      (setq json (buffer-substring-no-properties (point) (point-max)))
      (kill-buffer (current-buffer)))
    (json-read-from-string json)))

(defun get-gifs (query)
  "Retrieves giffy JSON object."
  (get-json (concat "http://api.giphy.com/v1/gifs/search?q=" query "&api_key=dc6zaTOxFJmzC")))

(defun get-one-gif (query)
  "Retrieves only one gif url from Giffy."
  (let* ((json-gif-info (get-gifs query))
         (gif-list (cdr (assoc 'data json-gif-info)))
         (first-gif-data (aref gif-list 1))
         (gif-urls-data (cdr (assoc 'images first-gif-data)))
         (gif-original-data (cdr (assoc 'original gif-urls-data))))
    (cdr (assoc 'url gif-original-data))))

(defun gif-me-love (query)
  "Add a loving Gif in current buffer."
  (interactive "sTheme for the gif: ")
  (let ((buffer (url-retrieve-synchronously (get-one-gif "love"))))
    (unwind-protect
         (let* ((data (with-current-buffer buffer
                       (goto-char (point-min))
                       (search-forward "\n\n")
                       (buffer-substring (point) (point-max))))
                (image (create-image data nil t)))
           (insert-image image)
           (image-animate image 0 t))
      (kill-buffer buffer))))

(provide 'gif-me)
;;; gif-me ends here
