.PS

m4_include(eschpic.m4)

a3TitleBlock(
	sheet=1,
	title="400VAC 3-phase Distribution",
	ref="ABC123",
	rev="0.1",
);

move to a3Pos(3, D);
R1: line down (10 * 1.5) invis;
{
line up 5;
box wid 2 ht 5;
line up 5;
}
"\rotatebox[origin=cb]{90}{R1slongtext}" at R1.start ljust
"R1e" at R1.end ljust

move to a3Pos(4, D);
R2: line down (12.7 * 1.5) invis;
{
line up 6.35;
box wid 2.54 ht 6.35;
line up 6.35;
}
"R2s" at R2.start ljust
"R2e" at R2.end ljust

# vim: filetype=pic
.PE
