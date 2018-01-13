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
Usage: wireWithInlineLabel(linespec, label)
'
m4_define_blind(`wireWithInlineLabel', `
	line $1 invis;
	{
		angle = angleBetweenPoints(last line.start, last line.end);
		if abs(last line.start.y - last line.end.y) > \
			abs(last line.start.x - last line.end.x) then {
			"\rotatebox{90}{textWireLabel(($2))}" at last line.c;
		} else {
			"textWireLabel(($2))" at last line.c;
		}
		textLength = textWireLabelLength(($2));
		wireLength = distanceBetweenPoints(last line.start, last line.end);
		stubLength = (wireLength - textLength) / 2;
		line from last line.start to polarCoord(last line.start, stubLength, angle);
		line from polarCoord(last line.end, textLength, angle) to 2nd last line.end;
	}
')


`
Usage: wireWithSideLabel(linespec, label)
'
m4_define_blind(`wireWithSideLabel', `
	line $1;
	{
		if abs(last line.start.y - last line.end.y) > \
			abs(last line.start.x - last line.end.x) then {
			"\rotatebox{90}{textWireLabel($2)}" at last line.c + (elen/32,0) rjust;
		} else {
			"textWireLabel($2)" at last line.c - (0,elen/16) above;
		}
	}
')

m4_divert(0)

# vim: filetype=pic
