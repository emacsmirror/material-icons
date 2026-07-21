;;; material-icons-dired.el --- Dired SVG icons -*- lexical-binding: t; package-lint-main-file: "material-icons.el"; -*-

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

;; Integrates SVG file-type icons into Dired buffers.  Enable the minor
;; mode `material-icons-dired-icons-mode' to display an icon before each file
;; or directory entry.

;;; Code:

(require 'material-icons-core)
(require 'dired)

;;;###autoload
(defun material-icons-dired-add-icons ()
  "Insert SVG icons before each file name in the current Dired buffer.
Icons are added as text-property `display' values.  Skips \".\" and
\"..\" entries, inserting a thin space instead."
  (let ((inhibit-read-only t)
        (space `(space :width ,(* material-icons-size 0.1))))
    (save-excursion
      (goto-char (point-min))
      (while (not (eobp))
        (when (dired-move-to-filename nil)
          (when-let* ((file (dired-get-filename 'relative 'noerror)))
            (let ((start (1- (point))))
              (if (member file '("." ".."))
                  (put-text-property start (point) 'display space)
                (let* ((dir-p (string-suffix-p "/" file))
                       (icon-path (if dir-p
                                      (material-icons-get-icon-for-dir file)
                                    (material-icons-get-icon-for-file file dir-p)))
                       (icon (material-icons-create-icon-image icon-path)))
                  (when icon (put-text-property start (point) 'display icon)))))))
        (forward-line 1)))))

;;;###autoload
(define-minor-mode material-icons-dired-icons-mode
  "Toggle display of SVG file-type icons in the current Dired buffer.

With prefix argument ARG, enable if ARG is positive, disable otherwise.
Icons update automatically after `dired-after-readin-hook'."
  :lighter " mat-icons"
  :group 'material-icons
  (if material-icons-dired-icons-mode
      (progn
        (material-icons-dired-add-icons)
        (add-hook 'dired-after-readin-hook #'material-icons-dired-add-icons nil t))
    (remove-hook 'dired-after-readin-hook #'material-icons-dired-add-icons t)
    (revert-buffer)))

(provide 'material-icons-dired)
;;; material-icons-dired.el ends here
