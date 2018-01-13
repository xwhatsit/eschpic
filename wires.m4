m4_divert(-1)

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

m4_divert(0)

# vim: filetype=pic
