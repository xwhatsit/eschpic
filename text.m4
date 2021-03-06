`
Show text ending with ohms symbol. Requires siunitx package to be installed.
'
m4_define_blind(`textOhms', `$1\si{\ohm}')


`
Rotates text
'
m4_define_blind(`textRotated', `\rotatebox{90}{$1}')


`
Produces (unquoted) text in component reference style.
'
m4_define_blind(`textComponentRef', `{\large\ttfamily\strut{}$1}')


`
Produces (unquoted) text in component value style.
'
m4_define_blind(`textComponentVal', `{\small\ttfamily\strut{}$1}')


`
Produces (unquoted) text in component description style.
'
m4_define_blind(`textComponentDescription', `{\footnotesize\strut{}$1}')


`
Produces (unquoted) text in terminal label style.
'
m4_define_blind(`textTerminalLabel', `{\small\ttfamily\itshape\strut{}$1}')


`
Produces (unquoted) text in module terminal label style.
'
m4_define_blind(`textModuleTerminalLabel', `{\footnotesize\ttfamily\strut{}$1}')

`
Calculates sizes of text module terminal label style text in millimetres
'
m4_define_blind(`textModuleTerminalLabelLength', `(m4_len($1) * 1.4933298)')
m4_define_blind(`textModuleTerminalLabelHeight', `pointsToMillimetres(6.65)')

`
Produces (unquoted) text in wire label style.
'
m4_define_blind(`textWireLabel', `{\small\ttfamily{}$1}')


`
Calculates sizes of wire label style text in millimetres
'
m4_define_blind(`textWireLabelLength', `(m4_len($1) * 1.6601882)')
m4_define_blind(`textWireLabelHeight', `pointsToMillimetres(7.7)')


`
Creates (unquoted) multi-line text using the tabular environment (lines as arguments, so comma-separated; alternatively,
can just use Latex \\ line separates directly in text).
'
m4_define_blind(`textMultiLine',
	`{\footnotesize \begin{tabular}[t]{@{}l@{}}'
	`m4_forloop(`m4_argNum', 1, $#,
		`m4_ifelse(m4_argNum, 1, `',
			` \\')' \normalsize{}`m4_argn(m4_argNum, $@)')' m4_newline()`\end{tabular}}')

`
As per textMultiLine, but centred.
'
m4_define_blind(`textMultiLineCentred',
	`{\footnotesize \begin{tabular}[t]{@{}c@{}}'
	`m4_forloop(`m4_argNum', 1, $#,
		`m4_ifelse(m4_argNum, 1, `',
			` \\')' \normalsize{}`m4_argn(m4_argNum, $@)')' m4_newline()`\end{tabular}}')
`
As per textMultiLine, but right-aligned.
'
m4_define_blind(`textMultiLineRAligned',
	`{\footnotesize \begin{tabular}[t]{@{}r@{}}'
	`m4_forloop(`m4_argNum', 1, $#,
		`m4_ifelse(m4_argNum, 1, `',
			` \\')' \normalsize{}`m4_argn(m4_argNum, $@)')' m4_newline()`\end{tabular}}')
