.PS

m4_include(eschpic.m4)

a3TitleBlock(
	sheet=1,
	title="400VAC 3-phase Distribution",
	ref="ABC123",
	rev="0.1",
);


move to a3Pos(4, D);
R2: line down (12.7 * 1.5) invis;
{
line up 6.35;
box wid 2.54 ht 6.35;
line up 6.35;
}
"R2s" at R2.start ljust
"R2e" at R2.end ljust

move to a3Pos(5, C);
line right elen;

R3: [
	pushDir();

	{
		line dirToDirection(peekDir()) elen*1.5 invis;
		Start: last line.start;
		End:   last line.end;
	}
	line dirToDirection(peekDir()) elen/2;
	if dirIsVertical(peekDir()) then {
		box wid elen/5 ht elen/2
	} else {
		box wid elen/2 ht elen/5
	}
	line dirToDirection(peekDir()) elen/2;

	popDir();
]
"R3S" at R3.Start above;
"R3E" at R3.End above;

corner;
line right elen;
corner;
line down elen;

# vim: filetype=pic
.PE
