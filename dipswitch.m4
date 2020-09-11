`
Dip switch. Not a component, just a nice picture showing switch positions.

Usage: dipSwitch([comma-separated key-value parameters])
Params:
	pos:		Position to place starting terminal at. Defaults to "Here".
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

			   box fill 0 wid (_dipSwitch_switchWidth - (3*linethick)) ht _dipSwitch_switchHeight*1/3 with \
			   	m4_ifelse(m4_argn(i, m4_extractargs(_dipSwitch_switches)), `1',
					`.n at last box.n - (0, linethick)', ` .s at last box.s + (0, linethick)');

			   move to NextStart then right _dipSwitch_switchWidth;
			   NextStart: Here;
		')
		popDir();
	] with .Start at _dipSwitch_pos;
')
