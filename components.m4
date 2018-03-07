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

Usage: componentDrawLabels(prefix, [internal=false])
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

		A: Start;
		K: End;

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
		 `type', `',
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
