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
	refPos:		Reference labelling position. One of blank (default), reverse, below, above, ljust, rjust.
	refPosAdj:	Distance to move the reference label position from the default. In format (x, y).
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
		 `refPos', `',
		 `refPosAdj', `(0, 0)',
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
	refPos:		Reference labelling position. One of blank (default), reverse, below, above, ljust, rjust.
	refPosAdj:	Distance to move the reference label position from the default. In format (x, y).
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
		 `refPos', `',
		 `refPosAdj', `(0, 0)',
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
	refPos:		Reference labelling position. One of blank (default), reverse, below, above, ljust, rjust.
	refPosAdj:	Distance to move the reference label position from the default. In format (x, y).
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
		 `refPos', `',
		 `refPosAdj', `(0, 0)',
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
				m4_ifelse(dirIsVertical(getDir()), 1, `
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
	pos:		Position to place centre at. Defaults to "Here".
	label:		Terminal label/number
	exportLabel:	Either true (default) or false; normally only needed when this is called by terminalGroup() to prevent duplicate labels
'
m4_define_blind(`terminal', `
	componentParseKVArgs(`_terminal_',
		(`pos', `Here',
		 `label', `',
		 `exportLabel', `true'), $@)
	
	_terminalCount := _terminalCount + 1;
	Terminal___Pos[_terminalCount]: circle diam elen/8 invis with .c at _terminal_pos;

	m4_ifelse(_terminal_label, `', `', `
		m4_ifelse(dirIsVertical(getDir()), 1, `
			  "textTerminalLabel(_terminal_label)" at last circle.w + (elen/32,0) rjust
		', `
			  "textTerminalLabel(_terminal_label)" at last circle.n - (0, elen/16) above
		')
		m4_ifelse(_terminal_exportLabel, `true', `componentWriteLabel(_terminal_label, terminal)')
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

Positions are defined as .Start1, .End1 etc.

Usage: terminalGroup([comma-separated key-value parameters])
Params:
	pos:		Position to place first terminal. Defaults to "Here".
	ref:
	val:	
	description:
	refPos:		Reference labelling position. One of blank (default), reverse, below, above, ljust, rjust.
	labels:		Terminal labels/numbers, in syntax (1, 2, 3) etc. Spacers are either blank arguments, or _2_ etc.
	count:		Not required if labels parameter is supplied.
'
m4_define_blind(`terminalGroup', `
	componentParseKVArgs(`_terminalGroup_',
		(`pos', `Here',
		 `ref', `',
		 `val', `',
		 `description', `',
		 `refPos', `',
		 `labels', `',
		 `count', `'), $@)
	
	m4_ifelse(_terminalGroup_count, `', `
		m4_define(`_terminalGroup_count', m4_nargs(m4_extractargs(_terminalGroup_labels)))
		m4_ifelse(_terminalGroup_count, 0, `
			m4_errprintl(`error: terminalGroup has zero count')
			m4_m4exit(1)
		')
	')
	m4_define(`_terminalGroup_totalTerminals', 0)
	m4_define(`_terminalGroup_totalPositions', 0)

	componentHandleRef(_terminalGroup_)
	[
		pushDir();

		Start: Here;

		m4_forloop(i, 1, _terminalGroup_count, `
			m4_define(`_terminal_termText', `')
			m4_ifelse(terminalGroup_labels, `', `', `m4_define(`_terminal_termText', m4_argn(i, m4_extractargs(_terminalGroup_labels)))')

			m4_define(`_terminalGroup_spacerCount', 0)
			m4_ifelse(_terminalGroup_labels, `', `', `
				m4_ifelse(_terminal_termText, `', `m4_define(`_terminalGroup_spacerCount', 1)')
				m4_regexp(_terminal_termText, `^_\([0-9]+\)_$', `m4_define(`_terminalGroup_spacerCount', \1)')
			')

			m4_ifelse(_terminalGroup_spacerCount, 0, `
				m4_define(`_terminalGroup_totalTerminals', m4_eval(_terminalGroup_totalTerminals + 1))
				m4_define(`_terminalGroup_totalPositions', m4_eval(_terminalGroup_totalPositions + 1))

				`N'_terminalGroup_totalTerminals: Here;
				m4_ifelse(_terminalGroup_labels, `', `', `
					`T'm4_patsubst(_terminal_termText, `[^A-Za-z0-9]', `_'): Here;
				')
				dirToDirection(peekDir());
				terminal(m4_ifelse(_terminalGroup_labels, `', `', `label=_terminal_termText'), exportLabel=false);
				m4_ifelse(_terminalGroup_labels, `', `', `
					componentWriteLabel(m4_ifelse(_terminalGroup_ref, `', `', _terminalGroup_ref_prefixed`:')`'_terminal_termText, terminal)
				')
			', `
				m4_define(`_terminalGroup_totalPositions', m4_eval(_terminalGroup_totalPositions + _terminalGroup_spacerCount))
			')

			m4_ifelse(i, _terminalGroup_count, `', `
				  move m4_ifelse(dirIsVertical(peekDir()), 1, `right', `down') m4_ifelse(_terminalGroup_spacerCount, 0, `elen/2', `elen/2 * _terminalGroup_spacerCount');
			')
		')

		boxWidth  = _terminalGroup_totalPositions * elen/2 m4_ifelse(_terminalGroup_labels, `', `', `+ elen/4');
		boxHeight = elen/3;
		box dashed elen/19 m4_ifelse(dirIsVertical(peekDir()), 1, `wid boxWidth ht boxHeight', `wid boxHeight ht boxWidth') \
			at (1/2 between N1 and `N'_terminalGroup_totalTerminals) m4_ifelse(_terminalGroup_labels, `', `', `- m4_ifelse(dirIsVertical(peekDir()), 1, (elen/8, 0), (0, -elen/8))');

		popDir();
	] with .Start at _terminalGroup_pos;

	# Must redefine positions for terminals, as they were enclosed in a scope
	m4_forloop(i, 1, _terminalGroup_totalTerminals, `
		Terminal___Pos[_terminalCount - i + 1]: last [].N`'m4_eval(_terminalGroup_totalTerminals - i + 1);
	')

	componentDrawLabels(_terminalGroup_)

	move to last[].Start;
')


`
Terminal rail.

Positions are defined as .N1, .N2 etc., and also .T[labelname] if those are supplied. If wire labels (and wires) are drawn, their ends are given as .WN1, .WN2 etc.

Usage: terminalRail([comma-separated key-value parameters])
Params:
	pos:		Position to place first terminal. Defaults to "Here".
	ref:
	val:	
	description:
	refPos:		Reference labelling position. One of blank (default), reverse, below, above, ljust, rjust.
	box:		Whether or not to put dashed box around terminal rail. Either true or false (default).
	labels:		Terminal labels/numbers, in syntax (1, 2, 3) etc. Spacers are either blank arguments, or _2_ etc.
	count:		Not required if labels parameter is supplied.
	wires:		Wire labels in syntax (1S1:12, 5Q1:4) etc. Not required; can add later using position references.
	wireLength:	Length of wires. Defaults to elen*1.5.
'
m4_define_blind(`terminalRail', `
	componentParseKVArgs(`_terminalRail_',
		(`pos', `Here',
		 `ref', `',
		 `val', `',
		 `description', `',
		 `refPos', `',
		 `box', `false',
		 `labels', `',
		 `count', `',
		 `wires', `',
		 `wireLength', `elen*1.5'), $@)
	m4_ifelse(_terminalRail_count, `', `
		m4_define(`_terminalRail_count', m4_nargs(m4_extractargs(_terminalRail_labels)))
		m4_ifelse(_terminalRail_count, 0, `
			m4_errprintl(`error: terminalRail has zero count')
			m4_m4exit(1)
		')
	')

	componentHandleRef(_terminalRail_)
	[
		pushDir();

		Start: Here;
		move dirToDirection(peekDir());
		End: Here;

		m4_define(`_terminalRail_totalTerminals', 0)
		move to Start;
		m4_forloop(i, 1, _terminalRail_count, `
			m4_define(`_terminal_termText', `')
			m4_ifelse(terminalRail_labels, `', `', `m4_define(`_terminal_termText', m4_argn(i, m4_extractargs(_terminalRail_labels)))')

			m4_define(`_terminalRail_spacerCount', 0)
			m4_ifelse(_terminalRail_labels, `', `', `
				m4_ifelse(_terminal_termText, `', `m4_define(`_terminalRail_spacerCount', 1)')
				m4_regexp(_terminal_termText, `^_\([0-9]+\)_$', `m4_define(`_terminalRail_spacerCount', \1)')
			')

			m4_ifelse(_terminalRail_spacerCount, 0, `
				m4_define(`_terminalRail_totalTerminals', m4_eval(_terminalRail_totalTerminals + 1))

				`Start'_terminalRail_totalTerminals: Here;
				line dirToDirection(peekDir()) elen/8;
				box m4_ifelse(dirIsVertical(peekDir()), 1, `wid elen/2 ht elen/4', `wid elen/4 ht elen/2') with dirToCompass(dirRev(peekDir())) at last line.end;
				`End'_terminalRail_totalTerminals: last box`'dirToCompass(peekDir());
				`N'_terminalRail_totalTerminals: `End'_terminalRail_totalTerminals;
				m4_ifelse(_terminalRail_labels, `', `', `
					`T'm4_patsubst(_terminal_termText, `[^A-Za-z0-9]', `_'): `N'_terminalRail_totalTerminals;
					"textTerminalLabel(_terminal_termText)" at last box.c;
					componentWriteLabel(m4_ifelse(_terminalRail_ref, `', `', _terminalRail_ref_prefixed`:')_terminal_termText, terminal)
				')

				m4_ifelse(_terminalRail_wires, `', `', `
					m4_define(`_terminal_wireText', m4_argn(i, m4_extractargs(_terminalRail_wires)))
					m4_ifelse(_terminal_wireText, `', `', `
						wire(dirToDirection(peekDir()) _terminalRail_wireLength from `N'_terminalRail_totalTerminals, _terminal_wireText, end)
						`WN'_terminalRail_totalTerminals: Here;
					')
				')

				m4_ifelse(i, _terminalRail_count, `', `move to `Start'_terminalRail_totalTerminals then m4_ifelse(dirIsVertical(peekDir()), 1, `right', `down') elen/2');
			', `
				move m4_ifelse(dirIsVertical(peekDir()), 1, `right', `down') (elen/2 * _terminalRail_spacerCount);
			')
		')

		popDir();
	] with .Start at _terminalRail_pos;


	componentDrawLabels(_terminalRail_)

	m4_ifelse(_terminalRail_box, `true', `box dashed elen/19 wid last [].wid + elen/4 ht last [].ht + elen/4 with .c at last [].c');

	move to last [].End;
')
