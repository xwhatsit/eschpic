`
Corner macro, to help with joining up lines at right-angles where the "then" part of a set of lines was omitted.
'
m4_define(`corner',
`{ line from Here up pointsToMillimetres(linethick / 2) }
{ line from Here down pointsToMillimetres(linethick / 2) }')


`
Wire junction to show wires joining. Can alternatively use "junction" instead of "dot".
'
m4_define(`dot', `circle diam 1 fill 0 with .c at Here; move to last circle.c')
m4_define(`junction', m4_defn(`dot'))


`
Usage: wireWithInlineLabel(linespec, label, labelPos)
Params:
	linespec: text describing a single line segment
	label:    the actual text to print
	labelPos: one of start, mid, end
'
m4_define_blind(`wireWithInlineLabel', `
	line $1 invis;
	{
		_angle = angleBetweenPoints(last line.start, last line.end);
		_textLength = textWireLabelLength(($2));
		_wireLength = distanceBetweenPoints(last line.start, last line.end);

		m4_ifelse(
			$3, `start', `_startLength = elen/4',
			$3, `mid',   `_startLength = (_wireLength - _textLength) / 2',
			$3, `end',   `_startLength = (_wireLength - _textLength) - elen/4');

		line from last line.start to polarCoord(last line.start, _startLength, _angle);
		line from last line.end to polarCoord(last line.end, _textLength, _angle) invis;
		line from last line.end to 3rd last line.end;
		if abs(last line.start.y - last line.end.y) > \
			abs(last line.start.x - last line.end.x) then {
			"\rotatebox{90}{textWireLabel(($2))}" at 2nd last line.c;
		} else {
			"textWireLabel(($2))" at 2nd last line.c;
		}
	}
')


`
Usage: wire(linespec, label, labelPos)
Params:
	linespec: text describing a single line segment
	label:    the actual text to print (optional)
	labelPos: one of start, mid, end   (optional, defaults to "start")
'
m4_define_blind(`wire', `
	m4_ifelse($2, `', `
		line $1
	', `
		_wireWithInlineLabelParseSegment($1, $2, m4_ifelse($3, `', `start', $3), first)
	')
')
m4_define_blind(`_wireWithInlineLabelParseSegment', `
	m4_pushdef(`thenPos', m4_regexp($1, `\bthen\b'))
	m4_pushdef(`segType', m4_ifelse($4, `', mid, $4))

	m4_ifelse(thenPos, -1, `
		m4_pushdef(`segment', $1)
	', `
		m4_pushdef(`segment', m4_substr($1, 0, thenPos))
	')

	m4_ifelse(segment, `', `', `
		m4_ifelse(segType, first, `
			line segment
			Wire___LastPos: last line.start;
			Wire___CurrPos: Here;
		', segType, mid, `
			Wire___LastPos: Here;
			continue segment;
			Wire___CurrPos: Here;
		')

		m4_pushdef(`labelPos', none)
		m4_ifelse($3, start, `
			m4_ifelse(segType, first, `m4_define(`labelPos', start)')
		', $3, mid, `
			m4_ifelse(segType, mid, `
				m4_define(`labelPos', mid)
			', segType, first, `
				m4_ifelse(thenPos, -1, `m4_define(`labelPos', mid)')
			')
		', $3, end, `
			m4_ifelse(thenPos, -1, `m4_define(`labelPos', end)')
		')

		m4_ifelse(labelPos, none, `', `
			_wire___angle      = angleBetweenPoints(Wire___LastPos, Here);
			_wire___textLength = textWireLabelLength(($2));
			_wire___wireLength = distanceBetweenPoints(Wire___LastPos, Here);
		')

		m4_ifelse(labelPos, start, `
			Wire___TextCentre: polarCoord(Wire___LastPos, elen/4 + (_wire___textLength / 2), _wire___angle);
		', labelPos, mid, `
			Wire___TextCentre: 1/2 between Wire___LastPos and Wire___CurrPos;
		', labelPos, end, `
			Wire___TextCentre: polarCoord(Wire___LastPos, _wire___wireLength - (elen/4 + (_wire___textLength / 2)), _wire___angle);
		')

		# Because we have to do a double-line over the bit after the label (to allow "continue" to work, might as well
		# double line the lot; for some reason PDF viewers at certain zoom levels make overwritten lines slightly bold
		m4_ifelse(labelPos, none, `
			line from Wire___LastPos to Wire___CurrPos;
		', `
			if abs(Wire___LastPos.y - Wire___CurrPos.y) > abs(Wire___LastPos.x - Wire___CurrPos.x) then {
				box ht _wire___textLength wid textWireLabelHeight() colored "white" with .c at Wire___TextCentre;
				"\rotatebox{90}{textWireLabel(($2))}" at Wire___TextCentre;
			} else {
				box wid _wire___textLength ht textWireLabelHeight() colored "white" with .c at Wire___TextCentre;
				"textWireLabel(($2))" at Wire___TextCentre;
			}
			line from Wire___LastPos to polarCoord(Wire___TextCentre, (_wire___textLength / 2), _wire___angle + 180);
			line from polarCoord(Wire___TextCentre, (_wire___textLength / 2), _wire___angle) to Wire___CurrPos;
		')

		m4_popdef(`labelPos')
	')

	m4_ifelse(thenPos, -1, `', `
		_wireWithInlineLabelParseSegment(m4_substr($1, m4_eval(thenPos + 4)), $2, $3)
	')

	m4_popdef(`segment')
	m4_popdef(`segType')
	m4_popdef(`thenPos')
')


`
Usage: wireWithSideLabel(linespec, label, labelPos)
Params:
	linespec: text describing a single line segment
	label:    the actual text to print
	labelPos: one of start, mid, end
'
m4_define_blind(`wireWithSideLabel', `
	line $1;
	{
		_angle = angleBetweenPoints(last line.start, last line.end);
		_textLength = textWireLabelLength($2);
		_wireLength = distanceBetweenPoints(last line.start, last line.end);

		m4_ifelse(
			$3, `start', `_startLength = elen/4',
			$3, `mid',   `_startLength = (_wireLength - _textLength) / 2',
			$3, `end',   `_startLength = (_wireLength - _textLength) - elen/4');

		if abs(last line.start.y - last line.end.y) > \
			abs(last line.start.x - last line.end.x) then {
			"\rotatebox{90}{textWireLabel($2)}" at \
				(1/2 between polarCoord(last line.start, _startLength, _angle) and \
					polarCoord(last line.start, _startLength + _textLength, _angle)) + \
						(elen/32,0) rjust;
						
		} else {
			"textWireLabel($2)" at \
				(1/2 between polarCoord(last line.start, _startLength, _angle) and \
					polarCoord(last line.start, _startLength + _textLength, _angle)) - \
						(0,elen/16) above;
		}
	}
')


`
Bus entry/exit symbol.

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

		move to Bus then dirToDirection(dirCW(dirCW(wireDir))) elen/2;
		C: Here;

		move to FirstWire;
		m4_forloop(i, 1, _busFan_count, `
			spline from Here dirToDirection(wireDir) elen/2 then to C then to Bus;

			move to last spline.start;
			move m4_ifelse(dirIsVertical(peekDir()), 1, `right', `down') elen/2;
		')

		m4_popdef(`wireDir')

		popDir();

	] with .Start at _busFan_pos;
')


`
Wire cross-reference, writes out to aux file.

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
		"textWireLabel(/?.?)" at pos;
	')
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

	"\hypertarget{$1:$2}{\hyperlink{$1:$3}{visibleText}}" \
		m4_ifelse(getDir(), dirUp,    `above',
		          getDir(), dirDown,  `below',
			  getDir(), dirLeft,  `rjust',
			  getDir(), dirRight, `ljust') at pos;

	m4_popdef(`visibleText')
	m4_popdef(`text')
')


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
