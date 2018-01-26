.PS

m4_include(eschpic.m4)

a3TitleBlock(
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

line down from last [].T_34;
line up from last[].T_Y1;
line down from last [].G_X8_T_14 then right elen/2 then up;
line up from last [].T_A1 then left elen/2 then down;
line down from last [].T_Y44 then right elen/2 then up;
line up from last [].T_Y43 then right elen/2 then down;


# vim: filetype=pic
.PE
