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
contactNO(
	ref=K1,
	val="REL-PR1-24DC/1/MB",
	description="Power Relay"
);
contactNO(
	pos=K1.Start + (elen/2, 0),
	set=2
);
contactNC(
	pos=K1.Start + (elen, 0),
	set=3
);
line dashed elen/15 from 3rd last [].MidContact to last [].MidContact;

move to K1.End;

line down then left 3*elen then up;
contactNO(
	ref=K2,
	val="REL-PR1-24DC/1/MB",
	description="Auxiliary Power Relay"
);
line up elen/2
coil(ref=KC,
	val="24VDC",
	description="Relay Coil")

down;
contactNC(ref=K8,
	  val="REL-PR1-24DC/NC",
	  decription="Aux",
	  pos=a3Pos(3,D))

right;
contactNC(ref=K8,
	  val="REL-PR1-24DC/NC",
	  decription="Aux",
	  pos=a3Pos(3,E))

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
