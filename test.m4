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

line up from last [].T_31;
junction;

line down ((2*elen) - 10.456058)/2 from last [].T_32 
line down 10.456058 invis;
"\scriptsize\texttt{\rotatebox{90}{(1K1:32)}}" at last line.c;
line down ((2*elen) - 10.456058)/2  from last line.end;
continue left;
junction;

wireWithSideLabel(from 2nd last [].T_24 down elen*2, 1K1:24);
junction;

move to K1.End;

#line down 2*elen;
#"\scriptsize\texttt{\rotatebox{90}{1K1:14}}" at last line.c rjust;
wireWithSideLabel(down 2*elen, 1K1:14);
continue left 3*elen then up;

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
	  pos=a3Pos(3,E));

right;
contactNO(ref=K8,
	  val="REL-PR1-24DC/NC",
	  decription="Aux",
	  pos=a3Pos(3,F));
wireWithInlineLabel(right elen*2, 1K8:14);

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
wireWithInlineLabel(right elen*2, R3S)
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
