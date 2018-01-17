m4_divert(-1)

`
Single male pin connector. Draws in current direction.

Usage: connectorMale([comma-separated key-value parameters])
Params:
	pos:		Position to place ".Start" at. Defaults to "Here".
	ref:		Component reference name. Must be a valid pic label (no spaces, starts with capital
			letter). Will prefix reference name with the current sheet number.
	val:		Component value
	description:	Additional text describing component purpose etc.
	part:		Part number. If this is supplied, it is added to the BOM.
	pin:		Pin number. Defaults to blank.
'
m4_define_blind(`connectorMale', `
	componentParseKVArgs(`_connectorMale_',
		(`pos', `Here',
		 `ref', `',
		 `val', `',
		 `description', `',
		 `part', `',
		 `pin', `'), $@)

	# if a ref was defined, prefix it with the sheet number
	m4_ifelse(_connectorMale_ref, `', `', m4_define(`_connectorMale_ref_prefixed', a3SheetNum`'_connectorMale_ref))

	# if ref was defined and is a valid pic label, then add a label
	m4_ifelse(m4_regexp(_connectorMale_ref, `^[A-Z][A-Za-z0-9]*$'), 0,
		_connectorMale_ref`:', `m4_errprint(
		`warning: could not define place name for ref "'_connectorMale_ref`": invalid pic label' m4_newline())')

	[
		pushDir();

		Start: Here;
		move dirToDirection(peekDir()) elen;
		End: Here;

		LabelPos: 1/4 between Start and End;

		arc ccw from polarCoord(Start, 1.6, dirToAngle(peekDir()) - 90) to polarCoord(Start, 1.6, dirToAngle(peekDir()) + 90) with .c at Start;
		line from polarCoord(Start, 1.6, dirToAngle(peekDir())) to End;

		popDir();
	] with .Start at _connectorMale_pos;

	componentDrawTerminalLabel(last [].LabelPos, _connectorMale_pin);

	move to last [].End;
')

m4_divert(0)

# vim: filetype=pic
