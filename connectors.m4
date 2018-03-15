`
Single male pin connector. Draws in current direction.

Usage: connectorMale([comma-separated key-value parameters])
Params:
	pos:		Position to place ".Start" at. Defaults to "Here".
	flipped:	Whether connector is flipped (i.e. draws connector part first with trailing wire). Either "true" or (default) "false".
	ref:		Component reference name. Must be a valid pic label (no spaces, starts with capital
			letter). Will prefix reference name with the current sheet number.
	val:		Component value
	description:	Additional text describing component purpose etc.
	part:		Part number. If this is supplied, it is added to the BOM.
	pin:		Pin number. Defaults to blank.
	len:		Pin extension length. Defaults to elen.
'
m4_define_blind(`connectorMale', `
	componentParseKVArgs(`_connectorMale_',
		(`pos', `Here',
		 `flipped', `false',
		 `ref', `',
		 `val', `',
		 `description', `',
		 `part', `',
		 `pin', `',
		 `len', `elen'), $@)
	componentHandleRef(_connectorMale_)
	[
		pushDir();

		Start: Here;
		move dirToDirection(peekDir()) _connectorMale_len;
		End: Here;

		m4_ifelse(_connectorMale_flipped, true, `
			AO: Start;
			BO: End;
		', `
			AO: End;
			BO: Start;
		')


		angle = angleBetweenPoints(AO, BO);

		LabelPos: polarCoord(AO, elen*7/16, angle);
		
		circle rad elen*1/16 at polarCoord(AO, elen/16, angle) shade "black";
		Sq1: polarCoord(last circle.c, elen/16, angle + 90);
		Sq2: polarCoord(last circle.c, elen/16, angle - 90);
		Sq3: polarCoord(Sq2, elen*3/16, angle);
		Sq4: polarCoord(Sq1, elen*3/16, angle);

		line from last circle.c to Sq1 then to Sq4 then to Sq3 then to Sq2 then to last circle.c shaded "black";
		line from polarCoord(AO, elen*3/16, angle) to BO;

		popDir();
	] with .Start at _connectorMale_pos;

	componentDrawTerminalLabel(last [].LabelPos, _connectorMale_pin);
	componentDrawLabels(_connectorMale_)
	componentWriteBOM(_connectorMale_)

	move to last [].End;
')


`
Single female pin connector. Draws in current direction.

Usage: connectorFemale([comma-separated key-value parameters])
Params:
	pos:		Position to place ".Start" at. Defaults to "Here".
	flipped:	Whether connector is flipped (i.e. draws connector part first with trailing wire). Either "true" or (default) "false".
	ref:		Component reference name. Must be a valid pic label (no spaces, starts with capital
			letter). Will prefix reference name with the current sheet number.
	val:		Component value
	description:	Additional text describing component purpose etc.
	part:		Part number. If this is supplied, it is added to the BOM.
	pin:		Pin number. Defaults to blank.
	len:		Pin extension length. Defaults to elen.
'
m4_define_blind(`connectorFemale', `
	componentParseKVArgs(`_connectorFemale_',
		(`pos', `Here',
		 `flipped', `false',
		 `ref', `',
		 `val', `',
		 `description', `',
		 `part', `',
		 `pin', `',
		 `len', `elen'), $@)
	componentHandleRef(_connectorFemale_)
	[
		pushDir();

		Start: Here;
		move dirToDirection(peekDir()) _connectorFemale_len;
		End: Here;

		m4_ifelse(_connectorFemale_flipped, true, `
			AO: Start;
			BO: End;
		', `
			AO: End;
			BO: Start;
		')

		angle = angleBetweenPoints(AO, BO);

		LabelPos: polarCoord(AO, elen/4, angle);

		arc ccw from polarCoord(AO, elen/8, angle - 90) to polarCoord(AO, elen/8, angle + 90) with .c at AO;
		line from polarCoord(AO, elen/8, angle) to BO;

		popDir();
	] with .Start at _connectorFemale_pos;

	componentDrawTerminalLabel(last [].LabelPos, _connectorFemale_pin);
	componentDrawLabels(_connectorFemale_)
	componentWriteBOM(_connectorFemale_)

	move to last [].End;
')


`
Multi-pin connector. Pins are numbered from 1 to count.

Defines position labels for each pin (replace "n" with pin number):
	.Tn: End position of pin
	.Xn: Connector-end of pin
	.Cn: Sub-connector itself (e.g. can use .C3.Start etc.)

Usage: connector([comma-separated key-value parameters])
Params:
	pos:		Position to place pin 1 ".Start" at. Defaults to "Here".
	flipped:	Whether connector is flipped (i.e. draws connector part first with trailing wire). Either "true" or (default) "false".
	ref:		Component reference name. Must be a valid pic label (no spaces, starts with capital
			letter). Will prefix reference name with the current sheet number.
	val:		Component value
	description:	Additional text describing component purpose etc.
	part:		Part number. If this is supplied, it is added to the BOM.
	count:		Pin count. Defaults to 1, or the count of labels in "labels" if those are supplied.
	labels:		Pin labels, in syntax "(1, 2, 3, PE)" etc. If not supplied, will auto-number from 1 to pincount.
	gender:		One of "male", "female", "m", "f", "M", or "F". Defaults to "female".
	showPinNums:	Whether or not to display pin numbers. Either (default) "true" or false.
	len:		Pin extension length. Defaults to elen.
'
m4_define_blind(`connector', `
	componentParseKVArgs(`_connector_',
		(`pos', `Here',
		 `flipped', `false',
		 `ref', `',
		 `val', `',
		 `description', `',
		 `part', `',
		 `count', `',
		 `labels', `',
		 `gender', `female',
		 `showPinNums', `true',
		 `len', `elen'), $@)
	componentHandleRef(_connector_)
	
	# determine gender
	m4_define(`_connector_gender_orig', m4_defn(`_connector_gender'))
	m4_undefine(`_connector_gender')
	m4_ifelse(_connector_gender_orig, `male',   `m4_define(`_connector_gender', Male)',
	          _connector_gender_orig, `m',      `m4_define(`_connector_gender', Male)',
	          _connector_gender_orig, `M',      `m4_define(`_connector_gender', Male)',
		  _connector_gender_orig, `female', `m4_define(`_connector_gender', Female)',
		  _connector_gender_orig, `f',      `m4_define(`_connector_gender', Female)',
		  _connector_gender_orig, `F',      `m4_define(`_connector_gender', Female)')
	m4_ifdef(`_connector_gender', `', `m4_errprint(`error: connector: gender unrecognised: "' _connector_gender_orig `"' m4_newline())
	                                   m4_m4exit(1)')

	m4_ifelse(_connector_labels, `', `
		m4_ifelse(_connector_count, `', `m4_define(`_connector_count', 1)')
		m4_define(`_connector_labels', `( m4_forloop(i, 1, _connector_count, `i, ') )')
	', `
		m4_ifelse(_connector_count, `', `m4_define(`_connector_count', m4_nargs(m4_extractargs(_connector_labels)))')
	')

	[
		Start: Here;
		m4_forloop(`i', 1, _connector_count, `
			C`'i: m4_indir(connector`'_connector_gender,
			               pin=m4_ifelse(_connector_showPinNums, true, m4_argn(i, m4_extractargs(_connector_labels))),
				       flipped=_connector_flipped,
				       len=_connector_len)
			X`'i: last [].AO;
			T`'i: last [].BO;
			move to last [].Start;
			m4_ifelse(i, _connector_count, `', `
				m4_ifelse(dirIsVertical(peekDir()), 1, `
					move `right' elen/2;
				', `
					move `down' elen/2;
				')
			')
		')
		End: C1.End;
	] with .Start at _connector_pos;

	componentDrawLabels(_connector_)
	componentWriteBOM(_connector_)

	move to last [].End;
')


`
Single terminal, with optional label.

Usage: terminal([comma-separated key-value parameters])
Params:
	pos:	Position to place centre at. Defaults to "Here".
	label:	Terminal label/number
'
m4_define_blind(`terminal', `
	componentParseKVArgs(`_terminal_',
		(`pos', `Here',
		 `label', `'), $@)
	
	_terminalCount := _terminalCount + 1;
	Terminal___Pos[_terminalCount]: circle diam elen/8 invis with .c at _terminal_pos;

	m4_ifelse(_terminal_label, `', `', `
		m4_ifelse(dirIsVertical(getDir()), 1, `
			  "textTerminalLabel(_terminal_label)" at last circle.w + (elen/32,0) rjust
		', `
			  "textTerminalLabel(_terminal_label)" at last circle.n - (0, elen/16) rjust
		')
	')

	move to last circle.c;
')


`
Support macros for terminal drawing; we need to defer drawing to the end, so terminals don't have wires inside.
'
m4_define_blind(`terminalsInit', `
	_terminalCount = 0;
')
m4_define_blind(`terminalsDrawDeferred', `
	for i = 1 to _terminalCount do {
		circle diam elen/8 outline "black" shaded "white" with .c at Terminal___Pos[i];
	}
')


`
Terminal group.

Positions are defined as .T1, .T2 etc., and also .T[labelname] if those are supplied.

Usage: terminalGroup([comma-separated key-value parameters])
Params:
	pos:		Position to place first terminal. Defaults to "Here".
	ref:
	val:	
	description:
	labels:		Terminal labels/numbers, in syntax (1, 2, 3) etc.
	count:		Not required if labels parameter is supplied.
'
m4_define_blind(`terminalGroup', `
	componentParseKVArgs(`_terminalGroup_',
		(`pos', `Here',
		 `ref', `',
		 `val', `',
		 `description', `',
		 `labels', `',
		 `count', `'), $@)
	
	m4_ifelse(_terminalGroup_count, `', `
		m4_define(`_terminalGroup_count', m4_nargs(m4_extractargs(_terminalGroup_labels)))
		m4_ifelse(_terminalGroup_count, 0, `
			m4_errprintl(`error: terminalGroup has zero count')
			m4_m4exit(1)
		')
	')

	componentHandleRef(_terminalGroup_)
	[
		pushDir();

		Start: Here;

		m4_forloop(i, 1, _terminalGroup_count, `
			`T'i: Here;
			m4_ifelse(_terminalGroup_labels, `', `', `
				`T'm4_patsubst(m4_argn(i, m4_extractargs(_terminalGroup_labels)), `[^A-Za-z0-9]', `_'): Here;
			')
			terminal(m4_ifelse(_terminalGroup_labels, `', `', `label=m4_argn(i, m4_extractargs(_terminalGroup_labels))'));
			move m4_ifelse(dirIsVertical(peekDir()), 1, `right', `down') elen/2;
		')

		boxWidth  = _terminalGroup_count * elen/2 m4_ifelse(_terminalGroup_labels, `', `', `+ elen/4');
		boxHeight = elen/3;
		box dashed elen/19 m4_ifelse(dirIsVertical(peekDir()), 1, `wid boxWidth ht boxHeight', `wid boxHeight wid boxWidth') \
			at (1/2 between T1 and `T'_terminalGroup_count) m4_ifelse(_terminalGroup_labels, `', `', `- m4_ifelse(dirIsVertical(peekDir()), 1, (elen/8, 0), (0, -elen/8))');

		popDir();
	] with .Start at _terminalGroup_pos;

	# Must redefine positions for terminals, as they were enclosed in a scope
	m4_forloop(i, 1, _terminalGroup_count, `
		Terminal___Pos[_terminalCount - i + 1]: last [].T`'m4_eval(_terminalGroup_count - i + 1);
	')

	componentDrawLabels(_terminalGroup_)

	move to last[].Start;
')
