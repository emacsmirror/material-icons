;;; material-icon-ibuffer.el --- Ibuffer SVG icons -*- lexical-binding: t -*-

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
;; buffer.  Icons are resolved via `material-icon-get-icon-for-file' and
;; `material-icon-get-icon-for-dir', reusing the project's file-map and
;; folder-map — no separate mode enumeration needed.
;; Enable `material-icon-ibuffer-icons-mode' to activate.

;;; Code:

(require 'material-icon-utils)
(require 'ibuffer)

(defgroup material-icon-ibuffer nil
  "Display SVG icons in Ibuffer."
  :group 'material-icon
  :group 'ibuffer)

(defcustom material-icon-ibuffer-icon t
  "Whether to display icons in Ibuffer."
  :group 'material-icon-ibuffer
  :type 'boolean)

(defcustom material-icon-ibuffer-human-readable-size t
  "Use human-readable file size in Ibuffer."
  :group 'material-icon-ibuffer
  :type 'boolean)

(defcustom material-icon-ibuffer-formats
  `((mark modified read-only ,(if (>= emacs-major-version 26) 'locked "")
          " " (icon 2 2)
          (name 18 18 :left :elide)
          " " (size-h 9 -1 :right)
          " " (mode 16 16 :left :elide)
          " " filename-and-process)
    (mark " " (name 16 -1) " " filename))
  "A list of ways to display buffer lines with `material-icon'.
See `ibuffer-formats' for details."
  :group 'material-icon-ibuffer
  :type '(repeat sexp))

(define-ibuffer-column icon
  (:name "" :inline t)
  (if material-icon-ibuffer-icon
      (let* ((buf-file (buffer-file-name))
             (icon-path
              (cond
               ((eq major-mode 'dired-mode)
                (material-icon-get-icon-for-dir (buffer-name)))
               (buf-file
                (material-icon-get-icon-for-file buf-file))
               (t
                (material-icon-get-icon-for-file (buffer-name)))))
             (icon (material-icon-create-icon-image icon-path)))
        (if icon
            (concat (propertize " " 'display icon) " ")
          "  "))
    "  "))

(defun material-icon-ibuffer--file-size-human-readable-to-bytes (file-size &optional flavor)
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

(define-ibuffer-column size-h
  (:name "Size"
   :inline t
   :header-mouse-map ibuffer-size-header-map
   :summarizer
   (lambda (column-strings)
     (let ((total 0))
       (dolist (string column-strings)
         (setq total
               (+ (float (material-icon-ibuffer--file-size-human-readable-to-bytes string))
                  total)))
       (if material-icon-ibuffer-human-readable-size
           (file-size-human-readable total)
         (format "%.0f" total)))))
  (let ((size (buffer-size)))
    (if material-icon-ibuffer-human-readable-size
        (file-size-human-readable size)
      (format "%s" size))))

(defvar material-icon-ibuffer-old-formats ibuffer-formats
  "Saved original `ibuffer-formats' before enabling icon mode.
Restored when `material-icon-ibuffer-icons-mode' is disabled.")

;;;###autoload
(define-minor-mode material-icon-ibuffer-icons-mode
  "Toggle display of SVG icons in the Ibuffer buffer list.
With prefix argument ARG, enable if ARG is positive, disable otherwise.
Icons are resolved from the buffer's file name (or directory name for
dired buffers), reusing the project's file-map and folder-map."
  :lighter nil
  :group 'material-icon
  (when (derived-mode-p 'ibuffer-mode)
    (setq-local ibuffer-formats
                (if material-icon-ibuffer-icons-mode
                    material-icon-ibuffer-formats
                  material-icon-ibuffer-old-formats))
    (ibuffer-update nil t)))

(provide 'material-icon-ibuffer)
;;; material-icon-ibuffer.el ends here
