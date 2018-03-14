.DEFAULT_GOAL := all

# make sure e.g. if pic fails, then the *.tex intermediate is removed
.DELETE_ON_ERROR:

ifndef V
.SILENT:
endif

.PRECIOUS: %.md5

M4_OPTS=-P # prefix builtins with "m4_"

M4_DEPS=components.m4 \
	connectors.m4 \
	contacts.m4   \
	direction.m4  \
	eschpic.m4    \
	modules.m4    \
	text.m4       \
	sensors.m4    \
	util.m4       \
	wires.m4

all : testdoc.pdf ;@echo "$@ done"

testdoc.pdf: testdoc.tex $(wildcard sheet*.m4) bom.csv.sorted
	@echo "  LATEX	" $<
	texfot --tee=/dev/null pdflatex $<

%.tex: %.pic
	@echo "  PIC	" $<
	dpic -g $< > $@

%.pic: %.m4 $(M4_DEPS) eschpic.aux.md5
	@echo "  M4	" $<
	m4 $(M4_OPTS) $< > $@

%.md5: FORCE
	@echo "  MD5	" $*
	@$(if $(filter-out $(shell cat $@ 2>/dev/null),$(shell md5sum $*)),md5sum $* > $@)

bom.csv.sorted: bom.csv
	@echo "  SORT	bom.csv"
	-tail +2 bom.csv | sort -n > $@

FORCE:

# use make -nps to figure out all intermediate targets
clean:
	rm -fv *.log *.aux
	@rm -rfv $(shell $(MAKE) -nps all | sed -n '/^# I/,$${/^[^\#\[%.][^ %]*: /s/:.*//p;}') $(filter %.d,$(MAKEFILE_LIST))
