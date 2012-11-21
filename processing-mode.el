;; processing-mode.el

;; Processing.org language based on Java mode. Adds keyword
;; highlighting for all recognized Processing language functions.
;; Allows compilation of buffers and "sketches" from within Emacs but
;; only for more recent versions of Processing.

;; Copyright (C) 2008, 2009 Rudolf Olah <omouse@gmail.com>

;; Modified for Processing 2.0 by Bunny Blake <discolingua@gmail.com>
;; Processing 2 modifications, November 2012

;; Modified by Peter Vasil <mail@petervasil.net>, November 2012

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

(eval-when-compile
  (require 'compile)
  (require 'cl))

(define-derived-mode processing-mode
  java-mode "Processing"
  "Major mode for Processing.
\\{java-mode-map}")

(defvar processing-location nil
  "The path to the processing-java command line tool,
e.g. /usr/bin/processing-java.")

(defconst processing-platform
  (cond ((string= system-type "gnu/linux")
     "linux")
    ((or (string= system-type "darwin") (string= system-type "macos"))
     "macosx")
    ((or (string= system-type "ms-dos") (string= system-type "windows-nt")
         (string= system-type "cygwin"))
     "windows"))
  "The platform that Processing is running on. It can be `linux', `macosx' or `windows'.")

(defconst processing-platform-bits
  (if (string-match "64" system-configuration)
      "64"
    "32"))

;; Functions

(defun processing-make-compile-command (sketch-dir output-dir cmd &optional platform bits)
  "Returns a string which is the compile-command for Processing
sketches, targetting the sketch files found in ``sketch-dir'',
with the output being stored in ``output-dir''. The command flag
that is executed on the sketch depends on the type of ``cmd''.

Valid types of commands are:

  - \"preprocess\"
  - \"build\"
  - \"run\"
  - \"present\"
  - \"export-applet\"
  - \"export-application\"

When ``cmd'' is set to \"export-application\", the ``platform''
must be set to one of \"windows\", \"macosx\", or \"linux\". If
no platform is selected, the default platform that Emacs is
running on will be selected."
  (concat processing-location
      " --force --sketch=\"" (expand-file-name sketch-dir)
      ;; "\" --output=\"" (expand-file-name output-dir)
      ;; Remove this comment when Processing implements the --preferences=??? command-line option.
      ;;"\" --preferences=\"" (expand-file-name "~/.processing/preferences.txt")
      "\" --" cmd
      (if (string= cmd "export")
          (concat " --platform="
                  (if platform platform processing-platform)
                  " --bits="
                  (if bits bits processing-platform-bits)
                  " --output=\"" (expand-file-name
                                  (concat "application."
                                          (if platform platform processing-platform))) "\"")
        (concat " --output=\"" (expand-file-name output-dir) "\""))))

(defun processing-commander (sketch-dir output-dir cmd &optional platform bits)
  "Runs the Processing compiler, using a compile-command
constructed using the ``processing-make-compile-command''
function."
  (let ((compilation-error-regexp-alist '(processing)))
    (compile (processing-make-compile-command sketch-dir output-dir cmd platform bits))))

(defun processing-sketch-compile (&optional cmd)
  "Runs the Processing Commander application with the current
buffer. The output directory is the sub-directory ``output''
which will be found in the parent directory of the buffer file."
  (interactive)
  ;; TODO: Add support for temporary sketches
  (let ((sketch-dir (file-name-directory buffer-file-name)))
    (processing-commander sketch-dir (concat sketch-dir "output") (if cmd cmd "run"))))

(defun processing-sketch-present ()
  (interactive)
  (processing-sketch-compile "present"))

(defun processing-sketch-build ()
  "Runs the build command for a Processing sketch. Processing
will process the sketch into .java files and then compile them
into .class files."
  (interactive)
  (processing-sketch-compile "build"))

(defun processing-export-application ()
  "Turns the Processing sketch into a Java application. Assumes
that the platform target is whatever platform Emacs is running
on."
  (interactive)
  (processing-sketch-compile "export"))

;; Add hook so that when processing-mode is loaded, the local variable
;; 'compile-command is set.
(add-hook 'processing-mode-hook
      (lambda ()
        (let ((sketch-dir (file-name-directory buffer-file-name)))
          (set (make-local-variable 'compile-command)
           (processing-make-compile-command sketch-dir
                            (concat sketch-dir "output")
                            "build")))))

;; Key bindings
(define-key processing-mode-map "\C-c\C-r" 'processing-sketch-compile)
(define-key processing-mode-map "\C-c\C-p" 'processing-sketch-present)
(define-key processing-mode-map "\C-c\C-b" 'processing-sketch-build)
(define-key processing-mode-map "\C-c\C-e" 'processing-export-application)

;; Regular expressions
;; Compilation
(pushnew
 ;; Mode name, REGEXP FILE LINE COLUMN TYPE HYPERLINK HIGHLIGHT
 '(processing "^\\([[:alnum:]]+.pde\\):\\([0-9]+\\):\\([0-9]+\\):.*$"
          1 2 3)
 compilation-error-regexp-alist-alist)

;; Font-lock, keywords
(defconst processing-font-lock-keywords-1
  (eval-when-compile
    `( ;; Shape functions
      (,(concat
     (regexp-opt '("triangle" "line" "arc" "point" "quad" "ellipse"
               "rect" "curve" "bezier")
             t)
     "(") 1 font-lock-function-name-face t)
      (,(concat
     (regexp-opt '("strokeWeight" "smooth" "strokeJoin" "noSmooth"
               "ellipseMode" "rectMode" "background" "stroke")
             t)
     "(") 1 font-lock-doc-face t)
      (,(regexp-opt '("width" "height" "frameRate" "frameCount" "noCursor()" "cursor()")
            t)
       . font-lock-constant-face)
      (,(concat "screen." (regexp-opt '("width" "height") t))
       1 font-lock-constant-face t)
      ))
  "Subdued level highlighting for Processing mode.")

;;(defconst processing-font-lock-keywords-2
;;  (append processing-font-lock-keywords-1
;;    (eval-when-compile
;;      `(

(defvar processing-font-lock-keywords processing-font-lock-keywords-1
  "Default expressions to highlight in Processing mode.")

;; ;; YASnippets
;; (if (fboundp 'yas-minor-mode)
;;     (progn
;;       (require 'yasnippet)
;;       (message "processing-mode: defining YASnippets")
;;       (yas-define-snippets
;;        'processing-mode
;;        '(
;;          ;; (key template name condition)
;;          ("tri" "triangle(${x1}, ${y1}, ${x2}, ${y2}, ${x3}, ${y3});"
;;           "triangle" nil)
;;          ("l(" "line(${x1}, ${y1}, ${x2}, ${y2});" "line 2d" nil)
;;          ("l(.3d" "line(${x1}, ${y1}, ${z1}, ${x2}, ${y2}, ${z2});" "line 3d" nil)
;;          ("arc" "arc(${x}, ${y}, ${width}, ${height}, ${start}, ${stop});" "arc" nil)
;;          ("p(" "point(${x}, ${y});" "point 2d" nil)
;;          ("p(.3d" "point(${x}, ${y}, ${z});" "point 3d" nil)
;;          ("quad" "quad(${x1}, ${y1}, ${x2}, ${y2}, ${x3}, ${y3}, ${x4}, ${y4});"
;;           "quad" nil)
;;          ("ell" "ellipse(${x}, ${y}, ${width}, ${height});" "ellipse" nil)
;;          ("rect" "rect(${x}, ${y}, ${width}, ${height});" "rect" nil)

;;          ;; Color Setting
;;          ("background" "background(${gray_or_color_or_hex});" "background .." nil)
;;          ("background.ca" "background(${gray_or_color_or_hex}, ${alpha});"
;;           "background .. alpha" nil)
;;          ("background.rgb" "background(${red}, ${green}, ${blue});" "background RGB" nil)
;;          ("background.rgba" "background(${red}, ${green}, ${blue}, ${alpha});"
;;           "background RGBA" nil)
;;          ("colorm" "colorMode(${RGB_or_HSV});" "color mode" nil)
;;          ("colorm.r" "colorMode(${RGB_or_HSV}, ${range});" "color mode range" nil)
;;          ("colorm.rgb" "colorMode(${RGB_or_HSV}, ${range1}, ${range2}, ${range3});"
;;           "color mode RGB/HSV range" nil)
;;          ("colorm.rgba" "colorMode(${RGB_or_HSV}, ${range1}, ${range2}, ${range3}, ${range4});"
;;           "color mode RGB/HSV, A range" nil)
;;          ("stroke" "stroke(${gray_or_color_or_hex});" "stroke .." nil)
;;          ("stroke.ca" "stroke(${gray_or_color_or_hex}, ${alpha});" "stroke .. alpha" nil)
;;          ("stroke.rgb" "stroke(${red}, ${green}, ${blue});" "stroke RGB" nil)
;;          ("stroke.rgba" "stroke(${red}, ${green}, ${blue}, ${alpha});" "stroke RGBA" nil)
;;          ("fill" "fill(${gray_or_color_or_hex});" "fill .." nil)
;;          ("fill.ca" "fill(${gray_or_color_or_hex}, ${alpha});" "fill .. alpha" nil)
;;          ("fill.rgb" "fill(${red}, ${green}, ${blue});" "fill RGB" nil)
;;          ("fill.rgba" "fill(${red}, ${green}, ${blue}, ${alpha});" "fill RGBA" nil)
;;          ))
;;       t)
;;   (progn
;;     (message "processing-mode: YASnippets not installed. Not defining any snippets.")
;;     nil))

(provide 'processing-mode)
