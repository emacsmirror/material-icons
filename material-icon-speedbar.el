;;; material-icon-speedbar.el --- Speedbar SVG icons -*- lexical-binding: t -*-

;; Copyright (C) 2026 Daniu Zhao

;; Author: Daniu Zhao <zhaodaniu1@gmail.com>

;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; Integrates SVG file-type icons into Speedbar.  Enable the global
;; minor mode `material-icon-speedbar-icons-mode' to show an icon before
;; each file or directory entry in the Speedbar frame.

;;; Code:

(require 'speedbar)
(require 'material-icon-utils)

(defun material-icon-speedbar-icons--add (orig-fn &rest args)
  "Around advice: replace expand-button with SVG icon in Speedbar lines.
ORIG-FN is `speedbar-make-tag-line', ARGS are its arguments.
The icon is stored in text property `material-icon-speedbar--icon' for
reapplication after expand-button changes."
  (let ((face (nth 7 args))
        (tag (nth 4 args))
        icon)
    (cond
     ((eq face 'speedbar-directory-face)
      (setq icon (material-icon-create-icon-image (material-icon-get-icon-for-dir tag))))
     ((eq face 'speedbar-file-face)
      (setq icon (material-icon-create-icon-image (material-icon-get-icon-for-file tag)))))
    (apply orig-fn args)
    (when icon
      (save-excursion
        (forward-line -1)
        (when (re-search-forward "\\([\\[{<]\\)\\([.?+-]\\)\\([]}>]\\)"
                                 (line-end-position) t)
          (let ((inhibit-read-only t))
            (put-text-property (match-beginning 1) (match-end 1) 'display '(space :width 0))
            (put-text-property (match-beginning 2) (match-end 2) 'display icon)
            (put-text-property (match-beginning 3) (match-end 3) 'display '(space :width 0))
            (put-text-property (match-beginning 0) (match-end 0)
                               'material-icon-speedbar--icon icon)))))))

(defun material-icon-speedbar-icons--update (orig-fn &rest args)
  "Around advice: reapply the icon after expand-button toggles.
ORIG-FN is `speedbar-change-expand-button-char', ARGS are its arguments.
Finds the `material-icon-speedbar--icon' text property on the line
and re-displays the icon after the expand-button state changes."
  (let ((icon (get-text-property (point) 'material-icon-speedbar--icon)))
    (unless icon
      (when-let* ((pos (text-property-not-all (line-beginning-position)
                                              (line-end-position)
                                              'material-icon-speedbar--icon nil)))
        (setq icon (get-text-property pos 'material-icon-speedbar--icon))))
    (apply orig-fn args)
    (when icon
      (let ((inhibit-read-only t)
            (start (1- (point)))
            (end (+ (point) 2)))
        (put-text-property start (1+ start) 'display '(space :width 0))
        (put-text-property (point) (1+ (point)) 'display icon)
        (put-text-property (1- end) end 'display '(space :width 0))
        (put-text-property start end 'material-icon-speedbar--icon icon)))))

(defun material-icon-speedbar-icons--enable ()
  "Activate Speedbar icon advices.
Installs around-advice on `speedbar-make-tag-line' and
`speedbar-change-expand-button-char'."
  (advice-add 'speedbar-make-tag-line :around #'material-icon-speedbar-icons--add)
  (advice-add 'speedbar-change-expand-button-char :around #'material-icon-speedbar-icons--update))

(defun material-icon-speedbar-icons--disable ()
  "Remove Speedbar icon advices.
Undoes the effect of `material-icon-speedbar-icons--enable'."
  (advice-remove 'speedbar-make-tag-line #'material-icon-speedbar-icons--add)
  (advice-remove 'speedbar-change-expand-button-char #'material-icon-speedbar-icons--update))

;;;###autoload
(define-minor-mode material-icon-speedbar-icons-mode
  "Toggle display of SVG icons in Speedbar.
With prefix argument ARG, enable if ARG is positive, disable otherwise.
This is a global minor mode — when enabled, all Speedbar frames show
file-type icons."
  :lighter " mat-ico"
  :global t
  :group 'material-icon
  (if material-icon-speedbar-icons-mode
      (material-icon-speedbar-icons--enable)
    (material-icon-speedbar-icons--disable)))

(provide 'material-icon-speedbar)
;;; material-icon-speedbar.el ends here
