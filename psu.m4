`
General power-supply symbol.

Usage: psu([comma-separated key-value parameters])
Params:
	pos:		Position to place first terminal at. Defaults to "Here".
	ref:		Component reference name. Must be a valid pic label (no spaces, starts with capital
			letter). Will prefix reference name with the current sheet number.
	val:		Component value
	description:	Additional text describing component purpose etc.
	part:		Part number. If this is supplied, it is added to the BOM.
	type:		In syntax e.g. AC/DC, or DC/DC etc.
	inputLabels:	In syntax e.g. (L1, N, PE) etc.
	outputLabels:	In syntax e.g. (24V, 0V) etc.
'
m4_define_blind(`psu', `
	componentParseKVArgs(`_psu_',
		(`pos', `Here',
		 `ref', `',
		 `val', `',
		 `description', `',
		 `part', `',
		 `type', `',
		 `inputLabels', `()',
		 `outputLabels', `()'), $@)

	m4_define(`_psu_inputType', `')
	m4_define(`_psu_outputType', `')
	m4_regexp(_psu_type, `\([A-Za-z]*\)/\([A-Za-z]*\)', `
		m4_define(`_psu_inputType', m4_translit(\1, `A-Z', `a-z'))
		m4_define(`_psu_outputType', m4_translit(\2, `A-Z', `a-z'))
	')
	m4_define(`_psu_inputCount', m4_nargs(m4_extractargs(_psu_inputLabels)))
	m4_define(`_psu_outputCount', m4_nargs(m4_extractargs(_psu_outputLabels)))

	module(
		ref=_psu_ref,
		val=_psu_val,
		description=_psu_description,
		part=_psu_part,
		internalLabels=false,
		terminals=(`Input'_psu_inputLabels)|(`Output'_psu_outputLabels)
	);

	box wid elen/2 ht elen/2 at 1/2 between last [].BoxStartT and last [].BoxEndB;
	line from last box.sw to last box.ne;

	InputC: 1/4 between last box.nw and last box.se;
	OutputC: 1/4 between last box.se and last box.nw;
	m4_ifelse(_psu_inputType, `ac', `
		"textComponentDescription($\sim$)" at InputC;
	', _psu_inputType, `dc', `
		move to InputC then left elen*5/32;
		line right elen*15/64;
		move from last line.c down elen/16 then left elen*15/128;
		line dashed elen*3/64 right elen*15/64;
	')

	m4_ifelse(_psu_outputType, `ac', `
		"textComponentDescription($\sim$)" at OutputC;
	', _psu_outputType, `dc', `
		move to OutputC then left elen*5/32;
		line right elen*15/64;
		move from last line.c down elen/16 then left elen*15/128;
		line dashed elen*3/64 right elen*15/64;
	')

')
