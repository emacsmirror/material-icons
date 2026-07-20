;;; material-icon-ibuffer.el --- Ibuffer SVG icons -*- lexical-binding: t -*-

;; Copyright (C) 2026 Daniu Zhao

;; Author: Daniu Zhao <zhaodaniu1@gmail.com>
;; Assisted-by: DeepSeek:DeepSeek-v4-pro
;; Homepage: https://github.com/zHaOdANiuu/material-icon.el
;; Version: 0.0.1
;; Keywords: convenience, buffers, icons

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

;; Adds an SVG icon column to Ibuffer, showing a mode-appropriate icon
;; for each buffer.  Enable `material-icon-ibuffer-icons-mode' to activate.

;;; Code:

(require 'material-icon-utils)
(require 'ibuffer)

(defvar material-icon-ibuffer--mode-icon-table
  (let ((tab (make-hash-table :test 'eq :size 60))
        (modes
         '(("python.svg"     python-mode)
           ("rust.svg"       rust-mode)
           ("go.svg"         go-mode)
           ("java.svg"       java-mode)
           ("javascript.svg" javascript-mode js-mode)
           ("typescript.svg" typescript-mode ts-mode)
           ("c.svg"          c-mode c-ts-mode)
           ("cpp.svg"        c++-mode c++-ts-mode)
           ("csharp.svg"     csharp-mode)
           ("ruby.svg"       ruby-mode)
           ("php.svg"        php-mode)
           ("swift.svg"      swift-mode)
           ("kotlin.svg"     kotlin-mode)
           ("scala.svg"      scala-mode)
           ("haskell.svg"    haskell-mode)
           ("erlang.svg"     erlang-mode)
           ("elixir.svg"     elixir-mode)
           ("clojure.svg"    clojure-mode)
           ("lisp.svg"       lisp-mode)
           ("emacs.svg"      emacs-lisp-mode)
           ("scheme.svg"     scheme-mode)
           ("racket.svg"     racket-mode)
           ("lua.svg"        lua-mode)
           ("perl.svg"       perl-mode)
           ("r.svg"          r-mode)
           ("julia.svg"      julia-mode)
           ("matlab.svg"     matlab-mode)
           ("sql.svg"        sql-mode)
           ("html.svg"       html-mode)
           ("css.svg"        css-mode)
           ("sass.svg"       scss-mode)
           ("less.svg"       less-mode)
           ("json.svg"       json-mode)
           ("yaml.svg"       yaml-mode)
           ("xml.svg"        xml-mode)
           ("markdown.svg"   markdown-mode)
           ("org.svg"        org-mode)
           ("tex.svg"        tex-mode)
           ("latex.svg"      latex-mode)
           ("shell.svg"      sh-mode bash-mode fish-mode)
           ("powershell.svg" powershell-mode)
           ("docker.svg"     dockerfile-mode docker-compose-mode)
           ("makefile.svg"   makefile-mode)
           ("cmake.svg"      cmake-mode)
           ("toml.svg"       toml-mode)
           ("ini.svg"        ini-mode)
           ("settings.svg"   conf-mode)
           ("folder.svg"     dired-mode)
           ("git.svg"        magit-mode git-commit-mode)
           ("diff.svg"       diff-mode)
           ("console.svg"    compilation-mode messages-buffer-mode)
           ("terminal.svg"   term-mode vterm-mode eshell-mode)
           ("help.svg"       help-mode))))
    (dolist (entry modes)
      (let ((icon (car entry)))
        (dolist (mode (cdr entry))
          (puthash mode icon tab))))
    tab)
  "Hash table: major-mode symbol -> SVG icon filename.
Built at load time for O(1) lookup.  Only used by the Ibuffer column.")

(define-ibuffer-column icon
  (:name "" :inline t)
  (let* ((icon-name (or (gethash major-mode material-icon-ibuffer--mode-icon-table)
                        material-icon-fallback-file))
         (icon-path (material-icon-resolve-icon icon-name material-icon-fallback-file))
         (icon (material-icon-create-icon-image icon-path)))
    (if icon
        (concat (propertize " " 'display icon) " ")
      "  ")))

(defvar material-icon-ibuffer-old-formats ibuffer-formats
  "Saved original `ibuffer-formats' before enabling icon mode.
Restored when `material-icon-ibuffer-icons-mode' is disabled.")

(defvar material-icon-ibuffer-formats
  `((mark modified read-only ,(if (>= emacs-major-version 26) 'locked "")
          " " (icon 2 2)
          (name 18 18 :left :elide)
          " " (size 9 -1 :right)
          " " (mode 16 16 :left :elide)
          " " filename-and-process)
    (mark " " (name 16 -1) " " filename))
  "Ibuffer column formats with the SVG icon column prepended.")

;;;###autoload
(define-minor-mode material-icon-ibuffer-icons-mode
  "Toggle display of SVG mode icons in the Ibuffer buffer list.
With prefix argument ARG, enable if ARG is positive, disable otherwise.
Icons appear in the first column of the Ibuffer listing."
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
