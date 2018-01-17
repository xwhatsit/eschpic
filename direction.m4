m4_divert(-1)

`
Special macros/variables for handling drawing directions; we save current direction into a pic
variable, so we can restore direction after drawing a component.

The pic up/down/left/right keywords are replaced with new ones that save the current direction. If
it is required that the direction is set without writing to getDir, then one can enclose the
keyword in m4 quotes (e.g. `down' instead of down).
'

`
Direction "enum"
'
m4_define(`dirUp',    1)
m4_define(`dirDown',  2)
m4_define(`dirLeft',  3)
m4_define(`dirRight', 4)


`
Macro to reverse the above text-to-number macros. Will save current position.
'
m4_define_blind(`dirToDirection',
	`m4_ifelse(m4_trim(`$1'), dirUp,    up,
	`m4_ifelse(m4_trim(`$1'), dirDown,  down,
	`m4_ifelse(m4_trim(`$1'), dirLeft,  left,
	`m4_ifelse(m4_trim(`$1'), dirRight, right,
	`m4_errprint(`error: dirToDirection: invalid direction parameter:' m4_trim(`$1')
		) m4_m4exit(1)')')')')')')


`
Direction macros themselves
'
m4_define(`up',    `m4_define_blind(`getDir', dirUp)    `up'')
m4_define(`down',  `m4_define_blind(`getDir', dirDown)  `down'')
m4_define(`left',  `m4_define_blind(`getDir', dirLeft)  `left'')
m4_define(`right', `m4_define_blind(`getDir', dirRight) `right'')


`
These macros can be used to save/restore direction on a stack. pushDir optionally takes an argument
specifying the new direction, otherwise it just gets set to right.
'
m4_define_blind(`pushDir', `
	m4_ifelse(`$1', `', `
		m4_pushdef(`getDir', dirRight) right', `
		m4_ifelse(m4_trim(`$1'), dirUp,    `m4_pushdef(`getDir', dirUp)    up', `
		m4_ifelse(m4_trim(`$1'), dirDown,  `m4_pushdef(`getDir', dirDown)  down', `
		m4_ifelse(m4_trim(`$1'), dirLeft,  `m4_pushdef(`getDir', dirLeft)  left', `
		m4_ifelse(m4_trim(`$1'), dirRight, `m4_pushdef(`getDir', dirRight) right',
			`m4_errprint(`error: pushDir: invalid direction parameter:' m4_trim(`$1')
			) m4_m4exit(1)')
		')')')')')
m4_define_blind(`popDir',  `
	m4_popdef(`getDir')
	m4_ifdef(`getDir', `
		m4_ifelse(getDir(), dirUp,    `up', `
		m4_ifelse(getDir(), dirDown,  `down', `
		m4_ifelse(getDir(), dirLeft,  `left', `
		m4_ifelse(getDir(), dirRight, `right',
			`m4_errprint(`error: popDir: getDir contained an invalid direction value:' getDir()
			) m4_m4exit(1)')
		')')')',
		`right')')
m4_define_blind(`peekDir', ` m4_dnl
	m4_pushdef(`tmpdir', getDir()) m4_dnl
	m4_popdef(`getDir') m4_dnl
	getDir() m4_dnl
	m4_pushdef(`getDir', tmpdir) m4_dnl
	m4_popdef(`tmpdir') m4_dnl
	') m4_dnl

m4_define_blind(`dirIsVertical',
	`m4_ifelse(m4_trim(`$1'), dirUp, 1, `m4_ifelse(m4_trim(`$1'), dirDown, 1, 0)')')
m4_define_blind(`dirIsHorizontal',
	`m4_ifelse(m4_trim(`$1'), dirLeft, 1, `m4_ifelse(m4_trim(`$1'), dirRight, 1, 0)')')
m4_define_blind(`dirIsConventional',
	`m4_ifelse(m4_trim(`$1'), dirDown, 1, `m4_ifelse(m4_trim(`$1'), dirRight, 1, 0)')')


`
Converts direction to angle (degrees)
'
m4_define_blind(`dirToAngle',
	`m4_ifelse(m4_trim(`$1'), dirUp,     90,
	`m4_ifelse(m4_trim(`$1'), dirDown,  270,
	`m4_ifelse(m4_trim(`$1'), dirLeft,  180,
	`m4_ifelse(m4_trim(`$1'), dirRight,   0,
	`m4_errprint(`error: dirToAngle: invalid direction parameter:' m4_trim(`$1')
		) m4_m4exit(1)')')')')')


`
Finds next cw/ccw direction
'
m4_define_blind(`dirCW',
	`m4_ifelse(m4_trim(`$1'), dirUp,    dirRight,
	`m4_ifelse(m4_trim(`$1'), dirDown,  dirLeft,
	`m4_ifelse(m4_trim(`$1'), dirLeft,  dirUp,
	`m4_ifelse(m4_trim(`$1'), dirRight, dirDown,
	`m4_errprint(`error: dirCW: invalid direction parameter:' m4_trim(`$1')
		) m4_m4exit(1)')')')')')
m4_define_blind(`dirCCW',
	`m4_ifelse(m4_trim(`$1'), dirUp,    dirLeft,
	`m4_ifelse(m4_trim(`$1'), dirDown,  dirRight,
	`m4_ifelse(m4_trim(`$1'), dirLeft,  dirDown,
	`m4_ifelse(m4_trim(`$1'), dirRight, dirUp,
	`m4_errprint(`error: dirCCW: invalid direction parameter:' m4_trim(`$1')
		) m4_m4exit(1)')')')')')

m4_divert(0)

# set default direction
right;
