`
General "module" symbol, with custom terminals and labels. Will draw either vertically or horizontally
depending on current direction.

Location references are defined in syntax .Group.Terminal. If the group or terminal name starts with a capital letter (i.e. is valid pic reference), then
the name is used directly. (e.g. Module.X1.L1). Otherwise, it is prefixed with G for groups or T for terminals (e.g. group 1A becomes Module.G1A, terminal 13
becomes Module.X1.T13 etc.). Invalid pic reference label characters are changed to underscores (e.g. group "X1 - Power Supply" becomes "X1___Power_Supply").
Terminal locations are also defined as .Group.N1 etc., numbering up to the terminal count.

Usage: module([key-value separated parameters])
Params:
	pos:		Position to place first terminal at. Defaults to "Here".
	ref:		Component reference name. Must be a valid pic label (no spaces, starts with capital
			letter). Will prefix reference name with the current sheet number.
	val:		Component value
	description:	Additional text describing component purpose etc.
	part:		Part number. If this is supplied, it is added to the BOM.
	terminals:	Description of the module's terminals, in the syntax:
			"([Groupname](T1(desc), T2, T3, T4), [[Groupname](T1, T2, T3, T4)...) | ([Groupname](T1, T2, T3, T4)])".
			The "|" symbol splits the module into top and bottom (or left and right). Spacer elements can either be blank terminals, or can use the syntax
			"_N_", where N is an integer specifying how many terminals to skip. Group name is optional.
			Example: "( X1(L1(Phase 1), L2(Phase 2), L3(Phase 3), PE(Protective Earth)) X13(DIO0, DIO1, _3_, DIO02, DCOM, VO24, DGND) ) | (X2(U, V, W, PE))".
	height:		Height of module (if in vertical orientation). Defaults to "elen * 2" if currently vertical,
			otherwise is automatically calculated.
	width:		Width of module (if in horizontal orientation). Defaults to "elen * 2" if currently horizontal,
			otherwise is automatically calculated.
	padding:	Padding of box along terminal axis. Defaults to elen/2.
	terminalPitch:	Spacing of terminals. Defaults to elen/2.
	terminalDepth:	Depth of terminal boxes. Defaults to elen/4.
'
m4_define_blind(`module', `
	componentParseKVArgs(`_module_',
		(`pos', `Here',
		 `ref', `',
		 `val', `',
		 `description', `',
		 `part', `',
		 `terminals', `',
		 `height', `2 * elen',
		 `width', `2 * elen',
		 `padding', `elen/2',
		 `terminalPitch', `elen/2',
		 `terminalDepth', `elen/4'), $@)
	componentHandleRef(_module_)

	[
		pushDir();
		dirToDirection(peekDir());

		m4_define(`_module_topterms', m4_trim(m4_substr(_module_terminals, 0, m4_index(_module_terminals, `|'))))
		m4_define(`_module_botterms', m4_trim(m4_substr(_module_terminals, m4_eval(m4_index(_module_terminals, `|') + 1))))

		m4_define(`_module_terminalDir', m4_ifelse(dirIsVertical(peekDir()), 1, dirRight, dirDown));

		Start: Here;
		move dirToDirection(dirRev(_module_terminalDir)) _module_padding then dirToDirection(peekDir()) (_module_terminalDepth)/2;
		BoxStartT: Here;

		move to Start;
		m4_define(`_module_numTopGroups', m4_nargs(m4_extractargs(_module_topterms)))
		m4_forloop(i, 1, _module_numTopGroups, `
			_moduleParseTerminals(m4_argn(i, m4_extractargs(_module_topterms)), true)
			GroupEnd: Here;
			move to _module_groupRef.LastTerminalBox.c then dirToDirection(_module_terminalDir) (_module_terminalPitch)/2;
			m4_ifelse(i, _module_numTopGroups, `', `
				  line dirToDirection(_module_terminalDir) _module_terminalPitch;
				  move to GroupEnd then dirToDirection(_module_terminalDir) _module_terminalPitch;
			')
		')
		BoxEndLastTermT: Here;
		move dirToDirection(_module_terminalDir) (_module_padding)/2;
		BoxEndT: Here;

		move to Start then dirToDirection(peekDir()) _module_height;
		End: Here;
		move dirToDirection(dirRev(_module_terminalDir)) _module_padding then dirToDirection(dirRev(peekDir())) (_module_terminalDepth)/2;
		BoxStartB: Here;
		move to End;
		m4_define(`_module_numBotGroups', m4_nargs(m4_extractargs(_module_botterms)))
		m4_forloop(i, 1, _module_numBotGroups, `
			_moduleParseTerminals(m4_argn(i, m4_extractargs(_module_botterms)), false)
			GroupEnd: Here;
			move to _module_groupRef.LastTerminalBox.c then dirToDirection(_module_terminalDir) (_module_terminalPitch)/2;
			m4_ifelse(i, _module_numBotGroups, `', `
				  line dirToDirection(_module_terminalDir) _module_terminalPitch;
				  move to GroupEnd then dirToDirection(_module_terminalDir) _module_terminalPitch;
			')
		')
		BoxEndLastTermB: Here;
		move dirToDirection(_module_terminalDir) (_module_padding)/2;
		BoxEndB: Here;

		m4_ifelse(dirIsVertical(peekDir()), 1, `
			if BoxEndT.x > BoxEndB.x then {
				BoxEndB: (BoxEndT.x, BoxEndB.y);
			} else {
				BoxEndT: (BoxEndB.x, BoxEndT.y);
			}
		', `
			if BoxEndT.y > BoxEndB.y then {
				BoxEndB: (BoxEndB.x, BoxEndT.y);
			} else {
				BoxEndT: (BoxEndT.x, BoxEndB.y);
			}
		')

		move to Start then dirToDirection(peekDir()) (_module_terminalDepth)/2 then dirToDirection(dirRev(_module_terminalDir)) (_module_terminalPitch)/2;
		line to BoxStartT \
			then dirToDirection(peekDir()) _module_height - _module_terminalDepth \
			then dirToDirection(_module_terminalDir) (_module_padding)/2;
		line from BoxEndLastTermT to BoxEndT then to BoxEndB then to BoxEndLastTermB;

		popDir();
	] with .Start at _module_pos;

	componentDrawLabels(_module_, true)
	componentWriteBOM(_module_, true)
')
m4_define_blind(`_moduleParseTerminals', `
	m4_regexp($1, `^\([^()]*\)\(.*\)', `
		m4_define(`_module_groupName', \1)
		m4_define(`_module_groupTerms', \2)
	')

	m4_define(`_module_termDescTextAlignment', m4_dnl
		m4_ifelse(dirIsVertical(peekDir()), 1, m4_dnl
			m4_ifelse($2, true, `below', `above'), m4_dnl
			m4_ifelse($2, true, `ljust', `rjust')))

	m4_define(`_module_numGroupTerms', m4_nargs(m4_extractargs(_module_groupTerms)))

	m4_define(`_module_groupRef', m4_ifelse(_module_groupName, `', `LastGroup', m4_patsubst(_module_groupName, `[^A-Za-z0-9]', `_')))
	m4_ifelse(m4_regexp(_module_groupRef, `^[A-Z]'), -1, `m4_define(`_module_groupRef', `G'_module_groupRef)')
	_module_groupRef: [
		Start: Here;

		# expand bounding box at start to make it symmetrical
		move dirToDirection(dirRev(_module_terminalDir)) (_module_terminalPitch);
		OuterStart: Here;
		move to Start;
		m4_forloop(j, 1, _module_numGroupTerms, `
			_moduleDrawTerm(m4_argn(j, m4_extractargs(_module_groupTerms)), $2, j)
		')
		End: Here;
	] with .Start at Here;

	# bounding box for group
	box invis wid _module_groupRef.wid ht _module_groupRef.ht with .c at _module_groupRef.c;

	move to last box m4_ifelse(dirIsVertical(peekDir()), 1, m4_dnl
				   m4_ifelse($2, true, `.s then down', `.n then up'), m4_dnl
				   m4_ifelse($2, true, `.e then right', `.w then left')) elen/8;
	m4_ifelse(_module_groupName, `', `', `
		ModuleGroupTextRef: Here;
		"textModuleTerminalLabel(_module_groupName)" at ModuleGroupTextRef;
		textWidth = textModuleTerminalLabelLength((_module_groupName));
		if textWidth < distanceBetweenPoints(_module_groupRef.OuterStart, _module_groupRef.End) - 2*(_module_terminalPitch)*5/8 then {
			move to ModuleGroupTextRef then dirToDirection(dirCW(peekDir())) textWidth/2;
			ModuleTextStart: Here;
			move to ModuleGroupTextRef then dirToDirection(dirCCW(peekDir())) textWidth/2;
			ModuleTextEnd: Here;

			groupLineLen = (last box m4_ifelse(dirIsVertical(peekDir()), 1, .wid, .ht) - \
				distanceBetweenPoints(ModuleTextStart, ModuleTextEnd)) / 2 - (_module_terminalPitch)*5/8;
			
			m4_define(`_module_groupLineFlickDir', m4_ifelse(dirIsVertical(peekDir()), 1, m4_dnl
				m4_ifelse($2, true, dirUp, dirDown), m4_ifelse($2, true, dirLeft, dirRight)))

			line from ModuleTextStart dirToDirection(dirRev(_module_terminalDir)) groupLineLen then \
				dirToDirection(_module_groupLineFlickDir) elen/16;
			line from ModuleTextEnd dirToDirection(_module_terminalDir) groupLineLen then \
				dirToDirection(_module_groupLineFlickDir) elen/16;
		}
	')

	move to _module_groupRef.End;
')
m4_define_blind(`_moduleDrawTerm', `
	m4_regexp($1, `\([^()]*\)\(.*\)', `
		m4_define(`_module_termText', \1)
		m4_define(`_module_termDesc', \2)
	')

	# handle spacers
	m4_define(`_module_spacerCount', 1)
	m4_regexp(m4_trim(_module_termText), `^_\([0-9]+\)_$', `m4_define(`_module_spacerCount', \1) m4_define(`_module_termText', `')')

	m4_define(`_module_termBoxDims', m4_dnl
		m4_ifelse(dirIsVertical(peekDir()), 1, m4_dnl
			wid _module_terminalPitch ht _module_terminalDepth, m4_dnl
			wid _module_terminalDepth ht _module_terminalPitch))
	m4_define(`_module_terminalBoxRef', m4_dnl
		m4_ifelse(dirIsVertical(peekDir()), 1, m4_ifelse($2, true, `.n', `.s'), m4_ifelse($2, true, `.w', `.e')))

	m4_ifelse(m4_eval(m4_len(_module_termText) == 0 && m4_len(_module_termDesc) == 0), 1, `
		box _module_termBoxDims invis with _module_terminalBoxRef at Here;
		move to last box.c then dirToDirection(dirRev(_module_terminalDir)) (_module_terminalPitch)/2;
		line dirToDirection(_module_terminalDir) (_module_terminalPitch)*_module_spacerCount;
	', `
		m4_ifelse(_module_termDesc, `', `', `m4_define(`_module_termDesc', m4_trim(m4_extractargs(_module_termDesc)))')

		box _module_termBoxDims with _module_terminalBoxRef at Here;
		"textModuleTerminalLabel(_module_termText)" at last box.c;
	')
	LastTerminalBox: last box;
	LastTerminal: last box`'_module_terminalBoxRef;
	m4_ifelse(_module_termDesc, `', `', `
		move dirToDirection(m4_ifelse($2, true, peekDir(), dirRev(peekDir()))) elen/8;
		LastTerminalInside: Here;
		m4_ifelse(dirIsVertical(peekDir()), 1, m4_dnl
			"textRotated(textModuleTerminalLabel(_module_termDesc))", m4_dnl
			"textModuleTerminalLabel(_module_termDesc)") _module_termDescTextAlignment at  LastTerminalInside;
		m4_define(`_module_termDescLen', textModuleTerminalLabelLength(_`'_module_termDesc))
		box invis m4_ifelse(dirIsVertical(peekDir()), 1, m4_dnl
			wid _module_terminalPitch ht _module_termDescLen, m4_dnl
			wid _module_termDescLen ht _module_terminalPitch) with _module_terminalBoxRef at LastTerminalInside;
	')
	move to LastTerminal then dirToDirection(_module_terminalDir) (_module_terminalPitch)*_module_spacerCount;

	m4_define(`_module_termRef', m4_patsubst(_module_termText, `[^A-Za-z0-9]', `_'))
	m4_ifelse(m4_regexp(_module_termRef, `^[A-Z]'), -1, `m4_define(`_module_termRef', `T'_module_termRef)')
	_module_termRef: LastTerminal;
	N$3: LastTerminal;
')
