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
	m4_define(`_coil_ref', `')
	m4_define(`_coil_val', `')
	m4_define(`_coil_description', `')
	m4_define(`_coil_part', `')
	m4_define(`_coil_startLabel', `A1')
	m4_define(`_coil_endLabel', `A2')

	# parse key-value arguments
	m4_prefixKVArgs(`_coil_', $@)

	# remove double quotes from those args
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

		{
			line dirToDirection(peekDir()) elen invis;
		}

		line dirToDirection(peekDir()) elen*(3/8);
		Start: last line.start;

		if dirIsVertical(peekDir()) then {
			box wid elen*(3/8) ht elen/4;
		} else {
			box wid elen/4 ht elen*(3/8);
		}

		line dirToDirection(peekDir()) elen*(3/8);
		End: last line.end;

		popDir();
	]

	# display terminal labels
	if dirIsVertical(getDir()) then {
		"textTerminalLabel(_coil_startLabel)" at last [].Start rjust;
		"textTerminalLabel(_coil_endLabel)" at last [].End rjust;
	} else {
		"textTerminalLabel(_coil_startLabel)" at last [].Start above;
		"textTerminalLabel(_coil_endLabel)" at last [].End above;
	}

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

m4_divert(0)

# vim: filetype=pic
