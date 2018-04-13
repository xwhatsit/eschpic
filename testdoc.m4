m4_include(eschpic.m4)

a3Sheet(
	sheet=1,
	title=400VAC 3-phase Distribution,
	ref=ABC123,
	rev=0.1,
);

move to a3Pos(2, A);
down;
coil(
	ref=V1,
	val=D NF,
	description=Solenoid Valve,
	type=valve,
);

move to a3Pos(3, A);
down;
coil(
	ref=V1,
	val=D F,
	description=Solenoid Valve,
	type=valve,
	flipped=true
);

move to a3Pos(4, A);
up;
coil(
	ref=V1,
	val=U NF,
	description=Solenoid Valve,
	type=valve,
);

move to a3Pos(5, A);
up;
coil(
	ref=V1,
	val=U F,
	description=Solenoid Valve,
	type=valve,
	flipped=true
);


move to a3Pos(2, B);
right;
coil(
	ref=V1,
	val=R NF,
	description=Solenoid Valve,
	type=valve,
);

move to a3Pos(3, B);
right;
coil(
	ref=V1,
	val=R F,
	description=Solenoid Valve,
	type=valve,
	flipped=true
);

move to a3Pos(4, B);
left;
coil(
	ref=V1,
	val=L NF,
	description=Solenoid Valve,
	type=valve,
);

move to a3Pos(5, B);
left;
coil(
	ref=V1,
	val=L F,
	description=Solenoid Valve,
	type=valve,
	flipped=true
);






move to a3Pos(2, C);
down;
coil(
	ref=V1,
	val=D NF reversed,
	description=Solenoid Valve,
	refPos=reversed,
	type=valve,
);

move to a3Pos(3, C);
down;
coil(
	ref=V1,
	val=D NF reversed,
	description=Solenoid Valve,
	refPos=reversed,
	type=valve,
);


move to a3Pos(4, C);
right;
coil(
	ref=V1,
	val=R NF reversed,
	description=Solenoid Valve,
	refPos=reversed,
	type=valve,
);

move to a3Pos(5, C);
right;
coil(
	ref=V1,
	val=R NF reversed,
	description=Solenoid Valve,
	refPos=reversed,
	type=valve,
);


wireGroup(path=down elen*3 from a3Pos(4, D), labels=(L1, L2, L3, PE));
motor(
	ref=M1,
	val=4kW,
	description=Induction Motor,
	type=AC,
	phase=3,
	showPE=true,
);

down;
contactGroup(
	pos=a3Pos(7, C),
	ref=Q1,
	val=12345,
	description=Isolator,
	actuation=twist,
	type=disconnector switch,
	contacts=NO(1, 2) NO(3, 4) NO(5, 6)
);

# vim: filetype=pic
