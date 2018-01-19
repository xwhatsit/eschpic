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
	componentHandleRef(_connectorMale_)
	[
		pushDir();

		Start: Here;
		move dirToDirection(peekDir()) elen;
		End: Here;


		LabelPos: 3/8 between Start and End;
		
		move to Start;
		move dirToDirection(peekDir()) 0.8;
		circle rad 0.8 at Here shade "black";
		line from polarCoord(last circle.c, 0.8, dirToAngle(peekDir()) + 90) dirToDirection(peekDir()) 2.4 \
			then dirToDirection(dirCW(peekDir())) 1.6 \
			then dirToDirection(dirCW(dirCW(peekDir()))) 2.4 shaded "black";
		line from polarCoord(Start, 2.4, dirToAngle(peekDir())) to End;

		popDir();
	] with .Start at _connectorMale_pos;

	componentDrawTerminalLabel(last [].LabelPos, _connectorMale_pin);
	componentDrawLabels(_connectorMale_)

	move to last [].End;
')


`
Single female pin connector. Draws in current direction.

Usage: connectorFemale([comma-separated key-value parameters])
Params:
	pos:		Position to place ".Start" at. Defaults to "Here".
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

		LabelPos: 1/4 between Start and End;

		arc ccw from polarCoord(Start, 1.6, dirToAngle(peekDir()) - 90) to polarCoord(Start, 1.6, dirToAngle(peekDir()) + 90) with .c at Start;
		line from polarCoord(Start, 1.6, dirToAngle(peekDir())) to End;

		popDir();
	] with .Start at _connectorFemale_pos;

	componentDrawTerminalLabel(last [].LabelPos, _connectorFemale_pin);
	componentDrawLabels(_connectorFemale_)

	move to last [].End;
')


`
Multi-pin connector. Pins are numbered from 1 to pincount.

Defines position labels for each pin (replace "n" with pin number):
	.T_n: End position of pin
	.C_n: Sub-connector itself (e.g. can use .C_n.Start etc.)

Usage: connector([comma-separated key-value parameters])
Params:
	pos:		Position to place pin 1 ".Start" at. Defaults to "Here".
	ref:		Component reference name. Must be a valid pic label (no spaces, starts with capital
			letter). Will prefix reference name with the current sheet number.
	val:		Component value
	description:	Additional text describing component purpose etc.
	part:		Part number. If this is supplied, it is added to the BOM.
	pincount:	Pin count. Defaults to 1.
	gender:		One of "male", "female", "m", "f", "M", or "F". Defaults to "female".
'
m4_define_blind(`connector', `
	componentParseKVArgs(`_connector_',
		(`pos', `Here',
		 `ref', `',
		 `val', `',
		 `description', `',
		 `part', `',
		 `pincount', `1',
		 `gender', `female'), $@)
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
			   C_`'i: m4_indir(connector`'_connector_gender, pin=i)
			   T_`'i:         last [].End;
			   move to last [].Start;
			   m4_ifelse(i, _connector_pincount, `',
			   	`m4_ifelse(dirIsVertical(peekDir()), 1,
					`move `right' elen/2',
					`move `down' elen/2')')
		')
		End: Here;
	] with .Start at _connector_pos;

	componentDrawLabels(_connector_)

	move to last [].End;
')

m4_divert(0)

# vim: filetype=pic
