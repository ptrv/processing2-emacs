;;; processing-company.el --- company-mode support for processing-mode  -*- lexical-binding: t; -*-

;; Copyright (C) 2015  Peter Vasil

;; Author: Peter Vasil <mail@petervasil.net>
;; Keywords: extensions

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

;;

;;; Code:

(require 'company)
(require 'company-keywords)
(require 'company-yasnippet)
(require 'processing-mode)

(defvar processing-company--keywords
  (cons 'processing-mode (append processing-functions
                                 processing-builtins
                                 processing-constants)))

(defun processing-company--init ()
  (setq-local company-backends '((company-keywords
                                  :with
                                  company-yasnippet
                                  company-dabbrev-code)))
  (make-local-variable 'company-keywords-alist)
  (add-to-list 'company-keywords-alist processing-company--keywords))

;;;###autoload
(defun processing-company-setup ()
  "Setup company-mode for processing-mode."
  (add-hook 'processing-mode-hook 'processing-company--init))

(provide 'processing-company)
;;; processing-company.el ends here
