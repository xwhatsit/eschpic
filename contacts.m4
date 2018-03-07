`
Helper macro for drawing contact actuators. Uses current direction.

Usage: componentDrawActuator(type, pos, actuationAngle, reversed)
Params:
	type:	        Head type. One of "manual", "selector" (also "turn" and "twist"), "push",
			"pull", "mushroom" (also "estop"), "foot", "proximity" (also "prox") or
			"key".
	pos:	        Location to draw it at.
	actuationAngle:	The direction of the actuator, i.e. 180 if horizontal, 90 if vertical.
	reversed:	Set to 1 if normal, -1 if flipped.
'
m4_define_blind(`componentDrawActuator', `
	m4_ifelse($1, `manual', `
		line from polarCoord($2, 1.2, $3 - 90) to polarCoord($2, 1.2, $3 + 90);
	', $1, `selector', `
		ActuatorSelectorT: polarCoord($2, 1.2, $3 - ($4*90));
		ActuatorSelectorB: polarCoord($2, 1.2, $3 + ($4*90));
		line from polarCoord(ActuatorSelectorB, 0.8, $3) to ActuatorSelectorB \
			then to ActuatorSelectorT \
			then to polarCoord(ActuatorSelectorT, 0.8, $3 - 180);
	', $1, `push', `
		ActuatorPushT: polarCoord($2, 1.2, $3 - 90);
		ActuatorPushB: polarCoord($2, 1.2, $3 + 90);
		line from polarCoord(ActuatorPushB, 0.8, $3 - 180) to ActuatorPushB \
			then to ActuatorPushT \
			then to polarCoord(ActuatorPushT, 0.8, $3 - 180);
	', $1, `pull', `
		ActuatorPullT: polarCoord($2, 1.2, $3 - 90);
		ActuatorPullB: polarCoord($2, 1.2, $3 + 90);
		line from polarCoord(ActuatorPullB, 0.8, $3) to ActuatorPullB \
			then to ActuatorPullT \
			then to polarCoord(ActuatorPullT, 0.8, $3);
	', $1, `mushroom', `
		ActuatorEStopT: polarCoord($2, 1.2, $3 - 90);
		ActuatorEStopB: polarCoord($2, 1.2, $3 + 90);
		arc cw from ActuatorEStopB to ActuatorEStopT with .c at $2;
		line from ActuatorEStopB to \
			polarCoord(ActuatorEStopB, pointsToMillimetres(linethick/2), $3 - 180);
		line from ActuatorEStopT to \
			polarCoord(ActuatorEStopT, pointsToMillimetres(linethick/2), $3 - 180);
		line from ActuatorEStopB to ActuatorEStopT;
	', $1, `foot', `
		ActuatorFootT: polarCoord($2,   1.33, $3 - ($4*117));
		ActuatorFootB: polarCoord($2,   1.33, $3 + ($4*63));
		ActuatorFootL: polarCoord(ActuatorFootB, 0.89, $3 - ($4*27));
		line from ActuatorFootL to ActuatorFootB to ActuatorFootT;
	', $1, `proximity', `
		ActuatorProxL: polarCoord($2, 2.4, $3);
		ActuatorProxC: 1/2 between $2 and ActuatorProxL;
		ActuatorProxT: polarCoord(ActuatorProxC, 1.2, $3 - ($4*90));
		ActuatorProxB: polarCoord(ActuatorProxC, 1.2, $3 + ($4*90));
		line from $2 to ActuatorProxT to ActuatorProxL to ActuatorProxB to $2;
		line from ActuatorProxB+(-0.4, ($4*0.4)) to ActuatorProxT+(-($4*0.4), -0.4);
		line from ActuatorProxB+(($4*0.4), 0.4) to ActuatorProxT+(0.4, -($4*0.4));
	', $1, `key', `
		ActuatorKeyTT: polarCoord($2,            1.33, $3 - ($4*76));
		ActuatorKeyTC: polarCoord(ActuatorKeyTT, 0.50, $3 + ($4*90));
		ActuatorKeyBM: polarCoord(ActuatorKeyTT, 2.48, $3 + ($4*90));
		ActuatorKeyBL: polarCoord(ActuatorKeyBM, 0.50, $3);
		ActuatorKeyBR: polarCoord(ActuatorKeyBM, 0.50, $3 - 180);
		circle rad 0.5 at ActuatorKeyTC;
		line from polarCoord(ActuatorKeyTT, 1.0, $3 + ($4*76)) \
			to polarCoord(ActuatorKeyBL, 0.5, $3 - ($4*90)) \
			to ActuatorKeyBL \
			to ActuatorKeyBR \
			to polarCoord(ActuatorKeyBR, 0.5, $3 - ($4*90)) \
			to polarCoord(ActuatorKeyTT, 1.0, $3 - ($4*256));
	', $1, `turn',  `componentDrawActuator(selector, $2, $3, $4)
	', $1, `twist', `componentDrawActuator(selector, $2, $3, $4)
	', $1, `estop', `componentDrawActuator(mushroom, $2, $3, $4)
	', $1, `prox',  `componentDrawActuator(proximity, $2, $3, $4)
	')
')


`
Helper macro for drawing actuator actions. Uses current direction. Defines at the very least
two positions, ActuatorActL and ActuatorActR, which are the connection points on either side.

Usage: componentDrawActuatorAction(type, pos, actuationAngle, reversed)
Params:
	type:           Action type. One of "maintained", "maintained-reset", "off",
	                "spring-return-l", "spring-return-r".
	pos:            Location to draw it at.
	actuationAngle: The direction of the actuator, i.e. 180 if horizontal, 90 if vertical.
	reversed:       Set to 1 if normal, -1 if flipped.
'
m4_define_blind(`componentDrawActuatorAction', `
	m4_ifelse($1, `maintained', `
		ActuatorActB: polarCoord($2, 1.2, actuatorAngle + actuatorRev*90);
		ActuatorActL: polarCoord($2, 0.4, actuatorAngle);
		ActuatorActR: polarCoord($2, 0.4, actuatorAngle - 180);
		line from polarCoord(ActuatorActL, pointsToMillimetres(linethick/2), actuatorAngle) \
			to ActuatorActL to ActuatorActB to ActuatorActR \
			to polarCoord(ActuatorActR, pointsToMillimetres(linethick/2), actuatorAngle - 180);
	', $1, `maintained-reset', `
		ActuatorActL: polarCoord($2,           1.20, actuatorAngle);
		ActuatorActR: polarCoord($2,           0.46, actuatorAngle - 180);
		ActuatorActT: polarCoord(ActuatorActL, 0.77, actuatorAngle - 90*actuatorRev);
		line from ActuatorActL to ActuatorActT to ActuatorActR;
	', $1, `off', `
		ActuatorActL: $2;
		ActuatorActR: $2;
		line dashed elen/25 \
			from polarCoord($2, pointsToMillimetres(linethick/2), actuatorAngle + 90*actuatorRev) \
			to polarCoord($2, 1.6, actuatorAngle - 90*actuatorRev);
	', $1, `spring-return-l', `
		ActuatorActL: polarCoord($2,           0.4, actuatorAngle);
		ActuatorActR: polarCoord($2,           1.2, actuatorAngle - 180);
		ActuatorActT: polarCoord(ActuatorActL, 0.8, actuatorAngle - 90*actuatorRev);
		ActuatorActB: polarCoord(ActuatorActL, 0.8, actuatorAngle + 90*actuatorRev);
		line from ActuatorActR to ActuatorActB to ActuatorActL to ActuatorActT to ActuatorActR;
	', $1, `spring-return-r', `
		ActuatorActL: polarCoord($2,           1.2, actuatorAngle);
		ActuatorActR: polarCoord($2,           0.4, actuatorAngle - 180);
		ActuatorActT: polarCoord(ActuatorActR, 0.8, actuatorAngle - 90*actuatorRev);
		ActuatorActB: polarCoord(ActuatorActR, 0.8, actuatorAngle + 90*actuatorRev);
		line from ActuatorActR to ActuatorActB to ActuatorActL to ActuatorActT to ActuatorActR;
	')
')


`
Helper macro for drawing contact actuators (e.g. see "actuation" parameter in contactNO). Should be called
within contact macro block itself (i.e. with "[", "]" brackets). Tries to combine multiple things in an
intelligent way.

Usage: componentAddContactActuators(actuatorString, [isNCContact])
Params:
	actuatorString: Space-separated string of actuator modifiers. Can be composed of following:
			heads:  See "type" parameter in componentDrawActuator
			action: See "type" parameter in componentDrawActuatorAction
			reset:  any head listed above followed by "-reset" (e.g. "pull-reset")
'
m4_define_blind(`componentAddContactActuators', `
	m4_pushdef(`actuatorString', ` '$1` ')

	m4_ifelse(dirIsVertical(peekDir()), 1, `
		actuatorAngle = 180;
		actuatorRev = 1;
	', `
		actuatorAngle = 90;
		actuatorRev = -1;
	');
	ActuatorPos: polarCoord(MidContact, 4, actuatorAngle);

	# draw reset action
	m4_pushdef(`actuatorReset', m4_regexp(actuatorString, `[ \t]\([A-Za-z]+\)-reset[ \t]', `\1'))
	m4_ifelse(actuatorReset, `', `', `
		ActuatorResetB: polarCoord(MidContact,     elen/8, actuatorAngle);
		ActuatorResetT: polarCoord(ActuatorResetB, elen/4, actuatorAngle - actuatorRev*90);
		ActuatorResetL: polarCoord(ActuatorResetT, 2.4,    actuatorAngle);
		line dashed elen/18 from ActuatorResetB to ActuatorResetT to ActuatorResetL;
		componentDrawActuator(actuatorReset, ActuatorResetL, actuatorAngle, actuatorRev);
	')

	# determine actuator head, modify ActuatorPos if necessary
	m4_pushdef(`actuatorHead', `')
	m4_ifelse(m4_eval(m4_index(actuatorString, ` manual ') != -1), 1, `
		m4_define(`actuatorHead', manual)
	', m4_eval(m4_index(actuatorString, ` selector ') != -1 ||
	           m4_index(actuatorString, ` turn ')     != -1 ||
		   m4_index(actuatorString, ` twist ')    != -1), 1, `
		m4_define(`actuatorHead', selector)
	', m4_eval(m4_index(actuatorString, ` push ') != -1), 1, `
		m4_define(`actuatorHead', push)
	', m4_eval(m4_index(actuatorString, ` pull ') != -1), 1, `
		ActuatorPos: polarCoord(ActuatorPos, 0.825, actuatorAngle - 180);
		m4_define(`actuatorHead', pull)
	', m4_eval(m4_index(actuatorString, ` estop ') != -1 ||
	                  m4_index(actuatorString, ` mushroom ') != -1), 1, `
		m4_define(`actuatorHead', mushroom)
	', m4_eval(m4_index(actuatorString, ` foot ') != -1), 1, `
		ActuatorPos: polarCoord(ActuatorPos, 0.63, actuatorAngle - 180);
		m4_define(`actuatorHead', foot)
	', m4_eval(m4_index(actuatorString, ` proximity ') != -1 ||
	           m4_index(actuatorString, ` prox ')      != -1), 1, `
		ActuatorPos: polarCoord(ActuatorPos, 1.2, actuatorAngle - 180);
		m4_define(`actuatorHead', proximity)
	', m4_eval(m4_index(actuatorString, ` key ') != -1), 1, `
		m4_define(`actuatorHead', key)
	')

	# draw action
	m4_ifelse(m4_index(actuatorString, ` 3-pos '), -1, `
		m4_ifelse(m4_eval(m4_index(actuatorString, ` maintained ') != -1), 1, `
			ActuatorPos: polarCoord(ActuatorPos, 1.5, actuatorAngle);
			ActuatorActM: 1/2 between MidContact and ActuatorPos;

			# drawn differently if we have a reset action
			m4_ifelse(actuatorReset, `', `
				componentDrawActuatorAction(maintained, ActuatorActM, actuatorAngle, actuatorRev);
				line dashed elen/18 from ActuatorPos to ActuatorActL;
				line dashed elen/18 from MidContact to ActuatorActR;
			', `
				componentDrawActuatorAction(maintained-reset, ActuatorActM, actuatorAngle, actuatorRev);
				line dashed elen/18 from ActuatorPos to MidContact;
			')
		', `
			m4_ifelse(actuatorHead, `', `', `line dashed elen/18 from ActuatorPos to MidContact')
		')
	', `
		ActuatorPos: polarCoord(ActuatorPos, 4.73, actuatorAngle);
		actuatorPosActSpacing = (8.73 - 1.6) / 3;
		actuatorPosEndOffset = (8.73 - (2 * actuatorPosActSpacing)) / 2;

		ActuatorActM: polarCoord(MidContact, actuatorPosEndOffset, actuatorAngle);
		m4_ifelse(m4_eval(m4_index(actuatorString, ` spring-return ') != -1 ||
		                  m4_index(actuatorString, ` spring-return-r ') != -1), 1, `
			componentDrawActuatorAction(spring-return-r, ActuatorActM, actuatorAngle, actuatorRev)
		', `
			componentDrawActuatorAction(maintained, ActuatorActM, actuatorAngle, actuatorRev)
		')
		line dashed elen/25 from MidContact to ActuatorActR;
		PrevActuatorActL: ActuatorActL;

		ActuatorActM: polarCoord(ActuatorActM, actuatorPosActSpacing, actuatorAngle);
		m4_ifelse(m4_eval(m4_index(actuatorString, ` mid-off ') != -1), 1, `
			componentDrawActuatorAction(off, ActuatorActM, actuatorAngle, actuatorRev);
		', `
			componentDrawActuatorAction(maintained, ActuatorActM, actuatorAngle, actuatorRev);
		')
		line dashed elen/25 from PrevActuatorActL to ActuatorActR;
		PrevActuatorActL: ActuatorActL;

		ActuatorActM: polarCoord(ActuatorActM, actuatorPosActSpacing, actuatorAngle);
		m4_ifelse(m4_eval(m4_index(actuatorString, ` spring-return ') != -1 ||
		                  m4_index(actuatorString, ` spring-return-l ') != -1), 1, `
			componentDrawActuatorAction(spring-return-l, ActuatorActM, actuatorAngle, actuatorRev);
		', `
			componentDrawActuatorAction(maintained, ActuatorActM, actuatorAngle, actuatorRev);
		')
		line dashed elen/25 from PrevActuatorActL to ActuatorActR;
		line dashed elen/25 from ActuatorPos to ActuatorActL;
	')

	# finally draw button head
	componentDrawActuator(actuatorHead, ActuatorPos, actuatorAngle, actuatorRev)

	m4_popdef(`actuatorReset')
	m4_popdef(`actuatorHead')
	m4_popdef(`actuatorString')
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
	actuation:	Means of contact actuation. Can specify more than one. See "actuationString" parameter
	                in componentAddContactActuators for valid values.
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
		 `actuation', `'), $@)
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
		componentAddContactActuators(_contactNO_actuation)

		# if terminal labels are defined, add positional labels as "T" + name (e.g. ".T13")
		m4_ifelse(_contactNO_fullStartLabel, `', `', `T'm4_patsubst(_contactNO_fullStartLabel, `[^A-Za-z0-9]', `_')`: AO')
		m4_ifelse(_contactNO_fullEndLabel,   `', `', `T'm4_patsubst(_contactNO_fullEndLabel,   `[^A-Za-z0-9]', `_')`: BO')

		popDir();
	] with .Start at _contactNO_pos;

	# display terminal labels
	componentDrawTerminalLabel(last [].AO, _contactNO_fullStartLabel);
	componentDrawTerminalLabel(last [].BO, _contactNO_fullEndLabel);

	componentDrawLabels(_contactNO_)
	componentWriteBOM(_contactNO_)

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
	actuation:	Means of contact actuation. Can specify more than one. See "actuationString" parameter
	                in componentAddContactActuators for valid values.
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
		 `actuation', `'), $@)
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
		componentAddContactActuators(_contactNC_actuation, true)

		# if terminal labels are defined, add positional labels as "T" + name (e.g. ".T13")
		m4_ifelse(_contactNC_fullStartLabel, `', `', `T'm4_patsubst(_contactNC_fullStartLabel, `[^A-Za-z0-9]', `_')`: AO')
		m4_ifelse(_contactNC_fullEndLabel,   `', `', `T'm4_patsubst(_contactNC_fullEndLabel,   `[^A-Za-z0-9]', `_')`: BO')

		popDir();
	] with .Start at _contactNC_pos;

	# display terminal labels
	componentDrawTerminalLabel(last [].AO, _contactNC_fullStartLabel);
	componentDrawTerminalLabel(last [].BO, _contactNC_fullEndLabel);

	componentDrawLabels(_contactNC_)
	componentWriteBOM(_contactNC_)

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

		# if terminal labels are defined, add positional labels as "T" + name (e.g. ".T13") (already present for NO contact)
		m4_ifelse(_contactCO_fullNCLabel, `', `', `T'_contactCO_fullNCLabel`: NC')

		popDir();
	] with .Start at _contactCO_pos;

	# display terminal labels (these will already be drawn for NO contact)
	componentDrawTerminalLabel(last [].NC, _contactCO_fullNCLabel);

	componentDrawLabels(_contactCO_)
	componentWriteBOM(_contactCO_)

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
	actuation:	See contactNO, contactNC.
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
		 `actuation', `',
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
	componentWriteBOM(_contactGroup_)

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

		m4_pushdef(`_actuation', m4_ifelse(_contactGroup_contactNum, 0, _contactGroup_actuation, `'))
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
			actuation=_actuation,
			flipped=_contactGroup_flipped,
		)

		# redefine terminal labels if they exist
		m4_ifelse(m4_indir(_contact`'_type`'_fullStartLabel), `', `',
			`T'm4_indir(_contact`'_type`'_fullStartLabel)`: last [].T'm4_indir(_contact`'_type`'_fullStartLabel))
		m4_ifelse(m4_indir(_contact`'_type`'_fullEndLabel), `', `',
			`T'm4_indir(_contact`'_type`'_fullEndLabel)`: last [].T'm4_indir(_contact`'_type`'_fullEndLabel))

		move to last [].Start;
		m4_ifelse(dirIsVertical(peekDir()), 1, `move `right' elen/2', `move `down' elen/2');

		m4_popdef(`_contactType')
		m4_popdef(`_actuation')
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


`
Thermal operating mechanism.

Usage: thermalOperator([comma-separated key-value parameters])
Params:
	pos:		Position to place ".Start" at. Defaults to "Here".
	ref:		Component reference name. Must be a valid pic label (no spaces, starts with capital
			letter). Will prefix reference name with the current sheet number.
	val:		Component value
	description:	Additional text describing component purpose etc.
	part:		Part number. If this is supplied, it is added to the BOM.
'
m4_define_blind(`thermalOperator', `
	componentParseKVArgs(`_thermalOperator_',
		(`pos', `Here',
		 `flipped', `false',
		 `ref', `',
		 `val', `',
		 `description', `',
		 `part', `'), $@)
	componentHandleRef(_thermalOperator_)

	[
		pushDir();

		Start: Here;
		line dirToDirection(peekDir()) elen/16 \
			then dirToDirection(dirCCW(peekDir())) elen/8 \
			then dirToDirection(peekDir()) elen/8 \
			then dirToDirection(dirCW(peekDir())) elen/8 \
			then dirToDirection(peekDir()) elen/16;
		End: Here;

		box wid elen/2 ht elen/4 with .n at Start;

	] with .Start at _thermalOperator_pos;

	componentDrawLabels(_thermalOperator_)
	componentWriteBOM(_thermalOperator_)
	move to last [].End;
')


`
Over-current operating mechanism.

Usage: overCurrentOperator([comma-separated key-value parameters])
Params:
	pos:		Position to place ".Start" at. Defaults to "Here".
	ref:		Component reference name. Must be a valid pic label (no spaces, starts with capital
			letter). Will prefix reference name with the current sheet number.
	val:		Component value
	description:	Additional text describing component purpose etc.
	part:		Part number. If this is supplied, it is added to the BOM.
'
m4_define_blind(`overCurrentOperator', `
	componentParseKVArgs(`_overCurrentOperator_',
		(`pos', `Here',
		 `flipped', `false',
		 `ref', `',
		 `val', `',
		 `description', `',
		 `part', `'), $@)
	componentHandleRef(_overCurrentOperator_)

	[
		pushDir();

		Start: Here;
		move dirToDirection(peekDir()) elen/4;
		End: Here;

		"{\scriptsize\strut{}$I>$}" at 1/2 between Start and End;

		box wid elen/2 ht elen/4 with .n at Start;

	] with .Start at _overCurrentOperator_pos;

	componentDrawLabels(_overCurrentOperator_)
	componentWriteBOM(_overCurrentOperator_)
	move to last [].End;
')
