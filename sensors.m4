`
Sensor symbol.

Usage: sensor([key-value separated parameters])
Params:
	pos:		Position to place ".Start at". Defaults to "Here".
	ref:		Component reference name. Must be a valid pic label (no spaces, starts with capital
			letter). Will prefix reference name with the current sheet number.
	val:		Component value
	description:	Additional text describing component purpose etc.
	part:		Part number. If this is supplied, it is added to the BOM.
	type:		Sensor type. One of "proximity", "prox", "distance" (all same thing for now).
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
		 `part', `',
		 `type', `',
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

		line from last box m4_ifelse(dirIsVertical(peekDir()), 1, `.e right', `.s down') elen/4;
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
