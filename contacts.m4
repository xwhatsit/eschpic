m4_divert(-1)

`
Helper macro for drawing button heads. Uses current direction.

Usage: componentDrawButtonHead(type, pos, operationAngle, reversed)
Params:
	type:	        Head type. One of "manual", "selector" (also "turn" and "twist"), "push",
			"pull", "mushroom" (also "estop"), "foot", or "key".
	pos:	        Location to draw it at.
	operationAngle:	The direction of the operator, i.e. 180 if horizontal, 90 if vertical.
	reversed:	Set to 1 if normal, -1 if flipped.
'
m4_define_blind(`componentDrawButtonHead', `
	m4_ifelse($1, `manual', `
		line from polarCoord($2, 1.2, $3 - 90) to polarCoord($2, 1.2, $3 + 90);
	', $1, `selector', `
		OperatorSelectorT: polarCoord($2, 1.2, $3 - $4*90);
		OperatorSelectorB: polarCoord($2, 1.2, $3 + $4*90);
		line from polarCoord(OperatorSelectorB, 0.8, $3) to OperatorSelectorB \
			then to OperatorSelectorT \
			then to polarCoord(OperatorSelectorT, 0.8, $3 - 180);
	', $1, `push', `
		OperatorPushT: polarCoord($2, 1.2, $3 - 90);
		OperatorPushB: polarCoord($2, 1.2, $3 + 90);
		line from polarCoord(OperatorPushB, 0.8, $3 - 180) to OperatorPushB \
			then to OperatorPushT \
			then to polarCoord(OperatorPushT, 0.8, $3 - 180);
	', $1, `pull', `
		OperatorPullT: polarCoord($2, 1.2, $3 - 90);
		OperatorPullB: polarCoord($2, 1.2, $3 + 90);
		line from polarCoord(OperatorPullB, 0.8, $3) to OperatorPullB \
			then to OperatorPullT \
			then to polarCoord(OperatorPullT, 0.8, $3);
	', $1, `mushroom', `
		OperatorEStopT: polarCoord($2, 1.2, $3 - 90);
		OperatorEStopB: polarCoord($2, 1.2, $3 + 90);
		arc cw from OperatorEStopB to OperatorEStopT with .c at $2;
		line from OperatorEStopB to \
			polarCoord(OperatorEStopB, pointsToMillimetres(linethick/2), $3 - 180);
		line from OperatorEStopT to \
			polarCoord(OperatorEStopT, pointsToMillimetres(linethick/2), $3 - 180);
		line from OperatorEStopB to OperatorEStopT;
	', $1, `foot', `
		OperatorFootT: polarCoord($2,   1.33, $3 - $4*117);
		OperatorFootB: polarCoord($2,   1.33, $3 + $4*63);
		OperatorFootL: polarCoord(OperatorFootB, 0.89, $3 - $4*27);
		line from OperatorFootL to OperatorFootB to OperatorFootT;
	', $1, `key', `
		OperatorKeyTT: polarCoord($2,            1.33, $3 - $4*76);
		OperatorKeyTC: polarCoord(OperatorKeyTT, 0.50, $3 + $4*90);
		OperatorKeyBM: polarCoord(OperatorKeyTT, 2.48, $3 + $4*90);
		OperatorKeyBL: polarCoord(OperatorKeyBM, 0.50, $3);
		OperatorKeyBR: polarCoord(OperatorKeyBM, 0.50, $3 - 180);
		circle rad 0.5 at OperatorKeyTC;
		line from polarCoord(OperatorKeyTT, 1.0, $3 + $4*76) \
			to polarCoord(OperatorKeyBL, 0.5, $3 - $4*90) \
			to OperatorKeyBL \
			to OperatorKeyBR \
			to polarCoord(OperatorKeyBR, 0.5, $3 - $4*90) \
			to polarCoord(OperatorKeyTT, 1.0, $3 - $4*256);
	', $1, `turn',  `componentDrawButtonHead(selector, $2, $3, $4)
	', $1, `twist', `componentDrawButtonHead(selector, $2, $3, $4)
	', $1, `estop', `componentDrawButtonHead(mushroom, $2, $3, $4)
	')
')


`
Helper macro for drawing button actions. Uses current direction. Defines at the very least
two positions, OperatorActL and OperatorActR, which are the connection points on either side.

Usage: componentDrawButtonAction(type, pos, operationAngle, reversed)
Params:
	type:           Action type. One of "maintained", "maintained-reset", "off",
	                "spring-return-l", "spring-return-r".
	pos:            Location to draw it at.
	operationAngle: The direction of the operator, i.e. 180 if horizontal, 90 if vertical.
	reversed:       Set to 1 if normal, -1 if flipped.
'
m4_define_blind(`componentDrawButtonAction', `
	m4_ifelse($1, `maintained', `
		OperatorActB: polarCoord($2, 1.2, operatorAngle + operatorRev*90);
		OperatorActL: polarCoord($2, 0.4, operatorAngle);
		OperatorActR: polarCoord($2, 0.4, operatorAngle - 180);
		line from polarCoord(OperatorActL, pointsToMillimetres(linethick/2), operatorAngle) \
			to OperatorActL to OperatorActB to OperatorActR \
			to polarCoord(OperatorActR, pointsToMillimetres(linethick/2), operatorAngle - 180);
	', $1, `maintained-reset', `
		OperatorActL: polarCoord($2,           1.20, operatorAngle);
		OperatorActR: polarCoord($2,           0.46, operatorAngle - 180);
		OperatorActT: polarCoord(OperatorActL, 0.77, operatorAngle - 90*operatorRev);
		line from OperatorActL to OperatorActT to OperatorActR;
	', $1, `off', `
		OperatorActL: $2;
		OperatorActR: $2;
		line dashed elen/25 \
			from polarCoord($2, pointsToMillimetres(linethick/2), operatorAngle + 90*operatorRev) \
			to polarCoord($2, 1.6, operatorAngle - 90*operatorRev);
	', $1, `spring-return-l', `
		OperatorActL: polarCoord($2,           0.4, operatorAngle);
		OperatorActR: polarCoord($2,           1.2, operatorAngle - 180);
		OperatorActT: polarCoord(OperatorActL, 0.8, operatorAngle - 90*operatorRev);
		OperatorActB: polarCoord(OperatorActL, 0.8, operatorAngle + 90*operatorRev);
		line from OperatorActR to OperatorActB to OperatorActL to OperatorActT to OperatorActR;
	', $1, `spring-return-r', `
		OperatorActL: polarCoord($2,           1.2, operatorAngle);
		OperatorActR: polarCoord($2,           0.4, operatorAngle - 180);
		OperatorActT: polarCoord(OperatorActR, 0.8, operatorAngle - 90*operatorRev);
		OperatorActB: polarCoord(OperatorActR, 0.8, operatorAngle + 90*operatorRev);
		line from OperatorActR to OperatorActB to OperatorActL to OperatorActT to OperatorActR;
	')
')


`
Helper macro for drawing contact operators (e.g. see "operation" parameter in contactNO). Should be called
within contact macro block itself (i.e. with "[", "]" brackets). Tries to combine multiple things in an
intelligent way.

Usage: componentAddContactOperators(operatorString, [isNCContact])
Params:
	operatorString: Space-separated string of operator modifiers. Can be composed of following:
			heads:  "manual", "selector", "turn", "twist" "push", "pull", "estop", "mushroom",
			        "foot", "key"
			action: "maintained", "3-pos", "mid-off", "spring-return", "spring-return-l", "spring-return-r"
			reset:  any head listed above followed by "-reset" (e.g. "pull-reset")
'
m4_define_blind(`componentAddContactOperators', `
	m4_pushdef(`operatorString', ` '$1` ')

	m4_ifelse(dirIsVertical(peekDir()), 1, `
		operatorAngle = 180;
		operatorRev = 1;
	', `
		operatorAngle = 90;
		operatorRev = -1;
	');
	OperatorPos: polarCoord(MidContact, 4, operatorAngle);

	# draw reset action
	m4_pushdef(`operatorReset', m4_regexp(operatorString, `[ \t]\([A-Za-z]+\)-reset[ \t]', `\1'))
	m4_ifelse(operatorReset, `', `', `
		OperatorResetB: polarCoord(MidContact,     elen/8, operatorAngle);
		OperatorResetT: polarCoord(OperatorResetB, elen/4, operatorAngle - operatorRev*90);
		OperatorResetL: polarCoord(OperatorResetT, 2.4,    operatorAngle);
		line dashed elen/18 from OperatorResetB to OperatorResetT to OperatorResetL;
		componentDrawButtonHead(operatorReset, OperatorResetL, operatorAngle, operatorRev);
	')

	# determine operator head, modify OperatorPos if necessary
	m4_pushdef(`operatorHead', `')
	m4_ifelse(m4_eval(m4_index(operatorString, ` manual ') != -1), 1, `
		m4_define(`operatorHead', manual)
	', m4_eval(m4_index(operatorString, ` selector ') != -1 ||
	           m4_index(operatorString, ` turn ')     != -1 ||
		   m4_index(operatorString, ` twist ')    != -1), 1, `
		m4_define(`operatorHead', selector)
	', m4_eval(m4_index(operatorString, ` push ') != -1), 1, `
		m4_define(`operatorHead', push)
	', m4_eval(m4_index(operatorString, ` pull ') != -1), 1, `
		OperatorPos: polarCoord(OperatorPos, 0.825, operatorAngle - 180);
		m4_define(`operatorHead', pull)
	', m4_eval(m4_index(operatorString, ` estop ') != -1 ||
	                  m4_index(operatorString, ` mushroom ') != -1), 1, `
		m4_define(`operatorHead', mushroom)
	', m4_eval(m4_index(operatorString, ` foot ') != -1), 1, `
		OperatorPos: polarCoord(OperatorPos, 0.63, operatorAngle - 180);
		m4_define(`operatorHead', foot)
	', m4_eval(m4_index(operatorString, ` key ') != -1), 1, `
		m4_define(`operatorHead', key)
	')

	# draw action
	m4_ifelse(m4_index(operatorString, ` 3-pos '), -1, `
		m4_ifelse(m4_eval(m4_index(operatorString, ` maintained ') != -1), 1, `
			OperatorPos: polarCoord(OperatorPos, 1.5, operatorAngle);
			OperatorActM: 1/2 between MidContact and OperatorPos;

			# drawn differently if we have a reset action
			m4_ifelse(operatorReset, `', `
				componentDrawButtonAction(maintained, OperatorActM, operatorAngle, operatorRev);
				line dashed elen/18 from OperatorPos to OperatorActL;
				line dashed elen/18 from MidContact to OperatorActR;
			', `
				componentDrawButtonAction(maintained-reset, OperatorActM, operatorAngle, operatorRev);
				line dashed elen/18 from OperatorPos to MidContact;
			')
		', `
			m4_ifelse(operatorHead, `', `', `line dashed elen/18 from OperatorPos to MidContact')
		')
	', `
		OperatorPos: polarCoord(OperatorPos, 4.73, operatorAngle);
		operatorPosActSpacing = (8.73 - 1.6) / 3;
		operatorPosEndOffset = (8.73 - (2 * operatorPosActSpacing)) / 2;

		OperatorActM: polarCoord(MidContact, operatorPosEndOffset, operatorAngle);
		m4_ifelse(m4_eval(m4_index(operatorString, ` spring-return ') != -1 ||
		                  m4_index(operatorString, ` spring-return-r ') != -1), 1, `
			componentDrawButtonAction(spring-return-r, OperatorActM, operatorAngle, operatorRev)
		', `
			componentDrawButtonAction(maintained, OperatorActM, operatorAngle, operatorRev)
		')
		line dashed elen/25 from MidContact to OperatorActR;
		PrevOperatorActL: OperatorActL;

		OperatorActM: polarCoord(OperatorActM, operatorPosActSpacing, operatorAngle);
		m4_ifelse(m4_eval(m4_index(operatorString, ` mid-off ') != -1), 1, `
			componentDrawButtonAction(off, OperatorActM, operatorAngle, operatorRev);
		', `
			componentDrawButtonAction(maintained, OperatorActM, operatorAngle, operatorRev);
		')
		line dashed elen/25 from PrevOperatorActL to OperatorActR;
		PrevOperatorActL: OperatorActL;

		OperatorActM: polarCoord(OperatorActM, operatorPosActSpacing, operatorAngle);
		m4_ifelse(m4_eval(m4_index(operatorString, ` spring-return ') != -1 ||
		                  m4_index(operatorString, ` spring-return-l ') != -1), 1, `
			componentDrawButtonAction(spring-return-l, OperatorActM, operatorAngle, operatorRev);
		', `
			componentDrawButtonAction(maintained, OperatorActM, operatorAngle, operatorRev);
		')
		line dashed elen/25 from PrevOperatorActL to OperatorActR;
		line dashed elen/25 from OperatorPos to OperatorActL;
	')

	# finally draw button head
	componentDrawButtonHead(operatorHead, OperatorPos, operatorAngle, operatorRev)

	m4_popdef(`operatorReset')
	m4_popdef(`operatorHead')
	m4_popdef(`operatorString')
')

`
Helper macro for drawing contact modifiers (e.g. see "type" parameter in contactNO). Should be called within
contact macro block itself (i.e. within "[", "]" brackets).

Usage: componentAddContactModifiers(typeString, [isNCContact])
Params:
	typeString:  Space-separated string of contact modifiers. Can be composed of "switch",
	             "disconnect", "fuse", "contactor", "thermal", "magnetic", "breaker", "limit".
	isNCContact: Optional. Should be set to "true" if this is a normally-closed contact.
'
m4_define_blind(`componentAddContactModifiers', `
	m4_ifelse(m4_index($1, `switch'), -1, `', `
		circle rad 0.4 with \
		m4_ifelse(dirIsVertical(peekDir()), 1,
			`.n at AM',
			`.w at AM')
	')
	m4_ifelse(m4_index($1, `disconnect'), -1, `', `
		m4_ifelse(dirIsVertical(peekDir()), 1,
			`line from AM-(0.6,0) to AM+(0.6,0)',
			`line from AM-(0,0.6) to AM+(0,0.6)')
	')
	m4_ifelse(m4_index($1, `fuse'), -1, `', `
		m4_ifelse(dirIsVertical(peekDir()), 1, `
			FuseN:  polarCoord(MidContact, 1.25, 108);
			FuseS:  polarCoord(MidContact, 1.25, 288);
			FuseNE: polarCoord(FuseN, 0.53,  18);
			FuseSE: polarCoord(FuseS, 0.53,  18);
			FuseNW: polarCoord(FuseN, 0.53, 198);
			FuseSW: polarCoord(FuseS, 0.53, 198);
			', `
			FuseN:  polarCoord(MidContact, 1.25, 162);
			FuseS:  polarCoord(MidContact, 1.25, 342);
			FuseNE: polarCoord(FuseN, 0.53,  72);
			FuseSE: polarCoord(FuseS, 0.53,  72);
			FuseNW: polarCoord(FuseN, 0.53, 252);
			FuseSW: polarCoord(FuseS, 0.53, 252);
		')
		line from FuseNE to FuseSE then to FuseSW then to FuseNW then to FuseNE then to FuseSE;
	')
	m4_ifelse(m4_index($1, `contactor'), -1, `', `
		_contactorLineAdjust = pointsToMillimetres(linethick/2);
		m4_ifelse(dirIsVertical(peekDir()), 1,
			`arc cw from AM+(0,_contactorLineAdjust) to AM+(0,1.2+_contactorLineAdjust) with .c at AM+(0,0.6+_contactorLineAdjust)',
			`arc cw from AM-(1.2+_contactorLineAdjust,0) to AM-(_contactorLineAdjust,0) with .c at AM-(0.6+_contactorLineAdjust,0)')
	')
	m4_ifelse(m4_index($1, `thermal'), -1, `', `
		m4_ifelse(dirIsVertical(peekDir()), 1, `
			Thermal1: polarCoord(MidContact, 0.63, 108);
			Thermal2: polarCoord(Thermal1,   0.94, 198);
			Thermal3: polarCoord(Thermal2,   0.94, 108);
			Thermal4: polarCoord(Thermal3,   0.94, 198);
			Thermal5: polarCoord(Thermal4,   0.94, 288);
			Thermal6: polarCoord(Thermal5,   0.63, 198);
			', `
			Thermal1: polarCoord(MidContact, 0.63, 162);
			Thermal2: polarCoord(Thermal1,   0.94,  72);
			Thermal3: polarCoord(Thermal2,   0.94, 162);
			Thermal4: polarCoord(Thermal3,   0.94,  72);
			Thermal5: polarCoord(Thermal4,   0.94, 342);
			Thermal6: polarCoord(Thermal5,   0.63,  72);
		')
		line from Thermal1 to Thermal2 then to Thermal3 then to Thermal4 then to Thermal5 then to Thermal6;
	')
	m4_ifelse(m4_index($1, `magnetic'), -1, `', `
		m4_ifelse(dirIsVertical(peekDir()), 1, `
			Magnetic1: polarCoord(MidContact, 0.63, 288);
			Magnetic2: polarCoord(Magnetic1,  1.00, 198);
			Magnetic3: polarCoord(Magnetic2,  0.50, 108);
			Magnetic4: polarCoord(Magnetic2,  0.50, 288);
			Magnetic5: polarCoord(Magnetic1,  2.30, 198);
			', `
			Magnetic1: polarCoord(MidContact, 0.63, 342);
			Magnetic2: polarCoord(Magnetic1,  1.12,  72);
			Magnetic3: polarCoord(Magnetic2,  0.50, 162);
			Magnetic4: polarCoord(Magnetic2,  0.50, 342);
			Magnetic5: polarCoord(Magnetic1,  2.40,  72);
		')
		line from Magnetic1 to Magnetic2;
		line from Magnetic2 to Magnetic3 then to Magnetic5 then to Magnetic4 then to Magnetic2 shaded "black";
	')
	m4_ifelse(m4_index($1, `breaker'), -1, `', `
		m4_pushdef(`offset', `m4_ifelse(m4_index($1, `disconnector'), -1, `0', `elen/10')')
		BreakerC: polarCoord(AM, offset, m4_ifelse(dirIsVertical(peekDir()), 1, 90, 180));
		line from BreakerC-(0.6,0.6) to BreakerC+(0.6,0.6);
		line from BreakerC-(0.6,-0.6) to BreakerC+(0.6,-0.6);
		m4_popdef(`offset')
	')
	m4_ifelse(m4_index($1, `limit'), -1, `', `
		m4_ifelse(dirIsVertical(peekDir()), 1, `_limitRev = 1', `_limitRev = -1');
		m4_ifelse($2, `true', `_limitAdjust = 0.83', `_limitAdjust = 0');
		LimitT: polarCoord(MidContact, 1.40 - _limitAdjust, contactAngle);
		LimitB: polarCoord(MidContact, 0.98 + _limitAdjust, contactAngle + _limitRev*180);
		LimitL: polarCoord(LimitT,     1.19, contactAngle + _limitRev*90);
		line from LimitB to LimitL then to LimitT;
	')
')


`
Normally-open contact. Draws in current direction.

Usage: contactNO([comma-separated key-value parameters])
Params:
	pos:		Position to place ".Start" at. Defaults to "Here".
	flipped:	Whether contact is flipped. Either "true" or "false". Defaults to "false".
	ref:		Component reference name. Must be a valid pic label (no spaces, starts with capital
			letter). Will prefix reference name with the current sheet number.
	val:		Component value
	description:	Additional text describing component purpose etc.
	part:		Part number. If this is supplied, it is added to the BOM.
	set:		Contact set number, used for automatic start/end terminal labels. Defaults to "1".
	startLabel:	Starting terminal label. Defaults to "3".
	endLabel:	Ending terminal label. Defaults to "4".
	type:		Contact type. Can specify more than one. See "typeString" parameter in
	                componentAddContactModifiers for valid values.
	operation:	Means of contact operation. Can specify more than one. See "operationString" parameter
	                in componentAddContactOperators for valid values.
'
m4_define_blind(`contactNO', `
	componentParseKVArgs(`_contactNO_',
		(`pos', `Here',
		 `flipped', `false',
		 `ref', `',
		 `val', `',
		 `description', `',
		 `part', `',
		 `set', `1',
		 `startLabel', `3',
		 `endLabel', `4',
		 `type', `',
		 `operation', `'), $@)
	componentHandleRef(_contactNO_)

	# assemble terminal labels
	m4_define(`_contactNO_fullStartLabel', _contactNO_set`'_contactNO_startLabel)
	m4_define(`_contactNO_fullEndLabel', _contactNO_set`'_contactNO_endLabel)

	[
		pushDir();

		Start: Here;
		move dirToDirection(peekDir()) elen;
		End: Here;

		m4_define(`_contactNO_flipped', m4_eval(m4_index(_contactNO_flipped, `true') != -1))

		m4_ifelse(m4_eval(_contactNO_flipped ^ dirIsConventional(peekDir())), 1, `
			AO: Start;
			BO: End;
		', `
			AO: End;
			BO: Start;
		')

		AM: 5/16 of the way between AO and BO;
		BM: 5/16 of the way between BO and AO;

		if dirIsVertical(peekDir()) then {
			contactAngle = 108;
			m4_ifelse(_contactNO_flipped, 1, `contactAngle = 360 - contactAngle');
		} else {
			contactAngle = 162;
			m4_ifelse(_contactNO_flipped, 1, `contactAngle = 180 - contactAngle');
		}
		line from AO to AM;
		line from BO to BM then to polarCoord(BM, 5.02, contactAngle);
		MidContact: polarCoord(BM, 2.51, contactAngle);

		componentAddContactModifiers(_contactNO_type)
		componentAddContactOperators(_contactNO_operation)

		# if terminal labels are defined, add positional labels as "T_" + name (e.g. ".T_13")
		m4_ifelse(_contactNO_fullStartLabel, `', `', `T_'_contactNO_fullStartLabel`: AO')
		m4_ifelse(_contactNO_fullEndLabel,   `', `', `T_'_contactNO_fullEndLabel`:   BO')

		popDir();
	] with .Start at _contactNO_pos;

	# display terminal labels
	componentDrawTerminalLabel(last [].AO, _contactNO_fullStartLabel);
	componentDrawTerminalLabel(last [].BO, _contactNO_fullEndLabel);

	componentDrawLabels(_contactNO_)

	move to last [].End
')


`
Normally-closed contact. Draws in current direction.

Usage: contactNC([comma-separated key-value parameters])
Params:
	pos:		Position to place ".Start" at. Defaults to "Here".
	flipped:	Whether contact is flipped. Either "true" or "false". Defaults to "false".
	ref:		Component reference name. Must be a valid pic label (no spaces, starts with capital
			letter). Will prefix reference name with the current sheet number.
	val:		Component value
	description:	Additional text describing component purpose etc.
	part:		Part number. If this is supplied, it is added to the BOM.
	set:		Contact set number, used for automatic start/end terminal labels. Defaults to "1".
	startLabel:	Starting terminal label. Defaults to "1".
	endLabel:	Ending terminal label. Defaults to "2".
	type:		Contact type. Can specify more than one. See "typeString" parameter in contactModifiers
			for valid values. Not all will work properly with NC contact.
	operation:	Means of contact operation. Can specify more than one. See "operationString" parameter
	                in componentAddContactOperators for valid values.
'
m4_define_blind(`contactNC', `
	componentParseKVArgs(`_contactNC_',
		(`pos', `Here',
		 `flipped', `false',
		 `ref', `',
		 `val', `',
		 `description', `',
		 `part', `',
		 `set', `1',
		 `startLabel', `1',
		 `endLabel', `2',
		 `type', `',
		 `operation', `'), $@)
	componentHandleRef(_contactNC_)

	# assemble terminal labels
	m4_define(`_contactNC_fullStartLabel', _contactNC_set`'_contactNC_startLabel)
	m4_define(`_contactNC_fullEndLabel', _contactNC_set`'_contactNC_endLabel)

	[
		pushDir();

		Start: Here;
		move dirToDirection(peekDir()) elen;
		End: Here;

		m4_define(`_contactNC_flipped', m4_eval(m4_index(_contactNC_flipped, `true') != -1))
		m4_ifelse(m4_eval(_contactNC_flipped ^ dirIsConventional(peekDir())), 1, `
			AO: Start;
			BO: End;
		', `
			AO: End;
			BO: Start;
		')

		AM: 1/2.9 of the way between AO and BO;
		BM: 5/16 of the way between BO and AO;

		if dirIsVertical(peekDir()) then {
			topAngle = 0;
			contactAngle = 72;
			m4_ifelse(_contactNC_flipped, 1, `contactAngle = 360 - contactAngle');
		} else {
			topAngle = 270;
			contactAngle = 198;
			m4_ifelse(_contactNC_flipped, 1, `contactAngle = 180 - contactAngle');
		}
		line from AO to AM then to polarCoord(AM, elen*(5/32), topAngle);
		line from BO to BM then to polarCoord(BM, elen*0.42, contactAngle);
		MidContact: polarCoord(BM, 2.51, contactAngle);

		componentAddContactModifiers(_contactNC_type, true)
		componentAddContactOperators(_contactNC_operation, true)

		# if terminal labels are defined, add positional labels as "T_" + name (e.g. ".T_13")
		m4_ifelse(_contactNC_fullStartLabel, `', `', `T_'_contactNC_fullStartLabel`: AO')
		m4_ifelse(_contactNC_fullEndLabel,   `', `', `T_'_contactNC_fullEndLabel`:   BO')

		popDir();
	] with .Start at _contactNC_pos;

	# display terminal labels
	componentDrawTerminalLabel(last [].AO, _contactNC_fullStartLabel);
	componentDrawTerminalLabel(last [].BO, _contactNC_fullEndLabel);

	componentDrawLabels(_contactNC_)

	move to last [].End
')


`
Change-over contact.

Usage: contactCO([comma-separated key-value parameters])
Params:
	pos:		Position to place ".Start" at. Defaults to "Here".
	flipped:	Non-flipped ("false") draws with common terminal down. Flipped ("true") has common
	                up. Defaults to "false".
	ref:		Component reference name. Must be a valid pic label (no spaces, starts with capital
			letter). Will prefix reference name with the current sheet number.
	val:		Component value
	description:	Additional text describing component purpose etc.
	part:		Part number. If this is supplied, it is added to the BOM.
	set:		Contact set number, used for automatic start/end terminal labels. Defaults to "1".
	cmLabel:	Common terminal label. Defaults to "1".
	noLabel:	Normally-open terminal label. Defaults to "4".
	ncLabel:	Normally-closed terminal label. Defaults to "2".
'
m4_define_blind(`contactCO', `
	componentParseKVArgs(`_contactCO_',
		(`pos', `Here',
		 `flipped', `false',
		 `ref', `',
		 `val', `',
		 `description', `',
		 `part', `',
		 `set', `1',
		 `cmLabel', `1',
		 `noLabel', `4',
		 `ncLabel', `2'), $@)
	componentHandleRef(_contactCO_)

	# assemble terminal labels
	m4_define(`_contactCO_fullCMLabel', _contactCO_set`'_contactCO_cmLabel)
	m4_define(`_contactCO_fullNOLabel', _contactCO_set`'_contactCO_noLabel)
	m4_define(`_contactCO_fullNCLabel', _contactCO_set`'_contactCO_ncLabel)

	[
		pushDir();

		Start: Here;
		move dirToDirection(peekDir()) elen;
		End: Here;

		dirToDirection(peekDir());

		contactNO(pos=Start, flipped=_contactCO_flipped, set=`', startLabel=_contactCO_fullNOLabel, endLabel=_contactCO_fullCMLabel);

		NO:         last [].AO;
		CM:         last [].BO;
		MidContact: last [].MidContact;

		m4_define(`_contactCO_flipped', m4_eval(m4_index(_contactCO_flipped, `true') != -1))
		m4_ifelse(dirIsVertical(peekDir()), 1, `
			NC: NO - (elen/2, 0);
			ncJoinAngle = 0;
			ncStartAngle = 270;
			m4_ifelse(_contactCO_flipped, 1, `ncStartAngle = 360 - ncStartAngle');
		', `
			NC: NO + (0, elen/2);
			ncJoinAngle = 270;
			ncStartAngle = 0;
			m4_ifelse(_contactCO_flipped, 1, `ncStartAngle = 180 - ncStartAngle');
		')
		NCCorner: polarCoord(NC, elen*3/8, ncStartAngle);
		NCJoin: polarCoord(NCCorner, elen*15/32, ncJoinAngle);

		line from NC to NCCorner to NCJoin;

		# if terminal labels are defined, add positional labels as "T_" + name (e.g. ".T_13") (already present for NO contact)
		m4_ifelse(_contactCO_fullNCLabel, `', `', `T_'_contactCO_fullNCLabel`: NC')

		popDir();
	] with .Start at _contactCO_pos;

	# display terminal labels (these will already be drawn for NO contact)
	componentDrawTerminalLabel(last [].NC, _contactCO_fullNCLabel);

	componentDrawLabels(_contactCO_)

	move to last [].End;
')


`
Multi-contact group. Useful for contactors, relays etc.

Usage contactGroup([comma-separated key-value parameters])
Params:
	pos:		Position to place first contact ".Start" at. Defaults to "Here".
	flipped:	Whether contacts are flipped. Either "true" or "false". Defaults to "false".
	ref:		Component reference name. Must be a valid pic label (no spaces, starts with capital
			letter). Will prefix reference name with the current sheet number.
	val:		Component value
	description:	Additional text describing component purpose etc.
	part:		Part number. If this is supplied, it is added to the BOM.
	type:		See contactNO, contactNC.
	operation:	See contactNO, contactNC.
	contacts:	Description of what contacts, in the syntax "NO(startLabel, endLabel) NC(startLabel, endLabel)...".
			If startLabel or endLabel are omitted (e.g. "NO" or "NO()"), they will be autonumbered using the default
			labels and by incrementing the set number. If contact is in lowercase (e.g. "no" or "nc"), then the
			contact "type" will not be applied.
	linked:		Whether to draw dashed linking line on the contacts. Defaults to "true".
	preDraw:	Any drawing commands to include before drawing the contacts
	postDraw:	Any drawing commands to include after drawing the contacts
'
m4_define_blind(`contactGroup', `
	componentParseKVArgs(`_contactGroup_',
		(`pos', `Here',
		 `flipped', `false',
		 `ref', `',
		 `val', `',
		 `description', `',
		 `part', `',
		 `type', `',
		 `operation', `',
		 `contacts', `',
		 `linked', `true',
		 `preDraw', `',
		 `postDraw', `'), $@)
	componentHandleRef(_contactGroup_)
	[
		pushDir();
		dirToDirection(peekDir())

		_contactGroup_preDraw

		m4_define(`_contactGroup_set', 1)
		m4_define(`_contactGroup_contactNum', 0)
		_contactGroupParseContacts(_contactGroup_contacts)

		FirstContactStart:      _contactGroup_contactNum`'th last [].Start;
		FirstContactMidContact: _contactGroup_contactNum`'th last [].MidContact;
		FirstContactEnd:        _contactGroup_contactNum`'th last [].End;
		m4_ifelse(_contactGroup_linked, `true',
			`line dashed elen/18 from FirstContactMidContact to last [].MidContact');

		_contactGroup_postDraw

		popDir();
	] with .FirstContactStart at _contactGroup_pos;

	componentDrawLabels(_contactGroup_)

	move to last [].FirstContactEnd;
')
m4_define_blind(`_contactGroupParseContacts', `
	m4_pushdef(`_regexp', `\(NO\|NC\|no\|nc\)\( *(\w* *, *\w* *)\)?')

	m4_pushdef(`_index', m4_regexp($1, _regexp))
	m4_ifelse(_index, -1, `', `
		m4_pushdef(`length', m4_regexp($1, _regexp, `m4_len(\&)'))

		m4_regexp($1, _regexp, `m4_pushdef(`_type', `\1') m4_pushdef(`_args', `\2')')

		m4_regexp(_args, `( *\(\w*\) *, *\(\w*\) *)', `m4_pushdef(`_firstArg', `\1') m4_pushdef(`_secondArg', `\2')')

		m4_ifelse(_args, `', `
			m4_pushdef(`_set', _contactGroup_set)
			m4_define(`_contactGroup_set', m4_eval(_contactGroup_set + 1))
			m4_pushdef(`_labelParams', `')
		', `
			m4_pushdef(`_set', `')
			m4_pushdef(`_labelParams', `startLabel=_firstArg, endLabel=_secondArg')
		')

		m4_pushdef(`_operation', m4_ifelse(_contactGroup_contactNum, 0, _contactGroup_operation, `'))
		m4_define(`_contactGroup_contactNum', m4_eval(_contactGroup_contactNum + 1))

		m4_pushdef(`_contactType', _contactGroup_type)
		m4_ifelse(_type, `no', `
			m4_define(_type, NO)
			m4_define(_contactType, `')
		')
		m4_ifelse(_type, `nc', `
			m4_define(_type, NC)
			m4_define(_contactType, `')
		')

		m4_ifelse(_type, `NO', `contactNO', _type, `NC', `contactNC')(
			set=_set,
			_labelParams,
			type=_contactType,
			operation=_operation,
			flipped=_contactGroup_flipped,
		)

		# redefine terminal labels if they exist
		m4_ifelse(m4_indir(_contact`'_type`'_fullStartLabel), `', `',
			`T_'m4_indir(_contact`'_type`'_fullStartLabel)`: last [].T_'m4_indir(_contact`'_type`'_fullStartLabel))
		m4_ifelse(m4_indir(_contact`'_type`'_fullEndLabel), `', `',
			`T_'m4_indir(_contact`'_type`'_fullEndLabel)`: last [].T_'m4_indir(_contact`'_type`'_fullEndLabel))

		move to last [].Start;
		m4_ifelse(dirIsVertical(peekDir()), 1, `move `right' elen/2', `move `down' elen/2');

		m4_popdef(`_contactType')
		m4_popdef(`_operation')
		m4_popdef(`_labelParams')
		m4_popdef(`_set')
		m4_popdef(`_secondArg')
		m4_popdef(`_firstArg')
		m4_popdef(`_type')
		m4_popdef(`_args')

		_contactGroupParseContacts(m4_substr($1, m4_eval(_index + length)))
	')
	m4_popdef(`_index')
	m4_popdef(`_regexp')
')

m4_divert(0)

# vim: filetype=pic
