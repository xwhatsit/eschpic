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
'
m4_define_blind(`connectorMale', `
	componentParseKVArgs(`_connectorMale_',
		(`pos', `Here',
		 `flipped', `false',
		 `ref', `',
		 `val', `',
		 `description', `',
		 `part', `',
		 `pin', `'), $@)
	componentHandleRef(_connectorMale_)
	[
		pushDir();

		Start: Here;
		move dirToDirection(peekDir()) elen;
		End: Here;

		m4_ifelse(_connectorMale_flipped, true, `
			AO: Start;
			BO: End;
		', `
			AO: End;
			BO: Start;
		')

		LabelPos: 7/16 between AO and BO;

		angle = angleBetweenPoints(AO, BO);
		
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
'
m4_define_blind(`connectorFemale', `
	componentParseKVArgs(`_connectorFemale_',
		(`pos', `Here',
		 `flipped', `false',
		 `ref', `',
		 `val', `',
		 `description', `',
		 `part', `',
		 `pin', `'), $@)
	componentHandleRef(_connectorFemale_)
	[
		pushDir();

		Start: Here;
		move dirToDirection(peekDir()) elen;
		End: Here;

		m4_ifelse(_connectorFemale_flipped, true, `
			AO: Start;
			BO: End;
		', `
			AO: End;
			BO: Start;
		')

		LabelPos: 1/4 between AO and BO;

		angle = angleBetweenPoints(AO, BO);
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
Multi-pin connector. Pins are numbered from 1 to pincount.

Defines position labels for each pin (replace "n" with pin number):
	.Tn: End position of pin
	.Xn: Connector-end of pin
	.Cn: Sub-connector itself (e.g. can use .Cn.Start etc.)

Usage: connector([comma-separated key-value parameters])
Params:
	pos:		Position to place pin 1 ".Start" at. Defaults to "Here".
	flipped:	Whether connector is flipped (i.e. draws connector part first with trailing wire). Either "true" or (default) "false".
	ref:		Component reference name. Must be a valid pic label (no spaces, starts with capital
			letter). Will prefix reference name with the current sheet number.
	val:		Component value
	description:	Additional text describing component purpose etc.
	part:		Part number. If this is supplied, it is added to the BOM.
	pincount:	Pin count. Defaults to 1.
	gender:		One of "male", "female", "m", "f", "M", or "F". Defaults to "female".
	showPinNums:	Whether or not to display pin numbers. Either (default) "true" or false.
'
m4_define_blind(`connector', `
	componentParseKVArgs(`_connector_',
		(`pos', `Here',
		 `flipped', `false',
		 `ref', `',
		 `val', `',
		 `description', `',
		 `part', `',
		 `pincount', `1',
		 `gender', `female',
		 `showPinNums', `true'), $@)
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

	[
		Start: Here;
		m4_forloop(`i', 1, _connector_pincount, `
			C`'i: m4_indir(connector`'_connector_gender,
			               pin=m4_ifelse(_connector_showPinNums, true, i),
				       flipped=_connector_flipped)
			X`'i: last [].AO;
			T`'i: last [].BO;
			move to last [].Start;
			m4_ifelse(i, _connector_pincount, `', `
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
	circle diam elen/8 with .c at _terminal_pos;

	m4_ifelse(_terminal_label, `', `', `
		m4_ifelse(dirIsVertical(getDir()), 1, `
			  "textTerminalLabel(_terminal_label)" at last circle.w + (elen/32,0) rjust
		', `
			  "textTerminalLabel(_terminal_label)" at last circle.n - (0, elen/16) rjust
		')
	')

	move to last circle.c;
')
