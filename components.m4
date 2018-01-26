# Set base unit used for components
elen = 12.7;

m4_divert(-1)

`
Macro to assist handling of component references. Prefixes the ref with the sheet number (if applicable), and
places a pic label if it's valid.

Usage: componentHandleRef(prefix)
'
m4_define_blind(`componentHandleRef', `
	# if a ref was defined and we have enabled it, prefix it with the sheet number
	m4_ifelse($1ref, `', `', m4_define(`$1ref_prefixed', m4_ifelse(a3PrefixRefs, `true', a3SheetNum, `')`'$1ref))

	# if ref was defined and is a valid pic label, then add a label
	m4_ifelse($1ref, `', `', `
		m4_ifelse(m4_regexp($1ref, `^[A-Z][A-Za-z0-9]*$'), 0,
			$1ref`:', `m4_errprint(
			`warning: could not define place name for ref "'$1ref`": invalid pic label' m4_newline())')')
')


`
Macro to parse and set defaults for components which take key-value params.

Usage: componentParseKVArgs(prefix, (argname_1, argdefault_1, [argname_n, argdefault_n]), originalArgs)
'
m4_define_blind(`componentParseKVArgs', `
	m4_pushdef(`componentPrefix', $1)
	_$0_setDefault$2
	m4_prefixKVArgs(componentPrefix, m4_shift(m4_shift($@)))
	m4_popdef(`componentPrefix')
')
m4_define_blind(`_componentParseKVArgs_setDefault', `
	m4_forloopn(`argI', 1, $#, 2, `m4_define(componentPrefix`'m4_argn(argI, $@),
		m4_argn(m4_eval(argI + 1), $@))')
')


`
Macro to assist drawing main component labels (ref/val/description etc.)

Usage: componentDrawLabels(prefix)
'
m4_define_blind(`componentDrawLabels', `
	m4_ifelse($1, `', `', `
		m4_pushdef($1`labels', `')

		m4_ifelse(m4_trim(m4_indir($1`ref')), `', `',
			`m4_define($1`labels',
				m4_ifelse(m4_trim($1`labels'), `', `', m4_indir($1`labels')` \\'
				)\normalsize{}textComponentRef(m4_indir($1`ref_prefixed')))')
		m4_ifelse(m4_trim(m4_indir($1`val')), `', `',
			`m4_define($1`labels',
				m4_ifelse(m4_trim($1`labels'), `', `', m4_indir($1`labels')` \\'
				)\normalsize{}textComponentVal(m4_indir($1`val')))')
		m4_ifelse(m4_trim(m4_indir($1`description')), `', `',
			`m4_define($1`labels',
				m4_ifelse(m4_trim($1`labels'), `', `', m4_indir($1`labels')` \\'
				)\normalsize{}textComponentDescription(m4_indir($1`description')))')

		m4_ifelse(m4_trim(m4_indir($1`labels')), `', `', `
			if dirIsVertical(getDir()) then {
				"textMultiLine(m4_indir($1`labels'))" at last [].w - (elen/4, 0) rjust;
			} else {
				"textMultiLine(m4_indir($1`labels'))" at last [].n + (0, elen/8) above;
			}
		')

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
	componentHandleRef(_resistor_)
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

	move to last [].End;
')


`
Diode. Draws in current direction.

Usage: diode([comma-separated key-value parameters])
Params:
	pos:		Position to place ".Start" at. Defaults to "Here".
	ref:		Component reference name. Must be a valid pic label (no spaces, starts with capital
			letter). Will prefix reference name with the current sheet number.
	val:		Component value
	description:	Additional text describing component purpose etc.
	part:		Part number. If this is supplied, it is added to the BOM.
	type:		Diode type. Either left blank, or "LED". Defaults to blank.
'
m4_define_blind(`diode', `
	componentParseKVArgs(`_diode_',
		(`pos', `Here',
		 `ref', `',
		 `val', `',
		 `description', `',
		 `part', `',
		 `type', `'), $@)
	componentHandleRef(_diode_)
	[
		pushDir();

		Start: Here;
		move dirToDirection(peekDir()) elen;
		End: Here;
		Centre: 1/2 between Start and End;

		move to Centre then dirToDirection(peekDir()) 1;
		KM: Here;
		move dirToDirection(dirCW(dirCW(peekDir()))) 2;
		AM: Here;

		line from Start to AM;
		line from KM to End;

		line from AM to polarCoord(AM, 1.2, dirToAngle(dirCW(peekDir()))) \
			then to KM \
			then to polarCoord(AM, 1.2, dirToAngle(dirCCW(peekDir()))) \
			then to AM;
		line from polarCoord(KM, 1.2 + pointsToMillimetres(linethick/2), dirToAngle(dirCW(peekDir()))) to \
			polarCoord(KM, 1.2 + pointsToMillimetres(linethick/2), dirToAngle(dirCCW(peekDir())));

		m4_ifelse(_diode_type, `LED', `
			LEDArrowStart1: polarCoord(AM, 1.5, dirToAngle(peekDir()) - 70);
			LEDArrowMid1: polarCoord(LEDArrowStart1, 0.85, dirToAngle(peekDir()) - 69);
			LEDArrowEnd1: polarCoord(LEDArrowStart1, 1.6, dirToAngle(peekDir()) - 69);

			LEDArrowStart2: polarCoord(LEDArrowStart1, 0.85, dirToAngle(peekDir()));
			LEDArrowMid2: polarCoord(LEDArrowStart2, 0.85, dirToAngle(peekDir()) - 69);
			LEDArrowEnd2: polarCoord(LEDArrowStart2, 1.6, dirToAngle(peekDir()) - 69);

			line from LEDArrowMid1 to polarCoord(LEDArrowMid1, 0.2, dirToAngle(peekDir()) - 158) \
				then to LEDArrowEnd1 \
				then to polarCoord(LEDArrowMid1, 0.2, dirToAngle(peekDir()) + 22) \
				then to LEDArrowMid1 shaded "black";
			line from LEDArrowMid1 to LEDArrowStart1;

			line from LEDArrowMid2 to polarCoord(LEDArrowMid2, 0.2, dirToAngle(peekDir()) - 158) \
				then to LEDArrowEnd2 \
				then to polarCoord(LEDArrowMid2, 0.2, dirToAngle(peekDir()) + 22) \
				then to LEDArrowMid2 shaded "black";
			line from LEDArrowMid2 to LEDArrowStart2;

		')

		popDir();
	] with .Start at _diode_pos;

	componentDrawLabels(_diode_)

	move to last [].End;
')
m4_define_blind(`LED', `diode(type=LED, $@)')


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
	componentHandleRef(_coil_)

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
3-phase contactor.

Usage: contactor3ph([comma-separated key-value parameters])
Params:
	pos:		Position to place first contact's (or the coil's) ".Start" at. Defaults to "Here".
	ref:		Component reference name. Must be a valid pic label (no spaces, starts with capital
			letter). Will prefix reference name with the current sheet number.
	val:		Component value
	description:	Additional text describing component purpose etc.
	part:		Part number. If this is supplied, it is added to the BOM.
	coil:		Whether or not to draw the coil. Either "true" or "false". Defaults to "false".
	aux:		Description of auxiliary contact(s). In same syntax as "contacts" parameter in contactGroup
			macro, e.g. "no(13, 14) nc(21, 22)", or simply "no, nc".
'
m4_define_blind(`contactor3ph', `
	componentParseKVArgs(`_contactor3ph_',
		(`pos', `Here',
		 `ref', `',
		 `val', `',
		 `description', `',
		 `part', `',
		 `coil', `false',
		 `aux', `'), $@)
	componentHandleRef(_contactor3ph_)

	m4_define(`_contactor3ph_preDraw', `')
	m4_define(`_contactor3ph_groupOffset', `(0, 0)')
	m4_ifelse(_contactor3ph_coil, `true', `
		m4_define(`_contactor3ph_groupOffset', `m4_ifelse(dirIsVertical(getDir()), 1, `(elen/2, 0)', `(0, -elen/2)')')
		m4_define(`_contactor3ph_preDraw', `
			Coil: coil();
			T_A1: last [].T_A1;
			T_A2: last [].T_A2;
			move to last [].Start;
			move to Here + _contactor3ph_groupOffset;
		')
	')
	contactGroup(
		linked=false,
		pos=_contactor3ph_pos + _contactor3ph_groupOffset,
		preDraw=_contactor3ph_preDraw,
		contacts=NO(1,2) NO(3,4) NO(5,6) _contactor3ph_aux,
		type=contactor
	);

	componentDrawLabels(_contactor3ph_)
	m4_ifelse(_contactor3ph_coil, `true', `
		line dashed elen/18 from last [].Coil.e to last []. last [].MidContact;
		move to last [].Coil.End;
	', `
		line dashed elen/18 from last [].FirstContactMidContact to last[]. last [].MidContact;
		move to last [].FirstContactEnd;
	')
')


`
3-phase thermal-magnetic overload with manual control (e.g. motor starter)

Usage: motorStarter([comma-separated key-value parameters])
Params:
	pos:		Position to place first contact's ".Start" at. Defaults to "Here".
	ref:		Component reference name. Must be a valid pic label (no spaces, starts with capital
			letter). Will prefix reference name with the current sheet number.
	val:		Component value
	description:	Additional text describing component purpose etc.
	part:		Part number. If this is supplied, it is added to the BOM.
	actuation:	Type of mechanical control to turn on/off. See componentDrawActuator for options.
			Defaults to "manual".
	aux:		Description of auxiliary contact(s). In same syntax as "contacts" parameter in contactGroup
			macro, e.g. "no(13, 14) nc(21, 22)", or simply "no, nc".
'
m4_define_blind(`motorStarter', `
	componentParseKVArgs(`_motorStarter_',
		(`pos', `Here',
		 `ref', `',
		 `val', `',
		 `description', `',
		 `part', `',
		 `actuation', `manual',
		 `aux', `'), $@)
	componentHandleRef(_motorStarter_)

	m4_define(`_motorStarter_actuationAngle', m4_ifelse(dirIsVertical(getDir()), 1, 180, 90))
	m4_define(`_motorStarter_postDraw', `
		BoxC: polarCoord(FirstContactMidContact, elen*5/8, _motorStarter_actuationAngle);
		HandlePos: polarCoord(BoxC, elen*1/2, _motorStarter_actuationAngle);
		Box: box wid elen*3/8 ht elen*3/8 at BoxC;
		line from Box.n to Box.s;
		line from Box.e to Box.w;
		componentDrawActuator(
			_motorStarter_actuation,
			HandlePos,
			_motorStarter_actuationAngle, 
			m4_ifelse(dirIsVertical(getDir()), 1, 1, -1));
		line dashed elen/18 from HandlePos to Box.w;
	')
	contactGroup(
		linked=false,
		pos=_motorStarter_pos,
		postDraw=_motorStarter_postDraw,
		contacts=NO(1,2) NO(3,4) NO(5,6) _motorStarter_aux,
		type=breaker disconnector
	);

	componentDrawLabels(_motorStarter_)
	line dashed elen/18 from last [].Box.e to last[]. last [].MidContact;
	move to last [].FirstContactEnd;
')


m4_divert(0)

# vim: filetype=pic
