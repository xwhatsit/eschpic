% eschpic document start, for processing with dpic -g

m4_ifdef(`eschSheetSize', `', `m4_define(`eschSheetSize', `a3')')

\documentclass{article}
\usepackage{booktabs}
\usepackage{datatool}
\usepackage{datetime2}
\usepackage{float}
\usepackage[eschSheetSize`'paper,left=10mm,top=10mm,right=10mm,bottom=10mm]{geometry}
\usepackage{longtable}
\usepackage{pdflscape}
\usepackage[hidelinks]{hyperref}
\usepackage{siunitx}
\usepackage{textcomp}
\usepackage{tikz}
\usepackage{varwidth}
\pagestyle{empty}

\DTLsetseparator{,}

\IfFileExists{bom_table.csv}{
\DTLloaddb[noheader,keys={ref,val,description,location,part,uid}]{bom}{bom_table.csv}
}

\begin{document}
m4_divert(9)
\pagebreak

\setcounter{LTchunksize}{1000}

\IfFileExists{bom_table.csv}{
\DTLifdbempty{bom}{}{
\section*{Component List}
\begin{longtable}{l l l r r}
\toprule
Reference & Value & Description & Location & Part Number \\ \midrule
\DTLforeach*{bom}
{\ref=ref,\val=val,\description=description,\location=location,\part=part,\uid=uid}
{%
	\DTLiffirstrow{}{\\}%
	\ref & \val & \description & \hyperlink{\uid}{\location} & \part
} \\
\bottomrule
\end{longtable}
}
}

\end{document}
% eschpic document end (divert=9)
m4_divert(-1)

% Order of includes is important
m4_include(util.m4)
m4_include(direction.m4)
m4_include(text.m4)
m4_include(components.m4)
m4_include(contacts.m4)
m4_include(connectors.m4)
m4_include(dipswitch.m4)
m4_include(hydraulics.m4)
m4_include(modules.m4)
m4_include(psu.m4)
m4_include(sensors.m4)
m4_include(wires.m4)

`
The following macros need to be here up the top, as they are used early on.
'

`
Gives a letter used for vertical-tic marks used on sheetTitleBlock() below.

Usage: eschVPosLetter(num)
Params:
        num:    Number between 0 and 9, which will produce a letter between A and J.

Notes:
        Numbers over 9 will produce strange double-letters, like "BA" for 10.
'
m4_define_blind(`eschVPosLetter', `m4_translit(`$1', `0-9', `A-J')')
m4_define_blind(`a3VPosLetter', `eschVPosLetter($@)') % for backwards compatibility


`
Does the reverse of eschVPosLetter.

Usage: eschVPosNumber(letter)
Params:
	letter:	Letter between A and J
'
m4_define_blind(`eschVPosNumber', `m4_translit(`$1', `A-J', `0-9')')
m4_define_blind(`a3VPosNumber', `eschVPosNumber($@)') % for backwards compatibility




% diversion 7 is run once within the first pic environment
m4_divert(7)
# start new BOM and label files with headers
componentStartBOMFile()
componentStartLabelFile()

# include aux file, then clear it
m4_sinclude(eschpic.aux)
m4_syscmd(rm -f eschpic.aux)

# end (divert=7)
m4_divert(-1)




`
Creates sheet with titleblock. South-west corner of inside (drawable area) will be aligned with (0, 0).

Usage: eschSheet([comma-separated key-value parameters])
Params:
        sheet:		Number for "Sheet:" box in titleblock. Font size is Latex \Huge. Required.
        title:          String for "Title:" box in titleblock. Font size is Latex \Huge.
        ref:            String for "Ref:" box in titleblock. Font size is Latex default.
        rev:            String for "Rev:" box in titleblock. Font size is Latex default.
        date:           String for "Date:" box in titleblock. Optional, defaults to \today. Default Latex font size.
        numHTics:       How many horizontal tic-mark divisions across sheet. Optional, defaults to 8.
        numVTics:       How many vertical tic-mark divisions down sheet. Optional, defaults to 6.
        outerMargin:    How many millimetres margin around all four sides from sheet size to outer border. Optional, defaults to 10.
        innerMargin:    How many millimetres margin from outside border to inside border. Optional, defaults to 10.
	prefixRefs:	Whether or not to prefix component references with the sheet number (e.g. "K1" becomes "3K1" on sheet 3). "true" or "false", defaults to "true"

Sets these pic variables:
        maxpswid:       Gets set to appropriate value for A3 landscape output.
        maxpsht:        As per maxpswid.

Defines the following macros:
	eschSheetNum:	  The sheet number specified in the "sheet" parameter
        eschOW:           Overall width of A3 landscape paper (420mm)
        eschOH:           Overall height of A3 landscape paper, minus 1mm between pages (296mm)
        eschOuterMargin:  Gets set to whatever outerMargin was in a3TitleBlock() call
        eschInnerMargin:  Gets set to whatever innerMargin was in a3TitleBlock() call
        eschW:            Width of titleblock in mm
        eschH:            Height of titleblock in mm
        eschIW:           Actual drawable area width inside titleblock
        eschIH:           Actual drawable area height inside titleblock
        eschNumHTics:     Gets set to whatever numHTics was in a3TitleBlock() call
        eschNumVTics:     Gets set to whatever nuMVTics was in a3TitleBlock() call
	eschPrefixRefs:   Gets set to whatever prefixRefs was in a3TitleBlock() call
'
m4_define_blind(`eschSheet', `
m4_undivert(8)
% eschpic sheet start
\begin{landscape}
\begin{figure}[H]
	\centering
.PS
	m4_undivert(7)
	# Use millimetres instead of inches
	scale = 25.4;

	# Set base unit used for components
	elen = 12.7;

	# set default direction
	right;

	# Required for deferred drawing of terminals
	terminalsInit()

	m4_divert(8)
	# Required for deferred drawing of terminals
	terminalsDrawDeferred()
.PE
\end{figure}
\end{landscape}
\pagebreak
% eschpic sheet end (divert=8)
	m4_divert(0)

	# set default args
	m4_define(`_sheet_sheet', `')
	m4_define(`_sheet_title', `')
	m4_define(`_sheet_ref', `')
	m4_define(`_sheet_rev', `')
	m4_define(`_sheet_date', `\today')
	m4_ifelse(eschSheetSize, `a3', `
		m4_define(`_sheet_numHTics', 8)
		m4_define(`_sheet_numVTics', 6)
	', eschSheetSize, `a2', `
		m4_define(`_sheet_numHTics', 11)
		m4_define(`_sheet_numVTics', 8)
	')
	m4_define(`_sheet_outerMargin', 10)
	m4_define(`_sheet_innerMargin', 10)
	m4_define(`_sheet_prefixRefs', true)

	# parse key-value arguments
	m4_prefixKVArgs(`_sheet_', $@)

	m4_ifelse(_sheet_sheet, `', `m4_errprint(`error: eschSheet: "sheet" parameter required'
		) m4_m4exit(1)')

	m4_define(`eschSheetNum', _sheet_sheet)
	m4_define(`a3SheetNum', eschSheetNum)
	m4_ifelse(eschSheetSize, `a3', `
		m4_define(`eschOW', `420')
		m4_define(`eschOH', `296')
	', eschSheetSize, `a2', `
		m4_define(`eschOW', `594')
		m4_define(`eschOH', `419')
	')

        m4_define(`eschOuterMargin', _sheet_outerMargin)
        m4_define(`eschInnerMargin', _sheet_innerMargin)
        m4_define(`eschW', `m4_eval(eschOW - (eschOuterMargin * 2))')
        m4_define(`eschH', `m4_eval(eschOH  - (eschOuterMargin * 2))')
        m4_define(`eschIW', `m4_eval(eschW - (2 * eschInnerMargin))')
        m4_define(`eschIH', `m4_eval(eschH - (2 * eschInnerMargin))')
        m4_define(`eschNumHTics', _sheet_numHTics)
        m4_define(`eschNumVTics', _sheet_numVTics)
	m4_define(`eschPrefixRefs', _sheet_prefixRefs)

        maxpswid = eschW / 25.4 * 2
        maxpsht  = eschH / 25.4 * 2

        [
                labeloffs = eschInnerMargin / 2;

                Outside: box wid eschW ht eschH invis;
                Inside:  box wid eschIW ht eschIH with .c at Outside.c;

                hstep = Inside.width / eschNumHTics;
                vstep = Inside.height / eschNumVTics

                # horizontal tick marks
                for x = 1 to (eschNumHTics - 1) do {
                        line down eschInnerMargin from (x * hstep + Inside.l.x),Outside.t.y;
                }

                # horizontal tick labels
                for x = 0 to (eschNumHTics - 1) do {
                        sprintf(`"{\Large %g}"', x + 1) at (x * hstep + Inside.l.x + (hstep / 2)),(Outside.t.y - labeloffs);
                }

                # vertical tick marks
                for y = 1 to (eschNumVTics - 1) do {
                        line right eschInnerMargin from Outside.l.x,(y * vstep + Inside.b.y);
                        line left  eschInnerMargin from Outside.r.x,(y * vstep + Inside.b.y);
                }

                # vertical tick labels
                m4_forloop(`count', 0, m4_eval(eschNumVTics - 1), `
                     `"{\Large 'eschVPosLetter(count)`}"' at (Outside.l.x + labeloffs),((m4_eval(eschNumVTics - 1) - count) * vstep + Inside.b.y + (vstep / 2))
                     `"{\Large 'eschVPosLetter(count)`}"' at (Outside.r.x - labeloffs),((m4_eval(eschNumVTics - 1) - count) * vstep + Inside.b.y + (vstep / 2))
                     ')

                # title block
                tbheight = eschInnerMargin;
                detailswidth = Inside.width/8;

                # we avoid double lines when certain PDF viewers are zoomed out by
                # making boxes invisible and just drawing the lines we need

                SheetNum: box wid tbheight*3 ht tbheight with .ne at Inside.se invis;
                line from SheetNum.nw to SheetNum.sw;
                `"\small \textit{Sheet:}"' ljust below at SheetNum.nw;

                Ref: box wid detailswidth ht tbheight with .nw at Inside.sw invis;
                `"\small \textit{Ref:}"' ljust below at Ref.nw;

                Rev: box wid detailswidth ht tbheight with .nw at Ref.ne invis;
                line from Rev.nw to Rev.sw;
                `"\small \textit{Rev:}"' ljust below at Rev.nw;

                Date: box wid detailswidth ht tbheight with .nw at Rev.ne invis;
                line from Date.nw to Date.sw;
                `"\small \textit{Date:}"' ljust below at Date.nw;

                Title: box wid SheetNum.w.x - Date.e.x ht tbheight with .nw at Date.ne invis;
                line from Title.nw to Title.sw;
                `"\small \textit{Title:}"' ljust below at Title.nw;

		line down from Ref.nw to Ref.sw then right to SheetNum.se then up to SheetNum.ne;

                `"\Huge '_sheet_title`"' at Title;
                `"'_sheet_date`"' at Date;
                `"'_sheet_ref`"' at Ref;
                `"'_sheet_rev`"' at Rev;
                `"\Huge '_sheet_sheet`"' at SheetNum;

		"\hypertarget{`sheet_'_sheet_sheet}{}" at Inside.c;
        ] with .Inside.sw at 0,0;
')
m4_define_blind(`a3Sheet', `eschSheet($@)')


`
Gives tic-number of horizontal position in millimetres.

Usage: eschHPosOf(hpos)
Params:
        hpos:   horizontal position in millimetres
'
m4_define_blind(`eschHPosOf', `(floor($1 / (eschIW / eschNumHTics)) + 1)')
m4_define_blind(`a3HPosOf', `eschHPosOf($@)') % for backwards compatibility


`
Converts horizontal tic number to millimetres.

Usage: eschHPos(htic)
Params:
	htic:	Tic-number (1 through eschNumHTics)
'
m4_define_blind(`eschHPos', `($1 * (eschIW / eschNumHTics) - ((eschIW / eschNumHTics) / 2))')
m4_define_blind(`a3HPos', `eschHPos($@)') % for backwards compatibility


`
Converts vertical tic letter to millimetres.

Usage: eschVPos(vtic)
Params:
	vtic:	Tic letter (A through eschVPosLetter(a3NumVTics))
'
m4_define_blind(`eschVPos', `(eschNumVTics - eschVPosNumber($1)) * (eschIH / eschNumVTics) - ((eschIH / eschNumVTics) / 2)')
m4_define_blind(`a3VPos', `eschVPos($@)') % for backwards compatibility


`
Gives tic-number (not letter!) of vertical position in millimetres.

Usage: eschVPosOf(vpos)
Params:
	vpos:	vertical position in millimetres
'
m4_define_blind(`eschVPosOf', `floor(eschNumVTics - ($1 / (eschIH / eschNumVTics)))')
m4_define_blind(`a3VPosOf', `eschVPosOf($@)') % for backwards compatibility


`
Converts htic/vtic letter/number pair to coordinates in millimetres.

Usage: eschPos(htic, vtic)
Params:
	htic:	Tic number (1 through eschNumHTics)
	vtic:	Tic letter (A through eschVPosLetter(eschNumVTics))
Example: eschPos(4, E)
'
m4_define_blind(`eschPos', `(eschHPos($1), eschVPos($2))')
m4_define_blind(`a3Pos', `(a3HPos($1), a3VPos($2))') % for backwards compatibility

m4_divert(0)
