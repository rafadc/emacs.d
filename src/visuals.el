;; Base16 theme
(load-file "~/.emacs.d/themes/base16-emacs/base16-default-theme.el")

;; Disable menu and icon bar
(menu-bar-mode -1)
(tool-bar-mode -1)

;; Show line numbers
(global-linum-mode t)

;; Paren highlight
(show-paren-mode 1)
(setq show-paren-delay 0)

;; Font
(set-face-attribute 'default nil
                    :family "M+ 2m" :height 180 :weight 'light)
