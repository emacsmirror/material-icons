;;; material-icons.el --- Material Icon Theme integration -*- lexical-binding: t -*-

;; Copyright (C) 2026 Daniu Zhao

;; Author: Daniu Zhao <zhaodaniu1@gmail.com>
;; Assisted-by: DeepSeek:DeepSeek-v4-pro
;; Homepage: https://github.com/zHaOdANiuu/material-icons.el
;; Version: 0.0.1
;; Package-Requires: ((emacs "27.1"))
;; Keywords: convenience, icons, svg, theme

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

;; Material Icon Theme integration for Emacs.  Provides SVG file-type
;; and folder-type icons in Dired, Ibuffer, and Speedbar buffers.
;; Icons are derived from the Material Icon Theme for VS Code.

;; Usage:
;;
;;   M-x material-icons-dired-icons-mode      — icons in the current Dired buffer
;;   M-x material-icons-ibuffer-icons-mode    — icons in Ibuffer
;;   M-x material-icons-speedbar-icons-mode   — icons globally in Speedbar
;;

;;; Code:

(require 'material-icons-core)
(require 'material-icons-dired)
(require 'material-icons-ibuffer)
(require 'material-icons-speedbar)

(provide 'material-icons)
;;; material-icons.el ends here
