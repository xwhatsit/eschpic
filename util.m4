divert(-1)

`
Removes surrounding double-quotes from a string

Usage: dequote(str)
Params:
        str:    string to remove double quotes from
'
define(`dequote', `patsubst(patsubst(`$1', `^"'), `"$')')


`
Expands to argument n out of remaining arguments; from m4 example documentation.

Usage: argn(argumentNumber, args)
Params:
        argumentNumber: Number specifying which argument
        args:           Argument list to extract from; usually $@
'
define(`argn', `ifelse(`$1', 1, ``$2'',
  `argn(decr(`$1'), shift(shift($@)))')')


`
From m4 example documentation.
quote(args) - convert args to single-quoted string
'
define(`quote', `ifelse(`$#', `0', `', ``$*'')')


`
From m4 example documentation.
dquote(args) - convert args to quoted list of quoted strings
'
define(`dquote', ``$@'')


`
From m4 example documentation.
dquote_elt(args) - convert args to list of double-quoted strings
'
define(`dquote_elt', `ifelse(`$#', `0', `', `$#', `1', ```$1''',
                             ```$1'',$0(shift($@))')')


`
For loop; from m4 example documentation.

Usage: forloop(counter, from, to, text)
Params:
        counter:        Count variable which is incremented
        from:           Starting value to count from
        to:             Ending value to count to (inclusive)
        text:           "Code" to run within loop
'
define(`forloop', `ifelse(eval(`($2) <= ($3)'), `1',
        `pushdef(`$1')_$0(`$1', eval(`$2'),
                eval(`$3'), `$4')popdef(`$1')')')
define(`_forloop',
        `define(`$1', `$2')$4`'ifelse(`$2', `$3', `',
                `$0(`$1', incr(`$2'), `$3', `$4')')')


`
Modification of forloop with "step" for iterator.

Usage: forloop(counter, from, to, step, text)
Params:
        counter:        Count variable which is incremented
        from:           Starting value to count from
        to:             Ending value to count to (inclusive)
	step:		Integer to increment by when counting
        text:           "Code" to run within loop
'
define(`forloopn', `ifelse(eval(`($2) <= ($3)'), `1',
        `pushdef(`$1')_$0(`$1', eval(`$2'),
                eval(`$3'), eval(`$4'), `$5')popdef(`$1')')')
define(`_forloopn',
        `define(`$1', `$2')$5`'ifelse(eval((`$2' + `$4') > `$3'), `1', `',
                `$0(`$1', eval(`$2' + `$4'), `$3', `$4', `$5')')')


`
From m4 example documentation.
foreach(x, (item_1, item_2, ..., item_n), stmt)
'
define(`foreach', `pushdef(`$1')_$0(`$1',
	(dquote(dquote_elt$2)), `$3')popdef(`$1')')
define(`_arg1', `$1')
define(`_foreach', `ifelse(`$2', `(`')', `',
	`define(`$1', _arg1$2)$3`'$0(`$1', (dquote(shift$2)), `$3')')')


`
Deletes leading and trailing whitespace

Usage: trim(str)
'
define(`trim', `patsubst(patsubst(`$1', `^\s*'), `\s*$')')


`
Returns "key" part of key-value pair (separated by equals sign)

Usage: getKVKey(kvArg)
Params:
	kvArg:	key-value argument (e.g. "width=100")
'
define(`getKVKey', `trim(substr(`$1', 0, index(`$1', `=')))')


`
Returns "value" part of key-value pair (separated by equals sign)

Usage: getKVVal(kvArg)
Params:
	kvArg:	key-value argument (e.g. "width=100")
'
define(`getKVVal', `trim(substr(`$1', incr(index(`$1', `='))))')



`
Parses key-value args (e.g. "width=100"), extracting keys and values. Defines a macro for each key
using the prefix, with the macro's definition being the value.

Usage: prefixKVArgs(prefix, arg{n}, [arg{n+1} ...])
Params:
	prefix:	String to prepend on the front of each macro name
	arg{n}: Key-value arguments
'
define(`prefixKVArgs', `
	foreach(`kvArg', (shift($@)),
		`define(`$1'getKVKey(kvArg), getKVVal(kvArg))'
		`prefix is $1, curr key is getKVKey(kvArg), curr val is getKVVal(kvArg)')')


divert(0)
