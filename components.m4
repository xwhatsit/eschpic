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
m4_define_blind(`resistor', `
	# set default args
	m4_define(`_resistor_ref', `')
	m4_define(`_resistor_val', `')
	m4_define(`_resistor_description', `')
	m4_define(`_resistor_part', `')

	# parse key-value arguments
	m4_prefixKVArgs(`_resistor_', $@)

	# remove double quotes from those args
	m4_define(`_resistor_ref', m4_dequote(_resistor_ref))
	m4_define(`_resistor_val', m4_dequote(_resistor_val))
	m4_define(`_resistor_description', m4_dequote(_resistor_description))
	m4_define(`_resistor_part', m4_dequote(_resistor_part))

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
	]

	# compose label(s)
	m4_define(`_resistor_labels', `')
	m4_ifelse(_resistor_ref, `', `',
		`m4_define(`_resistor_labels',
			m4_ifdef(`_resistor_labels', _resistor_labels` \\') textComponentRef(_resistor_ref_prefixed))')
	m4_ifelse(_resistor_val, `', `',
		`m4_define(`_resistor_labels',
			m4_ifdef(`_resistor_labels', _resistor_labels` \\') textComponentVal(_resistor_val))')
	m4_ifelse(_resistor_description, `', `',
		`m4_define(`_resistor_labels',
			m4_ifdef(`_resistor_labels', _resistor_labels` \\') textComponentDescription(_resistor_description))')
	
	# display label(s), if present 
	m4_ifelse(_resistor_labels, `', `', `
		if dirIsVertical(getDir()) then {
			"textMultiLine(_resistor_labels)" at last [].w rjust;
		} else {
			"textMultiLine(_resistor_labels)" at last [].n above;
		}
	')

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
	# set default args
	m4_define(`_earth_pos', `Here')
	m4_define(`_earth_type', `plain')

	# parse key-value arguments
	m4_prefixKVArgs(`_earth_', $@)

	# remove double-quotes from those args
	m4_define(`_earth_pos', m4_dequote(_earth_pos))
	m4_define(`_earth_type', m4_dequote(_earth_type))

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
	# set default args
	m4_define(`_coil_pos', `Here')
	m4_define(`_coil_ref', `')
	m4_define(`_coil_val', `')
	m4_define(`_coil_description', `')
	m4_define(`_coil_part', `')
	m4_define(`_coil_startLabel', `A1')
	m4_define(`_coil_endLabel', `A2')

	# parse key-value arguments
	m4_prefixKVArgs(`_coil_', $@)

	# remove double quotes from those args
	m4_define(`_coil_pos', m4_dequote(_coil_pos))
	m4_define(`_coil_ref', m4_dequote(_coil_ref))
	m4_define(`_coil_val', m4_dequote(_coil_val))
	m4_define(`_coil_description', m4_dequote(_coil_description))
	m4_define(`_coil_part', m4_dequote(_coil_part))
	m4_define(`_coil_startLabel', m4_dequote(_coil_startLabel))
	m4_define(`_coil_endLabel', m4_dequote(_coil_endLabel))

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
	m4_define(`_coil_label_alignment', `m4_ifelse(dirIsVertical(getDir()), `1', `rjust', `above')')
	"textTerminalLabel(_coil_startLabel)" at last [].AO _coil_label_alignment;
	"textTerminalLabel(_coil_endLabel)" at last [].BO _coil_label_alignment;

	# compose label(s)
	m4_define(`_coil_labels', `')
	m4_ifelse(_coil_ref, `', `',
		`m4_define(`_coil_labels',
			m4_ifdef(`_coil_labels', _coil_labels` \\') textComponentRef(_coil_ref_prefixed))')
	m4_ifelse(_coil_val, `', `',
		`m4_define(`_coil_labels',
			m4_ifdef(`_coil_labels', _coil_labels` \\') textComponentVal(_coil_val))')
	m4_ifelse(_coil_description, `', `',
		`m4_define(`_coil_labels',
			m4_ifdef(`_coil_labels', _coil_labels` \\') textComponentDescription(_coil_description))')
	
	# display label(s), if present 
	m4_ifelse(_coil_labels, `', `', `
		if dirIsVertical(getDir()) then {
			"textMultiLine(_coil_labels)" at last [].w rjust;
		} else {
			"textMultiLine(_coil_labels)" at last [].n above;
		}
	')

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
	# set default args
	m4_define(`_contactNO_pos', `Here')
	m4_define(`_contactNO_ref', `')
	m4_define(`_contactNO_val', `')
	m4_define(`_contactNO_description', `')
	m4_define(`_contactNO_part', `')
	m4_define(`_contactNO_set', `1')
	m4_define(`_contactNO_startLabel', `3')
	m4_define(`_contactNO_endLabel', `4')

	# parse key-value arguments
	m4_prefixKVArgs(`_contactNO_', $@)

	# remove double quotes from those args
	m4_define(`_contactNO_pos', m4_dequote(_contactNO_pos))
	m4_define(`_contactNO_ref', m4_dequote(_contactNO_ref))
	m4_define(`_contactNO_val', m4_dequote(_contactNO_val))
	m4_define(`_contactNO_description', m4_dequote(_contactNO_description))
	m4_define(`_contactNO_part', m4_dequote(_contactNO_part))
	m4_define(`_contactNO_set', m4_dequote(_contactNO_set))
	m4_define(`_contactNO_startLabel', m4_dequote(_contactNO_startLabel))
	m4_define(`_contactNO_endLabel', m4_dequote(_contactNO_endLabel))

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
		if dirIsVertical(peekDir()) then {
			line from BO to BM then to BM + (-elen/8, elen*(3/8));
		} else {
			line from BO to BM then to BM + (-elen*(3/8), elen/8);
		}

		# if terminal labels are defined, add positional labels as "T_" + name (e.g. ".T_13")
		m4_ifelse(_contactNO_fullStartLabel, `', `', `T_'_contactNO_fullStartLabel`: AO')
		m4_ifelse(_contactNO_fullEndLabel,   `', `', `T_'_contactNO_fullEndLabel`:   BO')

		popDir();
	] with .Start at _contactNO_pos;

	# display terminal labels
	m4_define(`_contactNO_label_alignment', `m4_ifelse(dirIsVertical(getDir()), `1', `rjust', `above')')
	"textTerminalLabel(_contactNO_set`'_contactNO_startLabel)" at last [].AO _contactNO_label_alignment;
	"textTerminalLabel(_contactNO_set`'_contactNO_endLabel)" at last [].BO _contactNO_label_alignment;

	# compose label(s)
	m4_define(`_contactNO_labels', `')
	m4_ifelse(_contactNO_ref, `', `',
		`m4_define(`_contactNO_labels',
			m4_ifdef(`_contactNO_labels', _contactNO_labels` \\') textComponentRef(_contactNO_ref_prefixed))')
	m4_ifelse(_contactNO_val, `', `',
		`m4_define(`_contactNO_labels',
			m4_ifdef(`_contactNO_labels', _contactNO_labels` \\') textComponentVal(_contactNO_val))')
	m4_ifelse(_contactNO_description, `', `',
		`m4_define(`_contactNO_labels',
			m4_ifdef(`_contactNO_labels', _contactNO_labels` \\') textComponentDescription(_contactNO_description))')
	
	# display label(s), if present 
	m4_ifelse(_contactNO_labels, `', `', `
		if dirIsVertical(getDir()) then {
			"textMultiLine(_contactNO_labels)" at last [].w rjust;
		} else {
			"textMultiLine(_contactNO_labels)" at last [].n above;
		}
	')

	move to last [].End
')

m4_divert(0)

# vim: filetype=pic
