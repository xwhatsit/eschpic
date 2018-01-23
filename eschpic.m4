# Use millimetres instead of inches
scale = 25.4;

# Order of includes is important
m4_include(util.m4)
m4_include(direction.m4)
m4_include(text.m4)
m4_include(components.m4)
m4_include(contacts.m4)
m4_include(connectors.m4)
m4_include(wires.m4)

m4_divert(-1)

`
Gives a letter used for vertical-tic marks used on a3TitleBlock() below.

Usage: a3VPosLetter(num)
Params:
        num:    Number between 0 and 9, which will produce a letter between A and J.

Notes:
        Numbers over 9 will produce strange double-letters, like "BA" for 10.
'
m4_define_blind(`a3VPosLetter', `m4_translit(`$1', `0-9', `A-J')')


`
Does the reverse of a3VPosLetter.

Usage: a3VPosNumber(letter)
Params:
	letter:	Letter between A and J
'
m4_define_blind(`a3VPosNumber', `m4_translit(`$1', `A-J', `0-9')')


`
A3 title block (landscape). South-west corner of inside (drawable area) will be aligned with (0, 0).

Usage: a3TitleBlock([comma-separated key-value parameters])
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
	a3SheetNum:	The sheet number specified in the "sheet" parameter
        a3OW:           Overall width of A3 landscape paper (420mm)
        a3OH:           Overall height of A3 landscape paper (297mm)
        a3OuterMargin:  Gets set to whatever outerMargin was in a3TitleBlock() call
        a3InnerMargin:  Gets set to whatever innerMargin was in a3TitleBlock() call
        a3W:            Width of titleblock in mm
        a3H:            Height of titleblock in mm
        a3IW:           Actual drawable area width inside titleblock
        a3IH:           Actual drawable area height inside titleblock
        a3NumHTics:     Gets set to whatever numHTics was in a3TitleBlock() call
        a3NumVTics:     Gets set to whatever nuMVTics was in a3TitleBlock() call
	a3PrefixRefs:	Gets set to whatever prefixRefs was in a3TitleBlock() call
'
m4_define_blind(`a3TitleBlock', `
	# set default args
	m4_define(`_a3_sheet', `')
	m4_define(`_a3_title', `')
	m4_define(`_a3_ref', `')
	m4_define(`_a3_rev', `')
	m4_define(`_a3_date', `\today')
	m4_define(`_a3_numHTics', 8)
	m4_define(`_a3_numVTics', 6)
	m4_define(`_a3_outerMargin', 10)
	m4_define(`_a3_innerMargin', 10)
	m4_define(`_a3_prefixRefs', true)

	# parse key-value arguments
	m4_prefixKVArgs(`_a3_', $@)

	m4_ifelse(_a3_sheet, `', `m4_errprint(`error: a3TitleBlock: "sheet" parameter required'
		) m4_m4exit(1)')

	m4_define(`a3SheetNum', _a3_sheet)
        m4_define(`a3OW', `420')
        m4_define(`a3OH', `297')
        m4_define(`a3OuterMargin', _a3_outerMargin)
        m4_define(`a3InnerMargin', _a3_innerMargin)
        m4_define(`a3W', `m4_eval(a3OW - (a3OuterMargin * 2))')
        m4_define(`a3H', `m4_eval(a3OH  - (a3OuterMargin * 2))')
        m4_define(`a3IW', `m4_eval(a3W - (2 * a3InnerMargin))')
        m4_define(`a3IH', `m4_eval(a3H - (2 * a3InnerMargin))')
        m4_define(`a3NumHTics', _a3_numHTics)
        m4_define(`a3NumVTics', _a3_numVTics)
	m4_define(`a3PrefixRefs', m4_dequote(_a3_prefixRefs))

        maxpswid = a3W / 25.4
        maxpsht  = a3H / 25.4

        [
                labeloffs = a3InnerMargin / 2;

                Outside: box wid a3W ht a3H invis;
                Inside:  box wid a3IW ht a3IH with .c at Outside.c;

                hstep = Inside.width / a3NumHTics;
                vstep = Inside.height / a3NumVTics

                # horizontal tick marks
                for x = 1 to (a3NumHTics - 1) do {
                        line up   a3InnerMargin from (x * hstep + Inside.l.x),Outside.b.y;
                        line down a3InnerMargin from (x * hstep + Inside.l.x),Outside.t.y;
                }

                # horizontal tick labels
                for x = 0 to (a3NumHTics - 1) do {
                        sprintf(`"{\Large %g}"', x + 1) at (x * hstep + Inside.l.x + (hstep / 2)),(Outside.b.y + labeloffs);
                        sprintf(`"{\Large %g}"', x + 1) at (x * hstep + Inside.l.x + (hstep / 2)),(Outside.t.y - labeloffs);
                }

                # vertical tick marks
                for y = 1 to (a3NumVTics - 1) do {
                        line right a3InnerMargin from Outside.l.x,(y * vstep + Inside.b.y);
                        line left  a3InnerMargin from Outside.r.x,(y * vstep + Inside.b.y);
                }

                # vertical tick labels
                m4_forloop(`count', 0, m4_eval(a3NumVTics - 1), `
                     `"{\Large 'a3VPosLetter(count)`}"' at (Outside.l.x + labeloffs),((m4_eval(a3NumVTics - 1) - count) * vstep + Inside.b.y + (vstep / 2))
                     `"{\Large 'a3VPosLetter(count)`}"' at (Outside.r.x - labeloffs),((m4_eval(a3NumVTics - 1) - count) * vstep + Inside.b.y + (vstep / 2))
                     ')

                # title block
                tbheight = Inside.height / 14;
                detailswidth = Inside.width/7;

                # we avoid double lines when certain PDF viewers are zoomed out by
                # making boxes invisible and just drawing the lines we need

                SheetNum: box wid tbheight ht tbheight with .se at Inside.se invis;
                line from SheetNum.ne to SheetNum.nw to SheetNum.sw;
                `"\small \textit{Sheet:}"' ljust below at SheetNum.nw;

                Title: box wid Inside.width/3.5 ht tbheight with .ne at SheetNum.nw invis;
                line from Title.ne to Title.nw to Title.sw;
                `"\small \textit{Title:}"' ljust below at Title.nw;

                Ref: box wid detailswidth ht tbheight/3 with .ne at Title.nw invis;
                line from Ref.ne to Ref.nw to Ref.sw;
                `"\small \textit{Ref:}"' ljust below at Ref.nw;

                Rev: box wid detailswidth ht tbheight/3 with .t at Ref.b invis;
                line from Rev.ne to Rev.nw to Rev.sw;
                `"\small \textit{Rev:}"' ljust below at Rev.nw;

                Date: box wid detailswidth ht tbheight/3 with .t at Rev.b invis;
                line from Date.ne to Date.nw to Date.sw;
                `"\small \textit{Date:}"' ljust below at Date.nw;

                `"\Huge 'm4_dequote(_a3_title)`"' at Title;
                `"'m4_dequote(_a3_date)`"' at Date;
                `"'m4_dequote(_a3_ref)`"' at Ref;
                `"'m4_dequote(_a3_rev)`"' at Rev;
                `"\Huge 'm4_dequote(_a3_sheet)`"' at SheetNum;
        ] with .Inside.sw at 0,0;
')


`
Gives tic-number of horizontal position in millimetres. Only works if using A3 title block.

Usage: a3HPosOf(hpos)
Params:
        hpos:   horizontal position in millimetres
'
m4_define_blind(`a3HPosOf', `floor($1 / (a3IW / a3NumHTics)) + 1')


`
Converts horizontal tic number to millimetres.

Usage: a3HPos(htic)
Params:
	htic:	Tic-number (1 through a3NumHTics)
'
m4_define_blind(`a3HPos', `($1 * (a3IW / a3NumHTics) - ((a3IW / a3NumHTics) / 2))')


`
Converts vertical tic letter to millimetres.

Usage: a3VPos(vtic)
Params:
	vtic:	Tic letter (A through a3VPosLetter(a3NumVTics))
'
m4_define_blind(`a3VPos', `(a3NumVTics - a3VPosNumber($1)) * (a3IH / a3NumVTics) - ((a3IH / a3NumVTics) / 2)')


`
Converts htic/vtic letter/number pair to coordinates in millimetres.

Usage: a3Pos(htic, vtic)
Params:
	htic:	Tic number (1 through a3NumHTics)
	vtic:	Tic letter (A through a3VPosLetter(a3NumVTics))
Example: a3Pos(4, E)
'
m4_define_blind(`a3Pos', `(a3HPos($1), a3VPos($2))')

m4_divert(0)
