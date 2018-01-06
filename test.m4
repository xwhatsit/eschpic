.PS

m4_include(eschpic.m4)

a3TitleBlock(
	sheet=1,
	title="400VAC 3-phase Distribution",
	ref="ABC123",
	rev="0.1",
);


move to a3Pos(5, C);
line right;
J1: dot;
line down;
"\scriptsize \texttt{\rotatebox{90}{R3E}}" at last line.c rjust below; move to last line.end;

resistor(
	ref=R3,
	val="textOhms(120)",
	description="Braking Resistor"
);

line down;
"\scriptsize \texttt{\rotatebox{90}{R3S}}" at last line.c rjust; move to last line.end;
corner;
line right;
corner;
line down;
PE();

line right elen*2 from J1 then down;
chassisEarth();
J2: junction;
line left;
earth();
line right from J2;
Foo: noiselessEarth();
"textMultiLine(Connections, to earth)" at Foo.e ljust;

# vim: filetype=pic
.PE
