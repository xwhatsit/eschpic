# Set base unit used for components
elen = 12.7;

m4_divert(-1)

`
Resistor. Draws in current direction.

Usage: resistor([comma-separated key-value parameters])
Params:
	ref:		Component reference name. Must be a valid pic label (no spaces, starts with capital
			letter). Will prefix reference name with the current sheet number.
	val:		Component value
	description:	Additional text describing component purpose etc.
	part:		Part number. If this is supplied, it is added to the BOM.
'
m4_define_blind(`resistor',
`
	# set default args
	m4_define(`_resistor_ref', `')
	m4_define(`_resistor_val', `')
	m4_define(`_resistor_part', `')
	m4_define(`_resistor_description', `')

	# parse key-value arguments
	m4_prefixKVArgs(`_resistor_', $@)

	# remove double quotes from those args
	m4_define(`_resistor_ref', m4_dequote(_resistor_ref))
	m4_define(`_resistor_val', m4_dequote(_resistor_val))
	m4_define(`_resistor_part', m4_dequote(_resistor_part))
	m4_define(`_resistor_description', m4_dequote(_resistor_description))

	# if a ref was defined, prefix it with the sheet number
	m4_ifelse(_resistor_ref, `', `', m4_define(`_resistor_ref_prefixed', a3SheetNum`'_resistor_ref))

	# if ref was defined and is a valid pic label, then add a label
	m4_ifelse(m4_regexp(_resistor_ref, `^[A-Z][A-Za-z0-9]*$'), 0, _resistor_ref`:', `m4_errprint(
		`warning: could not define place name for component ref "'_resistor_ref`" as it is not a valid pic label' m4_newline())')
	[
		pushDir();

		{
			line dirToDirection(peekDir()) elen*1.5 invis;
			Start: last line.start;
			End:   last line.end;
		}
		line dirToDirection(peekDir()) elen/2;
		if dirIsVertical(peekDir()) then {
			box wid elen/5 ht elen/2
		} else {
			box wid elen/2 ht elen/5
		}
		line dirToDirection(peekDir()) elen/2;

		popDir();
	]

	# compose label(s)
	m4_ifelse(_resistor_ref, `', `',
		`m4_define(`_resistor_labels',
			m4_ifdef(`_resistor_labels', _resistor_labels` \\') textComponentRef(_resistor_ref_prefixed))')
	m4_ifelse(_resistor_val, `', `',
		`m4_define(`_resistor_labels',
			m4_ifdef(`_resistor_labels', _resistor_labels` \\') textComponentVal(_resistor_val))')
	m4_ifelse(_resistor_description, `', `',
		`m4_define(`_resistor_labels',
			m4_ifdef(`_resistor_labels', _resistor_labels` \\') textComponentDescription(_resistor_description))')
	
	# display label(s), if present      "textMultiLine(_resistor_labels)" at last [].w rjust;)
	m4_ifelse(_resistor_labels, `', `', `
		if dirIsVertical(getDir()) then {
			"textMultiLine(_resistor_labels)" at last [].w rjust;
		} else {
			"textMultiLine(_resistor_labels)" at last [].n above;
		}
	')
	#"\small \ttfamily \begin{tabular}[t]{@{}l@{}}line 1 \\ line 2\end{tabular}" at R3.w rjust;

	move to last [].End
')

m4_divert(0)

# vim: filetype=pic
