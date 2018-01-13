m4_divert(-1)

`
Allows defining macros that won't substitute if no parameters are supplied.
From m4 example documentation.
'
m4_define(`m4_define_blind', `m4_ifelse(`$#', `0', ``$0'', `_$0(`$1', `$2', `$'`#', `$'`0')')')
m4_define(`_m4_define_blind', `m4_define(`$1', `m4_ifelse(`$3', `0', ``$4'', `$2')')')


`
Removes surrounding double-quotes from a string

Usage: m4_dequote(str)
Params:
        str:    string to remove double quotes from
'
m4_define(`m4_dequote', `m4_patsubst(m4_patsubst(`$1', `^"'), `"$')')


`
Expands to argument n out of remaining arguments; from m4 example documentation.

Usage: m4_argn(argumentNumber, args)
Params:
        argumentNumber: Number specifying which argument
        args:           Argument list to extract from; usually $@
'
m4_define(`m4_argn', `m4_ifelse(`$1', 1, ``$2'',
  `m4_argn(m4_decr(`$1'), m4_shift(m4_shift($@)))')')


`
From m4 example documentation.
m4_quote(args) - convert args to single-quoted string
'
m4_define(`m4_quote', `m4_ifelse(`$#', `0', `', ``$*'')')


`
From m4 example documentation.
m4_dquote(args) - convert args to quoted list of quoted strings
'
m4_define(`m4_dquote', ``$@'')


`
From m4 example documentation.
m4_dquote_elt(args) - convert args to list of double-quoted strings
'
m4_define(`m4_dquote_elt', `m4_ifelse(`$#', `0', `', `$#', `1', ```$1''',
                             ```$1'',$0(m4_shift($@))')')


`
For loop; from m4 example documentation.

Usage: m4_forloop(counter, from, to, text)
Params:
        counter:        Count variable which is incremented
        from:           Starting value to count from
        to:             Ending value to count to (inclusive)
        text:           "Code" to run within loop
'
m4_define(`m4_forloop', `m4_ifelse(m4_eval(`($2) <= ($3)'), `1',
        `m4_pushdef(`$1')_$0(`$1', m4_eval(`$2'),
                m4_eval(`$3'), `$4')m4_popdef(`$1')')')
m4_define(`_m4_forloop',
        `m4_define(`$1', `$2')$4`'m4_ifelse(`$2', `$3', `',
                `$0(`$1', m4_incr(`$2'), `$3', `$4')')')


`
Modification of m4_forloop with "step" for iterator.

Usage: m4_forloopn(counter, from, to, step, text)
Params:
        counter:        Count variable which is incremented
        from:           Starting value to count from
        to:             Ending value to count to (inclusive)
	step:		Integer to increment by when counting
        text:           "Code" to run within loop
'
m4_define(`m4_forloopn', `m4_ifelse(m4_eval(`($2) <= ($3)'), `1',
        `m4_pushdef(`$1')_$0(`$1', m4_eval(`$2'),
                m4_eval(`$3'), m4_eval(`$4'), `$5')m4_popdef(`$1')')')
m4_define(`_m4_forloopn',
        `m4_define(`$1', `$2')$5`'m4_ifelse(m4_eval((`$2' + `$4') > `$3'), `1', `',
                `$0(`$1', m4_eval(`$2' + `$4'), `$3', `$4', `$5')')')


`
From m4 example documentation.
m4_foreach(x, (item_1, item_2, ..., item_n), stmt)
'
m4_define(`m4_foreach', `m4_pushdef(`$1')_$0(`$1',
	(m4_dquote(m4_dquote_elt$2)), `$3')m4_popdef(`$1')')
m4_define(`_arg1', `$1')
m4_define(`_m4_foreach', `m4_ifelse(`$2', `(`')', `',
	`m4_define(`$1', _arg1$2)$3`'$0(`$1', (m4_dquote(m4_shift$2)), `$3')')')


`
Deletes leading and trailing whitespace

Usage: m4_trim(str)
'
m4_define(`m4_trim', `m4_patsubst(m4_patsubst(`$1', `^\s*'), `\s*$')')


`
Returns "key" part of key-value pair (separated by equals sign)

Usage: m4_getKVKey(kvArg)
Params:
	kvArg:	key-value argument (e.g. "width=100")
'
m4_define(`m4_getKVKey', `m4_trim(m4_substr(`$1', 0, m4_index(`$1', `=')))')


`
Returns "value" part of key-value pair (separated by equals sign)

Usage: m4_getKVVal(kvArg)
Params:
	kvArg:	key-value argument (e.g. "width=100")
'
m4_define(`m4_getKVVal', `m4_trim(m4_substr(`$1', m4_incr(m4_index(`$1', `='))))')



`
Parses key-value args (e.g. "width=100"), extracting keys and values. Defines a macro for each key
using the prefix, with the macro's definition being the value.

Usage: m4_prefixKVArgs(prefix, arg{n}, [arg{n+1} ...])
Params:
	prefix:	String to prepend on the front of each macro name
	arg{n}: Key-value arguments
'
m4_define(`m4_prefixKVArgs', `
	m4_foreach(`m4_kvArg', (m4_shift($@)), `m4_ifelse(m4_getKVKey(m4_kvArg), `', ,
		`m4_define($1`'m4_getKVKey(m4_kvArg), m4_getKVVal(m4_kvArg))')')')



`
Substitutes to simple newline; makes writing neatly-formatted macros easier.
'
m4_define(`m4_newline', `
')

`
Converts pts to mm.
'
m4_define_blind(`pointsToMillimetres', `($1 * 25.4 / 72)')


`
Converts degrees to radians
'
m4_define_blind(`degreesToRadians',`($1 * 0.017453292519943295)')


`
Converts radians to degrees
'
m4_define_blind(`radiansToDegrees',`($1 / 0.017453292519943295)')


`
Trig functions in degrees (pic's builtins use radians)
'
m4_define_blind(`cosd', `cos(degreesToRadians($1))')
m4_define_blind(`sind', `sin(degreesToRadians($1))')
m4_define_blind(`atan2d', `radiansToDegrees(atan2($1, $2))')


`
Converts polar coords to cartesian.

Usage: polarCoord(startPos, distance, angle)
Params:
	startPos:	cartesian coordinate to reference from
	distance:	distance from startPos to travel
	angle:		angle (in degrees) from 0° (horizontal right in pic)
'
m4_define_blind(`polarCoord', `(($1) + (($2) * cosd($3), ($2) * sind($3)))')


`
Calculates angle in degrees between two points.

Usage: angleBetweenPoints(startPos, endPos)
'
m4_define_blind(`angleBetweenPoints', `atan2d(($2).y - ($1).y, ($2).x - ($1).x)')


`
Calculates distance between two points.

Usage: distanceBetweenPoints(startPos, endPos)
'
m4_define_blind(`distanceBetweenPoints',`sqrt((($2).y-($1).y)^2 +(($2).x-($1).x)^2)')

m4_divert(0)
