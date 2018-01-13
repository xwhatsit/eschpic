.PS

m4_include(eschpic.m4)

a3TitleBlock(
	sheet=1,
	title="400VAC 3-phase Distribution",
	ref="ABC123",
	rev="0.1",
);


move to a3Pos(3, C);
wireWithSideLabel(right, 24VDC, start);
line right;
J0: dot;
line down;
contactNO(
	ref=K1,
	val="REL-PR1-24DC/1/MB",
	description="Power Relay"
);
K1B: contactNO(
	pos=K1.Start + (elen/2, 0),
	set=2
);
K1C: contactNC(
	pos=K1.Start + (elen, 0),
	set=3
);
line dashed elen/15 from 3rd last [].MidContact to last [].MidContact;
line up from 2nd last [].T_23;
junction;
line up from last [].T_31;
junction;

wireWithSideLabel(from K1.End down 4*elen, 1K1:14, start);
#line down elen then right 3*elen then down;

wireWithInlineLabel(from K1B.T_24 down 1.5*elen, 1:24, start);
line down elen/2 then right 3*elen then down 1.5*elen;
wireWithSideLabel(from K1C.T_32 down 1.5*elen, 1K1:32, start);
#continue right elen*3 then down 2*elen;

down;
contactNC(ref=K8,
	  val="REL-PR1-24DC/NC",
	  decription="Aux",
	  pos=a3Pos(3,E));

right;
contactNO(ref=K8,
	  val="REL-PR1-24DC/NC",
	  decription="Aux",
	  pos=a3Pos(3,F));
wireWithSideLabel(right elen*2, 1K8:14, end);

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
wireWithSideLabel(right elen*2, R3S, mid)
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

# vim: filetype=pic
.PE
