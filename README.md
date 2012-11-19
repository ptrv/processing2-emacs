# Emacs major-mode for Processing 2.0

Based on Rudolf Olah's version and modification by Bunny Blake.

https://github.com/emacsmirror/processing-mode  
https://gist.github.com/4083326

## Setup

In your .emacs file, add this:

    (add-to-list 'load-path "/path/to/processing2-emacs/")
    (autoload 'processing-mode "processing-mode" "Processing mode" t)
    (add-to-list 'auto-mode-alist '("\\.pde$" . processing-mode))

## Usage

The key-bindings are:

    C-c C-r    Run a sketch.
    C-c C-b    Compile a sketch into .class files.
    C-c C-p    Run a sketch full screen.
    C-c C-e    Export sketch.
