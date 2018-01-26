m4_divert(-1)

`
Show text ending with ohms symbol. Requires siunitx package to be installed.
'
m4_define_blind(`textOhms', `$1\si{\ohm}')


`
Produces (unquoted) text in component reference style.
'
m4_define_blind(`textComponentRef', `{\small\ttfamily\strut{}$1}')


`
Produces (unquoted) text in component value style.
'
m4_define_blind(`textComponentVal', `{\scriptsize\ttfamily\strut{}$1}')


`
Produces (unquoted) text in component description style.
'
m4_define_blind(`textComponentDescription', `{\scriptsize\strut{}$1}')


`
Produces (unquoted) text in terminal label style.
'
m4_define_blind(`textTerminalLabel', `{\scriptsize\ttfamily\itshape\strut{}$1}')


`
Produces (unquoted) text in module terminal label style.
'
m4_define_blind(`textModuleTerminalLabel', `{\scriptsize\ttfamily\strut{}$1}')

`
Produces (unquoted) text in wire label style.
'
m4_define_blind(`textWireLabel', `{\scriptsize\ttfamily{}$1}')


`
Calculates length of wire label style text in millimetres
'
m4_define_blind(`textWireLabelLength', `(m4_len($1) * 1.3070073)')


`
Creates (unquoted) multi-line text using the tabular environment (lines as arguments, so comma-separated; alternatively,
can just use Latex \\ line separates directly in text).
'
m4_define_blind(`textMultiLine',
	`{\scriptsize \begin{tabular}[t]{@{}l@{}}'
	`m4_forloop(`m4_argNum', 1, $#,
		`m4_ifelse(m4_argNum, 1, `',
			` \\')' \normalsize{}`m4_argn(m4_argNum, $@)')' m4_newline()`\end{tabular}}')



m4_divert(0)
