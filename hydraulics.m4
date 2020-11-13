`
Helper macro for drawing springs for use in valves.

Usage: hydraulicsDrawSpring(pos, angle)
Params:
	pos:	        Location to draw it at.
	angle:		Angle of spring.
'
m4_define_blind(`hydraulicsDrawSpring', `
	S1: $1;
	S2: polarCoord(S1, elen*15/160, $2 + 77);
	S3: polarCoord(S2, elen*15/80,  $2 - 77);
	S4: polarCoord(S3, elen*15/80,  $2 + 77);
	S5: polarCoord(S4, elen*15/80,  $2 - 77);
	S6: polarCoord(S5, elen*15/80,  $2 + 77);
	S7: polarCoord(S6, elen*15/80,  $2 - 77);
	S8: polarCoord(S7, elen*15/160, $2 + 77);

	line from S1 to S2 to S3 to S4 to S5 to S6 to S7 to S8;
')

`
Pump.

Usage: pump([comma-separated key-value parameters])
Params:
	pos:		Position to place first terminal at. Defaults to "Here".
	ref:		Component reference name.
	val:		Component value.
	description:	Additional text describing component purpose etc.
	refPos:		Reference labelling position. One of blank (default), reverse, below, above, ljust, rjust.
	part:		Part number. If this is supplied, it is added to BOM.
	flipped:	Either true or false (default). Pump normally draws from intake-side to exhaust-side.
	type:		Either fixed or variable (referring to displacement); defaults to fixed.
	bidirectional:	Either true or false (default).
	startLabel:	Starting terminal label. Defaults to blank.
	endLabel:	Ending terminal label. Defaults to blank.
'
m4_define_blind(`pump', `
	componentParseKVArgs(`_pump_',
		(`pos', `Here',
		 `ref', `',
		 `val', `',
		 `description', `',
		 `refPos', `',
		 `part', `',
		 `flipped', `false',
		 `type', `fixed',
		 `bidirectional', `false',
		 `startLabel', `',
		 `endLabel', `'), $@)
	componentHandleRef(_pump_)
	[
		pushDir();

		Start: Here;
		move dirToDirection(peekDir()) elen;
		End: Here;

		m4_ifelse(_pump_flipped, false, `
			AO: Start;
			BO: End;
		', `
			AO: End;
			BO: Start;
		')

		AM: 2/7 between AO and BO;
		BM: 2/7 between BO and AO;

		line from AO to AM;
		line from BO to BM;

		circle rad elen*3/14 at 1/2 between AM and BM;

		arAngle = angleBetweenPoints(AO, BO);
		Ar1: BM;
		ArC: 1/6 between BM and AM;
		Ar2: polarCoord(ArC, elen*3/42, arAngle + 90);
		Ar3: polarCoord(ArC, elen*3/42, arAngle - 90);
		line from Ar1 to Ar2 to Ar3 to Ar1 shade "black";

		m4_ifelse(_pump_bidirectional, `true', `
			Ar1: AM;
			ArC: 1/6 between AM and BM;
			Ar2: polarCoord(ArC, elen*3/42, arAngle + 90);
			Ar3: polarCoord(ArC, elen*3/42, arAngle - 90);
			line from Ar1 to Ar2 to Ar3 to Ar1 shaded "black";
		')

		m4_ifelse(_pump_type, `variable', `
			V1: polarCoord(last circle.c, elen*17/56, 225);
			V2: polarCoord(last circle.c, elen*17/56, 45);
			line from V1 to V2;

			VA1: V2;
			VA2: polarCoord(VA1, elen*8/65, 242);
			VA3: polarCoord(VA1, elen*8/65, 208);
			VAC: 1/2 between VA2 and VA3;
			line from VAC to VA2 to VA1 to VA3 to VAC shaded "black";
		')

		popDir();
	] with .Start at _pump_pos;

	# display terminal labels
	componentDrawTerminalLabel(last [].AO, textTerminalLabel(_pump_startLabel))
	componentDrawTerminalLabel(last [].BO, textTerminalLabel(_pump_endLabel))

	componentDrawLabels(_pump_)
	componentWriteBOM(_pump_)

	move to last [].End;
')


`
Non-return valve, or check valve.

Usage: checkValve([comma-separated key-value parameters])
Params:
	pos:		Position to place first terminal at. Defaults to "Here".
	ref:		Component reference name.
	val:		Component value.
	description:	Additional text describing component purpose etc.
	refPos:		Reference labelling position. One of blank (default), reverse, below, above, ljust, rjust.
	part:		Part number. If this is supplied, it is added to BOM.
	flipped:	Either true or false (default). Check valve is normally drawn in direction of flow.
	startLabel:	Starting terminal label. Defaults to blank.
	endLabel:	Ending terminal label. Defaults to blank.
'
m4_define_blind(`checkValve', `
	componentParseKVArgs(`_checkValve_',
		(`pos', `Here',
		 `ref', `',
		 `val', `',
		 `description', `',
		 `refPos', `',
		 `part', `',
		 `flipped', `false',
		 `type', `fixed',
		 `bidirectional', `false',
		 `startLabel', `',
		 `endLabel', `'), $@)
	componentHandleRef(_checkValve_)
	[
		pushDir();

		Start: Here;
		move dirToDirection(peekDir()) elen;
		End: Here;

		m4_ifelse(_checkValve_flipped, false, `
			AO: Start;
			BO: End;
			m4_define(`_checkValve_flowDir', peekDir())
		', `
			AO: End;
			BO: Start;
			m4_define(`_checkValve_flowDir', dirRev(peekDir()))
		')

		AM: 3/8 between AO and BO;
		BM: 41/96 between BO and AO;

		line from AO to AM;
		line from BM to BO;

		circle rad elen/12 at 47/96 between AO and BO;

		move to AM then dirToDirection(dirCCW(_checkValve_flowDir)) elen/8 dirToDirection(_checkValve_flowDir) elen/8;
		T1: Here;
		move to AM then dirToDirection(dirCW(_checkValve_flowDir)) elen/8 dirToDirection(_checkValve_flowDir) elen/8;
		T2: Here;
		line from AM to T1;
		line from AM to T2;

		move to BM then dirToDirection(_checkValve_flowDir) elen/16;
		hydraulicsDrawSpring(Here, dirToAngle(_checkValve_flowDir));

		popDir();
	] with .Start at _checkValve_pos;

	m4_define(`_checkValve_refPosXRef', last []. last circle.c.x)
	m4_define(`_checkValve_refPosYRef', last []. last circle.c.y)
	componentDrawLabels(_checkValve_)
	componentWriteBOM(_checkValve_)

	move to last [].End;
')


`
Directional control valve.

Usage: directionalValve([comma-separated key-value parameters])
Params:
	pos:		Position to place first terminal at. Defaults to "Here".
	ref:		Component reference name.
	val:		Component value.
	description:	Additional text describing component purpose etc.
	refPos:		Reference labelling position. One of blank (default), reverse, below, above, ljust, rjust.
	part:		Part number. If this is supplied, it is added to BOM.
	ports:		Labels and counts for valve ports. In syntax (P, T) | (A, B), with | used to divide top and bottom of valve. If port
			labels are not given (i.e. something liked (,) | () is used), port numbers are auto-incremented in T1..Tn style.
	functions:	Spool functions, in syntax (blocked(P), dir(B, T), blocked(A)) | (bidir(P, B), bidir(T, A)). | symbol separates positions
			from each other. For now, only two positions are supported. Available functions:
				blocked(P1):	Simple blocked-off (capped) port. Only takes one port name.
				dir(P1, P2):	One-way directional flow from first port to second.
				bidir(P1, P2):	Bidirectional flow between two ports.
	actuation:	Only solenoid (direct actuation) is supported for now.
	return:		Only spring is supported for now.
'
m4_define_blind(`directionalValve', `
	componentParseKVArgs(`_directionalValve_',
		(`pos', `Here',
		 `ref', `',
		 `val', `',
		 `description', `',
		 `refPos', `',
		 `part', `',
		 `ports', `',
		 `functions', `',
		 `actuation', `',
		 `return', `'), $@)
	componentHandleRef(_directionalValve_)
	[
		pushDir();

		Start: Here;
		move dirToDirection(peekDir()) elen;
		End: Here;

		m4_define(`_directionalValve_portDir', m4_ifelse(dirIsVertical(peekDir()), 1, dirRight, dirDown));

		m4_define(`_directionalValve_topports', m4_trim(m4_substr(_directionalValve_ports, 0, m4_index(_directionalValve_ports, `|'))))
		m4_define(`_directionalValve_botports', m4_trim(m4_substr(_directionalValve_ports, m4_eval(m4_index(_directionalValve_ports, `|') + 1))))

		m4_define(`_directionalValve_numtopports', m4_nargs(m4_extractargs(_directionalValve_topports)))
		m4_define(`_directionalValve_numbotports', m4_nargs(m4_extractargs(_directionalValve_botports)))

		m4_define(`_directionalValve_portctr', 1)
		move to Start;
		m4_forloop(i, 1, _directionalValve_numtopports, `
			m4_define(`_directionalValve_topvislabel['i`]', m4_argn(i, m4_extractargs(_directionalValve_topports)))
			m4_define(`_directionalValve_topport['i`]', m4_argn(i, m4_extractargs(_directionalValve_topports)))
			m4_ifelse(m4_trim(m4_indir(`_directionalValve_topport['i`]')), `', `
				m4_define(`_directionalValve_topport['i`]', _directionalValve_portctr)
				m4_define(`_directionalValve_portctr', m4_eval(_directionalValve_portctr + 1))
			')
			m4_define(`_directionalValve_topposlabel['i`]', m4_patsubst(m4_indir(`_directionalValve_topport['i`]'), `^[^A-Z]', `T\&'))
			m4_define(`_directionalValve_portpos['m4_indir(`_directionalValve_topport['i`]')`]', m4_indir(`_directionalValve_topposlabel['i`]'))
			m4_define(`_directionalValve_portontop['m4_indir(`_directionalValve_topport['i`]')`]', 1)

			m4_indir(`_directionalValve_topposlabel['i`]'): Here;
			line dirToDirection(peekDir()) elen/4;
			`Inside'm4_indir(`_directionalValve_topposlabel['i`]'): Here;
			move dirToDirection(dirRev(peekDir())) elen/4 dirToDirection(_directionalValve_portDir) elen/4;
		')

		move to End;

		m4_forloop(i, 1, _directionalValve_numbotports, `
			m4_define(`_directionalValve_botvislabel['i`]', m4_argn(i, m4_extractargs(_directionalValve_botports)))
			m4_define(`_directionalValve_botport['i`]', m4_argn(i, m4_extractargs(_directionalValve_botports)))
			m4_ifelse(m4_trim(m4_indir(`_directionalValve_botport['i`]')), `', `
				m4_define(`_directionalValve_botport['i`]', _directionalValve_portctr)
				m4_define(`_directionalValve_portctr', m4_eval(_directionalValve_portctr + 1))
			')
			m4_define(`_directionalValve_botposlabel['i`]', m4_patsubst(m4_indir(`_directionalValve_botport['i`]'), `^[^A-Z]', `T\&'))
			m4_define(`_directionalValve_portpos['m4_indir(`_directionalValve_botport['i`]')`]', m4_indir(`_directionalValve_botposlabel['i`]'))
			m4_define(`_directionalValve_portontop['m4_indir(`_directionalValve_botport['i`]')`]', 0)

			m4_indir(`_directionalValve_botposlabel['i`]'): Here;
			line dirToDirection(dirRev(peekDir())) elen/4;
			`Inside'm4_indir(`_directionalValve_botposlabel['i`]'): Here;
			move dirToDirection(peekDir()) elen/4 dirToDirection(_directionalValve_portDir) elen/4;
		')


		m4_define(`_directionalValve_leftfns',  m4_trim(m4_substr(_directionalValve_functions, 0, m4_index(_directionalValve_functions, `|'))))
		m4_define(`_directionalValve_rightfns', m4_trim(m4_substr(_directionalValve_functions, m4_eval(m4_index(_directionalValve_functions, `|') + 1))))
		
		m4_define(`_directionalValve_numleftfns', m4_nargs(m4_extractargs(_directionalValve_leftfns)))
		m4_define(`_directionalValve_numrightftfns', m4_nargs(m4_extractargs(_directionalValve_rightfns)))

		m4_foreach(`fn', _directionalValve_leftfns, `
			_directionalValveDrawFunction(fn, 0)
		')

		m4_foreach(`fn', _directionalValve_rightfns, `
			_directionalValveDrawFunction(fn, 1)
		')

		move to `Inside'm4_indir(_directionalValve_topposlabel[1]);
		m4_ifelse(m4_eval(_directionalValve_numtopports == 1 && _directionalValve_numbotports == 1), 1, `
			move dirToDirection(dirRev(_directionalValve_portDir)) elen/4;
		', `
			move dirToDirection(dirRev(_directionalValve_portDir)) elen/8;
		')
		DivT: Here;
		move dirToDirection(peekDir()) elen/2;
		DivB: Here;
		line from DivT to DivB;
		m4_ifelse(dirIsVertical(peekDir()), 1, `
			ValveBox: box wid elen ht elen/2 at 1/2 between DivB and DivT;
		', `
			ValveBox: box wid elen/22 ht elen at 1/2 between DivB and DivT;
		')

		m4_ifelse(_directionalValve_actuation, `solenoid', `
			m4_ifelse(dirIsVertical(peekDir()), 1, `
				line from ValveBox.sw left elen*5/16 then up elen/4 then right elen*5/16;
				move to ValveBox.sw then left elen*7/32;
				line to Here + (elen/8, elen/4);
			', `
				line from ValveBox.nw up elen*5/16 then right elen/4 then down elen*5/16;
				move to ValveBox.nw then up elen*7/32;
				line to Here + (elen/8, -elen/4);
			')
		')

		m4_ifelse(_directionalValve_return, `spring', `
			m4_ifelse(dirIsVertical(peekDir()), 1, `
				move to ValveBox.se then up elen/8;
				hydraulicsDrawSpring(Here, 0);
			', `
				move to ValveBox.sw then right elen/8;
				hydraulicsDrawSpring(Here, 270);
			')
		')

		popDir();
	] with .Start at _directionalValve_pos;

	m4_forloop(i, 1, _directionalValve_numtopports, `
		componentDrawTerminalLabel(`last [].'m4_indir(`_directionalValve_topposlabel['i`]'),
			m4_indir(`_directionalValve_topvislabel['i`]'))
	')
	m4_forloop(i, 1, _directionalValve_numbotports, `
		componentDrawTerminalLabel(`last [].'m4_indir(`_directionalValve_botposlabel['i`]'),
			m4_indir(`_directionalValve_botvislabel['i`]'))
	')

	componentDrawLabels(_directionalValve_)
	componentWriteBOM(_directionalValve_)

	move to last [].End;
')
m4_define_blind(`_directionalValveDrawFunction', `
	m4_define(`_directionalValve_fn', m4_trim(m4_substr($1, 0, m4_index($1, `('))))
	m4_define(`_directionalValve_ps', m4_trim(m4_substr($1, m4_eval(m4_index($1, `(') + 1)))

	m4_regexp($1, `\([^()]*\)\(.*\)', `
		m4_define(`_directionalValve_fn', m4_trim(\1))
		m4_define(`_directionalValve_ps', m4_trim(\2))
	')

	m4_define(`_directionalValve_p1', m4_argn(1, m4_extractargs(_directionalValve_ps)))
	m4_ifelse(_directionalValve_fn, `blocked', `
		move to `Inside'm4_indir(`_directionalValve_portpos['_directionalValve_p1`]');
		m4_ifelse($2, 1, `move dirToDirection(dirRev(_directionalValve_portDir)) elen/2')
		Loc1: Here;
		m4_ifelse(m4_indir(`_directionalValve_portontop['_directionalValve_p1`]'), 1, `
			line dirToDirection(peekDir()) elen/7;
		', `
			line dirToDirection(dirRev(peekDir())) elen/7;
		')
		move dirToDirection(dirRev(_directionalValve_portDir)) elen/28;
		line dirToDirection(_directionalValve_portDir) elen/14;
	', _directionalValve_fn, `dir', `
		m4_define(`_directionalValve_p2', m4_argn(2, m4_extractargs(_directionalValve_ps)))
		move to `Inside'm4_indir(`_directionalValve_portpos['_directionalValve_p1`]');
		m4_ifelse($2, 1, `move dirToDirection(dirRev(_directionalValve_portDir)) elen/2')
		Loc1: Here;

		move to `Inside'm4_indir(`_directionalValve_portpos['_directionalValve_p2`]');
		m4_ifelse($2, 1, `move dirToDirection(dirRev(_directionalValve_portDir)) elen/2')
		Loc2: Here;

		line from Loc1 to Loc2;
		_directionalValveDrawArrow(Loc2, angleBetweenPoints(Loc1, Loc2))
	', _directionalValve_fn, `bidir', `
		m4_define(`_directionalValve_p2', m4_argn(2, m4_extractargs(_directionalValve_ps)))
		move to `Inside'm4_indir(`_directionalValve_portpos['_directionalValve_p1`]');
		m4_ifelse($2, 1, `move dirToDirection(dirRev(_directionalValve_portDir)) elen/2')
		Loc1: Here;

		move to `Inside'm4_indir(`_directionalValve_portpos['_directionalValve_p2`]');
		m4_ifelse($2, 1, `move dirToDirection(dirRev(_directionalValve_portDir)) elen/2')
		Loc2: Here;

		line from Loc1 to Loc2;
		_directionalValveDrawArrow(Loc1, angleBetweenPoints(Loc2, Loc1))
		_directionalValveDrawArrow(Loc2, angleBetweenPoints(Loc1, Loc2))
	')
')
m4_define_blind(`_directionalValveDrawArrow', `
	angle = $2;
	Ar1: polarCoord($1, elen/32, angle + 180);
	ArC: polarCoord(Ar1, elen/8, angle + 180);
	Ar2: polarCoord(ArC, elen/28, angle + 90);
	Ar3: polarCoord(ArC, elen/28, angle - 90);
	line from ArC to Ar2 to Ar1 to Ar3 to ArC shaded "black";
')


`
Filter.

Usage: filter([comma-separated key-value parameters])
Params:
	pos:		Position to place first terminal at. Defaults to "Here".
	ref:		Component reference name.
	val:		Component value.
	description:	Additional text describing component purpose etc.
	refPos:		Reference labelling position. One of blank (default), reverse, below, above, ljust, rjust.
	part:		Part number. If this is supplied, it is added to BOM.
	startLabel:	Starting terminal label. Defaults to blank.
	endLabel:	Ending terminal label. Defaults to blank.
'
m4_define_blind(`filter', `
	componentParseKVArgs(`_filter_',
		(`pos', `Here',
		 `ref', `',
		 `val', `',
		 `description', `',
		 `refPos', `',
		 `part', `',
		 `startLabel', `',
		 `endLabel', `'), $@)
	componentHandleRef(_filter_)
	[
		pushDir();

		Start: Here;
		move dirToDirection(peekDir()) elen;
		End: Here;

		AO: Start;
		BO: End;

		AM: 7/24 between AO and BO;
		BM: 7/24 between BO and AO;

		line from AO to AM;
		line from BO to BM;

		angle = dirToAngle(peekDir());
		F1: polarCoord(1/2 between AO and BO, elen*5/24, angle - 90);
		F2: polarCoord(1/2 between AO and BO, elen*5/24, angle + 90);

		line dashed elen/32 from F1 to F2;
		line from AM to F1 to BM to F2 to AM;


		popDir();
	] with .Start at _filter_pos;

	# display terminal labels
	componentDrawTerminalLabel(last [].AO, textTerminalLabel(_filter_startLabel))
	componentDrawTerminalLabel(last [].BO, textTerminalLabel(_filter_endLabel))

	componentDrawLabels(_filter_)
	componentWriteBOM(_filter_)

	move to last [].End;
')


`
Pressure gauge.

Usage: pressureGauge([comma-separated key-value parameters])
Params:
	pos:		Position to place first terminal at. Defaults to "Here".
	ref:		Component reference name.
	val:		Component value.
	description:	Additional text describing component purpose etc.
	refPos:		Reference labelling position. One of blank (default), reverse, below, above, ljust, rjust.
	part:		Part number. If this is supplied, it is added to BOM.
'
m4_define_blind(`pressureGauge', `
	componentParseKVArgs(`_pressureGauge_',
		(`pos', `Here',
		 `ref', `',
		 `val', `',
		 `description', `',
		 `refPos', `',
		 `part', `',
		 `startLabel', `',
		 `endLabel', `'), $@)
	componentHandleRef(_pressureGauge_)
	[
		pushDir();

		Start: Here;

		move dirToDirection(peekDir()) elen/3;
		AM: Here;

		move to Start then dirToDirection(peekDir()) elen/2;
		C: Here;

		line from Start to AM;

		circle rad elen/6 with at C;

		line from last circle.se to last circle.nw;

		A1: polarCoord(last circle.nw, elen*3/128, 315);
		AC: polarCoord(A1, elen/8, 315);
		A2: polarCoord(AC, elen/24, 225);
		A3: polarCoord(AC, elen/24, 45);
		line from AC to A2 to A1 to A3 to AC shaded "black";

		popDir();
	] with .Start at _pressureGauge_pos;

	m4_define(`_pressureGauge_refPosXRef', last []. last circle.c.x)
	m4_define(`_pressureGauge_refPosYRef', last []. last circle.c.y)

	componentDrawLabels(_pressureGauge_)
	componentWriteBOM(_pressureGauge_)

	move to last [].Start;
')


`
Orifice.

Usage: orifice([comma-separated key-value parameters])
Params:
	pos:		Position to place first terminal at. Defaults to "Here".
	ref:		Component reference name.
	val:		Component value.
	description:	Additional text describing component purpose etc.
	refPos:		Reference labelling position. One of blank (default), reverse, below, above, ljust, rjust.
	part:		Part number. If this is supplied, it is added to BOM.
	type:		Orifice type. For now, only fixed (default) is supported.
	startLabel:	Starting terminal label. Defaults to blank.
	endLabel:	Ending terminal label. Defaults to blank.
'
m4_define_blind(`orifice', `
	componentParseKVArgs(`_orifice_',
		(`pos', `Here',
		 `ref', `',
		 `val', `',
		 `description', `',
		 `refPos', `',
		 `part', `',
		 `startLabel', `',
		 `endLabel', `'), $@)
	componentHandleRef(_orifice_)
	[
		pushDir();

		Start: Here;
		move dirToDirection(peekDir()) elen;
		End: Here;

		line from Start to End;

		AM: 1/4 between Start and End;
		BM: 1/4 between End and Start;

		move to AM then dirToDirection(dirCW(peekDir())) elen/8;
		A1S: Here;
		move to BM then dirToDirection(dirCW(peekDir())) elen/8;
		A1E: Here;

		move to AM then dirToDirection(dirCCW(peekDir())) elen/8;
		A2S: Here;
		move to BM then dirToDirection(dirCCW(peekDir())) elen/8;
		A2E: Here;

	] with .Start at _orifice_pos;

	# arc curves drawn outside of group, so as to not move terminal text too far out from imaginary arc centre
	move to 1/2 between last [].A1S and last [].A1E then dirToDirection(dirCW(peekDir())) elen/3;
	A_orifice_1C_: Here;
	arc cw from last [].A1S to last [].A1E with .c at A_orifice_1C_;
	move to 1/2 between last [].A2S and last [].A2E then dirToDirection(dirCCW(peekDir())) elen/3;
	A_orifice_2C_: Here;
	arc ccw from last [].A2S to last [].A2E with .c at A_orifice_2C_;

	popDir();

	# display terminal labels
	componentDrawTerminalLabel(last [].Start, textTerminalLabel(_orifice_startLabel))
	componentDrawTerminalLabel(last [].End, textTerminalLabel(_orifice_endLabel))

	componentDrawLabels(_orifice_)
	componentWriteBOM(_orifice_)

	move to last [].End;
')
