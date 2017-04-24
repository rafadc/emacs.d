(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(coffee-tab-width 2)
 '(custom-enabled-themes (quote (smart-mode-line-dark)))
 '(custom-safe-themes
   (quote
    ("a802c77b818597cc90e10d56e5b66945c57776f036482a033866f5f506257bca" "135bbd2e531f067ed6a25287a47e490ea5ae40b7008211c70385022dbab3ab2a" "3c83b3676d796422704082049fc38b6966bcad960f896669dfc21a7a37a748fa" "756597b162f1be60a12dbd52bab71d40d6a2845a3e3c2584c6573ee9c332a66e" "6a37be365d1d95fad2f4d185e51928c789ef7a4ccf17e7ca13ad63a8bf5b922f" default)))
 '(elfeed-feeds
   (quote
    ("http://nullprogram.com/feed/"
     ("http://feeds.feedburner.com/codinghorror" programming)
     ("http://www.toptal.com/blog.rss" programming)
     ("http://xkcd.com/rss.xml" webcomic)
     ("http://sachachua.com/blog/feed/" emacs))))
 '(magit-push-arguments (quote ("--set-upstream")))
 '(magit-rebase-arguments (quote ("--autosquash" "--autostash")))
 '(org-agenda-files (quote ("~/Dropbox/org/index.org")))
 '(package-selected-packages
   (quote
    (golden-ratio ob-restclient restclient moe-theme spotify org-ref counsel-projectile counsel magithub org-mobile git-gutter-fringe raml-mode color-theme-sanityinc-tomorrow eyebrowse tide salt-mode hyde highlight-indentation company creamsody-theme vue-mode sourcerer-theme esup ensime markdown-mode org-gcal calfw helm-spotify elfeed-org rust-mode ruby-refactor emmet-mode yaml-mode htmlize jump-char tabbar-ruler tabbar smart-mode-line-powerline-theme telephone-line org org-plus-contrib org-capture yasnippet yafolding web-mode use-package unicode-fonts undo-tree tle smooth-scrolling smart-mode-line slim-mode scss-mode rvm ruby-tools ruby-end ruby-compilation ruby-block rubocop robe request-deferred rainbow-delimiters projectile-rails phi-search org-bullets nyan-mode nrepl neotree multiple-cursors move-text markdown-toc magit kv keyfreq js2-mode hlinum haskell-mode haml-mode guide-key go-mode github-browse-file git-timemachine git-gutter gh flymake-ruby flymake-jslint flymake-cursor flycheck find-file-in-project expand-region exec-path-from-shell elm-mode elixir-mix elfeed dockerfile-mode docker cyberpunk-theme company-go color-theme coffee-mode closure-lint-mode clojurescript-mode clojure-test-mode avy alchemist ac-cider-compliment))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(require 'package)
(add-to-list 'package-archives
             '("melpa" . "http://melpa.org/packages/") t)
(add-to-list 'package-archives
	     '("marmalade" .
	       "http://marmalade-repo.org/packages/"))

(setq package-enable-at-startup nil)

(package-initialize)

(setq initial-scratch-message "\;; Beware of the emacs church

")

(require 'ob-tangle)
(require 'org)
(org-babel-load-file
 (expand-file-name "settings.org"
                   user-emacs-directory))
