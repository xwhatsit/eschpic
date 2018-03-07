m4_include(eschpic.m4)

a3Sheet(
	sheet=1,
	title=400VAC 3-phase Distribution,
	ref=ABC123,
	rev=0.1,
);
move to a3Pos(3, C);
down;
module(
	ref=A2,
	val=XPS-AC5121,
	description=E-Stop Module,
	terminals=X1(A1, A2) (Y1) (13, 23, 33, Y43) | (,) (Y2) X8(14, 24, 34, Y44)
);

line down elen*2 from last [].T34 then right elen*4;
wireRef(A2T34)

line up from last[].TY1;
line down from last [].GX8T14 then right elen/2 then up;

a3Sheet(
	sheet=2,
	title=Next Sheet,
	ref=ABC123,
	rev=0.1,
);

line from a3Pos(6, E) down;
wireRef(A2T34)

#print sprintf("___wireRef(A2T34, %.0f, %.0f, %.0f)", a3SheetNum, a3HPosOf(Here.x), a3VPosOf(Here.y)) >> "eschpic.aux"
