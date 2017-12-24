# Use millimetres instead of inches
scale = 25.4


divert(-1)

`
Removes surrounding double-quotes from a string

Usage: dequote(str)
Params:
        str:    string to remove double quotes from
'
define(`dequote', `patsubst(patsubst(`$1', `^"'), `"$')')

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
Expands to argument n out of remaining arguments; from m4 example documentation.

Usage: argn(argumentNumber, args)
Params:
        argumentNumber: Number specifying which argument
        args:           Argument list to extract from; usually $@
'
define(`argn', `ifelse(`$1', 1, ``$2'',
  `argn(decr(`$1'), shift(shift($@)))')')

define(`a3test', `
        forloop(`argnum', `1', `$#', `
                ifelse(index(argn(argnum, $@), `width='), 0, `has width', `not width')
                ')
')


`
Gives a letter used for vertical-tic marks used on a3TitleBlock() below.

Usage: a3VPosLetter(num)
Params:
        num:    Number between 0 and 9, which will produce a letter between A and J.

Notes:
        Numbers over 9 will produce strange double-letters, like "BA" for 10.
'
define(`a3VPosLetter', `translit(`$1', `0-9', `A-J')')


`
A3 title block (landscape). South-west corner of inside (drawable area) will be aligned with (0, 0).

Usage: a3TitleBlock(sheetNum, title, ref, rev, [date = `\today', numHTics = 8, numVTics = 6, outerMargin = 10, innerMargin = 10])
Params:
        sheetNum:       Number for "Sheet:" box in titleblock. Font size is Latex \Huge.
        title:          String for "Title:" box in titleblock. Font size is Latex \Huge.
        ref:            String for "Ref:" box in titleblock. Font size is Latex default.
        rev:            String for "Rev:" box in titleblock. Font size is Latex default.
        date:           String for "Date:" box in titleblock. Optional, defaults to \today. Default Latex font size.
        numHTics:       How many horizontal tic-mark divisions across sheet. Optional, defaults to 8.
        numVTics:       How many vertical tic-mark divisions down sheet. Optional, defaults to 6.
        outerMargin:    How many millimetres margin around all four sides from sheet size to outer border. Optional, defaults to 10.
        innerMargin:    How many millimetres margin from outside border to inside border. Optional, defaults to 10.

Sets these pic variables:
        maxpswid:       Gets set to appropriate value for A3 landscape output.
        maxpsht:        As per maxpswid.

Defines the following macros:
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
'
define(`a3TitleBlock', `
        define(`a3OW', `420')
        define(`a3OH', `297')
        define(`a3OuterMargin', `ifelse(`$8', , `10', `$8')')
        define(`a3InnerMargin', `ifelse(`$9', , `10', `$9')')
        define(`a3W', `eval(a3OW - (a3OuterMargin * 2))')
        define(`a3H', `eval(a3OH  - (a3OuterMargin * 2))')
        define(`a3IW', `eval(a3W - (2 * a3InnerMargin))')
        define(`a3IH', `eval(a3H - (2 * a3InnerMargin))')
        define(`a3NumHTics', `ifelse(`$6', , `8', `$6')')
        define(`a3NumVTics', `ifelse(`$7', , `6', `$7')')

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
                forloop(`count', 0, eval(a3NumVTics - 1), `
                     `"{\Large 'a3VPosLetter(count)`}"' at (Outside.l.x + labeloffs),((eval(a3NumVTics - 1) - count) * vstep + Inside.b.y + (vstep / 2))
                     `"{\Large 'a3VPosLetter(count)`}"' at (Outside.r.x - labeloffs),((eval(a3NumVTics - 1) - count) * vstep + Inside.b.y + (vstep / 2))
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

                `"\Huge 'dequote(`$2')`"' at Title;
                `"'dequote(ifelse(`$5', , `\today', `$5'))`"' at Date;
                `"'dequote(`$3')`"' at Ref;
                `"'dequote(`$4')`"' at Rev;
                `"\Huge 'dequote(`$1')`"' at SheetNum;
        ] with .Inside.sw at 0,0;
')

`
Gives tic-number of horizontal position in millimetres. Only works if using A3 title block.

Usage: a3HPosOf(hpos)
Params:
        hpos:   horizontal position in millimetres
'
define(`a3HPosOf', `floor($1 / (a3IW / a3NumHTics)) + 1')

divert(0)
