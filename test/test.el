;;; -*- lexical-binding: t -*-
(require 'material-icons)
(add-hook 'dired-mode-hook #'material-icons-dired-icons-mode)
(add-hook 'ibuffer-mode-hook  #'material-icons-ibuffer-icons-mode)
(with-eval-after-load 'speedbar
  (material-icons-speedbar-icons-mode 1))
(setq material-icons-size 22)

(dired "~/.emacs.d")
(ibuffer-jump "~/.emacs.d")
(speedbar "~/.emacs.d")
