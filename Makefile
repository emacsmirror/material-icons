.PHONY: all lint package-lint checkdoc byte-compile compress test clean
MAKEFLAGS := -rR

EMACS := emacs
EMACS_BATCH := $(EMACS) -Q --batch

test-file := test/test.el
el-args := material-icons-file-map.el
el-args += material-icons-folder-map.el
el-args += material-icons-core.el
el-args += material-icons-dired.el
el-args += material-icons-ibuffer.el
el-args += material-icons-speedbar.el
el-args += material-icons.el
elc-args := $(el-args:.el=.elc)
el-str-list := $(patsubst %,\"%\",$(el-args))

all: lint byte-compile compress test

lint: package-lint checkdoc

package-lint: $(el-args)
	@echo "[package-lint]"
	@$(EMACS_BATCH) \
		--eval "(progn\
      (package-initialize)\
      (require 'package-lint)\
      (let ((command-line-args-left '($(el-str-list))))\
        (package-lint-batch-and-exit)))"

checkdoc: $(el-args)
	@echo "[checkdoc]"
	@$(EMACS_BATCH) \
		--eval "(progn\
      (require 'checkdoc)\
      (let ((sentence-end-double-space nil)\
            (checkdoc-proper-noun-list nil)\
            (checkdoc-verb-check-experimental-flag nil)\
            (warnings-buffer \"*Warnings*\")\
            (ok t))\
        (dolist (f '($(el-str-list)))\
          (let ((warnings (get-buffer warnings-buffer)))\
            (when warnings (kill-buffer warnings)))\
          (let ((inhibit-message t))\
            (checkdoc-file f))\
          (let ((warnings (get-buffer warnings-buffer)))\
            (when warnings\
              (setq ok nil)\
              (with-current-buffer warnings\
                (message \"%s\" (buffer-string))))))\
        (kill-emacs (if ok 0 1))))"

byte-compile: $(elc-args)

compress: icons.tar.gz

icons.tar.gz:
	tar -czvf icons.tar.gz -C test icons

test: compress $(elc-args)
	$(EMACS) -Q -L . -l $(test-file)

$(elc-args): %.elc : %.el
	@$(EMACS_BATCH) -L . \
		--eval "(setq byte-compile-error-on-warn t)" \
		-f batch-byte-compile $<

clean:
	rm -f *.elc
