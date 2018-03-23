`
Corner macro, to help with joining up lines at right-angles where the "then" part of a set of lines was omitted.
'
m4_define(`corner',
`{ line from Here up pointsToMillimetres(linethick / 2) }
{ line from Here down pointsToMillimetres(linethick / 2) }')


`
Wire junction to show wires joining. Can alternatively use "junction" instead of "dot".

Usage: dot[(pos)]
Params:
	pos:	Position to place junction at
'
m4_define(`dot', `circle diam 1 fill 0 with .c at m4_ifelse($1, `', `Here', $1); move to last circle.c')
m4_define(`junction', `dot($@)')


`
Usage: wire(linespec, label, labelPos)
Params:
	linespec: text describing path wire takes (can have multiple segments, be sure to use "then" to separate)
	label:    the actual text to print (optional)
	labelPos: one or more of start, mid, end (optional, defaults to "start end")
'
m4_define_blind(`wire', `
	m4_ifelse($2, `', `
		line $1
	', `
		m4_pushdef(`haveDrawnMid', false)
		_wireParseSegment($1, $2, m4_ifelse($3, `', `start end', $3), first)
		m4_popdef(`haveDrawnMid')
	')
')
m4_define_blind(`_wireParseSegment', `
	m4_pushdef(`thenPos', m4_regexp($1, `\bthen\b'))
	m4_pushdef(`segType', m4_ifelse($4, `', mid, $4))

	m4_ifelse(thenPos, -1, `
		m4_pushdef(`segment', $1)
	', `
		m4_pushdef(`segment', m4_substr($1, 0, thenPos))
	')

	m4_ifelse(segment, `', `', `
		m4_ifelse(segType, first, `
			line segment;
			Wire___LastPos: last line.start;
			Wire___CurrPos: Here;
		', segType, mid, `
			Wire___LastPos: Here;
			continue segment;
			Wire___CurrPos: Here;
		')

		m4_pushdef(`labelPos', `')
		m4_ifelse(m4_eval(m4_regexp($3, `\bstart\b') != -1), 1, `
			m4_ifelse(segType, first, `m4_define(`labelPos', labelPos `start')')
		')
		m4_ifelse(m4_eval(m4_regexp($3, `\bmid\b') != -1), 1, `
			m4_ifelse(segType, mid, `
				m4_define(`labelPos', labelPos `mid')
			', segType, first, `
				m4_ifelse(thenPos, -1, `m4_define(`labelPos', labelPos `mid')')
			')
		')
		m4_ifelse(m4_eval(m4_regexp($3, `\bend\b') != -1), 1, `
			m4_ifelse(thenPos, -1, `m4_define(`labelPos', labelPos `end')')
		')

		m4_ifelse(labelPos, `', `', `
			_wire___angle      = angleBetweenPoints(Wire___LastPos, Here);
			_wire___textLength = textWireLabelLength(($2));
			_wire___wireLength = distanceBetweenPoints(Wire___LastPos, Here);
		')

		m4_ifelse(m4_eval(m4_regexp(labelPos, `\bstart\b') != -1), 1, `
			_wireDrawLabel(start, $2)
		')
		m4_ifelse(m4_eval(m4_regexp(labelPos, `\bmid\b') != -1), 1, `
			m4_ifelse(haveDrawnMid, false, `
				m4_define(`haveDrawnMid', true)
				_wireDrawLabel(mid, $2)

			')
		')
		m4_ifelse(m4_eval(m4_regexp(labelPos, `\bend\b') != -1), 1, `
			_wireDrawLabel(end, $2)
		')

		m4_popdef(`labelPos')
	')

	m4_ifelse(thenPos, -1, `', `
		_wireParseSegment(m4_substr($1, m4_eval(thenPos + 4)), $2, $3)
	')

	m4_popdef(`segment')
	m4_popdef(`segType')
	m4_popdef(`thenPos')
')
m4_define_blind(`_wireDrawLabel', `
	m4_ifelse($1, start, `
		Wire___TextCentre: polarCoord(Wire___LastPos, elen/4 + (_wire___textLength / 2), _wire___angle);
	', $1, mid, `
		Wire___TextCentre: 1/2 between Wire___LastPos and Wire___CurrPos;
	', $1, end, `
		Wire___TextCentre: polarCoord(Wire___LastPos, _wire___wireLength - (elen/4 + (_wire___textLength / 2)), _wire___angle);
	')

	if abs(Wire___LastPos.y - Wire___CurrPos.y) > abs(Wire___LastPos.x - Wire___CurrPos.x) then {
		box ht _wire___textLength wid textWireLabelHeight() colored "white" with .c at Wire___TextCentre;
		"\rotatebox{90}{textWireLabel(($2))}" at Wire___TextCentre;
	} else {
		box wid _wire___textLength ht textWireLabelHeight() colored "white" with .c at Wire___TextCentre;
		"textWireLabel(($2))" at Wire___TextCentre;
	}
	line from polarCoord(Wire___TextCentre, (_wire___textLength / 2), _wire___angle) to Wire___CurrPos;
')


`
Usage: wireGroup([comma-separated key-value parameters])
Params:
	ref:		Optional; if given, reference positions are created as "Ref.Start1", "Ref.End1". If labels are supplied and they are
			valid pic reference labels, will also create "Ref.Label.Start", "Ref.Label.End" etc.
	path:		Path of the first line
	count:		How many wires to place. Not required if "labels" is supplied.
	labels:		Wire labels for each wire, in form "(L1, L2, L3, PE)" etc.
	labelPos:	One or more of start, mid, end (optional, defaults to "start end")
	stagger:	Either or both of start and end. Adds offset to start and/or end. Defaults to no stagger.
'
m4_define_blind(`wireGroup', `
	componentParseKVArgs(`_wireGroup_',
		(`ref', `',
		 `path', `',
		 `count', `',
		 `labels', `()',
		 `labelPos', `start end',
		 `stagger', `'), $@)
	
	m4_ifelse(_wireGroup_path, `', `
		m4_errprintl(`error: wireGroup must have a "path" parameter')
		m4_m4exit(1)
	')

	m4_ifelse(_wireGroup_count, `', `m4_define(`_wireGroup_count', m4_nargs(m4_extractargs(_wireGroup_labels)))')
	m4_ifelse(_wireGroup_count, 0, `
		m4_errprintl(`error: wireGroup has zero count')
		m4_m4exit(1)
	')

	m4_ifelse(_wireGroup_ref, `', `', `
		m4_ifelse(m4_eval(m4_regexp(_wireGroup_ref, `^[A-Z][A-Za-z0-9]*$') == -1), 1, `
			m4_errprintl(`error: wireGroup ref' "_wireGroup_ref" `is not a valid pic label')
			m4_m4exit(1)
		')
	')

	m4_pushdef(`segCount', 0)
	_wireGroupParseSegment(_wireGroup_path, _wireGroup_labelPos, first)
	m4_forloop(i, 0, m4_eval(_wireGroup_count - 1), `
		wire(from _wireGroupGetOffset(0, i) to _wireGroupGetOffset(1, i) m4_forloop(j, 2, segCount, `then to _wireGroupGetOffset(j, i)'),
		     m4_argn(m4_eval(i + 1), m4_extractargs(_wireGroup_labels)),
		     _wireGroup_labelPos)
	')

	m4_ifelse(_wireGroup_ref, `', `', `
		_wireGroup_ref: [
			Start1: WireGroup___Pos_0;
			End1:   WireGroup___Pos_`'segCount;
			m4_forloop(i, 2, _wireGroup_count, `
				Start`'i: WireGroup___Pos_0 + _wireGroupDirOffset(1, m4_eval(i - 1));
				End`'i:   WireGroup___Pos_`'segCount + _wireGroupDirOffset(segCount, m4_eval(i - 1)) + _wireGroupEndOffset(segCount, m4_eval(i - 1));
			')

			m4_ifelse(_wireGroup_labels, `()', `', `
				m4_forloop(i, 1, _wireGroup_count, `
					m4_pushdef(`label', m4_argn(i, m4_extractargs(_wireGroup_labels)))
					m4_ifelse(m4_eval(m4_regexp(label, `^[A-Z][A-Za-z0-9]*$') != -1), 1, `
						label: [
							Start: Start`'i;
							End:   End`'i;
						] with .Start at Start`'i;
					')
					m4_popdef(`label')
				')
			')
		] with .Start1 at WireGroup___Pos_0;
	')

	move to WireGroup___Pos_`'segCount;

	m4_popdef(`segCount')
')
m4_define_blind(`_wireGroupGetOffset', ` m4_dnl
	m4_ifelse(m4_eval($1 == 0 && m4_regexp(_wireGroup_stagger, `\bstart\b') == -1), 1, ` m4_dnl
		WireGroup___Pos_$1 + _wireGroupDirOffset(1, $2) m4_dnl
	', ` m4_dnl
		WireGroup___Pos_$1 + _wireGroupDirOffset($1, $2) + _wireGroupEndOffset($1, $2) m4_dnl
	') m4_dnl
')
m4_define_blind(`_wireGroupDirOffset', ` m4_dnl
	m4_ifelse(dirIsVertical(m4_indir(_wireGroup_direction[m4_max($1, 1)])), 1, ($2 * elen/2, 0), (0, -($2 * elen/2))) m4_dnl
')
m4_define_blind(`_wireGroupEndOffset', ` m4_dnl
	m4_ifelse(m4_eval($1 == segCount && m4_regexp(_wireGroup_stagger, `\bend\b') == -1), 1, ` m4_dnl
		(0, 0) m4_dnl
	', ` m4_dnl
		m4_ifelse(dirIsVertical(m4_indir(_wireGroup_direction[m4_max($1, 1)])), 1, ` m4_dnl
			(0, -($2 * elen/2)) m4_dnl
		', ` m4_dnl
			($2 * elen/2, 0) m4_dnl
		') m4_dnl
	') m4_dnl
')
m4_define_blind(`_wireGroupParseSegment', `
	m4_pushdef(`thenPos', m4_regexp($1, `\bthen\b'))
	m4_pushdef(`segType', m4_ifelse($3, `', mid, $3))

	m4_ifelse(thenPos, -1, `
		m4_pushdef(`segment', $1)
	', `
		m4_pushdef(`segment', m4_substr($1, 0, thenPos))
	')

	m4_ifelse(segment, `', `', `
		m4_ifelse(segType, first, `
			line segment invis;
			`WireGroup___Pos_'segCount`: last line.start;'
		', `
			continue segment;
		')
		`WireGroup___Pos_'m4_eval(segCount + 1)`: Here;'
	')
	m4_define(`_wireGroup_direction['m4_eval(segCount + 1)`]', getDir())
	m4_define(`segCount', m4_eval(segCount + 1))


	m4_ifelse(thenPos, -1, `', `
		_wireGroupParseSegment(m4_substr($1, m4_eval(thenPos + 4)), $2)
	')

	m4_popdef(`segType')
	m4_popdef(`thenPos')
')


`
Bus entry/exit symbol.

Can use busEntry/busExit convenience macros and omit the "type" param.

Defines position labels for each wire connection point, as .Tn.
Also defines .Bus (or just .B) for the bus connection point.

Usage: busFan([comma-separated key-value parameters])
Params:
	pos:		Start position. Defaults to "Here".
	type:		Either "entry" or "exit".
	count:		Number of wires. If not specified, figures this out from the "labels" parameter.
	labels:		Labels for each wire, in form "(L1, L2, L3, PE)".
'
m4_define_blind(`busFan', `
	componentParseKVArgs(`_busFan_',
		(`pos', `Here',
		 `type', `',
		 `count', `',
		 `labels', `'), $@)
	
	m4_ifelse(_busFan_count, `', `m4_define(`_busFan_count', m4_nargs(m4_extractargs(_busFan_labels)))')
	m4_ifelse(_busFan_count, 0, `
		m4_errprintl(`error: busFan has zero count')
		m4_m4exit(1)
	')

	m4_ifelse(_busFan_type, `entry', `
	', _busFan_type, `exit',  `
	', `
		m4_errprintl(`error: busFan needs a type of either "entry" or "exit"')
		m4_m4exit(1)
	')
	
	[
		pushDir();

		m4_pushdef(`wireDir', m4_ifelse(_busFan_type, `entry', peekDir(), dirCW(dirCW(peekDir()))))

		Start: Here;
		move dirToDirection(peekDir()) elen/2;
		m4_ifelse(_busFan_type, `entry', `
			move m4_ifelse(dirIsVertical(peekDir()), 1, `right', `down') ((_busFan_count - 1) / 2) * elen/2
		', `
			move m4_ifelse(dirIsVertical(peekDir()), 1, `left', `up') ((_busFan_count - 1) / 2) * elen/2
		')
		move dirToDirection(peekDir()) elen/2;
		End: Here;

		m4_ifelse(_busFan_type, entry, `
			FirstWire: Start;
			Bus: End;
		', `
			Bus: Start;
			FirstWire: End;
		')
		B: Bus;

		move to Bus then dirToDirection(dirCW(dirCW(wireDir))) elen/2;
		C: Here;

		move to FirstWire;
		m4_forloop(i, 1, _busFan_count, `
			`T'i: Here;

			m4_ifelse(_busFan_labels, `', `', `"textTerminalLabel(m4_argn(i, m4_extractargs(_busFan_labels)))" \
				m4_ifelse(dirIsVertical(peekDir()), 1, `rjust', `above') at `T'i');

			spline from `T'i dirToDirection(wireDir) elen/2 then to C then to Bus;

			move to last spline.start;
			move m4_ifelse(dirIsVertical(peekDir()), 1, `right', `down') elen/2;
		')

		m4_popdef(`wireDir')

		popDir();

	] with .Start at _busFan_pos;

	move to last [].End;
')
m4_define_blind(`busEntry', `busFan(type=entry, $@)')
m4_define_blind(`busExit', `busFan(type=exit, $@)')


`
Bus/cable.

Usage: bus([comma-separated key-value parameters])
Params:
	path:		text describing path bus takes (can have multiple segments, be sure to use "then" to separate)
	ref:		reference to display for the wire, will be prefixed with sheet num if this is enabled
	val:		value text to display
	description:	description text
	part:		part number, will be added to BOM if provided
	labelPos:	position of labelling, one of "start", "mid", "end" (defaults to "mid")
'
m4_define_blind(`bus', `
	componentParseKVArgs(`_bus_',
		(`path', `',
		 `ref', `',
		 `val', `',
		 `description', `',
		 `part', `',
		 `labelPos', `mid'), $@)
	
	m4_ifelse(_bus_path, `', `
		m4_errprintl(`error: bus must have a "path" parameter')
		m4_m4exit(1)
	')

	m4_pushdef(`haveLabelInfo', false)
	m4_pushdef(`labelDir')

	_busParseSegment(_bus_path, _bus_ref, _bus_val, _bus_description, _bus_labelPos, first)

	m4_ifelse(haveLabelInfo, true, `
		_bus___angle     = angleBetweenPoints(Bus___LabelLineStart, Bus___LabelLineEnd);
		m4_ifelse(_bus_labelPos, start, `
			Bus___LabelC: polarCoord(Bus___LabelLineStart, elen/4, _bus___angle);
		', _bus_labelPos, mid, `
			Bus___LabelC: 1/2 between Bus___LabelLineStart and Bus___LabelLineEnd;
		', _bus_labelPos, end, `
			Bus___LabelC: polarCoord(Bus___LabelLineEnd, elen/4, _bus___angle + 180);
		')

		m4_ifelse(dirIsVertical(labelDir), 1, `
			line from Bus___LabelC - (elen/8, elen/16) to Bus___LabelC + (elen/8, elen/16);
		', `
			line from Bus___LabelC - (elen/16, elen/8) to Bus___LabelC + (elen/16, elen/8);
		')

		componentHandleRef(_bus_)
		componentCombineLabels(_bus_)
		m4_ifelse(dirIsVertical(labelDir), 1, `
			"textMultiLine(_bus_labels)" rjust at last line.start;
		', `
			"textMultiLine(_bus_labels)" above at last line.end;
		')
		m4_popdef(_bus_labels)
	')

	m4_popdef(`labelDir')
	m4_popdef(`haveLabelInfo')

	m4_define(`_bus_pos', Bus___LabelC);
	componentWriteBOM(_bus_)

	move to Bus___CurrPos;
')
m4_define_blind(`_busParseSegment', `
	m4_pushdef(`thenPos', m4_regexp($1, `\bthen\b'))
	m4_pushdef(`segType', m4_ifelse($6, `', mid, $6))

	m4_ifelse(thenPos, -1, `
		m4_pushdef(`segment', $1)
	', `
		m4_pushdef(`segment', m4_substr($1, 0, thenPos))
	')

	m4_ifelse(segment, `', `', `
		m4_ifelse(segType, first, `
			line segment thickness 2.5*linethick;
			Bus___LastPos: last line.start;
			Bus___CurrPos: Here;
		', segType, mid, `
		  	Bus___LastPos: Here;
			continue segment;
			Bus___CurrPos: Here;
		')

		m4_pushdef(`labelPos', none)
		m4_ifelse($5, start, `
			m4_ifelse(segType, first, `m4_define(`labelPos', start)')
		', $5, mid, `
			m4_ifelse(segType, mid, `
				m4_define(`labelPos', mid)
			', segType, first, `
				m4_ifelse(thenPos, -1, `m4_define(`labelPos', mid)')
			')
		', $5, end, `
			m4_ifelse(thenPos, -1, `m4_define(`labelPos', end)')
		')

		m4_ifelse(labelPos, none, `', `
			m4_ifelse(haveLabelInfo, false, `
				m4_define(`haveLabelInfo', true)
				Bus___LabelLineStart: Bus___LastPos;
				Bus___LabelLineEnd: Bus___CurrPos;
				m4_define(`labelDir', getDir())
			', `
				m4_define(`labelPos', none)
			')
		')

		m4_popdef(`labelPos')
	')

	m4_ifelse(thenPos, -1, `', `
		_busParseSegment(m4_substr($1, m4_eval(thenPos + 4)), $2, $3, $4, $5)
	')

	m4_popdef(`segment')
	m4_popdef(`segType')
	m4_popdef(`thenPos')
')


`
Wire cross-reference, shows label and writes out to aux file. Automatically moves down/right for next wire ref depending on direction.

Usage: wireRef(name, pos)
Params:
	name:		Internal name used to refer to reference.
	pos:		Position to place reference at. Defaults to "Here".
'
m4_define_blind(`wireRef', `
	m4_pushdef(`pos', m4_ifelse($2, `', Here, $2))

	# output this wire ref first
	print sprintf("`_wireRef'($1, %.0f, %.0f, %.0f)", a3SheetNum, a3HPosOf(pos`'.x), a3VPosOf(pos`'.y)) >> "eschpic.aux"

	m4_ifdef(`_wireRefOut_$1.last', `
		m4_define(`_wireRefOut_$1.last', m4_eval(m4_defn(`_wireRefOut_$1.last') + 1))
	', `
		m4_define(`_wireRefOut_$1.last', 0)
	')
	m4_pushdef(`currID', m4_defn(`_wireRefOut_$1.last'))

	# find first ref without our ID
	m4_pushdef(`haveRef', 0)
	m4_ifdef(`_wireRef_$1.last', `
		m4_forloop(`searchID', 0, m4_defn(`_wireRef_$1.last'), `
			m4_ifelse(m4_eval(searchID != currID && haveRef != 1), 1, `
				m4_define(`haveRef', 1)
				_wireRefDrawText($1, currID, searchID, pos)
			')
		')
	')
	m4_ifelse(haveRef, 0, `
		m4_errprintl(`warning: no ref found for' $1 `, may need to recompile')
		"m4_ifelse(dirIsVertical(getDir()), 1, `textRotated(textWireLabel(/?.?))', `textWireLabel(/?.?)')" _wireRefTextAlignment() at pos;
	')
	pushDir()
	move to pos then m4_ifelse(dirIsVertical(peekDir()), 1, `right', `down') elen/2;
	popDir()
	m4_popdef(`haveRef')

	m4_popdef(`currID')
	m4_popdef(`pos')
')


`
Support macro to draw rotated/shifted wire reference.

Usage: _wireRefDrawText(label, currID, referencedID, pos)
'
m4_define_blind(`_wireRefDrawText', `
	m4_pushdef(`text', _wireRefText($1, $3))
	m4_pushdef(`visibleText', m4_ifelse(dirIsVertical(getDir()), 1, `\rotatebox{90}{textWireLabel(text)}', `textWireLabel(text)'))

	"\hypertarget{$1:$2}{\hyperlink{$1:$3}{visibleText}}" _wireRefTextAlignment() at pos;

	m4_popdef(`visibleText')
	m4_popdef(`text')
')


`
Support macro to calculate text alignment for wire reference. Uses current dir.
'
m4_define_blind(`_wireRefTextAlignment', `m4_ifelse(getDir(), dirUp, `above', getDir(), dirDown, `below', getDir(), dirLeft,  `rjust', getDir(), dirRight, `ljust')')


`
Support macro to create wire reference labelling text from a label and ID.

Usage: _wireRefText(label, id)
'
m4_define_blind(`_wireRefText', `m4_dnl
/`'m4_defn(_wireRef_$1[$2].sheet).`'m4_defn(_wireRef_$1[$2].h)`'a3VPosLetter(m4_defn(_wireRef_$1[$2].v))')


`
Macro to read in wire refs from aux file
'
m4_define_blind(`_wireRef', `
	m4_ifdef(_wireRef_$1.last, `
		m4_define(_wireRef_$1.last, m4_eval(m4_defn(_wireRef_$1.last) + 1))
	', `
		m4_define(_wireRef_$1.last, 0)
	')
	m4_pushdef(`currID', m4_defn(_wireRef_$1.last))

	m4_define(_wireRef_$1[currID].sheet, $2)
	m4_define(_wireRef_$1[currID].h, $3)
	m4_define(_wireRef_$1[currID].v, $4)

	m4_popdef(`currID')
')
