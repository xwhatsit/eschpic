`
Macro to assist handling of component references. Prefixes the ref with the sheet number (if applicable), and
places a pic label if it's valid.

Usage: componentHandleRef(prefix)
'
m4_define_blind(`componentHandleRef', `
	# if a ref was defined and we have enabled it, prefix it with the sheet number
	m4_ifelse($1ref, `', `', m4_define(`$1ref_prefixed', m4_ifelse(a3PrefixRefs, `true', a3SheetNum, `')`'$1ref))

	# if ref was defined and is a valid pic label, then add a label
	m4_ifelse($1ref, `', `', `m4_ifelse(m4_regexp($1ref, `^[A-Z][A-Za-z0-9]*$'), 0, $1ref`:')')
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
Support macro to combine ref/val/description text into a multiline text string. Puts them onto the stack
as [prefix]labels, remember to pop this off!

Usage: componentCombineLabels(prefix)
'
m4_define_blind(`componentCombineLabels', `
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
')


`
Macro to assist drawing main component labels (ref/val/description etc.)

Usage: componentDrawLabels(prefix, [internal=false])
'
m4_define_blind(`componentDrawLabels', `
	m4_ifelse($1, `', `', `
		componentCombineLabels($1)
		m4_ifelse(m4_trim(m4_indir($1`labels')), `', `', `
			m4_ifelse($2, `true', `
				if dirIsVertical(getDir()) then {
					"textMultiLine(m4_indir($1`labels'))" at last [].w + (elen/16, 0) ljust;
				} else {
					"textMultiLine(m4_indir($1`labels'))" at last [].n - (0, elen/2) below;
				}
			', `
				if dirIsVertical(getDir()) then {
					"textMultiLine(m4_indir($1`labels'))" at last [].w - (elen/4, 0) rjust;
				} else {
					"textMultiLine(m4_indir($1`labels'))" at last [].n + (0, elen/8) above;
				}
			')
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
Macro to assist writing BOM file's header (column names)
'
m4_define_blind(`componentStartBOMFile', `
	print "Reference,Value,Description,Location,Part Number,UID" > "bom.csv"
')


`
Macro to assist writing out BOM entries to aux file

Usage: componentWriteBOM(prefix)
'
m4_define_blind(`componentWriteBOM', `
	m4_pushdef(`ref', m4_indir($1`ref_prefixed'))
	m4_pushdef(`val', m4_indir($1`val'))
	m4_pushdef(`description', m4_indir($1`description'))
	m4_pushdef(`part', m4_indir($1`part'))
	m4_pushdef(`sheet', a3SheetNum)
	m4_pushdef(`hpos', a3HPosOf((m4_indir($1`pos')).x))
	m4_pushdef(`vpos', a3VPosOf((m4_indir($1`pos')).y))

	m4_ifelse(m4_indir($1`ref'), `', `', `
		m4_ifdef(`_componentBOM_'ref`.last', `
			m4_define(`_componentBOM_'ref`.last', m4_eval(m4_defn(`_componentBOM_'ref`.last') + 1))
		', `
			m4_define(`_componentBOM_'ref`.last', 0)
		')
		m4_pushdef(`currID', m4_defn(`_componentBOM_'ref`.last'))

		print sprintf("`_componentBOMEntry'(ref,currID,val,description,part,sheet,%.0f,%.0f)", hpos, vpos) >> "eschpic.aux";
		"\hypertarget{ref`_'currID}{}" at m4_indir($1`pos');

		m4_popdef(`currID')
	')

	m4_popdef(`vpos')
	m4_popdef(`hpos')
	m4_popdef(`sheet')
	m4_popdef(`part')
	m4_popdef(`description')
	m4_popdef(`val')
	m4_popdef(`ref')
')


`
Support macro writing out BOM entries when triggered from aux file

Usage: _componentBOMEntry(ref, id, val, description, part, sheet, hpos, vpos)
'
m4_define_blind(`_componentBOMEntry', `
	m4_ifelse($5, `', `', `print "$1,$3,$4,$6.$7`'a3VPosLetter($8),$5,$1_$2" >> "bom.csv"')
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
	componentWriteBOM(_resistor_)

	move to last [].End;
')


`
Potentiometer. Defines T1, T2, T3 position references (2x outside terminals and the sliding contact
terminal respectively).

Usage: potentiometer([comma-separated key-value parameters])
Params:
	pos:		Position to place ".Start" at. Defaults to "Here".
	ref:		Component reference name. Must be a valid pic label (no spaces, starts with capital
			letter). Will prefix reference name with the current sheet number.
	val:		Component value
	description:	Additional text describing component purpose etc.
	part:		Part number. If this is supplied, it is added to the BOM.
	flipped:	Either true or false (default). Normally, drawn in conventional direction (sliding
			terminal down or right).
'
m4_define_blind(`potentiometer', `
	componentParseKVArgs(`_potentiometer_',
		(`pos', `Here',
		 `ref', `',
		 `val', `',
		 `description', `',
		 `part', `',
		 `flipped', `false'), $@)
	componentHandleRef(_potentiometer_)
	[
		pushDir();

		Start: Here;
		move dirToDirection(peekDir()) elen;
		End: Here;

		m4_ifelse(m4_eval(dirIsConventional(peekDir()) ^ m4_ifelse(_potentiometer_flipped, false, 0, 1)), 1, `
			AO: Start;
			BO: End;
		', `
			AO: End;
			BO: Start;
		')

		AM: 5/16 between AO and BO;
		BM: 5/16 between BO and AO;

		box m4_ifelse(dirIsVertical(peekDir()), 1, `wid elen/8 ht elen*3/8', `wid elen*3/8 ht elen/8') at 1/2 between AO and BO;
		line from AO to AM;
		line from BO to BM;

		CM: `last box'm4_ifelse(dirIsVertical(peekDir()), 1, `.e', `.s');
		m4_define(`_potentiometer_slideDir', m4_ifelse(dirIsVertical(peekDir()), 1, `dirRight', `dirDown'));
		move to CM then dirToDirection(_potentiometer_slideDir) elen/32;
		CA3: Here;
		move dirToDirection(_potentiometer_slideDir) elen*3/32;
		CA1: Here;
		move dirToDirection(peekDir()) elen/32;
		CA2: Here;
		move to CA1 then dirToDirection(dirRev(peekDir())) elen/32;
		CA4: Here;
		line from CA1 to CA2 to CA3 to CA4 to CA1 filled 0;

		move to last box.c then dirToDirection(_potentiometer_slideDir) elen/2;
		CT: Here;
		move to BO then dirToDirection(_potentiometer_slideDir) elen/2;
		CO: Here;
		line from CO to CT then to CA1;

		T1: AO;
		T2: BO;
		T3: CO;

		popDir();
	] with .Start at _potentiometer_pos;

	componentDrawLabels(_potentiometer_)
	componentWriteBOM(_potentiometer_)

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
	flipped:	Either true or false (default). Diode normally draws anode to cathode.
	type:		Diode type. Either left blank, or "LED". Defaults to blank.
	startLabel:	Starting terminal label. Defaults to blank.
	endLabel:	Ending terminal label. Defaults to blank.
'
m4_define_blind(`diode', `
	componentParseKVArgs(`_diode_',
		(`pos', `Here',
		 `ref', `',
		 `val', `',
		 `description', `',
		 `part', `',
		 `flipped', `false',
		 `type', `',
		 `startLabel', `',
		 `endLabel', `'), $@)
	componentHandleRef(_diode_)
	[
		pushDir();

		Start: Here;
		move dirToDirection(peekDir()) elen;
		End: Here;
		Centre: 1/2 between Start and End;

		m4_ifelse(_diode_flipped, false, `
			AO: Start;
			BO: End;
		', `
			AO: End;
			BO: Start;
		')

		AM: 5/32 between Centre and AO;
		KM: 5/32 between Centre and BO;

		line from AO to AM;
		line from KM to BO;

		line from AM to polarCoord(AM, elen*3/32, dirToAngle(dirCW(peekDir()))) \
			then to KM \
			then to polarCoord(AM, elen*3/32, dirToAngle(dirCCW(peekDir()))) \
			then to AM;
		line from polarCoord(KM, elen*3/32 + pointsToMillimetres(linethick/2), dirToAngle(dirCW(peekDir()))) to \
			polarCoord(KM, elen*3/32 + pointsToMillimetres(linethick/2), dirToAngle(dirCCW(peekDir())));

		m4_ifelse(_diode_type, `LED', `
			akAngle = angleBetweenPoints(AO, BO);
			LEDArrowStart1: polarCoord(AM, elen*15/128, akAngle - 70);
			LEDArrowMid1: polarCoord(LEDArrowStart1, elen*17/256, akAngle - 69);
			LEDArrowEnd1: polarCoord(LEDArrowStart1, elen/8, akAngle - 69);

			LEDArrowStart2: polarCoord(LEDArrowStart1, elen*17/256, akAngle);
			LEDArrowMid2: polarCoord(LEDArrowStart2, elen*17/256, akAngle - 69);
			LEDArrowEnd2: polarCoord(LEDArrowStart2, elen/8, akAngle - 69);

			line from LEDArrowMid1 to polarCoord(LEDArrowMid1, elen/64, akAngle - 158) \
				then to LEDArrowEnd1 \
				then to polarCoord(LEDArrowMid1, elen/64, akAngle + 22) \
				then to LEDArrowMid1 shaded "black";
			line from LEDArrowMid1 to LEDArrowStart1;

			line from LEDArrowMid2 to polarCoord(LEDArrowMid2, elen/64, akAngle - 158) \
				then to LEDArrowEnd2 \
				then to polarCoord(LEDArrowMid2, elen/64, akAngle + 22) \
				then to LEDArrowMid2 shaded "black";
			line from LEDArrowMid2 to LEDArrowStart2;
		')

		A: AO;
		K: BO;

		# if terminal labels are defined, add positional labels as "T" + name (e.g. ".TA")
		m4_ifelse(_diode_startLabel, `', `', `T'_diode_startLabel`: A')
		m4_ifelse(_diode_endLabel, `', `', `T'_diode_endLabel`: K')

		popDir();
	] with .Start at _diode_pos;

	# display terminal labels
	componentDrawTerminalLabel(last [].A, textTerminalLabel(_diode_startLabel))
	componentDrawTerminalLabel(last [].K, textTerminalLabel(_diode_endLabel))

	componentDrawLabels(_diode_)
	componentWriteBOM(_diode_)

	move to last [].End;
')
m4_define_blind(`LED', `diode(type=LED, $@)')


`
Pilot lamp.

Usage: lamp([comma-separated key-value parameters])
Params:
	pos:		Position to place ".Start" at. Defaults to "Here".
	ref:		Component reference name. Must be a valid pic label (no spaces, starts with capital
	        	letter). Will prefix reference name with the current sheet number.
	val:		Component value
	description:	Additional text describing component purpose etc.
	part:		Part number. If this is supplied, it is added to the BOM.
	startLabel:	Starting terminal label. Defaults to X1.
	endLabel:	Ending terminal label. Defaults to X2.
'
m4_define_blind(`lamp', `
	componentParseKVArgs(`_lamp_',
		(`pos', `Here',
		 `ref', `',
		 `val', `',
		 `description', `',
		 `part', `',
		 `startLabel', `X1',
		 `endLabel', `X2'), $@)
	componentHandleRef(_lamp_)
	[
		pushDir();

		Start: Here;
		move dirToDirection(peekDir()) elen;
		End: Here;

		m4_ifelse(dirIsConventional(peekDir()), 1, `
			AO: Start;
			BO: End;
		', `
			AO: End;
			BO: Start;
		')

		AM: 5/16 between AO and BO;
		BM: 5/16 between BO and AO;

		circle rad elen*3/16 at 1/2 between AO and BO;
		line from last circle.ne to last circle.sw;
		line from last circle.nw to last circle.se;

		line from AO to AM;
		line from BO to BM;

		# if terminal labels are defined, add positional labels as "T" + name (e.g. ".TX1")
		m4_ifelse(_lamp_startLabel, `', `', `T'_lamp_startLabel`: Start')
		m4_ifelse(_lamp_endLabel, `', `', `T'_lamp_endLabel`: End')

		popDir();
	] with .Start at _lamp_pos;

	# display terminal labels
	componentDrawTerminalLabel(last [].AO, textTerminalLabel(_lamp_startLabel))
	componentDrawTerminalLabel(last [].BO,   textTerminalLabel(_lamp_endLabel))

	componentDrawLabels(_lamp_)
	componentWriteBOM(_lamp_)

	move to last [].End;
')


`
Battery. Draws in current direction.

Usage: battery([comma-separated key-value parameters])
Params:
	pos:		Position to place ".Start" at. Defaults to "Here".
	ref:		Component reference name. Must be a valid pic label (no spaces, starts with capital
	        	letter). Will prefix reference name with the current sheet number.
	val:		Component value
	description:	Additional text describing component purpose etc.
	part:		Part number. If this is supplied, it is added to the BOM.
	startLabel:	Starting terminal label. Defaults to blank.
	endLabel:	Ending terminal label. Defaults to blank.
'
m4_define_blind(`battery', `
	componentParseKVArgs(`_battery_',
		(`pos', `Here',
		 `ref', `',
		 `val', `',
		 `description', `',
		 `part', `',
		 `startLabel', `',
		 `endLabel', `'), $@)
	componentHandleRef(_battery_)
	[
		pushDir();

		Start: Here;
		move dirToDirection(peekDir()) elen;
		End: Here;

		move to Start then dirToDirection(peekDir()) elen*3/8;
		AI: Here;
		move dirToDirection(peekDir()) elen*9/32;
		BI: Here;

		line from Start to AI;
		line from BI to End;

		move to AI;
		m4_forloop(`i', 0, 2, `
			move dirToDirection(dirCW(peekDir())) elen/8;
			line dirToDirection(dirCCW(peekDir())) elen/4;

			move to last line.c then down elen*7/128;
			m4_ifelse(dirIsVertical(peekDir()), 1, `box wid elen/8 ht elen/64', `box wid elen/64 ht elen/8') shaded "black" with .c at Here;
			move to last box.c then dirToDirection(peekDir()) elen*7/128;
		')

		# if terminal labels are defined, add positional labels as "T" + name (e.g. ".TA")
		m4_ifelse(_battery_startLabel, `', `', `T'_battery_startLabel`: Start')
		m4_ifelse(_battery_endLabel, `', `', `T'_battery_endLabel`: End')

		popDir();
	] with .Start at _battery_pos;

	# display terminal labels
	componentDrawTerminalLabel(last [].Start, textTerminalLabel(_battery_startLabel))
	componentDrawTerminalLabel(last [].End,   textTerminalLabel(_battery_endLabel))

	componentDrawLabels(_battery_)
	componentWriteBOM(_battery_)

	move to last [].End;
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

		# if terminal labels are defined, add positional labels as "T" + name (e.g. ".TA1")
		m4_ifelse(_coil_startLabel, `', `', `T'_coil_startLabel`: AO')
		m4_ifelse(_coil_endLabel,   `', `', `T'_coil_endLabel`:   BO')

		popDir();
	] with .Start at _coil_pos;

	# display terminal labels
	componentDrawTerminalLabel(last [].AO, textTerminalLabel(_coil_startLabel))
	componentDrawTerminalLabel(last [].BO, textTerminalLabel(_coil_endLabel))

	componentDrawLabels(_coil_)
	componentWriteBOM(_coil_)

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
			TA1: last [].TA1;
			TA2: last [].TA2;
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
	componentWriteBOM(_contactor3ph_)
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

		Thermal: thermalOperator(pos=FirstContactEnd);
		Current: overCurrentOperator();
		line down 5/16*elen;
		T2: Here;

		thermalOperator(pos=polarCoord(FirstContactEnd, elen/2, _motorStarter_actuationAngle + 180));
		overCurrentOperator();
		line down 5/16*elen;
		T4: Here;

		thermalOperator(pos=polarCoord(FirstContactEnd, elen, _motorStarter_actuationAngle + 180));
		overCurrentOperator();
		line down 5/16*elen;
		T6: Here;

		ThermalX: m4_ifelse(dirIsVertical(getDir()), 1, `(Box.s, Thermal.w)', `(Thermal.w, Box.s)');
		CurrentX: m4_ifelse(dirIsVertical(getDir()), 1, `(Box.s, Current.w)', `(Current.w, Box.s)');
		line dashed elen/18 from Box.s to ThermalX then to Thermal.w;
		line dashed elen/18 from ThermalX to CurrentX then to Current.w;
		End: Here;

		componentDrawTerminalLabel(T2, 2);
		componentDrawTerminalLabel(T4, 4);
		componentDrawTerminalLabel(T6, 6);
	')
	contactGroup(
		linked=false,
		pos=_motorStarter_pos,
		postDraw=_motorStarter_postDraw,
		contacts=NO(1,) NO(3,) NO(5,) _motorStarter_aux,
		type=breaker disconnector
	);


	line dashed elen/18 from last [].Box.e to last[]. 7th last [].MidContact;
	componentDrawLabels(_motorStarter_)
	componentWriteBOM(_motorStarter_)
	move to last [].End;
')


`
Transformer.

Usage: transformer([comma-separated key-value parameters])
Params:
	pos:		Position to place start at. Defaults to "Here".
	ref:		Component reference name.
	val:		Component value
	description:	Additional text describing component purpose etc.
	part:		Part number. If this is supplied, it is added to the BOM.
'
m4_define_blind(`transformer', `
	componentParseKVArgs(`_transformer_',
		(`pos', `Here',
		 `ref', `',
		 `val', `',
		 `description', `',
		 `part', `'), $@)
	componentHandleRef(_transformer_)

	[
		pushDir();

		Start: Here;
		move down elen;
		End: Here;

		line from Start dirToDirection(peekDir()) elen*13/32;
		PrimaryBase: Here;
		m4_define(_transformer_coilDir, m4_ifelse(dirIsVertical(peekDir()), 1, `right', `down'))
		m4_forloop(i, 1, 4, `
			ArcStart: Here;
			move _transformer_coilDir elen/8;
			ArcEnd: Here;
			ArcC: 1/2 between ArcStart and ArcEnd;
			arc ccw from ArcStart to ArcEnd with .c at ArcC;
		')
		line dirToDirection(dirCW(dirCW(peekDir()))) elen*13/32;
		TP1: Start;
		TP2: Here;

		move to PrimaryBase then dirToDirection(peekDir()) elen*3/16;
		SecondaryBase: Here;
		m4_forloop(i, 1, 4, `
			ArcStart: Here;
			move _transformer_coilDir elen/8;
			ArcEnd: Here;
			ArcC: 1/2 between ArcStart and ArcEnd;
			arc cw from ArcStart to ArcEnd with .c at ArcC;
		')
		line dirToDirection(peekDir()) elen*13/32;
		TS1: End;
		TS2: Here;
		line from SecondaryBase to End;

		popDir();
	] with .Start at _transformer_pos;

	componentDrawLabels(_transformer_)
	componentWriteBOM(_transformer_)

	move to last [].End
')


`
Motor.

Usage: motor([comma-separated key-value parameters])
Params:
	pos:		Position to place first terminal at. Defaults to "Here".
	ref:		Component reference name.
	val:		Component value.
	description:	Additional text describing component purpose etc.
	part:		Part number. If this is supplied, it is added to BOM.
	phase:		Either 2 or 3 (default), meaning 2-phase or 3-phase.
	type:		Either AC (default) or DC.
	labels:		Terminal labels. In format (U1, V1, W1). Defaults to (U1, V1, W1) for 3-phase, and "(1, 2)" for 2-phase.
	showPE:		Whether to show PE terminal. Either true or false (default).
	showEarth:	Whether or not to show earthing. Either true or false (default).
'
m4_define_blind(`motor', `
	componentParseKVArgs(`_motor_',
		(`pos', `Here',
		 `ref', `',
		 `val', `',
		 `description', `',
		 `part', `',
		 `phase', `3',
		 `type', `AC',
		 `labels', `',
		 `showPE', `false',
		 `showEarth', `false'), $@)
	componentHandleRef(_motor_)

	[
		pushDir();

		m4_define(`_motor_termDir', m4_ifelse(dirIsVertical(peekDir()), 1, dirRight, dirDown));
		m4_define(`_motor_termSpacing', m4_ifelse(_motor_phase, 3, elen/2, elen/4))

		Start: Here;
		move dirToDirection(_motor_termDir) _motor_termSpacing;
		CT: Here;
		move dirToDirection(_motor_termDir) _motor_termSpacing;
		RT: Here;
		move to CT then dirToDirection(peekDir()) elen*3/4;
		circle rad elen*5/16 with .c at Here;


		"textComponentDescription(M)" above at last circle.c - (0,elen/8);
		m4_ifelse(_motor_phase, 2, `
			line from Start dirToDirection(peekDir()) elen*9/16;
			line from RT   dirToDirection(peekDir()) elen*9/16;

			move to last circle.c then down elen*3/32 then left elen*15/128;
			line right elen*15/64;
			move from last line.c down elen/16 then left elen*15/128;
			line dashed elen*3/64 right elen*15/64;

			m4_ifelse(_motor_labels, `', `m4_define(`_motor_labels', (1, 2))')
			m4_define(`_motor_label1', m4_argn(1, m4_extractargs(_motor_labels)))
			m4_define(`_motor_label2', m4_argn(2, m4_extractargs(_motor_labels)))
			dirToDirection(peekDir());
			componentDrawTerminalLabel(Start, _motor_label1)
			componentDrawTerminalLabel(RT,    _motor_label2)
			m4_ifelse(m4_regexp(_motor_label1, `[A-Za-z0-9]*$'), 0, `T'_motor_label1: Start);
			m4_ifelse(m4_regexp(_motor_label2, `[A-Za-z0-9]*$'), 0, `T'_motor_label2: RT);
		', `
			line from Start dirToDirection(peekDir()) elen/4 then to last m4_ifelse(m4_trim(peekDir()), dirDown,  circle.nw,
												m4_trim(peekDir()), dirUp,    circle.sw,
												m4_trim(peekDir()), dirRight, circle.nw,
												m4_trim(peekDir()), dirLeft,  circle.ne);
			line from CT to last m4_ifelse(m4_trim(peekDir()), dirDown,  circle.n,
						       m4_trim(peekDir()), dirUp,    circle.s,
						       m4_trim(peekDir()), dirRight, circle.w,
						       m4_trim(peekDir()), dirLeft,  circle.e);
			line from RT dirToDirection(peekDir()) elen/4 then to last m4_ifelse(m4_trim(peekDir()), dirDown,  circle.ne,
											     m4_trim(peekDir()), dirUp,    circle.se,
											     m4_trim(peekDir()), dirRight, circle.sw,
											     m4_trim(peekDir()), dirLeft,  circle.se);

			"textComponentDescription(3$\sim$)" below at last circle.c + (0,elen*3/32);

			m4_ifelse(_motor_labels, `', `m4_define(`_motor_labels', (U1, V1, W1))')
			m4_define(`_motor_label1', m4_argn(1, m4_extractargs(_motor_labels)))
			m4_define(`_motor_label2', m4_argn(2, m4_extractargs(_motor_labels)))
			m4_define(`_motor_label3', m4_argn(3, m4_extractargs(_motor_labels)))
			dirToDirection(peekDir());
			componentDrawTerminalLabel(Start, _motor_label1)
			componentDrawTerminalLabel(CT,    _motor_label2)
			componentDrawTerminalLabel(RT,    _motor_label3)
			m4_ifelse(m4_regexp(_motor_label1, `[A-Za-z0-9]*$'), 0, `T'_motor_label1: Start);
			m4_ifelse(m4_regexp(_motor_label2, `[A-Za-z0-9]*$'), 0, `T'_motor_label2: CT);
			m4_ifelse(m4_regexp(_motor_label3, `[A-Za-z0-9]*$'), 0, `T'_motor_label2: RT);
		')


		m4_ifelse(_motor_showPE, true, `
			move to RT then dirToDirection(_motor_termDir) elen/2;
			TPE: Here;
			move dirToDirection(peekDir()) m4_ifelse(_motor_phase, 2, elen/2, elen/4);
			PE1: Here;
			PE3: last m4_ifelse(dirIsVertical(peekDir()), 1, circle.e, circle.s);
			move from PE3 dirToDirection(_motor_termDir) elen*3/16;
			PE2: Here;
			line from TPE to PE1 then to PE2 then to PE3;

			dirToDirection(peekDir());
			componentDrawTerminalLabel(TPE, PE)
		')

		m4_ifelse(_motor_showEarth, true, `
			ET1: last m4_ifelse(dirIsVertical(peekDir()), 1, circle.e, circle.s);
			move to ET1 then m4_ifelse(dirIsVertical(peekDir()), 1, `right', `down') elen/16;
			ET2: Here;
			move dirToDirection(peekDir()) elen*3/64;
			line from Here dirToDirection(dirRev(peekDir())) elen*3/32;
			move to ET2;
			m4_ifelse(dirIsVertical(peekDir()), 1, `line right elen/4')
			corner;
			earth();
		')

		popDir();
	] with .Start at _motor_pos;

	componentDrawLabels(_motor_)
	componentWriteBOM(_motor_)

	move to last [].Start;
')

`
Brake.

Usage: brake([comma-separated key-value parameters])
Params:
	pos:		Position to place starting terminal at. Defaults to "Here".
	ref:		Component reference name.
	val:		Component value.
	description:	Additional text describing component purpose etc.
	part:		Part number. If this is supplied, it is added to BOM.
	startLabel:	Label of start terminal; defaults to A1.
	endLabel:	Label of end terminal; defaults to A2.
'
m4_define_blind(`brake', `
	componentParseKVArgs(`_brake_',
		(`pos', `Here',
		 `ref', `',
		 `val', `',
		 `description', `',
		 `part', `',
		 `startLabel', `A1',
		 `endLabel', `A2'), $@)
	componentHandleRef(_brake_)

	[
		pushDir();

		Start: Here;
		move dirToDirection(peekDir()) elen;
		End: Here;

		m4_ifelse(dirIsConventional(peekDir()), 1, `
			AO: Start;
			BO: End;
		', `
			AO: End;
			BO: Start;
		')
		AM: 3/8 between AO and BO;
		BM: 3/8 between BO and AO;
		Centre: 1/2 between AO and BO;

		m4_define(`_brake_brakeDir', m4_ifelse(dirIsVertical(peekDir()), 1, dirRight, dirDown))

		line from AO to AM;
		line from BO to BM;
		box m4_ifelse(dirIsVertical(peekDir()), 1, wid elen*3/8 ht elen/4, wid elen/4 ht elen*3/8) at Centre;
		line from m4_ifelse(dirIsVertical(peekDir()), 1, `last box.e') dirToDirection(_brake_brakeDir) elen/8;
		BC1: Here;
		move from BC1 dirToDirection(peekDir()) elen*3/32;
		BB1: Here;
		move from BC1 dirToDirection(dirRev(peekDir())) elen*3/32;
		BT1: Here;

		move from BC1 dirToDirection(_brake_brakeDir) elen/16;
		BC2: Here;
		move from BC2 dirToDirection(peekDir()) elen*9/64;
		BB2: Here;
		move from BC2 dirToDirection(dirRev(peekDir())) elen*9/64;
		BT2: Here;

		line from BC1 to BT1 to BT2 to BB2 to BB1 to BC1;

		componentDrawTerminalLabel(AO, _brake_startLabel)
		componentDrawTerminalLabel(BO, _brake_endLabel)

		popDir();
	] with .Start at _brake_pos;

	componentDrawLabels(_brake_)
	componentWriteBOM(_brake_)

	move to last [].End;
')
