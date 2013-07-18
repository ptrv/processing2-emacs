EMACS ?= emacs
EMACSFLAGS =
VERSION =

SRCS = processing-snippets.el

PACKAGE_SRCS = $(SRCS) \
	processing-snippets-pkg.el \
	snippets
PACKAGE = processing-snippets-$(VERSION).tar

.PHONY: package
package : $(PACKAGE)

$(PACKAGE) : $(PACKAGE_SRCS)
	rm -rf processing-snippets-$(VERSION)
	mkdir -p processing-snippets-$(VERSION)
	cp -f -r $(PACKAGE_SRCS) processing-snippets-$(VERSION)
	tar cf $(PACKAGE) processing-snippets-$(VERSION)
	rm -rf processing-snippets-$(VERSION)

.PHONY: clean
clean :
	rm -rf $(PACKAGE)
