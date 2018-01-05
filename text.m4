m4_divert(-1)

`
Show text ending with ohms symbol. Requires siunitx package to be installed.
'
m4_define_blind(`textOhms', `$1\si{\ohm}')


`
Produces (unquoted) text in component reference style.
'
m4_define_blind(`textComponentRef', `{\small \ttfamily $1}')


`
Produces (unquoted) text in component value style.
'
m4_define_blind(`textComponentVal', `{\scriptsize \ttfamily $1}')


`
Produces (unquoted) text in component description style.
'
m4_define_blind(`textComponentDescription', `{\scriptsize $1}')


`
Creates (unquoted) multi-line text using the tabular environment (lines as arguments, so comma-separated; alternatively,
can just use Latex \\ line separates directly in text).
'
m4_define_blind(`textMultiLine',
	`{\scriptsize \begin{tabular}[t]{@{}l@{}}'
	`m4_forloop(`m4_argNum', 1, $#,
		`m4_ifelse(m4_argNum, 1, `',
			` \\')' `m4_argn(m4_argNum, $@)')' m4_newline()`\end{tabular}}')



m4_divert(0)
