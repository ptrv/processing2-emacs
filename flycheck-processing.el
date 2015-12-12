;;; flycheck-processing.el --- Flycheck checker for processing-mode

;; Copyright (C) 2015  Peter Vasil

;; Author: Martin Yrjölä <martin.yrjola@gmail.com>
;; Keywords: extensions
;; Version: 0.1
;; Package-Requires: ((processing-mode "1.3.0") (flycheck "0.22"))

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This provides flycheck integration for processing-mode. It allows flycheck to
;; use the processing-java command-line tool to parse results for its display.
;;
;; Basic usage:
;;
;;  (require 'flycheck-processing)
;;  (flycheck-processing-setup)

;;; Code:

(require 'flycheck)
(require 'processing-mode)

(flycheck-define-checker processing
  "Processing command line tool.

See https://github.com/processing/processing/wiki/Command-Line"
  :command ("processing-java"
            "--force"
            (eval (concat "--sketch=" (file-name-directory (buffer-file-name))))
            (eval (concat "--output=" (flycheck-temp-dir-system)))
            "--build")
  :error-patterns
  ((error line-start (file-name) ":" line ":" column (* (or digit ":")) (message) line-end))
  :modes processing-mode)

;;;###autoload
(defun flycheck-processing-setup ()
  "Convenience function to setup the processing flycheck checker.

Adds `processing-java' checker to `flycheck-checkers'"
  (add-to-list 'flycheck-checkers 'processing))

(provide 'flycheck-processing)
;;; flycheck-processing.el ends here
