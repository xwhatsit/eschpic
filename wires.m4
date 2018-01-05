m4_divert(-1)

`
Corner macro, to help with joining up lines at right-angles where the "then" part of a set of lines was omitted.
'
m4_define(`corner',
`{ line from Here up pointsToMillimetres(linethick / 2) }
{ line from Here down pointsToMillimetres(linethick / 2) }')


`
Wire junction to show wires joining. Can alternatively use "junction" instead of "dot".
'
m4_define(`dot', `circle diam 1 fill 0 with .c at Here; move to last circle.c')
m4_define(`junction', m4_defn(`dot'))

m4_divert(0)

# vim: filetype=pic
