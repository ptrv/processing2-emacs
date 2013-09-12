# Emacs major-mode for Processing 2.0

Based on Rudolf Olah's version and modification by Bunny Blake.

https://github.com/emacsmirror/processing-mode

https://gist.github.com/4083326

The snippets are taken from Sublime Text 2's Processing plugin and converted to yasnippet snippets.

## Installation

The easiest way is to install the ELPA package from MELPA with `M-x
package-install RET processing-mode`. All dependencies are automatically
installed.

## Manual installation

To install `processing-mode` manually, clone the repository:

```lisp
git clone https://github.com/ptrv/processing2-emacs
```

In your `.emacs` file, add this:

```lisp
(add-to-list 'load-path "/path/to/processing2-emacs/")
(autoload 'processing-mode "processing-mode" "Processing mode" t)
(add-to-list 'auto-mode-alist '("\\.pde$" . processing-mode))
```

Add the following to set up processing snippets for [yasnippet][1]:

```lisp
(autoload 'processing-snippets-initialize "processing-snippets" nil nil nil)
(eval-after-load 'yasnippet '(processing-snippets-initialize))
```

[1]: https://github.com/capitaomorte/yasnippet

## Configuration

Set variables in `.emacs` or with `customize-group RET processing RET`
(this works only after `processing-mode` has been loaded):

```lisp
(setq processing-location "/path/to/processing-java")
(setq processing-application-dir "/path/to/processing-application-dir")
(setq processing-sketchbook-dir "/path/to/processing-sketchbook-dir")
```

For example, on Mac the default settings are the following:

```lisp
(setq processing-location "/usr/bin/processing-java")
(setq processing-application-dir "/Applications/Processing.app")
(setq processing-sketchbook-dir "~/Documents/Processing")
```

Usually when you run a processing sketch, the build files are generated
in a sub-directory called `output` in the current sketch directory. It
is also possible to set the `processing-output-dir` to another
directory:

```lisp
(setq processing-output-dir "/tmp")
```

Optionally it is also possible to set up basic [Auto-Complete][2]
support to have keyword completion.

```lisp
(defun processing-mode-init ()
  (make-local-variable 'ac-sources)
  (setq ac-sources '(ac-source-dictionary ac-source-yasnippet))
  (make-local-variable 'ac-user-dictionary)
  (setq ac-user-dictionary (append processing-functions
                                   processing-builtins
                                   processing-constants)))

(add-to-list 'ac-modes 'processing-mode)
(add-hook 'processing-mode-hook 'processing-mode-init)
```

[2]: http://cx4a.org/software/auto-complete/

## Usage

The key-bindings are:

    C-c C-p r    Run a sketch.
    C-c C-p b    Compile a sketch into .class files.
    C-c C-p p    Run a sketch full screen.
    C-c C-p e    Export sketch.
    C-c C-p d    Find in reference.
    C-c C-p f    Find or create sketch.
    C-c C-p s    Search in Processing forum.
