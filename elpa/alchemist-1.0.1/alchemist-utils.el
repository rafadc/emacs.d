;;; alchemist-utils.el ---

;; Copyright © 2014-2015 Samuel Tonini

;; Author: Samuel Tonini <tonini.samuel@gmail.com

;; This file is not part of GNU Emacs.

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program. If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;;; Code:

(require 'ansi-color)

(defvar alchemist-utils--elixir-project-root-indicator
  "mix.exs"
  "The file which indicate an elixir project root.")

(defun alchemist-utils--elixir-project-root ()
  "Finds the root directory of the project.
It walks the directory tree until it finds a elixir project root indicator."
  (let* ((file (file-name-as-directory (expand-file-name default-directory))))
    (locate-dominating-file file alchemist-utils--elixir-project-root-indicator)))

(defun alchemist-utils--flatten (alist)
  (cond ((null alist) nil)
        ((atom alist) (list alist))
        (t (append (alchemist-utils--flatten (car alist))
                   (alchemist-utils--flatten (cdr alist))))))

(defun alchemist-utils--build-runner-cmdlist (command)
  "Build the commands list for the runner."
  (remove "" (alchemist-utils--flatten
              (list (if (stringp command)
                        (split-string command)
                      command)))))

(defun alchemist-utils--clear-search-text (search-text)
  (let* ((search-text (replace-regexp-in-string  "\\.$" "" search-text))
         (search-text (replace-regexp-in-string  "^\\.$" "" search-text))
         (search-text (replace-regexp-in-string  ",$" "" search-text))
         (search-text (replace-regexp-in-string  "^,$" "" search-text)))
    search-text))

(defun alchemist-utils--erase-buffer (buffer)
  "Use `erase-buffer' inside BUFFER."
  (with-current-buffer buffer
    (erase-buffer)))

(defun alchemist-utils--get-buffer-content (buffer)
  "Return the content of BUFFER."
  (with-current-buffer buffer
    (buffer-substring (point-min) (point-max))))

(defun alchemist--utils-clear-ansi-sequences (string)
  "Clear STRING from all ansi escape sequences."
  (ansi-color-filter-apply string))

(defun alchemist-utils--remove-newline-at-end (string)
  (replace-regexp-in-string "\n$" "" string))

(defun alchemist-utils--count-char-in-str (regexp str)
  (loop with start = 0
        for count from 0
        while (string-match regexp str start)
        do (setq start (match-end 0))
        finally return count))

(defun alchemist-utils--is-test-file-p ()
  "Check wether the visited file is a test file."
  (string-match "_test\.exs$" (or (buffer-file-name) "")))

(defun alchemist-utils--empty-string-p (string)
  (or (null string)
      (let* ((string (replace-regexp-in-string "^\s+" "" string ))
             (string (replace-regexp-in-string "\s+$" "" string)))
        (string= string ""))))

(provide 'alchemist-utils)

;;; alchemist-utils.el ends here
