# Emacs major-mode for Processing 2.0

Based on Rudolf Olah's version and modification by Bunny Blake.

https://github.com/emacsmirror/processing-mode

https://gist.github.com/4083326

The snippets are taken from Sublime Text 2's Processing plugin and converted to yasnippet snippets.

## Installation

The easiest way is to install the ELPA package from MELPA with `M-x
package-install RET processing-mode`. All dependencies are automatically
installed.

## Maual installation

To install `processing-mode` manually, clone the repository:

    git clone https://github.com/ptrv/processing2-emacs

In your .emacs file, add this:

    (add-to-list 'load-path "/path/to/processing2-emacs/")
    (autoload 'processing-mode "processing-mode" "Processing mode" t)
    (add-to-list 'auto-mode-alist '("\\.pde$" . processing-mode))
    (setq processing-location "/path/to/processing-java")
    (setq processing-application-dir "/path/to/processing/dir")

Add the following to set up processing snippets for [yasnippet][1]:

    (autoload 'processing-snippets-initialize "processing-mode" nil nil nil)
    (eval-after-load 'yasnippet '(processing-snippets-initialize))

Optionally it is also possible to set up basic [Audo-Complete][2]
support to have keyword completion.

    (defun processing-mode-init ()
      (make-local-variable 'ac-sources)
      (setq ac-sources '(ac-source-dictionary ac-source-yasnippet))
      (make-local-variable 'ac-user-dictionary)
      (setq ac-user-dictionary processing-functions)
      (setq ac-user-dictionary (append ac-user-dictionary processing-builtins))
      (setq ac-user-dictionary (append ac-user-dictionary processing-constants)))

    (add-to-list 'ac-modes 'processing-mode)
    (add-hook 'processing-mode-hook 'processing-mode-init)


[1]: https://github.com/capitaomorte/yasnippet
[2]: http://cx4a.org/software/auto-complete/

## Usage

The key-bindings are:

    C-c C-r    Run a sketch.
    C-c C-b    Compile a sketch into .class files.
    C-c C-p    Run a sketch full screen.
    C-c C-e    Export sketch.
