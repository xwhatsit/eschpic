# Set base unit used for components
elen = 12.7;

m4_divert(-1)

`
Macro to parse and set defaults for components which take key-value params.

Usage: componentParseKVArgs(prefix, (argname_1, argdefault_1, [argname_n, argdefault_n]), originalArgs)
'
m4_define_blind(`componentParseKVArgs', `
	m4_pushdef(`componentPrefix', $1)
	_$0_setDefault$2
	m4_prefixKVArgs(componentPrefix, m4_shift(m4_shift($@)))
	_$0_removeDoubleQuotes$2
	m4_popdef(`componentPrefix')
')
m4_define_blind(`_componentParseKVArgs_setDefault', `
	m4_forloopn(`argI', 1, $#, 2, `m4_define(componentPrefix`'m4_argn(argI, $@),
		m4_argn(m4_eval(argI + 1), $@))')
')
m4_define_blind(`_componentParseKVArgs_removeDoubleQuotes', `
	m4_forloopn(`argI', 1, $#, 2, `
		m4_define(componentPrefix`'m4_argn(argI, $@),
			m4_dequote(m4_indir(componentPrefix`'m4_argn(argI, $@))))')
')


`
Macro to assist drawing main component labels (ref/val/description etc.)

Usage: componentDrawLabels(prefix)
'
m4_define_blind(`componentDrawLabels', `
	m4_ifelse($1, `', `', `
		m4_pushdef($1`labels', `')

		m4_ifelse(m4_indir($1`ref'), `', `',
			`m4_define($1`labels',
				m4_ifdef($1`labels', m4_indir($1`labels')` \\') 
					textComponentRef(m4_indir($1`ref_prefixed')))')
		m4_ifelse(m4_indir($1`val'), `', `',
			`m4_define($1`labels',
				m4_ifdef($1`labels', m4_indir($1`labels')` \\')
					textComponentVal(m4_indir($1`val')))')
		m4_ifelse(m4_indir($1`description'), `', `',
			`m4_define($1`labels',
				m4_ifdef($1`labels', m4_indir($1`labels')` \\')
					textComponentDescription(m4_indir($1`description')))')

		if dirIsVertical(getDir()) then {
			"textMultiLine(m4_indir($1`labels'))" at last [].w - (elen/4, 0) rjust;
		} else {
			"textMultiLine(m4_indir($1`labels'))" at last [].n + (0, elen/8) above;
		}

		m4_popdef($1`labels')
	')
')


`
Macro to assist drawing terminal labels

Usage: componentDrawTerminalLabel(position, label)
'
m4_define_blind(`componentDrawTerminalLabel', `
	"textTerminalLabel($2)" at $1 m4_ifelse(dirIsVertical(getDir()), `1', `+(elen/32,0) rjust', `-(0,elen/16) above')
')


`
Resistor. Draws in current direction.

Usage: resistor([comma-separated key-value parameters])
Params:
	pos:		Position to place ".Start" at. Defaults to "Here".
	ref:		Component reference name. Must be a valid pic label (no spaces, starts with capital
			letter). Will prefix reference name with the current sheet number.
	val:		Component value
	description:	Additional text describing component purpose etc.
	part:		Part number. If this is supplied, it is added to the BOM.
'
m4_define_blind(`resistor', `
	componentParseKVArgs(`_resistor_',
		(`pos', `Here',
		 `ref', `',
		 `val', `',
		 `description', `',
		 `part', `'), $@)

	# if a ref was defined, prefix it with the sheet number
	m4_ifelse(_resistor_ref, `', `', m4_define(`_resistor_ref_prefixed', a3SheetNum`'_resistor_ref))

	# if ref was defined and is a valid pic label, then add a label
	m4_ifelse(m4_regexp(_resistor_ref, `^[A-Z][A-Za-z0-9]*$'), 0,
		_resistor_ref`:', `m4_errprint(
		`warning: could not define place name for ref "'_resistor_ref`": invalid pic label' m4_newline())')
	[
		pushDir();

		line dirToDirection(peekDir()) elen/4;
		Start: last line.start;

		if dirIsVertical(peekDir()) then {
			box wid elen/5 ht elen/2
		} else {
			box wid elen/2 ht elen/5
		}

		line dirToDirection(peekDir()) elen/4;
		End: last line.end;

		popDir();
	] with .Start at _resistor_pos;

	componentDrawLabels(_resistor_)

	move to last [].End
')


`
Earth/ground symbol. Single-ended.

Usage: earth([comma-separated key-value parameters])
Params:
	pos:	Position to place ".Start" at. Defaults to "Here".
	type:	Earth type (plain, noiseless, protective, chassis). Default is "plain".
'
m4_define_blind(`earth', `
	componentParseKVArgs(`_earth_',
		(`pos', `Here',
		 `type', `plain'), $@)

	[
		pushDir();

		{
			line down elen/4;
			Start: last line.start;
			Stub: last line.end;

			m4_ifelse(_earth_type, `chassis', `', `
				{ line left elen/6; }
				{ line right elen/6; }
				move down elen/16;
				Centre: Here;
				{ line left elen/9; }
				{ line right elen/9; }
				move down elen/16;
				BottomLine: Here;
				{ line left elen/14; }
				{ line right elen/14; }
			')

			m4_ifelse(
				_earth_type, `noiseless', `
					arc cw from polarCoord(Centre, elen/4, 210) \
					       to polarCoord(Centre, elen/4, 330)   \
					       with .c at Centre;
				',
				_earth_type, `protective', `
					circle rad elen/4 at Centre;
				',
				_earth_type, `chassis', `
					line from Stub + (elen/12, -elen/8) to Stub + (elen/6, 0) \
						then left elen/6 \
						then to Here + (-elen/12, -elen/8);
					line from Stub + (-elen/4, -elen/8) to Stub + (-elen/6, 0) \
						then right elen/6;
				'
			)
		}

		popDir();
	] with .Start at _earth_pos;
	move to last [].Start;
')


`
Convenience macros for the special earth types. PE = protectiveEarth.
'
m4_define_blind(`noiselessEarth', `earth(type=noiseless, $@)')
m4_define_blind(`chassisEarth', `earth(type=chassis, $@)')
m4_define_blind(`protectiveEarth', `earth(type=protective, $@)')
m4_define(`PE', m4_defn(`protectiveEarth'))


`
Coil. Draws in current direction.

Usage: coil([comma-separated key-value parameters])
Params:
	pos:		Position to place ".Start" at. Defaults to "Here".
	ref:		Component reference name. Must be a valid pic label (no spaces, starts with capital
			letter). Will prefix reference name with the current sheet number.
	val:		Component value
	description:	Additional text describing component purpose etc.
	part:		Part number. If this is supplied, it is added to the BOM.
	startLabel:	Starting terminal label. Defaults to "A1".
	endLabel:	Ending terminal label. Defaults to "A2".
'
m4_define_blind(`coil', `
	componentParseKVArgs(`_coil_',
		(`pos', `Here',
		 `ref', `',
		 `val', `',
		 `description', `',
		 `part', `',
		 `startLabel', `A1',
		 `endLabel', `A2'), $@)

	# if a ref was defined, prefix it with the sheet number
	m4_ifelse(_coil_ref, `', `', m4_define(`_coil_ref_prefixed', a3SheetNum`'_coil_ref))

	# if ref was defined and is a valid pic label, then add a label
	m4_ifelse(m4_regexp(_coil_ref, `^[A-Z][A-Za-z0-9]*$'), 0,
		_coil_ref`:', `m4_errprint(
		`warning: could not define place name for ref "'_coil_ref`": invalid pic label' m4_newline())')
	[
		pushDir();

		Start: Here;
		move dirToDirection(peekDir()) elen;
		End: Here;
		if dirIsConventional(peekDir()) then {
			AO: Start;
			BO: End;
		} else {
			AO: End;
			BO: Start;
		}
		AM: 3/8 of the way between AO and BO;
		BM: 3/8 of the way between BO and AO;
		Centre: 1/2 of the way between AO and BO;

		line from BO to BM;
		line from AO to AM;

		if dirIsVertical(peekDir()) then {
			box wid elen*(3/8) ht elen/4 with .c at Centre;
		} else {
			box wid elen/4 ht elen*(3/8) with .c at Centre;
		}

		# if terminal labels are defined, add positional labels as "T" + name (e.g. ".T_A1")
		m4_ifelse(_coil_fullStartLabel, `', `', `T_'_coil_startLabel`: AO')
		m4_ifelse(_coil_fullEndLabel,   `', `', `T_'_coil_endLabel`:   BO')

		popDir();
	] with .Start at _coil_pos;

	# display terminal labels
	componentDrawTerminalLabel(last [].AO, textTerminalLabel(_coil_startLabel))
	componentDrawTerminalLabel(last [].BO, textTerminalLabel(_coil_endLabel))

	componentDrawLabels(_coil_)

	move to last [].End
')


`
Normally-open contact. Draws in current direction.

Usage: contactNO([comma-separated key-value parameters])
Params:
	pos:		Position to place ".Start" at. Defaults to "Here".
	ref:		Component reference name. Must be a valid pic label (no spaces, starts with capital
			letter). Will prefix reference name with the current sheet number.
	val:		Component value
	description:	Additional text describing component purpose etc.
	part:		Part number. If this is supplied, it is added to the BOM.
	set:		Contact set number, used for automatic start/end terminal labels. Defaults to "1".
	startLabel:	Starting terminal label. Defaults to "3".
	endLabel:	Ending terminal label. Defaults to "4".
'
m4_define_blind(`contactNO', `
	componentParseKVArgs(`_contactNO_',
		(`pos', `Here',
		 `ref', `',
		 `val', `',
		 `description', `',
		 `part', `',
		 `set', `1',
		 `startLabel', `3',
		 `endLabel', `4'), $@)

	# if a ref was defined, prefix it with the sheet number
	m4_ifelse(_contactNO_ref, `', `', m4_define(`_contactNO_ref_prefixed', a3SheetNum`'_contactNO_ref))

	# if ref was defined and is a valid pic label, then add a label
	m4_ifelse(m4_regexp(_contactNO_ref, `^[A-Z][A-Za-z0-9]*$'), 0,
		_contactNO_ref`:', `m4_errprint(
		`warning: could not define place name for ref "'_contactNO_ref`": invalid pic label' m4_newline())')
	
	# assemble terminal labels
	m4_define(`_contactNO_fullStartLabel', _contactNO_set`'_contactNO_startLabel)
	m4_define(`_contactNO_fullEndLabel', _contactNO_set`'_contactNO_endLabel)

	[
		pushDir();

		Start: Here;
		move dirToDirection(peekDir()) elen;
		End: Here;
		if dirIsConventional(peekDir()) then {
			AO: Start;
			BO: End;
		} else {
			AO: End;
			BO: Start;
		}

		AM: 5/16 of the way between AO and BO;
		BM: 5/16 of the way between BO and AO;

		line from AO to AM;
		line from BO to BM;
		if dirIsVertical(peekDir()) then {
			continue to BM + (-elen/8, elen*(3/8));
		} else {
			continue to BM + (-elen*(3/8), elen/8);
		}
		MidContact: 1/2 of the way between Here and BM;

		# if terminal labels are defined, add positional labels as "T_" + name (e.g. ".T_13")
		m4_ifelse(_contactNO_fullStartLabel, `', `', `T_'_contactNO_fullStartLabel`: AO')
		m4_ifelse(_contactNO_fullEndLabel,   `', `', `T_'_contactNO_fullEndLabel`:   BO')

		popDir();
	] with .Start at _contactNO_pos;

	# display terminal labels
	componentDrawTerminalLabel(last [].AO, _contactNO_set`'_contactNO_startLabel);
	componentDrawTerminalLabel(last [].BO, _contactNO_set`'_contactNO_endLabel);

	componentDrawLabels(_contactNO_)

	move to last [].End
')


`
Normally-closed contact. Draws in current direction.

Usage: contactNC([comma-separated key-value parameters])
Params:
	pos:		Position to place ".Start" at. Defaults to "Here".
	ref:		Component reference name. Must be a valid pic label (no spaces, starts with capital
			letter). Will prefix reference name with the current sheet number.
	val:		Component value
	description:	Additional text describing component purpose etc.
	part:		Part number. If this is supplied, it is added to the BOM.
	set:		Contact set number, used for automatic start/end terminal labels. Defaults to "1".
	startLabel:	Starting terminal label. Defaults to "1".
	endLabel:	Ending terminal label. Defaults to "2".
'
m4_define_blind(`contactNC', `
	componentParseKVArgs(`_contactNC_',
		(`pos', `Here',
		 `ref', `',
		 `val', `',
		 `description', `',
		 `part', `',
		 `set', `1',
		 `startLabel', `1',
		 `endLabel', `2'), $@)

	# if a ref was defined, prefix it with the sheet number
	m4_ifelse(_contactNC_ref, `', `', m4_define(`_contactNC_ref_prefixed', a3SheetNum`'_contactNC_ref))

	# if ref was defined and is a valid pic label, then add a label
	m4_ifelse(m4_regexp(_contactNC_ref, `^[A-Z][A-Za-z0-9]*$'), 0,
		_contactNC_ref`:', `m4_errprint(
		`warning: could not define place name for ref "'_contactNC_ref`": invalid pic label' m4_newline())')
	
	# assemble terminal labels
	m4_define(`_contactNC_fullStartLabel', _contactNC_set`'_contactNC_startLabel)
	m4_define(`_contactNC_fullEndLabel', _contactNC_set`'_contactNC_endLabel)

	[
		pushDir();

		Start: Here;
		move dirToDirection(peekDir()) elen;
		End: Here;
		if dirIsConventional(peekDir()) then {
			AO: Start;
			BO: End;
		} else {
			AO: End;
			BO: Start;
		}

		AM: 1/2.9 of the way between AO and BO;
		BM: 5/16 of the way between BO and AO;

		if dirIsVertical(peekDir()) then {
			topAngle = 0;
			bottomAngle = 72;
		} else {
			topAngle = 270;
			bottomAngle = 198;
		}
		line from AO to AM then to polarCoord(AM, elen*(5/32), topAngle);
		line from BO to BM then to polarCoord(BM, elen*0.42, bottomAngle);
		MidContact: polarCoord(BM, elen*(3/16) / sind(bottomAngle), bottomAngle);

		# if terminal labels are defined, add positional labels as "T_" + name (e.g. ".T_13")
		m4_ifelse(_contactNC_fullStartLabel, `', `', `T_'_contactNC_fullStartLabel`: AO')
		m4_ifelse(_contactNC_fullEndLabel,   `', `', `T_'_contactNC_fullEndLabel`:   BO')

		popDir();
	] with .Start at _contactNC_pos;

	# display terminal labels
	componentDrawTerminalLabel(last [].AO, textTerminalLabel(_contactNC_set`'_contactNC_startLabel));
	componentDrawTerminalLabel(last [].BO, textTerminalLabel(_contactNC_set`'_contactNC_endLabel));

	componentDrawLabels(_contactNC_)

	move to last [].End
')


m4_divert(0)

# vim: filetype=pic
