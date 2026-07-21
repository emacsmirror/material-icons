;;; material-icons-core.el --- Icon core functions -*- lexical-binding: t; package-lint-main-file: "material-icons.el"; -*-

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

;; Shared utilities for material-icons: icon resolution, file/folder lookup
;; tables, and SVG image creation with caching.  Also provides the core
;; hash-table-backed lookup tables built from the large mapping alists
;; in `material-file-map' and `material-folder-map'.

;;; Code:

(require 'material-icons-file-map)
(require 'material-icons-folder-map)

(defmacro material-icons--alist-to-table (alist test)
  "Build a hash table from ALIST using TEST as the `:test' function.
Each cons cell (KEY . VALUE) in ALIST becomes one hash-table entry.
Returns the new hash table."
  `(let ((tab (make-hash-table :test ',test :size (length ,alist))))
     (dolist (pair ,alist)
       (puthash (car pair) (cdr pair) tab))
     tab))

(defvar material-icons-size (frame-char-height)
  "Icon size in pixels.
Computed from the default font height at load time.
Set to a fixed number to override the automatic value.")

(defvar material-icons-cache (make-hash-table :test 'equal)
  "Cache: \"ICON-PATH/SIZE\" -> image object.
Cleared automatically when `material-icons-size' is changed via
`material-icons-set-icon-size'.")

(defvar material-icons-path-cache (make-hash-table :test 'equal)
  "Cache: ICON-NAME -> resolved absolute SVG file path.")

(defvar material-icons-file-icon-table
  (material-icons--alist-to-table material-icons-mappings equal)
  "Hash table: file name/extension -> SVG icon filename.
Built from `material-icons-mappings' at load time.")

(defvar material-icons-folder-icon-table
  (material-icons--alist-to-table material-icons-folder-mappings equal)
  "Hash table: directory name -> SVG icon filename.
Built from `material-icons-folder-mappings' at load time.")

(defconst material-icons-directory
  (expand-file-name "icons" (file-name-directory (or load-file-name buffer-file-name)))
  "Directory containing SVG icon files.")

(defconst material-icons-fallback-file "file.svg"
  "Fallback icon filename for regular files (shown when no mapping matches).")

(defconst material-icons-fallback-folder "folder.svg"
  "Fallback icon filename for directories (shown when no mapping matches).")

(defgroup material-icons nil
  "Material Icon Theme: SVG file-type icons for Dired, Ibuffer, and Speedbar."
  :prefix "material-icons-"
  :group 'convenience)

(defun material-icons-set-icon-size (size)
  "Set icon SIZE in pixels and invalidate the image cache."
  (setq material-icons-size size)
  (clrhash material-icons-cache))

(defun material-icons-resolve-icon (icon-name fallback)
  "Resolve ICON-NAME to an existing SVG path under `material-icons-directory'.
If ICON-NAME doesn't exist on disk, return the path for FALLBACK instead.
Results are cached in `material-icons-path-cache' to avoid repeated
filesystem checks."
  (or (gethash icon-name material-icons-path-cache)
      (let* ((path (expand-file-name icon-name material-icons-directory))
             (result (if (file-exists-p path)
                         path
                       (expand-file-name fallback material-icons-directory))))
        (puthash icon-name result material-icons-path-cache)
        result)))

(defun material-icons-get-icon-for-file (filename &optional dir-p)
  "Get the SVG icon path for FILENAME.
When DIR-P is non-nil, treat FILENAME as a directory name without
performing a filesystem directory check.  Returns the fallback icon
path when no matching icon is found."
  (let* ((ext (file-name-extension filename))
         (is-dir (or dir-p (file-directory-p filename)))
         (fallback (if is-dir
                       material-icons-fallback-folder
                     material-icons-fallback-file))
         (name-lc (downcase (file-name-nondirectory
                             (directory-file-name filename))))
         (icon-name
          (if is-dir
              (or (gethash name-lc material-icons-folder-icon-table) fallback)
            (or (gethash name-lc material-icons-file-icon-table)
                (when ext
                  (gethash (downcase ext) material-icons-file-icon-table))
                fallback))))
    (material-icons-resolve-icon icon-name fallback)))

(defun material-icons-get-icon-for-dir (dirname)
  "Get the SVG icon path for directory DIRNAME.
Looks up DIRNAME in `material-icons-folder-icon-table' and falls back
to `material-icons-fallback-folder' if no specific icon is found."
  (let* ((icon-name (or (gethash
                         (downcase
                          (file-name-nondirectory (directory-file-name dirname)))
                         material-icons-folder-icon-table)
                        material-icons-fallback-folder)))
    (material-icons-resolve-icon icon-name material-icons-fallback-folder)))

(defun material-icons-create-icon-image (icon-path)
  "Create an SVG image object from ICON-PATH, with caching.
The image is scaled to `material-icons-size'.  Returns nil when
ICON-PATH is nil or when image creation fails."
  (when icon-path
    (let ((key (format "%s/%d" icon-path material-icons-size)))
      (or (gethash key material-icons-cache)
          (let ((img (create-image
                      icon-path 'svg nil
                      :height material-icons-size
                      :ascent 'center)))
            (when img (puthash key img material-icons-cache))
            img)))))

(let ((dir (file-name-directory load-file-name)))
  (unless (file-exists-p (expand-file-name "icons" dir))
    (let ((default-directory dir))
      (shell-command "tar -xzf icons.tar.gz"))))

(provide 'material-icons-core)
;;; material-icons-core.el ends here
