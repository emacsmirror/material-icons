;;; entry.el --- Entry point for testing material-icon  -*- lexical-binding: t; -*-

(require 'material-icon)
(add-hook 'dired-mode-hook    #'material-icon-dired-icons-mode)
(add-hook 'ibuffer-mode-hook  #'material-icon-ibuffer-icons-mode)
(add-hook 'speedbar-mode-hook #'material-icon-speedbar-icons-mode)
(material-icon-set-icon-size 22)

(dired "~/.emacs.d")
(speedbar "~/.emacs.d")
(ibuffer)

(provide 'entry)
;;; entry.el ends here
