.PHONY: all compile lint checkdoc test run clean package install
MAKEFLAGS := -rR

ELDEV  := eldev
EMACS  := emacs

EL     := $(wildcard *.el)
ELC    := $(EL:.el=.elc)

all: compile

compile: $(ELC)

$(ELC): %.elc : %.el
	$(ELDEV) -dtT compile $(<F)

lint: checkdoc
	$(ELDEV) lint

checkdoc:
	$(ELDEV) lint doc

test:
	$(ELDEV) -dtT test

run: compile
	$(EMACS) -Q -L . -l test/run.el

package: compile
	$(ELDEV) package

install: package
	$(ELDEV) package install

clean:
	rm -f *.elc
