m4_divert(-1)

`
General "module" symbol, with custom terminals and labels. Will draw either vertically or horizontally
depending on current direction.

Usage: module([key-value separated parameters])
Params:
	pos:		Position to place first terminal at. Defaults to "Here".
	ref:		Component reference name. Must be a valid pic label (no spaces, starts with capital
			letter). Will prefix reference name with the current sheet number.
	val:		Component value
	description:	Additional text describing component purpose etc.
	part:		Part number. If this is supplied, it is added to the BOM.
	terminals:	Description of the module's terminals, in the syntax:
			"[Groupname](T1, T2, T3, T4) [[Groupname](T1, T2, T3, T4)... | [Groupname](T1, T2, T3, T4)]".
			The "|" symbol splits the module into top and bottom (or left and right). Group name is
			optional. Example: "X1(L1, L2, L3, PE) X13(DIO0, DIO1, DIO02, DCOM, VO24, DGND) | X2(U, V, W, PE)".
	height:		Height of module (if in vertical orientation). Defaults to "elen * 2" if currently vertical,
			otherwise is automatically calculated.
	width:		Width of module (if in horizontal orientation). Defaults to "elen * 2" if currently horizontal,
			otherwise is automatically calculated.
'
m4_define_blind(`module', `
	componentParseKVArgs(`_module_',
		(`pos', `Here',
		 `ref', `',
		 `val', `',
		 `description', `',
		 `part', `',
		 `terminals', `',
		 `height', `2 * elen',
		 `width', `2 * elen'), $@)
	componentHandleRef(_module_)

	[
		pushDir();
		dirToDirection(peekDir());

		m4_errprint(terminals: "_module_terminals" m4_newline())
		m4_define(`_module_topterms', m4_regexp(_module_terminals, `^\([^|]*\)', `\1'))
		m4_define(`_module_botterms', m4_regexp(_module_terminals, `|\(.*\)', `\1'))
		m4_errprint(top terminals:    "_module_topterms" m4_newline())
		m4_errprint(bottom terminals: "_module_botterms" m4_newline())

		_moduleParseTerminals(_module_topterms)
		_moduleParseTerminals(_module_botterms)

		box wid _module_width ht _module_height;

		popDir();
	]

	componentDrawLabels(_module_)
')
m4_define_blind(`_moduleParseTerminals', `

	m4_errprint(matching:
		m4_regexp($1, `^ *\(\w[^(]*\)? *\(([^)]*)\)', `group1: \1
		group2: \2') m4_newline())

	#m4_popdef(`_group')
')

m4_divert(0)

# vim: filetype=pic
