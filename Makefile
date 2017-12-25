.DEFAULT_GOAL := all

ifndef V
.SILENT:
endif

all : doc.pdf ;@echo "$@ done"

doc.pdf: doc.tex test.tex
	texfot --tee=/dev/null pdflatex doc.tex

test.tex: test.pic eschpic.m4 util.m4
	m4 $< | dpic -g > $@

%.pic: %.m4
	@echo "  M4	" $<
	m4 $< > $@

# use make -nps to figure out all intermediate targets
clean :;@rm -rfv $(shell $(MAKE) -nps all | sed -n '/^# I/,$${/^[^\#\[%.][^ %]*: /s/:.*//p;}') $(filter %.d,$(MAKEFILE_LIST))
