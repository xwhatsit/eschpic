`
Sensor symbol.

Usage: sensor([key-value separated parameters])
Params:
	pos:		Position to place ".Start at". Defaults to "Here".
	ref:		Component reference name. Must be a valid pic label (no spaces, starts with capital
			letter). Will prefix reference name with the current sheet number.
	val:		Component value
	description:	Additional text describing component purpose etc.
	refPos:		Reference labelling position. One of blank (default), reverse, below, above, ljust, rjust.
	part:		Part number. If this is supplied, it is added to the BOM.
	type:		Sensor type. One of "proximity", "prox", "distance" (all same thing for now).
	flipped:	Whether to draw output in standard orientation ("false", default).
	positiveLabel:	Label of positive terminal. Defaults to "BN".
	negativeLabel:	Label of negative terminal. Defaults to "BU".
	outputLabel:	Label of output terminal. Defaults to "BK".
'
m4_define_blind(`sensor', `
	componentParseKVArgs(`_sensor_',
		(`pos', `Here',
		 `ref', `',
		 `val', `',
		 `description', `',
		 `refPos', `',
		 `part', `',
		 `type', `',
		 `flipped', `false',
		 `positiveLabel', `BN',
		 `negativeLabel', `BU',
		 `outputLabel', `BK'), $@)
	componentHandleRef(_sensor_)

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
		AM: 1/4 between AO and BO;
		BM: 1/4 between BO and AO;

		box wid elen/2 ht elen/2 at 1/2 between Start and End;
		line from AO to AM;
		line from BO to BM;

		line from last box m4_ifelse(dirIsVertical(peekDir()), 1, m4_ifelse(_sensor_flipped, `false', `.e right', `.w left'), m4_ifelse(_sensor_flipped, `false', `.s down', `.n up')) elen/4;
		CO: Here;

		componentDrawActuator(_sensor_type, last box.c, m4_ifelse(dirIsVertical(peekDir()), 1, `180, 1', `90, -1'));

		`T'm4_patsubst(_sensor_positiveLabel, `[^A-Za-z0-9]', `_')`: AO';
		`T'm4_patsubst(_sensor_negativeLabel, `[^A-Za-z0-9]', `_')`: BO';
		`T'm4_patsubst(_sensor_outputLabel,   `[^A-Za-z0-9]', `_')`: CO';

		popDir();
	] with .Start at _sensor_pos;

	componentDrawTerminalLabel(last [].AO, _sensor_positiveLabel);
	componentDrawTerminalLabel(last [].BO, _sensor_negativeLabel);

	pushDir(m4_ifelse(dirIsVertical(getDir()), 1, dirRight, dirDown));
	componentDrawTerminalLabel(last [].CO, _sensor_outputLabel);
	popDir();

	move to last [].End

	componentDrawLabels(_sensor_)
	componentWriteBOM(_sensor_)
')


`
Resolver symbol.

Usage: resolver([key-value separated parameters])
Params:
	pos:		Position to place first terminal at. Defaults to "Here".
	ref:		Component reference name.
	val:		Component value.
	description:	Component description.
	refPos:		Reference labelling position. One of blank (default), reverse, below, above, ljust, rjust.
	part:		Part number.
	labels:		Terminal labels, in format (1st, 2nd...). Defaults to (R1, R2, S1, S3, S2, S4).
'
m4_define_blind(`resolver', `
	componentParseKVArgs(`_resolver_',
		(`pos', `Here',
		 `ref', `',
		 `val', `',
		 `description', `',
		 `refPos', `',
		 `part', `',
		 `labels', `(R1, R2, S1, S3, S2, S4)'), $@)

	componentHandleRef(_resolver_)
	[
		pushDir();

		m4_define(`_resolver_termDir', m4_ifelse(dirIsVertical(peekDir()), 1, dirRight, dirDown));
		m4_define(`_resolver_termCount', m4_nargs(m4_extractargs(_resolver_labels)))

		Start: Here;

		m4_forloop(i, 1, _resolver_termCount, `
			N`'i: Here;
			m4_define(`_resolver_currLabel', m4_argn(i, m4_extractargs(_resolver_labels)))
			m4_ifelse(m4_regexp(_resolver_currLabel, `[A-Za-z0-9]*$'), 0, `T'_resolver_currLabel: Here);
			line dirToDirection(peekDir()) elen/4;
			componentDrawTerminalLabel(N`'i, _resolver_currLabel)
			move to N`'i then dirToDirection(_resolver_termDir) elen/2;
		')

		move to Start then dirToDirection(dirRev(_resolver_termDir)) elen/4 then dirToDirection(peekDir()) elen/4;
		BoxCorner: Here;
		
		m4_define(`_resolver_boxLen', `(elen/2 * _resolver_termCount)')
		m4_define(`_resolver_boxRef', m4_ifelse(m4_eval(peekDir() == dirUp),    1, `.sw',
							m4_eval(peekDir() == dirDown),  1, `.nw',
							m4_eval(peekDir() == dirLeft),  1, `.ne',
							m4_eval(peekDir() == dirRight), 1, `.nw'))
		box m4_ifelse(dirIsVertical(peekDir()), 1, `wid _resolver_boxLen ht elen*7/8', `wid elen*7/8 ht _resolver_boxLen') with _resolver_boxRef at BoxCorner;

		circle rad elen*5/16 at last box.c;
		CC: last circle.c;
		move to CC then left elen*7/32;

		spacing = elen*3/32;
		amplitude = elen*3/16;

		AC1: Here + (0, 0);
		AC2: AC1 + (spacing*1, amplitude);
		AC3: AC1 + (spacing*2, 0);
		AC4: AC1 + (spacing*3, -amplitude);
		AC5: AC1 + (spacing*4, 0);
		spline from AC1 to AC2 to AC3 to AC4 to AC5;

		AC1: AC1 + (spacing*1, 0);
		AC2: AC1 + (spacing*1, amplitude);
		AC3: AC1 + (spacing*2, 0);
		AC4: AC1 + (spacing*3, -amplitude);
		AC5: AC1 + (spacing*4, 0);
		spline from AC1 to AC2 to AC3 to AC4 to AC5;


		popDir();
	] with .Start at _resolver_pos;

	m4_define(`_resolver_refPosXRef', last []. last circle.c.x)
	m4_define(`_resolver_refPosYRef', last []. last circle.c.y)

	componentDrawLabels(_resolver_)
	componentWriteBOM(_resolver_)

	move to last [].Start;
')


`
Encoder symbol.

Usage: encoder([key-value separated parameters])
Params:
	pos:		Position to place first terminal at. Defaults to "Here".
	ref:		Component reference name.
	val:		Component value.
	description:	Component description.
	refPos:		Reference labelling position. One of blank (default), reverse, below, above, ljust, rjust.
	part:		Part number.
	labels:		Terminal labels, in format (1st, 2nd...). Defaults to (V+, V-, A, B).
'
m4_define_blind(`encoder', `
	componentParseKVArgs(`_encoder_',
		(`pos', `Here',
		 `ref', `',
		 `val', `',
		 `description', `',
		 `refPos', `',
		 `part', `',
		 `type', `',
		 `labels', `(V+, V-, A, B)'), $@)

	componentHandleRef(_encoder_)
	[
		pushDir();

		m4_define(`_encoder_termDir', m4_ifelse(dirIsVertical(peekDir()), 1, dirRight, dirDown));
		m4_define(`_encoder_termCount', m4_nargs(m4_extractargs(_encoder_labels)))

		Start: Here;

		m4_forloop(i, 1, _encoder_termCount, `
			N`'i: Here;
			m4_define(`_encoder_currLabel', m4_argn(i, m4_extractargs(_encoder_labels)))
			m4_ifelse(m4_regexp(_encoder_currLabel, `[A-Za-z0-9]*$'), 0, `T'_encoder_currLabel: Here);
			line dirToDirection(peekDir()) elen/4;
			componentDrawTerminalLabel(N`'i, _encoder_currLabel)
			move to N`'i then dirToDirection(_encoder_termDir) elen/2;
		')

		move to Start then dirToDirection(dirRev(_encoder_termDir)) elen/4 then dirToDirection(peekDir()) elen/4;
		BoxCorner: Here;
		
		m4_define(`_encoder_boxLen', `(elen/2 * _encoder_termCount)')
		m4_define(`_encoder_boxRef', m4_ifelse(m4_eval(peekDir() == dirUp),    1, `.sw',
							m4_eval(peekDir() == dirDown),  1, `.nw',
							m4_eval(peekDir() == dirLeft),  1, `.ne',
							m4_eval(peekDir() == dirRight), 1, `.nw'))
		box m4_ifelse(dirIsVertical(peekDir()), 1, `wid _encoder_boxLen ht elen*7/8', `wid elen*7/8 ht _encoder_boxLen') with _encoder_boxRef at BoxCorner;

		circle rad elen*5/16 at last box.c;
		CC: last circle.c;
		move to CC then left elen*7/32;

		spacing = elen*1/8;
		amplitude = elen*1/8;

		SW1: Here + (0, 0);
		SW2: SW1 + (0, amplitude);
		SW3: SW1 + (spacing*1, amplitude);
		SW4: SW1 + (spacing*1, 0);
		SW5: SW1 + (spacing*2, 0);
		SW6: SW1 + (spacing*2, amplitude);
		SW7: SW1 + (spacing*3, amplitude);
		line from SW1 to SW2 to SW3 to SW4 to SW5 to SW6 to SW7;

		SW1: SW1 + (spacing/2, -(amplitude + elen/32));
		SW2: SW1 + (0, amplitude);
		SW3: SW1 + (spacing*1, amplitude);
		SW4: SW1 + (spacing*1, 0);
		SW5: SW1 + (spacing*2, 0);
		SW6: SW1 + (spacing*2, amplitude);
		SW7: SW1 + (spacing*3, amplitude);
		line from SW1 to SW2 to SW3 to SW4 to SW5 to SW6 to SW7;

		popDir();
	] with .Start at _encoder_pos;

	m4_define(`_encoder_refPosXRef', last []. last circle.c.x)
	m4_define(`_encoder_refPosYRef', last []. last circle.c.y)

	componentDrawLabels(_encoder_)
	componentWriteBOM(_encoder_)

	move to last [].Start;
')
