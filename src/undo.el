(global-undo-tree-mode 1)

(defalias 'redo 'undo-tree-redo)

(global-set-key (kbd "s-z") 'undo)
(global-set-key (kbd "s-Z") 'redo)
(global-set-key (kbd "<C-s-268632090>") 'undo-tree-visualize)

