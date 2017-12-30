.DEFAULT_GOAL := all

# make sure e.g. if pic fails, then the *.tex intermediate is removed
.DELETE_ON_ERROR:

ifndef V
.SILENT:
endif

M4_OPTS=-P # prefix builtins with "m4_"

M4_DEPS=components.m4 \
	eschpic.m4    \
	util.m4

all : doc.pdf ;@echo "$@ done"

doc.pdf: doc.tex test.tex
	@echo "  LATEX	" $<
	texfot --tee=/dev/null pdflatex doc.tex

%.tex: %.pic
	@echo "  PIC	" $<
	dpic -g $< > $@

%.pic: %.m4 $(M4_DEPS)
	@echo "  M4	" $<
	m4 $(M4_OPTS) $< > $@

# use make -nps to figure out all intermediate targets
clean :;@rm -rfv $(shell $(MAKE) -nps all | sed -n '/^# I/,$${/^[^\#\[%.][^ %]*: /s/:.*//p;}') $(filter %.d,$(MAKEFILE_LIST))
