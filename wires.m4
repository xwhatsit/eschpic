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
		m4_ifelse(segType, mid, `m4_define(`segType', last)')
	', `
		m4_pushdef(`segment', m4_substr($1, 0, thenPos))
	')

	m4_ifelse(segment, `', `', `
		m4_ifelse(segType, first, `
			line segment
			Wire___LastPos: last line.start;
			Wire___CurrPos: Here;
			m4_ifelse($3, start, `
				_wire___angle      = angleBetweenPoints(Wire___LastPos, Here);
				_wire___textLength = textWireLabelLength(($2));
				_wire___wireLength = distanceBetweenPoints(Wire___LastPos, Here);
				Wire___TextCentre: polarCoord(Wire___LastPos, elen/4 + (_wire___textLength / 2), _wire___angle);

				if abs(Wire___LastPos.y - Wire___CurrPos.y) > abs(Wire___LastPos.x - Wire___CurrPos.x) then {
					box wid _wire___textLength ht textWireLabelHeight() shaded "black" with .c at Wire___TextCentre;
					"\rotatebox{90}{textWireLabel(($2))}" at 1/2 between Wire___LastPos and Wire___CurrPos;
					line from polarCoord(Wire___TextCentre, (_wire___textLength / 2), _wire___angle) to Wire___CurrPos;
				} else {
					box wid _wire___textLength ht textWireLabelHeight() colored "white" with .c at Wire___TextCentre;
					"textWireLabel(($2))" at Wire___TextCentre;
					line from polarCoord(Wire___TextCentre, (_wire___textLength / 2), _wire___angle) to Wire___CurrPos;
				}
			')
		', segType, mid, `
			Wire___LastPos: Here;
			continue segment;
			Wire___CurrPos: Here;

			m4_ifelse($3, mid, `
				_wire___angle      = angleBetweenPoints(Wire___LastPos, Here);
				_wire___textLength = textWireLabelLength(($2));
				_wire___wireLength = distanceBetweenPoints(Wire___LastPos, Here);
				Wire___TextCentre: 1/2 between Wire___LastPos and Wire___CurrPos;

				if abs(Wire___LastPos.y - Wire___CurrPos.y) > abs(Wire___LastPos.x - Wire___CurrPos.x) then {
					box ht _wire___textLength wid textWireLabelHeight() colored "white" with .c at Wire___TextCentre;
					"\rotatebox{90}{textWireLabel(($2))}" at Wire___TextCentre;
					line from polarCoord(Wire___TextCentre, (_wire___textLength / 2), _wire___angle) to Wire___CurrPos;
				} else {
					box wid _wire___textLength ht textWireLabelHeight() colored "white" with .c at Wire___TextCentre;
					"textWireLabel(($2))" at Wire___TextCentre;
					line from polarCoord(Wire___TextCentre, (_wire___textLength / 2), _wire___angle) to Wire___CurrPos;
				}
			')
		', segType, last, `
			Wire___LastPos: Here;
			continue segment;
			Wire___CurrPos: Here;
			m4_ifelse($3, end, `
				_wire___angle      = angleBetweenPoints(Wire___LastPos, Here);
				_wire___textLength = textWireLabelLength(($2));
				_wire___wireLength = distanceBetweenPoints(Wire___LastPos, Here);
				Wire___TextCentre: polarCoord(Wire___LastPos, _wire___wireLength - (elen/4 + (_wire___textLength / 2)), _wire___angle);

				if abs(Wire___LastPos.y - Wire___CurrPos.y) > abs(Wire___LastPos.x - Wire___CurrPos.x) then {
					box ht _wire___textLength wid textWireLabelHeight() colored "white" with .c at Wire___TextCentre;
					"\rotatebox{90}{textWireLabel(($2))}" at Wire___TextCentre;
				} else {
					box wid _wire___textLength ht textWireLabelHeight() colored "white" with .c at Wire___TextCentre;
					"textWireLabel(($2))" at Wire___TextCentre;
				}
			')
		')
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


#`
#Usage: wireGroup(linespec, 
