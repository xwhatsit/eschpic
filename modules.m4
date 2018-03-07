`
General "module" symbol, with custom terminals and labels. Will draw either vertically or horizontally
depending on current direction.

Usage: module([key-value separated parameters])
Params:
	pos:		Position to place first terminal at. Defaults to "Here".
	ref:		Component reference name. Must be a valid pic label (no spaces, starts with capital
			letter). Will prefix reference name with the current sheet number.
	val:		Component value
	description:	Additional text describing component purpose etc.
	part:		Part number. If this is supplied, it is added to the BOM.
	terminals:	Description of the module's terminals, in the syntax:
			"[Groupname](T1, T2, T3, T4) [[Groupname](T1, T2, T3, T4)... | [Groupname](T1, T2, T3, T4)]".
			The "|" symbol splits the module into top and bottom (or left and right). Group name is
			optional. Example: "X1(L1, L2, L3, PE) X13(DIO0, DIO1, DIO02, DCOM, VO24, DGND) | X2(U, V, W, PE)".
	height:		Height of module (if in vertical orientation). Defaults to "elen * 2" if currently vertical,
			otherwise is automatically calculated.
	width:		Width of module (if in horizontal orientation). Defaults to "elen * 2" if currently horizontal,
			otherwise is automatically calculated.
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
		 `width', `2 * elen'), $@)
	componentHandleRef(_module_)

	[
		pushDir();
		dirToDirection(peekDir());

		m4_define(`_module_topterms', m4_regexp(_module_terminals, `^\([^|]*\)', `\1'))
		m4_define(`_module_botterms', m4_regexp(_module_terminals, `|\(.*\)', `\1'))

		Start: Here;

		m4_pushdef(`_groupCount', 0)
		m4_pushdef(`_totalTermCount', 0)
		move dirToDirection(dirCCW(peekDir())) elen/8;
		_moduleParseTerminals(_module_topterms, 1)
		move dirToDirection(dirCCW(peekDir())) elen/8;
		m4_define(`_module_topGroupCount', _groupCount)
		m4_define(`_module_topTermCount', _totalTermCount)
		m4_popdef(`_totalTermCount')
		m4_popdef(`_groupCount')

		move to Start;
		move dirToDirection(peekDir()) 2*elen;

		m4_pushdef(`_groupCount', 0)
		m4_pushdef(`_totalTermCount', 0)
		move dirToDirection(dirCCW(peekDir())) elen/8;
		_moduleParseTerminals(_module_botterms, -1)
		move dirToDirection(dirCCW(peekDir())) elen/8;
		m4_define(`_module_botGroupCount', _groupCount)
		m4_define(`_module_botTermCount', _totalTermCount)
		m4_popdef(`_totalTermCount')
		m4_popdef(`_groupCount')

		m4_define(`_module_topWidth', m4_eval(_module_topGroupCount + _module_topTermCount*2))
		m4_define(`_module_botWidth', m4_eval(_module_botGroupCount + _module_botTermCount*2))
		m4_define(`_module_greatestWidth', `m4_ifelse(
			m4_eval(_module_topWidth > _module_botWidth), 1, _module_topWidth, _module_botWidth)')

		m4_ifelse(dirIsVertical(peekDir()), 1, `
			m4_define(`_module_width', elen*_module_greatestWidth/4 + elen/4)
		', `
			m4_define(`_module_height', elen*_module_greatestWidth/4 + elen/4)
		')

		box wid _module_width ht _module_height with \
			m4_ifelse(m4_trim(peekDir()),
				dirDown,  `.nw', 
				dirRight, `.nw',
				dirUp,    `.sw',
				dirLeft,  `.ne') at Start;

		popDir();
	] with .Start at _module_pos;

	componentDrawLabels(_module_, true)
')
m4_define_blind(`_moduleParseTerminals', `
	m4_pushdef(`_regex', `^ *\(\w[^(]*\)? *\(([^)]*)\)')
	m4_pushdef(`_index', m4_regexp($1, _regex))
	m4_ifelse(_index, -1, `', `
		m4_regexp($1, _regex, `
			m4_pushdef(`_whole', \&)
			m4_pushdef(`_group', \1)
			m4_pushdef(`_terms', \2)
		')

		m4_define(`_groupCount', m4_eval(_groupCount + 1))

		m4_pushdef(`_termCount', 0)
		_moduleDrawGroup(_group, _terms, $2)
		m4_define(`_totalTermCount', m4_eval(_totalTermCount + _termCount))
		m4_popdef(`_termCount')

		m4_popdef(`_terms')
		m4_popdef(`_group')

		_moduleParseTerminals(m4_substr($1, m4_eval(_index + m4_len(_whole))), $2)
		m4_popdef(`_whole')
	')
	m4_popdef(`_index')
	m4_popdef(`_regex')
')
m4_define_blind(`_moduleDrawGroup', `
	ModuleGroupStart: Here;
	move dirToDirection(dirCCW(peekDir())) elen/8;
	move to polarCoord(Here, elen/8, $3*dirToAngle(peekDir()));
	m4_foreach(_term, $2, `
		m4_define(`_termCount', m4_eval(_termCount + 1))
		m4_ifelse(_term, `', `
			box wid elen/2 ht elen/4 invis;
		', `
			m4_pushdef(`_term_escaped', `m4_patsubst(_term, `[^A-Za-z0-9]', `_')')
			TB`'_term_escaped: box wid elen/2 ht elen/4;
			ModuleGroupTermRef: polarCoord(last box.c, elen/8, $3*dirToAngle(peekDir())-180);
			G`'m4_patsubst($1, `[^A-Za-z0-9]', `_')T`'_term_escaped: ModuleGroupTermRef;
			T`'_term_escaped: ModuleGroupTermRef;
			"textModuleTerminalLabel(_term)" at last box.c;
			m4_popdef(`term_escaped')
		')
		move to last box.c then dirToDirection(dirCCW(peekDir())) elen/4;
	')
	move to polarCoord(Here, elen/8, $3*dirToAngle(peekDir())-180);
	move dirToDirection(dirCCW(peekDir())) elen/8;
	ModuleGroupEnd: Here;

	ModuleGroupTextRef: polarCoord(1/2 between ModuleGroupStart and ModuleGroupEnd,
		5.5, $3*dirToAngle(peekDir()));
	"textModuleTerminalLabel($1)" at ModuleGroupTextRef;

	move to ModuleGroupEnd;
')
