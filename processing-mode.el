;;; processing-mode.el --- Major mode for Processing 2.0

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

;;; Commentary:

;; In your .emacs file, add this:
;;
;;    (add-to-list 'load-path "/path/to/processing2-emacs/")
;;    (autoload 'processing-mode "processing-mode" "Processing mode" t)
;;    (add-to-list 'auto-mode-alist '("\\.pde$" . processing-mode))
;;
;; To add the snippets put this also in your .emacs file:
;;
;;     (yas-load-directory  "/path/to/processing2-emacs/snippets")
;;
;; and eventually add this to activate yasnippet if it is not:
;;
;;     (add-hook 'processing-mode-hook 'yas-minor-mode)
;;
;; Usage:
;;
;; The key-bindings are:
;;
;;     C-c C-r    Run a sketch.
;;     C-c C-b    Compile a sketch into .class files.
;;     C-c C-p    Run a sketch full screen.
;;     C-c C-e    Export sketch.

;;; Code:
(eval-when-compile
  (require 'compile)
  (require 'cl))

(defcustom processing-location nil
  "The path to the processing-java command line tool.
The path should be something like /usr/bin/processing-java."
  :type 'string)

(defconst processing-platform
  (cond ((string= system-type "gnu/linux")
     "linux")
    ((or (string= system-type "darwin") (string= system-type "macos"))
     "macosx")
    ((or (string= system-type "ms-dos") (string= system-type "windows-nt")
         (string= system-type "cygwin"))
     "windows"))
  "The platform that Processing is running on.  It can be `linux', `macosx' or `windows'.")

(defconst processing-platform-bits
  (if (string-match "64" system-configuration)
      "64"
    "32"))

;; Functions

(defun processing-make-compile-command (sketch-dir output-dir cmd &optional platform bits)
  "Return a string which is the `compile-command' for Processing.
sketches, targetting the sketch files found in SKETCH-DIR,
with the output being stored in OUTPUT-DIR.  The command flag
that is executed on the sketch depends on the type of CMD.
Optional arguments are PLATFORM and BITS.

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
  "Run the Processing compiler, using a `compile-command'.
It is constructed using the ``processing-make-compile-command''
function.  Arguments are SKETCH-DIR, OUTPUT-DIR and CMD.
Optional arguments PLATFORM and BITS."
  (let ((compilation-error-regexp-alist '(processing)))
    (compile (processing-make-compile-command sketch-dir output-dir cmd platform bits))))

(defun processing-sketch-compile (cmd)
  "Run the Processing Commander application with the current buffer.
The output directory is the sub-directory ``output''
which will be found in the parent directory of the buffer file.
CMD is the run type command argument."
  ;; TODO: Add support for temporary sketches
  (let ((sketch-dir (file-name-directory buffer-file-name)))
    (processing-commander sketch-dir (concat sketch-dir "output") cmd)))

(defun processing-sketch-run ()
  "Run sketch."
  (interactive)
  (processing-sketch-compile "run")
  )
(defun processing-sketch-present ()
  "Run sketch fullscreen."
  (interactive)
  (processing-sketch-compile "present"))

(defun processing-sketch-build ()
  "Run the build command for a Processing sketch.
Processing will process the sketch into .java files and then compile them
into .class files."
  (interactive)
  (processing-sketch-compile "build"))

(defun processing-export-application ()
  "Turn the Processing sketch into a Java application.
Assumes that the platform target is whatever platform Emacs is running
on."
  (interactive)
  (processing-sketch-compile "export"))

;; Add hook so that when processing-mode is loaded, the local variable
;; 'compile-command is set.
;; (add-hook 'processing-mode-hook
;;       (lambda ()
;;         (let ((sketch-dir (file-name-directory buffer-file-name)))
;;           (set (make-local-variable 'compile-command)
;;                (processing-make-compile-command sketch-dir
;;                                                 (concat sketch-dir "output")
;;                                                 "build")))))

;; Regular expressions
;; Compilation
(eval-after-load "compile"
  '(add-hook 'processing-mode-hook
             (lambda ()
               (add-to-list
                'compilation-error-regexp-alist
                '("^\\([[:alnum:]]+.pde\\):\\([0-9]+\\):\\([0-9]+\\).*$" 1 2 3)))))

;; Font-lock, keywords
(defvar processing-functions
  '("triangle" "line" "arc" "ellipse" "point" "quad" "rect" "bezier"
    "bezierDetail" "bezierPoint" "bezierTangent" "curve" "curveDetail"
    "curvePoint" "curveTangent" "curveTightness" "box" "sphere"
    "sphereDetail" "background" "size" "fill" "noFill" "stroke"
    "noStroke" "colorMode" "ellipseMode" "rectMode" "smooth" "noSmooth"
    "strokeCap" "strokeJoin" "strokeWeight" "noCursor" "cursor" "random"
    "randomSeed" "floor" "ceil" "noLoop" "loop" "createShape" "loadShape"
    "beginShape" "bezierVertex" "curveVertex" "endShape" "quadraticVertex"
    "vertex" "shape" "shapeMode" "mouseClicked" "mousePressed" "mouseDragged"
    "mouseMoved" "mouseReleased" "keyPressed" "keyReleased" "keyTyped"
    "createInput" "createReader" "loadBytes" "loadStrings" "loadTable"
    "loadXML" "open" "selectFolder" "selectInput" "day" "hour" "millis"
    "minute" "month" "second" "year" "print" "println" "save" "saveFrame"
    "beginRaw" "beginRecord" "createOutput" "createWriter" "endRaw"
    "endRecord" "PrintWriter" "saveBytes" "saveStream" "saveStrings"
    "SelectOutput" "applyMatrix" "popMatrix" "printMatrix" "pushMatrix"
    "resetMatrix" "rotate" "rotateX" "rotateY" "rotateZ" "scale" "shearX"
    "shearY" "translate" "ambientLight" "directionalLight" "lightFalloff"
    "lights" "lightSpecular" "noLights" "normal" "pointLight" "spotLight"
    "beginCamera" "camera" "endCamera" "frustum" "ortho" "perspective"
    "printCamera" "printProjection" "modelX" "modelY" "modelZ" "screenX"
    "screenY" "screenZ" "ambient" "emissive" "shininess" "specular" "alpha"
    "blue" "brightness" "color" "green" "hue" "lerpColor" "red" "saturation"
    "createImage" "image" "imageMode" "loadImage" "noTint" "requestImage"
    "tint" "texture" "textureMode" "textureWrap" "blend" "copy" "filter"
    "get" "loadPixels" "set" "updatePixels" "blendMode" "createGraphics"
    "hint" "loadShader" "resetShader" "shader" "createFont" "loadFont"
    "text" "textFont" "textAlign" "textLeading" "textMode" "textSize"
    "textWidth" "textAscent" "textDescent" "abs" "constrain" "dist" "exp"
    "lerp" "log" "mag" "map" "max" "min" "norm" "pow" "round" "sq" "sqrt"
    "acos" "asin" "atan" "atan2" "cos" "degrees" "radians" "sin" "tan"
    "noise" "noiseDetail" "noiseSeed"))

(defvar processing-constants
  '("ADD" "ALIGN_CENTER" "ALIGN_LEFT" "ALIGN_RIGHT" "ALPHA" "ALPHA_MASK"
    "ALT" "AMBIENT" "ARROW" "ARGB" "BACKSPACE" "BASELINE" "BEVEL" "BLEND"
    "BLUE_MASK" "BLUR" "BOTTOM" "BURN" "CENTER" "CHATTER" "CLOSE" "CMYK"
    "CODED" "COMPLAINT" "COMPOSITE" "COMPONENT" "CONCAVE_POLYGON" "CONTROL"
    "CONVEX_POLYGON" "CORNER" "CORNERS" "CROSS" "CUSTOM" "DARKEST" "DEGREES"
    "DEG_TO_RAD" "DELETE" "DIAMETER" "DIFFERENCE" "DIFFUSE" "DILATE" "DIRECTIONAL"
    "DISABLE_ACCURATE_2D" "DISABLE_ACCURATE_TEXTURES" "DISABLE_DEPTH_MASKS"
    "DISABLE_DEPTH_SORT" "DISABLE_DEPTH_TEST" "DISABLE_NATIVE_FONTS"
    "DISABLE_OPENGL_ERRORS" "DISABLE_TEXTURE_CACHE" "DISABLE_TEXTURE_MIPMAPS"
    "DISABLE_TRANSFORM_CACHE" "DISABLE_STROKE_PERSPECTIVE" "DISABLED"
    "DODGE" "DOWN" "DXF" "ENABLE_ACCURATE_2D" "ENABLE_ACCURATE_TEXTURES"
    "ENABLE_DEPTH_MASKS" "ENABLE_DEPTH_SORT" "ENABLE_DEPTH_TEST"
    "ENABLE_NATIVE_FONTS" "ENABLE_OPENGL_ERRORS" "ENABLE_TEXTURE_CACHE"
    "ENABLE_TEXTURE_MIPMAPS" "ENABLE_TRANSFORM_CACHE" "ENABLE_STROKE_PERSPECTIVE"
    "ENTER" "EPSILON" "ERODE" "ESC" "EXCLUSION" "GIF" "GRAY" "GREEN_MASK"
    "GROUP" "HALF" "HALF_PI" "HAND" "HARD_LIGHT" "HINT_COUNT" "HSB" "IMAGE"
    " INVERT" "JPEG" "LEFT" "LIGHTEST" "LINES" "LINUX" "MACOSX" "MAX_FLOAT"
    " MAX_INT" "MITER" "MODEL" "MOVE" "MULTIPLY" "NORMAL" "NORMALIZED"
    "NO_DEPTH_TEST" "NTSC" "ONE" "OPAQUE" "OPEN" "ORTHOGRAPHIC" "OVERLAY"
    "PAL" "PDF" "P2D" "P3D" "PERSPECTIVE" "PI" "PIXEL_CENTER" "POINT" "POINTS"
    "POSTERIZE" "PROBLEM" "PROJECT" "QUAD_STRIP" "QUADS" "QUARTER_PI"
    "RAD_TO_DEG" "RADIUS" "RADIANS" "RED_MASK" "REPLACE" "RETURN" "RGB"
    "RIGHT" "ROUND" "SCREEN" "SECAM" "SHIFT" "SPECULAR" "SOFT_LIGHT" "SQUARE"
    "SUBTRACT" "SVIDEO" "TAB" "TARGA" "TEXT" "TFF" "THIRD_PI" "THRESHOLD"
    "TIFF" "TOP" "TRIANGLE_FAN" "TRIANGLES" "TRIANGLE_STRIP" "TUNER" "TWO"
    "TWO_PI" "UP" "WAIT" "WHITESPACE" "OPENGL" "JAVA2D"))

(defvar processing-builtins
  '("mouseX" "mouseY" "pmouseX" "pmouseY" "mouseButton" "mousePressed"
    "key" "keyCode" "keyPressed" "width" "height" "frameRate" "frameCount"
    "displayWidth" "displayHeight" "focused" "screenWidth" "screenHeight"))

(defvar processing-functions-regexp (regexp-opt processing-functions 'words))
(defvar processing-constants-regexp (regexp-opt processing-constants 'words))
(defvar processing-builtins-regexp (regexp-opt processing-builtins 'words))

(defconst processing-font-lock-keywords-1
  `((,processing-functions-regexp . font-lock-keyword-face)
    (,processing-constants-regexp . font-lock-constant-face)
    (,processing-builtins-regexp . font-lock-builtin-face)))

(defvar processing-font-lock-keywords processing-font-lock-keywords-1
  "Default expressions to highlight in Processing mode.")

(defvar processing-mode-map
  (let ((processing-mode-map (make-sparse-keymap)))
    (define-key processing-mode-map "\C-c\C-r" 'processing-sketch-run)
    (define-key processing-mode-map "\C-c\C-p" 'processing-sketch-present)
    (define-key processing-mode-map "\C-c\C-b" 'processing-sketch-build)
    (define-key processing-mode-map "\C-c\C-e" 'processing-export-application)
    processing-mode-map)
  "Keymap for processing major mode.")

(define-derived-mode processing-mode
  java-mode "Processing"
  "Major mode for Processing.
\\{java-mode-map}"
  (set (make-local-variable 'c-basic-offset) 2)
  (set (make-local-variable 'tab-width) 2)

  (font-lock-add-keywords 'processing-mode processing-font-lock-keywords)
  )

(provide 'processing-mode)
;;; processing-mode.el ends here
