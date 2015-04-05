My emacs files

Just checkout with

```
git clone https://github.com/rafadc/emacs.d .emacs.d
```

Also it is a good idea to add **personal_notes.org** to global gitignore.

# Features

- M-x overridden to autocomplete
- Using guide key to bring help to all keybindings. Just press a keybinging to wait foll all possible completions.
- git-timemachine to navigate through history

# Cheatsheet

## Navigation

- **C-TAB**: Open tree explorer
- **C-x-p**: Next window
- **C-x-o**: Previous window

## Managing text

- **M-down**: Move current line down
- **M-up**: Move current line up
- **s-e**: Expand region
- **s-d**: Mark next like selection
- **H-SPC**: Rectangle selection
- **C-c C-e**: Evals the expression and replaces with the result

## Finding files

- **C-p** : Find files in project
- **s-F** : Search in contents using ag

## Git

- **F6**: Git status
- **s-F6**: Git time machine

## Org mode

- **F7**: Opens a file called *personal_notes.org* in the root folder of projectile folder. I use it for quick notes and brainstorming.

## Other

- **C-c o** : Open in external editor
