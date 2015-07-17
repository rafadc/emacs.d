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

(require 'cl-lib)
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
  (cl-remove "" (alchemist-utils--flatten
                 (list (if (stringp command)
                           (split-string command)
                         command)))))

(defun alchemist-utils--clear-search-text (search-text)
  (let* ((search-text (alchemist-utils--remove-dot-at-the-end search-text))
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
  (cl-loop with start = 0
           for count from 0
           while (string-match regexp str start)
           do (setq start (match-end 0))
           finally return count))

(defun alchemist-utils--is-test-file-p ()
  "Check wether the visited file is a test file."
  (string-match "_test\.exs$" (or (buffer-file-name) "")))

(defun alchemist-utils--remove-dot-at-the-end (string)
  (replace-regexp-in-string "\\.$" "" string))

(defun alchemist-utils--empty-string-p (string)
  (or (null string)
      (let* ((string (replace-regexp-in-string "^\s+" "" string ))
             (string (replace-regexp-in-string "\s+$" "" string)))
        (string= string ""))))

(defun alchemist-utils--prepare-aliases-for-elixir (aliases)
  (let* ((aliases (mapcar (lambda (a)
                            (let ((module (alchemist-utils--remove-dot-at-the-end (car a)))
                                  (alias (alchemist-utils--remove-dot-at-the-end (car (cdr a)))))
                            (if (not (or (alchemist-utils--empty-string-p alias)
                                         (string= alias module)))
                                (format "{%s, %s}"
                                        (if (alchemist-utils--empty-string-p alias)
                                            module
                                          alias)
                                        module)))) aliases))
         (aliases (mapconcat #'identity aliases ",")))
    (format "[%s]" aliases)))

(defun alchemist-utils--prepare-modules-for-elixir (modules)
  (let* ((modules (mapconcat #'identity modules ",")))
    (format "[%s]" modules)))

(defun alchemist-utils--snakecase-to-camelcase (str)
  "Convert a snake_case string `STR' to a CamelCase string.

This function is useful for converting file names like my_module to Elixir
module names (MyModule)."
  (mapconcat 'capitalize (split-string str "_") ""))

(defun alchemist-utils--add-ext-to-path-if-not-present (path ext)
  "Add `EXT' to `PATH' if `PATH' doesn't already ends with `EXT'."
  (if (string-suffix-p ext path)
      path
    (concat path ext)))

(defun alchemist-utils--path-to-module-name (path)
  "Convert `PATH' to its Elixir module name equivalent.

For example, convert 'my_app/my_module.ex' to 'MyApp.MyModule'."
  (let* ((path (file-name-sans-extension path))
         (path (split-string path "/"))
         (path (cl-remove-if (lambda (str) (equal str "")) path)))
    (mapconcat #'alchemist-utils--snakecase-to-camelcase path ".")))

(defun alchemist-utils--add-trailing-slash (path)
  (if (not (string-match-p "/$" path))
      (format "%s/" path)
    path))

(provide 'alchemist-utils)

;;; alchemist-utils.el ends here
