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
                    :family "M+ 1m" :height 180 :weight 'light)

;; Smoother scrolling with mouse
(setq mouse-wheel-follow-mouse 't)
(setq mouse-wheel-scroll-amount '(1 ((shift) . 1)))

;; Scrolling with keyboard before touching bottom
(setq redisplay-dont-pause t
      scroll-margin 1
      scroll-step 1
      scroll-conservatively 10000
      scroll-preserve-screen-position 1)
