;;; material-icon-utils.el --- Icon utility functions -*- lexical-binding: t -*-

;; Copyright (C) 2026 Daniu Zhao

;; Author: Daniu Zhao <zhaodaniu1@gmail.com>
;; Assisted-by: DeepSeek:DeepSeek-v4-pro
;; Homepage: https://github.com/zHaOdANiuu/material-icon.el
;; Version: 0.0.1
;; Keywords: convenience, icons, svg

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

;; Shared utilities for material-icon: icon resolution, file/folder lookup
;; tables, and SVG image creation with caching.  Also provides the core
;; hash-table-backed lookup tables built from the large mapping alists
;; in `material-file-map' and `material-folder-map'.

;;; Code:

(require 'material-icon-file-map)
(require 'material-icon-folder-map)

(defconst material-icon-directory
  (expand-file-name "icons" (file-name-directory (or load-file-name buffer-file-name)))
  "Directory containing SVG icon files.")

(defconst material-icon-fallback-file "file.svg"
  "Fallback icon filename for regular files (shown when no mapping matches).")

(defconst material-icon-fallback-folder "folder.svg"
  "Fallback icon filename for directories (shown when no mapping matches).")

(defvar material-icon-size (frame-char-height)
  "Icon size in pixels.
Computed from the default font height at load time.
Set to a fixed number to override the automatic value.")

(defvar material-icon-cache (make-hash-table :test 'equal)
  "Cache: \"ICON-PATH/SIZE\" -> image object.
Cleared automatically when `material-icon-size' is changed via
`material-icon-set-icon-size'.")

(defvar material-icon-path-cache (make-hash-table :test 'equal)
  "Cache: ICON-NAME -> resolved absolute SVG file path.")

(defmacro material-icon--alist-to-table (alist test)
  "Build a hash table from ALIST using TEST as the `:test' function.
Each cons cell (KEY . VALUE) in ALIST becomes one hash-table entry.
Returns the new hash table."
  `(let ((tab (make-hash-table :test ',test :size (length ,alist))))
     (dolist (pair ,alist)
       (puthash (car pair) (cdr pair) tab))
     tab))

(defvar material-icon-file-icon-table
  (material-icon--alist-to-table material-icon-mappings equal)
  "Hash table: file name/extension -> SVG icon filename.
Built from `material-icon-mappings' at load time.")

(defvar material-icon-folder-icon-table
  (material-icon--alist-to-table material-icon-folder-mappings equal)
  "Hash table: directory name -> SVG icon filename.
Built from `material-icon-folder-mappings' at load time.")

(defun material-icon-set-icon-size (size)
  "Set icon SIZE in pixels and invalidate the image cache."
  (setq material-icon-size size)
  (clrhash material-icon-cache))

(defun material-icon-resolve-icon (icon-name fallback)
  "Resolve ICON-NAME to an existing SVG path under `material-icon-directory'.
If ICON-NAME doesn't exist on disk, return the path for FALLBACK instead.
Results are cached in `material-icon-path-cache' to avoid repeated
filesystem checks."
  (or (gethash icon-name material-icon-path-cache)
      (let* ((path (expand-file-name icon-name material-icon-directory))
             (result (if (file-exists-p path)
                         path
                       (expand-file-name fallback material-icon-directory))))
        (puthash icon-name result material-icon-path-cache)
        result)))

(defun material-icon-get-icon-for-file (filename &optional dir-p)
  "Get the SVG icon path for FILENAME.
When DIR-P is non-nil, treat FILENAME as a directory name without
performing a filesystem directory check.  Returns the fallback icon
path when no matching icon is found."
  (let* ((name (file-name-nondirectory (directory-file-name filename)))
         (ext  (file-name-extension filename))
         (is-dir (or dir-p (file-directory-p filename)))
         (fallback (if is-dir
                       material-icon-fallback-folder
                     material-icon-fallback-file))
         (name-lc (downcase name))
         (icon-name
          (if is-dir
              (or (gethash name-lc material-icon-folder-icon-table) fallback)
            (or (gethash name-lc material-icon-file-icon-table)
                (when ext
                  (gethash (downcase ext) material-icon-file-icon-table))
                fallback))))
    (material-icon-resolve-icon icon-name fallback)))

(defun material-icon-get-icon-for-dir (dirname)
  "Get the SVG icon path for directory DIRNAME.
Looks up DIRNAME in `material-icon-folder-icon-table' and falls back
to `material-icon-fallback-folder' if no specific icon is found."
  (let* ((name (file-name-nondirectory (directory-file-name dirname)))
         (icon-name (or (gethash (downcase name)
                                 material-icon-folder-icon-table)
                        material-icon-fallback-folder)))
    (material-icon-resolve-icon icon-name material-icon-fallback-folder)))

(defun material-icon-create-icon-image (icon-path)
  "Create an SVG image object from ICON-PATH, with caching.
The image is scaled to `material-icon-size'.  Returns nil when
ICON-PATH is nil or when image creation fails."
  (when icon-path
    (let ((key (format "%s/%d" icon-path material-icon-size)))
      (or (gethash key material-icon-cache)
          (let ((img (create-image icon-path 'svg nil
                                   :height material-icon-size
                                   :ascent 'center)))
            (when img (puthash key img material-icon-cache))
            img)))))

(provide 'material-icon-utils)
;;; material-icon-utils.el ends here
