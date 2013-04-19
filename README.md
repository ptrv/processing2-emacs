# Emacs major-mode for Processing 2.0

Based on Rudolf Olah's version and modification by Bunny Blake.

https://github.com/emacsmirror/processing-mode

https://gist.github.com/4083326

The snippets are taken from Sublime Text 2's Processing plugin and converted to yasnippet snippets.

## Installation

The easies way to install processing2 mode is via MELPA

Install the ELPA package from MELPA or Marmalade with `M-x
package-install RET processing-mode`. All dependencies are automatically
installed.

## Maual installation

To install `processing-mode` manually, clone the repository:

    git clone https://github.com/ptrv/processing2-emacs

In your .emacs file, add this:

    (add-to-list 'load-path "/path/to/processing2-emacs/")
    (autoload 'processing-mode "processing-mode" "Processing mode" t)
    (add-to-list 'auto-mode-alist '("\\.pde$" . processing-mode))

Add the following to set up processing snippets for yasnippet:

    (autoload 'processing-snippets-initialize "processing-mode" nil nil nil)
    (eval-after-load 'yasnippet '(processing-snippets-initialize))


## Usage

The key-bindings are:

    C-c C-r    Run a sketch.
    C-c C-b    Compile a sketch into .class files.
    C-c C-p    Run a sketch full screen.
    C-c C-e    Export sketch.
