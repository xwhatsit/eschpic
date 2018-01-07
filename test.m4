.PS

m4_include(eschpic.m4)

a3TitleBlock(
	sheet=1,
	title="400VAC 3-phase Distribution",
	ref="ABC123",
	rev="0.1",
);


move to a3Pos(3, C);
line right;
J0: dot;
line down;
coil(
	ref=K1,
	val="REL-PR1-24DC/1/MB",
	description="Power Relay"
);
line down then right;
coil(
	ref=K2,
	val="REL-PR1-24DC/1/MB",
	description="Aux. Power Relay"
);
line right then down;
earth();

line right elen*5 from J0;
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
corner;
earth();
line right from J2;
corner;
NEarth: noiselessEarth();
"textMultiLine(Connections, to earth)" at NEarth.e ljust;

# vim: filetype=pic
.PE
