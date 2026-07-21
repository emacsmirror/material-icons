;;; material-icons-ibuffer.el --- Ibuffer SVG icons -*- lexical-binding: t; package-lint-main-file: "material-icons.el"; -*-

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

;; Adds an SVG icon column to Ibuffer, showing a file-type icon for each
;; buffer.  Icons are resolved via `material-icons-get-icon-for-file' and
;; `material-icons-get-icon-for-dir', reusing the project's file-map and
;; folder-map — no separate mode enumeration needed.
;; Enable `material-icons-ibuffer-icons-mode' to activate.

;;; Code:

(require 'material-icons-core)
(require 'ibuffer)

(defvar material-icons-ibuffer-old-formats ibuffer-formats
  "Saved original `ibuffer-formats' before enabling icon mode.
Restored when `material-icons-ibuffer-icons-mode' is disabled.")

(defgroup material-icons-ibuffer nil
  "Display SVG icons in Ibuffer."
  :group 'material-icons
  :group 'ibuffer)

(defcustom material-icons-ibuffer-icon t
  "Whether to display icons in Ibuffer."
  :group 'material-icons-ibuffer
  :type 'boolean)

(defcustom material-icons-ibuffer-human-readable-size t
  "Use human-readable file size in Ibuffer."
  :group 'material-icons-ibuffer
  :type 'boolean)

(defcustom material-icons-ibuffer-formats
  `((mark modified read-only ,(if (>= emacs-major-version 26) 'locked "")
     " " (icon 2 2)
     (name 18 18 :left :elide)
     " " (size-h 9 -1 :right)
     " " (mode 16 16 :left :elide)
     " " filename-and-process)
    (mark " " (name 16 -1) " " filename))
  "A list of ways to display buffer lines with `material-icons'.
See `ibuffer-formats' for details."
  :group 'material-icons-ibuffer
  :type '(repeat sexp))

(defun material-icons-ibuffer--file-size-human-readable-to-bytes (file-size &optional flavor)
  "Convert a human-readable FILE-SIZE string into bytes with FLAVOR."
  (let ((power (if (or (null flavor) (eq flavor 'iec))
                   1024.0
                 1000.0))
        (prefixes '("k" "M" "G" "T" "P" "E" "Z" "Y"))
        (iterator 0))
    (catch 'bytes
      (while
          (cond
           ((equal iterator 8)
            (throw 'bytes (* (string-to-number file-size) (expt power 0))))
           ((string-match (elt prefixes iterator) file-size)
            (throw 'bytes (* (string-to-number file-size) (expt power (1+ iterator)))))
           (t
            (setq iterator (1+ iterator))))))))

(define-ibuffer-column icon
  (:name "" :inline t)
  (if material-icons-ibuffer-icon
      (let* ((buf-file (buffer-file-name))
             (icon-path
              (cond
               ((eq major-mode 'dired-mode)
                (material-icons-get-icon-for-dir (buffer-name)))
               (buf-file
                (material-icons-get-icon-for-file buf-file))
               (t
                (material-icons-get-icon-for-file (buffer-name)))))
             (icon (material-icons-create-icon-image icon-path)))
        (if icon
            (concat (propertize " " 'display icon) " ")
          "  "))
    "  "))

(define-ibuffer-column size-h
  (:name "Size"
   :inline t
   :header-mouse-map ibuffer-size-header-map
   :summarizer
   (lambda (column-strings)
     (let ((total 0))
       (dolist (string column-strings)
         (setq total
               (+ (float (material-icons-ibuffer--file-size-human-readable-to-bytes string))
                  total)))
       (if material-icons-ibuffer-human-readable-size
           (file-size-human-readable total)
         (format "%.0f" total)))))
  (let ((size (buffer-size)))
    (if material-icons-ibuffer-human-readable-size
        (file-size-human-readable size)
      (format "%s" size))))

;;;###autoload
(define-minor-mode material-icons-ibuffer-icons-mode
  "Toggle display of SVG icons in the Ibuffer buffer list.
With prefix argument ARG, enable if ARG is positive, disable otherwise.
Icons are resolved from the buffer's file name (or directory name for
Dired buffers), reusing the project's file-map and folder-map."
  :lighter nil
  :group 'material-icons
  (when (derived-mode-p 'ibuffer-mode)
    (setq-local ibuffer-formats
                (if material-icons-ibuffer-icons-mode
                    material-icons-ibuffer-formats
                  material-icons-ibuffer-old-formats))
    (ibuffer-update nil t)))

(provide 'material-icons-ibuffer)
;;; material-icons-ibuffer.el ends here
