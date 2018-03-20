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
	part=PN123456,
	terminals=X1(A1, A2) (Y1) (13, 23, 33, Y43) | (,) (Y2) X8(14, 24, 34, Y44)
);

wire(down elen*2 from last [].T34 then right elen*7, 1A2.34, end)
wireRef(A2T34)

wire(down elen*5 from last [].TY2, 1A2.Y2, mid)
contactor3ph()

line up from A2.TY1;
line down from A2.GX8T14 then right elen/2 then up;

a3Sheet(
	sheet=2,
	title=Next Sheet,
	ref=ABC123,
	rev=0.1,
);

down;
contactNO(
	pos=a3Pos(7, E),
	ref=K3,
	val=Omron G23A,
	description=Manual Relay,
	part=9871234,
	actuation=push
);
wire(down then right 2*elen, Foo.Bar, end)
wireRef(A2T34)

contactNC(
	pos=a3Pos(6, B),
	ref=K3,
	val=Omron G23A,
	description=Manual Relay,
	part=9871234,
	actuation=push
);

# vim: filetype=pic
