# Set base unit used for components
elen = 12.7;

m4_divert(-1)

`
Converts pts to mm.
'
m4_define_blind(`pointsToMillimetres', `($1 * 25.4 / 72)')


`
Corner macro, to help with joining up lines at right-angles where the "then" part of a set of lines was omitted.
'
m4_define(`corner',
`{ line from Here up pointsToMillimetres(linethick / 2) }
{ line from Here down pointsToMillimetres(linethick / 2) }')


`
Resistor
'
m4_define_blind(`resistor', `
line down (elen * 1.5) invis;
{
line up (elen / 2);
box wid (elen / 5) ht (elen / 2);
line up (elen / 2);
}
')

m4_divert(0)

# vim: filetype=pic
