# eschpic
IEC Electrical drawing system based on m4/dpic/TikZ/LaTeX

Inspired by J. D. Aplevich's excellent [Circuit_macros
package](https://ece.uwaterloo.ca/~aplevich/Circuit_macros/). Eschpic
also makes use of Aplevich's interpreter of Kernighan's Pic language,
[dpic](https://ece.uwaterloo.ca/~aplevich/dpic/), which has some useful
extensions over the GNU version.

Although it's based on similar technology (pic/m4/TikZ/LaTeX), eschpic
is rather different to Circuit_macros:
 - Targeted at IEC-style electrical drawings for industrial and
   automation purposes, rather than EEs
 - Produces an entire standalone document, with titleblocks etc.
 - (Somewhat) simpler syntax and drawing style, with self-describing
   key-value parameters

## Features
 - Handles wire references automatically; use hyperref package to allow
   following them between sheets
 - Variety of pre-existing IEC symbols; extensive and customisable
   generic "contacts" macro for automatically drawing
   pushbuttons/selector switches/contactors/relays/isolators etc.
 - Follows pic and Circuit_macros drawing style, by automatically moving
   current drawing position and direction to end of previous component
   or wire.
 - However, tries to maintain conventional electrical drawing component
   orientation (whether vertical or horizontal), so e.g. contact symbols
   are always drawn the "right" way up.
 - wireGroup() macro to easily draw and label multiple wires at
   consistent spacing and orientation without having to describe their
   paths individually; wires always kept in top-to-bottom, left-to-right
   order
 - Automatic generation of a Bill of Materials table at the end of the
   document, if part numbers for each component are given. Hyperref is
   used to navigate to the component by clicking from the BOM table.

## Documentation
Documentation is currently lacking, although reasonable parameter
descriptions are provided for each macro inside the m4 files. For now,
look at the testdoc.m4 file to see an example.

## Use
The repository is already set up with a makefile and example drawing
(testdoc.m4) to try out. It demonstrates a couple of key features,
including wire referencing, labelling and the Bill of Materials table.

Ensure the following is installed:
 - m4
 - LaTeX (pdflatex)
 - TikZ
 - dpic

Simply typing "make" should produce a PDF file. You may need to run it
again to update wire references/locations after the first pass.
