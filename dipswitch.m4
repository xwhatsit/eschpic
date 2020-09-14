`
Dip switch. Not a component, just a nice picture showing switch positions.

Usage: dipSwitch([comma-separated key-value parameters])
Params:
	pos:		Position to place .Start (top left) at. Defaults to "Here".
	onLabel:	On position label. Defaults to "On".
	offLabel:	Off position label. Defaults to "Off".
	labels:		Optional switch label parameter, in format "(1, 2, 3, 4)".
			If not specified, the labels are autonumbered from 1.
	switches:	Switch positions in format "(1, 0, 1, 0)".
	switchWidth:	Width of a switch element. Defaults to elen/4.
	switchHeight:	Height of a switch element. Defaults to elen/2.
'
m4_define_blind(`dipSwitch', `
	componentParseKVArgs(`_dipSwitch_',
		(`pos', `Here',
		 `onLabel', `On',
		 `offLabel', `Off',
		 `labels', `',
		 `switches', `',
		 `switchWidth', `elen/4',
		 `switchHeight', `elen/2'), $@)

	m4_define(`_dipSwitch_count', m4_nargs(m4_extractargs(_dipSwitch_switches)))
	m4_ifelse(_dipSwitch_labels, `', `m4_define(`_dipSwitch_labels', `( m4_forloop(i, 1, _dipSwitch_count, `i, '))')')
	


	[
		pushDir();
		Start: Here;

		leftPadding = max(textModuleTerminalLabelLength(_dipSwitch_onLabel ), \
			textModuleTerminalLabelLength(_dipSwitch_offLabel )) + linethick;

		Outline: box \
			wid (leftPadding + _dipSwitch_count * _dipSwitch_switchWidth + linethick) \
			ht (_dipSwitch_switchHeight + elen/4 + linethick*2) with .nw \
			at Start;

		NextStart: Start + (leftPadding + _dipSwitch_switchWidth / 2, -linethick);

		"textTerminalLabel(_dipSwitch_onLabel)" rjust at NextStart - (_dipSwitch_switchWidth / 2, textModuleTerminalLabelHeight()/2);
		"textTerminalLabel(_dipSwitch_offLabel)" rjust at \
			NextStart - (_dipSwitch_switchWidth / 2, _dipSwitch_switchHeight);

		m4_forloop(`i', 1, _dipSwitch_count, `
			   box wid (_dipSwitch_switchWidth - linethick) ht _dipSwitch_switchHeight with .n at NextStart;
			   "textModuleTerminalLabel(m4_argn(i, m4_extractargs(_dipSwitch_labels)))" below at last box.s;

			   box fill 0 wid (_dipSwitch_switchWidth - (3*linethick)) ht _dipSwitch_switchHeight/3 with \
			   	m4_ifelse(m4_argn(i, m4_extractargs(_dipSwitch_switches)), `1',
					`.n at last box.n - (0, linethick)', ` .s at last box.s + (0, linethick)');

			   move to NextStart then right _dipSwitch_switchWidth;
			   NextStart: Here;
		')
		popDir();
	] with .Start at _dipSwitch_pos;
')



`
Rotary switch. Not a component, just a nice picture showing switch position.

Usage: rotarySwitch([comma-separated key-value parameters])
Params:
	pos:		Position to place starting centre at. Defaults to "Here".
	labels:		Optional switch label parameter, in format "(1, 2, 3, 4)".
			If not specified, the labels are autonumbered from 0 in hex.
	count:		Position count if labels parameter is not specified.
	setting:	Switch position (the corresponding label).
	startAngle:	Angle in degrees to place the first label at. Defaults to 0 (3 o'clock).
	diameter:	Switch diameter; defaults to elen.
'
m4_define_blind(`rotarySwitch', `
	componentParseKVArgs(`_rotarySwitch_',
		(`pos', `Here',
		 `labels', `',
		 `setting', `',
		 `startAngle', `0',
		 `diameter', `elen'), $@)

	m4_ifelse(_rotarySwitch_labels, `', `
		m4_define(`_rotarySwitch_labels', `( m4_forloop(i, 0, _rotarySwitch_count, `m4_format(`%X', i), '))')
	', `
		m4_define(`_rotarySwitch_count', m4_nargs(m4_extractargs(_rotarySwitch_switches)))
	')

	[
		pushDir();
		Start: Here;

		Outer: circle diameter _rotarySwitch_diameter with .c at Start;

		m4_forloop(`n', 1, _rotarySwitch_count, `
			angle = -(360/_rotarySwitch_count * m4_eval(n - 1)) - _rotarySwitch_startAngle;
			"textModuleTerminalLabel(m4_argn(n, m4_extractargs(_rotarySwitch_labels)))" at \
			   	polarCoord(Start, _rotarySwitch_diameter/2 - textModuleTerminalLabelHeight()*2/3, angle);

			m4_ifelse(m4_argn(n, m4_extractargs(_rotarySwitch_labels)), _rotarySwitch_setting, `
				arrowHalfLen = (_rotarySwitch_diameter - textModuleTerminalLabelHeight() * 8/3 - linethick)/2;
				line thickness linethick*3 from polarCoord(Start, arrowHalfLen, angle - 180) \
					to polarCoord(Start, arrowHalfLen*2/3, angle);
				Pointer: polarCoord(Start, arrowHalfLen, angle);
				PL: polarCoord(Pointer, arrowHalfLen, angle + 150);
				PR: polarCoord(Pointer, arrowHalfLen, angle - 150);
				line filled 0 from 1/2 between PL and PR to PR to Pointer to PL to 1/2 between PL and PR;
			')
		')

		Inner: circle diameter _rotarySwitch_diameter - textModuleTerminalLabelHeight()*8/3 with .c at Start;

		popDir();
	] with .Start at _rotarySwitch_pos;
')
