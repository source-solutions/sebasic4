<HTML>
<HEAD/>
<BODY>
<H1 ALIGN="CENTER">Assembly Language Coding Standards</H1>
<P ALIGN="CENTER"><STRONG>Ken Clowes (kclowes@ee.ryerson.ca)</STRONG></P>
<P ALIGN="LEFT"></P>
<BR>

<H2><A NAME="SECTION00010000000000000000">
Contents</A>
</H2>
<!--Table of Contents-->
<UL>
<LI><A NAME="tex2html8"
 HREF="CodingStdAsm.html">Contents</A>
<LI><A NAME="tex2html9"
 HREF="CodingStdAsm.html#SECTION00020000000000000000">Introduction</A>
<LI><A NAME="tex2html10"
 HREF="CodingStdAsm.html#SECTION00030000000000000000">Public Documentation</A>
<LI><A NAME="tex2html11"
 HREF="CodingStdAsm.html#SECTION00040000000000000000">Assembly language coding</A>
<UL>
<LI><A NAME="tex2html12"
 HREF="CodingStdAsm.html#SECTION00041000000000000000">Numbers</A>
<LI><A NAME="tex2html13"
 HREF="CodingStdAsm.html#SECTION00042000000000000000">Symbolic Constants</A>
<LI><A NAME="tex2html14"
 HREF="CodingStdAsm.html#SECTION00043000000000000000">Names</A>
<LI><A NAME="tex2html15"
 HREF="CodingStdAsm.html#SECTION00044000000000000000">Formatting</A>
<LI><A NAME="tex2html16"
 HREF="CodingStdAsm.html#SECTION00045000000000000000">Private implementation comments</A>
<LI><A NAME="tex2html17"
 HREF="CodingStdAsm.html#SECTION00046000000000000000">A simple example</A>
</UL>
<LI><A NAME="tex2html18"
 HREF="CodingStdAsm.html#SECTION00050000000000000000">Organization</A>
<UL>
<LI><A NAME="tex2html19"
 HREF="CodingStdAsm.html#SECTION00051000000000000000">Assembly language code organization</A>
</UL>
<LI><A NAME="tex2html20"
 HREF="CodingStdAsm.html#SECTION00060000000000000000">A Real Example</A>
<LI><A NAME="tex2html21"
 HREF="CodingStdAsm.html#SECTION00070000000000000000">The <TT>asmdoc</TT> tool</A>
<UL>
<LI><A NAME="tex2html22"
 HREF="CodingStdAsm.html#SECTION00071000000000000000">Detailed description of asmdoc tags</A>
</UL>
<LI><A NAME="tex2html23"
 HREF="CodingStdAsm.html#SECTION00080000000000000000">Assembler conventions</A>
<UL>
<LI><A NAME="tex2html24"
 HREF="CodingStdAsm.html#SECTION00081000000000000000">A Structured Assembler</A>
</UL>
<LI><A NAME="tex2html25"
 HREF="CodingStdAsm.html#SECTION00090000000000000000">Bibliography</A>
</UL>
<!--End of Table of Contents-->

<P>

<H1><A NAME="SECTION00020000000000000000">
Introduction</A>
</H1>
This document describes coding standards for assembly language
programs.  While the standards described could be used with any
assembly language, the examples assume the DECUS
variant<A NAME="tex2html1"
 HREF="footnode.html#foot43"><SUP>1</SUP></A> of the
6811 assembly language (i.e. the format used in the third year
microprocessor course--ELE 538--at
Ryerson.)<A NAME="tex2html2"
 HREF="footnode.html#foot280"><SUP>2</SUP></A>  Even more specifically, we describe
writing a library module of functions.

<P>
Some general background to coding standards in any language is
described in ``General Coding Standards''[<A
 HREF="CodingStdAsm.html#Clowes:CodingStdGen">Clo</A>].

<P>

<H1><A NAME="SECTION00030000000000000000">
Public Documentation</A>
</H1>
We use the term <EM>public documentation</EM> to describe the
information a user of a module needs to know about <EM>what</EM> can be
done with the module and <EM>how to use</EM> its features.
Implementation details--<EM>how implementation works</EM>--
should not be public.

<P>
Each source code file is a module containing one or more subroutines.
The entire module should have a public comment describing its overall
use and each subroutine should be described.  We use the convention
that any comment on a line beginning with <TT>;;</TT> is a public
comment.

<P>
For example, suppose a module called <TT>strings.asm</TT> contains
several functions similar to the C functions in the standard
<TT>strings.h</TT> library.  The public documentation could look
something like this using traditional comments.

<P>
<PRE>
;; 
;; The string MODULE contains a collection of string routines
;;
;; The SUBROUTINE strlen determines the length of a null-terminated string...
;;
;; ENTRY CONDITIONS:
;;    Register X -- the starting address of the string
;; 
;; EXIT CONDITIONS:
;;   Accumulator B contains the length of the string
</PRE>
<P>
This informal kind of public comments may be all that is required.
However, I suggest that each subroutine be more formally described
with each of the following features:

<P>
<DL>
<DT><STRONG>Name:</STRONG>
<DD>Obviously every subroutine has a name that should evoke
its meaning.

<P>
<DT><STRONG>Description:</STRONG>
<DD>A brief description of what the subroutine does.

<P>
<DT><STRONG>Parameters:</STRONG>
<DD>What are the parameters to the subroutine and how
  are they passed.

<P>
<DT><STRONG>Return value(s):</STRONG>
<DD>What (if anything) does the subroutine return
  and how does the caller obtain these values.

<P>
<DT><STRONG>Side effects:</STRONG>
<DD>What other side-effects (such as the modification
  of registers or global variables) are done.
</DL>
<P>
I have written a simple script--<EM>asmdoc</EM><A NAME="tex2html4"
 HREF="footnode.html#foot281"><SUP>3</SUP></A>--which extracts these structured comments
and creates a cross-referenced HTML file suitable for Web
viewing.

<P>
Keywords beginning with the <code>@</code> character are used to structure
the comments.  For example, some of the public comments for the
strings module are:

<P>
<PRE>
;; @module strings
;; This module contains a collection of string routines.
;;
;; @name strlen
;; Determines the length of a null-terminated string.  If
;; the string is less than 256 characters in length, the correct
;; length is returned in Accumulator B and the Carry bit in the 
;; Condition Code register is cleared.  Otherwise, 255 is returned
;; and the C bit is set.
;;
;;
;; @param Register X -- the starting address of the string
;; @return AccB -- the length of the string (if less than 256
;;         characters).
;;         &lt;dd&gt;CC -- Carry bit Set if length &gt; 255; else Cleared
;; @side none
;;
;; @name strcpy
;; Copies a null-terminated string.
;;
;; @param X source string
;; @param Y destination string
;; @return nothing
;; @side Registers A, X, Y are modified.
</PRE>
<P>
The <TT>asmdoc</TT> tool converts these to HTML which can be viewed in a
browser; Figure&nbsp;<A HREF="CodingStdAsm.html#fig:ss">1</A> is a screen shot of some of the generated
documentation.

<P>
<BR>
<DIV ALIGN="CENTER"><A NAME="fig:ss">&#160;</A><A NAME="68">&#160;</A>
<TABLE WIDTH="50%">
<CAPTION><STRONG>Figure 1:</STRONG>
Screen shot of formatted documentation</CAPTION>
<TR><TD><IMG
 WIDTH="677" HEIGHT="690"
 SRC="img1.gif"
 ALT="\begin{figure}
\begin{center}
\leavevmode
\epsfysize=6in \epsfbox{figures/ScreenShot.ps} \end{center}\end{figure}"></TD></TR>
</TABLE>
</DIV><BR>
<P>
It is useful to write the public documentation (and generate a more
readable formatted version) before writing code.  Documenting the
interface precisely forces you to think about what you really want the
code to do and you may detect some ambiguities or inconsistencies in
the public specifications.

<P>
For example, the interface to <TT>strlen</TT> is inconsistent with the
one for <TT>strcpy</TT>.  In particular, the <TT>strlen</TT> is
documented as having no side effects (apart of course from the return
values in Accumulator A and the Condition Code register); however,
<TT>strcpy</TT> is documented as modifying the registers A, X and
Y<A NAME="tex2html5"
 HREF="footnode.html#foot282"><SUP>4</SUP></A>.
Once this inconsistency is detected, the programmer should decide
which convention to use and modify the documentation so that all
interfaces are reasonably consistent.

<P>

<H1><A NAME="SECTION00040000000000000000">
Assembly language coding</A>
</H1>
The best programmers are lazy--they want to be able to read, maintain,
modify and ensure the correctness of their software with as little
effort as possible.  Curiously, writing source code that allows the
programmer to be lazy in the future (reading, testing, maintaining)
requires hard work.

<P>
We now examine the nitty-gritty details of writing assembly language
code that is readable, maintainable and safer (than it otherwise would
be) and that allows the programmer to be lazy in the future.

<P>

<H2><A NAME="SECTION00041000000000000000">
Numbers</A>
</H2>
Assembly language programmers are only a small step away from the
bottom level binary machine language that the computer actually
interprets. The machine only ``sees'' bit patterns, but the
assembly language programmer can specify a particular pattern in
various ways.

<P>
Let's consider a simple example.  Suppose the underlying bit pattern
the programmer wishes to express is ``<TT>01000011</TT>''.  This
sequence of bit values can have any number of higher level meanings.
Some possibilities are:
<UL>
<LI>It represents the decimal number <TT>67</TT>.
<LI>It represents the opcode for a machine language instruction.
  For example, we usually think of opcodes in hexadecimal (which is
  how they are described in data sheets) and the 6811 instruction
  <TT>COMA</TT> has the opcode <TT>$43</TT>.

<P>
<LI>It represents the <SMALL>ASCII</SMALL> code for the letter `C'.
<LI>It represents something that the programmer really thinks of as
  a bit pattern; in this case, it can be expressed in
  hexadecimal(<TT>$43</TT>), octal (<TT>0o103</TT>) or binary
(<TT>0b01000011</TT>) notation.
</UL>
<P>
All of the following assembly language instructions generate the
identical machine language code (<TT>$8643</TT>).  However, they
express the bit pattern ``<TT>01000011</TT>'' in different ways that
more closely resemble the programmer's intent and are augmented with
additional private comments that make the intent even more explicit.

<P><PRE>
 ldaa #67         ;expected average percent grade (rounded up)
 ldaa #'C         ;expected average letter grade
 ldaa #$43       ;Opcode for the COMA 6811 instruction
 ldaa #0b01000011 ;DEVfoo cntrl: intrpt, pulse handshake, POS logic
</PRE>

<P>

<H2><A NAME="SECTION00042000000000000000">
Symbolic Constants</A>
</H2>

<P>
The previous examples stress that numbers should be expressed in a
format closest to the programmer's abstract idea of the number.  This
alone, however, is often not sufficient.  Rather, important constants
should be given symbolic names that reflect their meaning.

<P>
As a simple example, the code above should be re-written by first
defining the values of symbolic constants (with meaningful names) as
follows:

<P>
<PRE>
      EXPECTED_AVG_PERCENT_GRADE = 67; (rounded up)
      EXPECTED_AVG_LETTER_GRADE = 'C
      OPCODE_COMA = $43
      INT_ENABLE = 0b01000000
      PULSE_HAND = 0b00000010
      POS_LOGIC  = 0b00000001
      CTRL_IE_POS_PULSE = INT_ENABLE | PULSE_HAND | POS_LOGIC
</PRE>
<P>
The instructions can then be written so that their meaning is
self-evident:

<P>
<PRE>
       ldaa #EXPECTED_AVG_PERCENT_GRADE
       ldaa #EXPECTED_AVG_LETTER_GRADE
       ldaa #OPCODE_COMA
       ldaa #CTRL_IE_POS_PULSE
</PRE>
<P>
Once again, all of these instructions produce the identical machine
language (<TT>$8643</TT>).

<P>
Let's look at this issue from the opposite point of view.  Suppose
that the machine language for a section of code is
<TT>$CC02EEBD7123</TT>.  
The machine language instructions can be disassembled to produce:

<P>
<PRE>
    ldd #$02EE
    jsr $7123
</PRE>
<P>
It is conceivable (though unlikely) that this is what the assembly
language programmer wrote.

<P>
Suppose we also know that the subroutine at address <TT>$7123</TT>
simply delays for the number of bus cycles specified in Accumulator D.
We also assume that the bus speed is 1 MHz (hence a bus cycle lasts 1
<IMG
 WIDTH="12" HEIGHT="24" ALIGN="MIDDLE" BORDER="0"
 SRC="img3.gif"
 ALT="$\mu$">sec).  It is now plausible that the programmer wrote:

<P>
<PRE>
          ; delay for 750 microseconds
      ldd #750
      jsr delay
</PRE>
<P>
The program is now more readable.  It is also safer since the
assembler will figure out the correct address of the <TT>delay</TT>
subroutine.  Had the programmer really written <code>jsr $7123</code>, she
would have to check that the address was correct when any changes were
made to the source code; furthermore, if she mis-typed ``7123'' as
``7132'', the assembler would not detect the error.  With the symbolic
name, no complex address calculations are required and if she had
mis-typed ``delay'' as ``dealy'', the assembler would signal an
``undefined symbol'' error message.

<P>
The remaining problem with the source code is the appearance of the
``magic number'' 750 embedded into an instruction.  To see the
potential for mischief, suppose that 750 is embedded into several
<code>ldd #750</code> instructions and that sometimes 750 means the delay
time in microseconds but on other occasions it represents the hourly
wages in cents (i.e. $7.50/hour) for a hamburger flipper.  If we want
to change all the 750 <IMG
 WIDTH="12" HEIGHT="24" ALIGN="MIDDLE" BORDER="0"
 SRC="img3.gif"
 ALT="$\mu$">sec delays to 800 <IMG
 WIDTH="12" HEIGHT="24" ALIGN="MIDDLE" BORDER="0"
 SRC="img3.gif"
 ALT="$\mu$">sec, we have to be
very careful.  The solution, of course, is to use symbolic constants
as follows:

<P>
<PRE>
      MAC_WAGES = 750 ;units = pennies per hour
      DELAY = 750     ;units = microseconds
         .
         .
      ldd #DELAY
      jsr delay
         .
         .
      ldd #MAC_WAGES
      jsr payMe
         .
         .
      ldd #DELAY
      jsr delay
         .
         .
         .
</PRE>
<P>
It is now very simple to change all the delay times and not change the
restaurant wages by editing a symbol definition.  This makes a
lazy programmer happy (they don't even have to understand the source
code; reading the comments for the symbol definitions is sufficient)
and the modifications are safer.

<P>
But we can do even better.  If the program is to run on a
microprocessor with a 2 MHz bus, all the constants that depend on a 1
MHz bus will have to change.  Once again we can satisfy the lazy
programmer and make modifications more safely with the following:

<P>
<PRE>
      CYCLES_PER_MICRO = 1  
      DELAY_IN_MICROS = 750 ;microseconds
      DELAY_PARAM = CYCLES_PER_MICRO * DELAY_IN_MICROS

      ldd #DELAY_PARAM
      jsr delay
</PRE>
<P>

<H2><A NAME="SECTION00043000000000000000">
Names</A>
</H2>
Assembly language is a symbolic language and a competent programmer
chooses sensible names for constants, subroutines, variables and labels.

<P>
One important aspect of names (especially ones that are exported) is
the possible implementation specific limitations on the length of
names and their case sensitivity.  For example, some assemblers are
case insensitive, but others are not.  Hence it is a good rule of
thumb to avoid names that differ only by the case of letters.  This
rule does not mean that you should use only upper-case or only
lower-case names.  You can and should use different cases as a visual
clue to the reader of the source code.

<P>
Some assemblers or linkers limit the meaningful length of symbols to 8
characters, so it is a good idea (for portability) to ensure that all
symbols are unique in their initial 8 characters<A NAME="tex2html6"
 HREF="footnode.html#foot284"><SUP>5</SUP></A>.

<P>

<H3><A NAME="SECTION00043100000000000000">
Symbolic constants</A>
</H3>
The importance of using symbolic constants instead of embedding magic
numbers into source code has already been discussed.  But what kind of
names should be used?  As always, the most important rules are to use
``common sense'' and be consistent.

<P>
My preference for symbolic constants is to give them clearly
descriptive names using upper-case letters.  For multi-word names, I
prefer using the underscore character (<code>_</code>) to separate the
words.

<P>
In the case of names that are defined by manufacturers' data sheets,
it is preferable to use the established name rather than inventing
your own.  For example, use the name <code>ADCTL</code> for the 6811's A/D
control register rather than something like
<code>AD_CONTROL_REGISTER</code>.

<P>
Note also that in the case of built-in device registers (usually
memory mapped in the memory space starting at $1000 for the 6811),
there are two common ways to address a register: either you can use
the absolute address or use indexed addressing with IX containing the
base address of the register area.  Since indexed addressing is the
most common, my preference for address equates is:

<P>
<PRE>
      REGBAS = $1000            ;Base address of I/O register block
      ADCTL  = $30              ;Offset to the A/D control register
      ADCTL_ABS = REGBAS + ADCTL ;Absolute address of A/D control reg.
      
      ldx #REGBAS
        ;The following two instructions do the same thing:
      staa ADCTL,X     ;indexed addressing ==&gt; 2-bytes, 4 cycles
      staa ADCTL_ABS   ;extended addressing ==&gt; 3-bytes, 4 cycles
</PRE>
<P>

<H3><A NAME="SECTION00043200000000000000">
Subroutine and variable names</A>
</H3>
Subroutines and variables should be given descriptive names; this is
especially important for those that are exported (i.e. are described
in the public documentation of the interface).

<P>
My preference is to use either short lower case names (especially for
subroutines that are similar to standard C library functions such as
<TT>strlen</TT>).  In the case of more obscure subroutines with
multi-word names, I often use upper case to highlight the beginning of
each word (such as <TT>DrawRectangle</TT>).

<P>
Names of subroutines or variables that are meant to be accessed from either
assembly code or higher level languages such as C must begin with an
underscore (<code>_</code>) character.  (For example, the a subroutine named
<code>strlen</code> could not be called from C but one called <code>_strlen</code>
could be.)

<P>

<H3><A NAME="SECTION00043300000000000000">
Labels</A>
</H3>
Labels should be used for the targets of all branch statements.
(i.e. avoid statements with explicit relative addressing such as
<TT>bra&nbsp;.+3</TT>.) 

<P>
The organization of assembly language programs should follow
structured techniques rather than unorganized ``spaghetti code''.  For
example, consider the following pseudo-code design of a program
fragment:

<P>
<PRE>
        #define FOO 5
        if (AccA == FOO) {
           IX++;
           AccB++;
        }
        IY++;
</PRE>
<P>
When translated into assembler, there has to be a conditional branch
around the ``then clause'' and it seems reasonable to label the target
of the branch as ``endif'' as shown below:

<P>
<PRE>
         FOO = 5
         cmpa #FOO
         bne endif
            inx
            incb
      endif:
         iny
</PRE>
<P>
Unfortunately, if there is more than one ``if statement'', the
``endif'' label cannot be re-used.  One way around the problem is to
use labels like ``<code>endif_1</code>'', ``<code>endif_2</code>'' and so on.  For larger
modules, I prepend an abbreviation of the subroutine name obtaining
labels like <code>len_ef1</code>.  It is also permissible, of course, to use
more meaningful labels for branch targets such as ``<code>bad</code>'' or
``<code>oops</code>'' or ``<code>done</code>''. 

<P>

<H2><A NAME="SECTION00044000000000000000">
Formatting</A>
</H2>
Precise standards for formatting are an individual or organizational
choice.  Whatever standards you adopt should aid the reader of the
source code and be applied consistently.  In particular, the mere fact
that your source code is legal does not justify ugly, inconsistent
formatting.  Avoid writing code like:

<P>
<PRE>
    FOO = 5
         cmpa       #FOO
      bne   endif
                   inx
   incb
      endif:iny
</PRE>
<P>
I recommend that you indent code (or use horizontal space) in some
sensible fashion (but avoid tabs, use spaces) and limit the length of
lines to 80 characters or less.

<P>
If you use (x)emacs, you can add the following to the
  <code>~/.emacs</code> file:

<P>
<PRE>
      ; This adds additional extensions which indicate files normally
      ; handled by asm-mode
      (setq auto-mode-alist
            (append '(("\\.asm$"  . asm-mode)
                      )
                    auto-mode-alist))
      ; Use auto-fill-mode (minor mode) in asm-mode
      ; Can be annoying...you may wish to turn it off
      (add-hook 'asm-mode-hook 'turn-on-auto-fill)
      
      ;show line-numbers in the mode-line
      (setq line-number-mode t)
</PRE>
<P>

<H2><A NAME="SECTION00045000000000000000">
Private implementation comments</A>
</H2>
Assembly language has far fewer structured flow control and data
typing features than high level languages do.  Consequently, it is
common for assembly language programs to be commented in far more
detail than a high level language would be.  Remember, however, that
these detailed implementation comments are not meant to be read by
someone who merely wants to use a subroutine you have written.  All
the information they require should be in the public comments.

<P>
Although comments may be quite detailed, keep in mind that they are
only meant to be read by an assembly language programmer who wants to
understand or modify your code.  Do not insult their intelligence with
useless comments like:

<P>
<PRE>
        inca ; Increment Accumulator A by one.
</PRE>
<P>

<H2><A NAME="SECTION00046000000000000000">
A simple example</A>
</H2>
We can put some of the ideas together with a simple example.  Suppose
Accumulator A contains the binary representation of a decimal digit
(i.e. a number between 0-9) and we want to transform it into the
character representation of the digit.

<P>
A straightforward, but poor, way of doing this would be:

<P>
<PRE>
       adda #$30  ;even worse would be adda #48
</PRE>
<P>
Much better, of course (at least if you have been reading carefully)
would be:

<P>
<PRE>
       adda #'0
</PRE>
<P>
However, we should also check that the initial value in Accumulator A
is valid.  We should also specify what to do if it is not valid;
perhaps, we could return the character `?' if the digit were invalid.
We could transform the whole sequence into a subroutine, obtaining:

<P>
<PRE>
      ILLEGAL_DIGIT_RETURN = '?
      digtoa:
             tsta
             bmi bad  ;the digit must be &gt;= 0
             cmpa #9
             bhi bad  ;it also must be &lt;= 9
               adda #'0
               rts
      bad:   ldaa #ILLEGAL_DIGIT_RETURN
             rts
</PRE>
<P>
Of course, public documentation of the <TT>digtoa</TT> subroutine
interface should have been written first, but we leave this as an
exercise.

<P>

<H1><A NAME="SECTION00050000000000000000">
Organization</A>
</H1>
Each project should have its own directory.  The directory should
always contain a <TT>README</TT> file that briefly describes what the
project is about and the important files in the directory.

<P>
There should also be a <TT>Makefile</TT>.  Normally, the default
target for <TT>make</TT> should create any object modules or
<TT>.s19</TT> files and documentation files required by the user.

<P>
Other common targets are:
<DL>
<DT><STRONG>clean:</STRONG>
<DD>Removes generated files.
<P>
<DT><STRONG>doc:</STRONG>
<DD>Creates documentation files.

<P>
<DT><STRONG>archive:</STRONG>
<DD>Creates an archive of source files.

<P>
<DT><STRONG>test:</STRONG>
<DD>Runs tests on the software.
</DL>
<P>

<H2><A NAME="SECTION00051000000000000000">
Assembly language code organization</A>
</H2>

<P>
Modern assemblers and linkers allow the programmer to be less
concerned with the absolute address of entities when writing their
programs and allow allow logically distinct portions of the assembly
code to be organized into distinct <EM>areas</EM> or <EM>segments</EM>
that the linker can deal with.

<P>
For example, I tend to organize even the most trivial program into at
least two sections: one for code and another for data.
A general template (excluding public comments) looks like:

<P>
<DIV><BR><P><BR><TT>; Symbolic constants <BR>         <EM>definitions of symbol constants go here</EM><BR></TT><BR><P><BR><TT>.area DATA<BR>         <EM>variables go here</EM><BR></TT><BR><P><BR><TT>.area _CODE<BR>         <EM>actual instructions go here</EM><BR></TT></DIV>
<P>
One advantage of doing this (even in trivial programs) is that you can
set the actual absolute address of each of the segments at link time.
On simple programs, I often set the start of the data area to $6000
and the start of the code area to $6200.  By placing important
variables at the beginning of the data segment, I can view many of
them just by examining a memory dump of $6000-$6010.

<P>
Another advantage is the ability to intermix <TT>.area&nbsp;DATA</TT> and
<TT>.area&nbsp;_CODE</TT> directives.  For example, if you have several
subroutines where some use global memory references common to all of
them and some also use static references that are private, you can
write code like:

<P>
<DIV><TT>.area DATA<BR>         <EM>common variables go here</EM><BR></TT><BR><P><BR><TT>;foo starts here...<BR>        .area DATA<BR>         <EM>foo variables go here</EM><BR></TT><BR><P><BR><TT>.area _CODE ;for the foo routine<BR>     foo:<BR>         <EM>actual instructions for "foo'' go here</EM><BR></TT><BR><P><BR><TT>;bar starts here...<BR>        .area DATA<BR>         <EM>bar variables go here</EM><BR></TT><BR><P><BR><TT>.area _CODE ;for the bar routine<BR>     bar:<BR>         <EM>actual instructions for "bar'' go here</EM><BR></TT></DIV>
<P>

<H1><A NAME="SECTION00060000000000000000">
A Real Example</A>
</H1>

<P>
I have written a real example illustrating many of the points
discussed here.  This example also illustrates the use of makefiles
and how to test software.

<P>
The example is self-documenting.  To obtain a copy and try it out do
the following:

<P>
<DL COMPACT>
<DT>1.
<DD>Create a new directory and change to it.  (For example
<code>mkdir coding; cd coding</code>.)

<P>
<DT>2.
<DD>Copy the example archive and unpack it with the commands:
<PRE>
       cp ~kclowes/public/CodStdEx.tgz .
       zcat CodStdEx.tgz | tar xvf -
</PRE>
<P>
<DT>3.
<DD>Use Netscape to examine the directory you are in.  Click on the
  file called <TT>README</TT> and read it.

<P>
<DT>4.
<DD>In the shell, invoke the command <TT>make</TT>.

<P>
<DT>5.
<DD>Hit the <EM>reload</EM> button in Netscape to see the new
  directory listing.

<P>
<DT>6.
<DD>There are lots more files now.  Browse some of them (especially
  the <TT>.html</TT> ones; a good starting point is <TT>test1.html</TT>.)
  
<DT>7.
<DD>Once you get the general idea of what is going on (but before
  your eyes glaze over), run the command <code>make ex</code> in the shell,
  read the newly created file <TT>exercises.html</TT> and do what you
  can...
</DL>
<P>

<P>

<H1><A NAME="SECTION00070000000000000000">&#160;</A>
<A NAME="asmdocAppen">&#160;</A><BR>
The <TT>asmdoc</TT> tool
</H1>

<P>
The <TT>asmdoc</TT> tool is a simple little program (actually a perl
script) that translates public comments as described here into
formatted and cross-referenced HTML files.  

<P>
To use <TT>asmdoc</TT>, add public comments to an assembly language
file, say <TT>foo.asm</TT> and invoke the command
<TT>asmdoc&nbsp;foo.asm</TT>. A HTML file with the same base name
(<TT>foo.html</TT> in this case) will be generated and can be viewed
with a browser such as Netscape.

<P>
All public comments must be on lines that begin with two semi-colons
(;;).

<P>
Some special tags are used and begin with the <code>@</code> character.  In
particular, the first public comment should be:

<P>
<PRE>
;;  @module Your_module_name
</PRE>
<P>
Until the next special tag word (one starting with @), the following
public comments are basically treated as paragraphs; a
blank public comment line separates paragraphs.  For example:

<P>
<PRE>
;;This is the beginning of a paragraph. Here is the second
;;sentence. &lt;B&gt;Boring&lt;/B&gt; stuff...but the next paragraphs are elegant.
;;
;;Fourscore and seven years ago our fathers brought forth on this
;;continent a new nation, conceived in liberty and dedicated to the
;;proposition that all men are created equal.
;;
;;Now we are engaged in a great civil war, testing whether that nation
;;or any nation so conceived and so dedicated can long endure. We are
</PRE>
<P>
The HTML browser will reformat the paragraphs so that they are
justified on the screen so don't worry too much about the visual
formatting of the comments in the source code.  If you know HTML, you
can add your own HTML directives.  For example, the
<code>&lt;B&gt;Boring&lt;/B&gt;</code> uses HTML markup commands to display the word
``Boring'' in bold.

<P>
While you can add any paragraphs you want after the <code>@module</code> tag
(even the Gettysburg Address), you should write zero or more
paragraphs that describe the module in general terms.

<P>
You can also use other special tags like <code>@version</code>,
<code>@author</code> and <code>@example</code>.  (see below for their precise
meanings) in the module section if you wish.

<P>
Following the module section, each public subroutine should be
described.  The public documentation of a subroutine must begin with
the special tag <code>@name</code> followed by the name of the subroutine
being documented.  For example:

<P>
<PRE>
;;  @name strlen
</PRE>
<P>
You can then include any number of free form paragraphs that describe
the subroutine.  The very first sentence should be short and will be
used in the summary section that <TT>asmdoc</TT> generates to briefly
describe each documented subroutine and provide a link to the detailed
documentation.  Consequently, there must be at least one sentence
following a <code>@name</code> tag.

<P>
Following the general description of the subroutine you should use the
<code>@param</code> tag for each (if any) parameters passed to the routine.
Next, the way any results are returned should be described with the
<code>@return</code> tag.  If there are any additional side effects (such as
the modification of other registers or global variables), they should
be commented with the <code>@side</code> tag.

<P>
You may also want to include examples of use; use the <code>@example</code>
tag to introduce them.  Since examples usually include a few lines of
assembly that we do not wish the browser to format these lines as a
paragraph.  The HTML ``pre'' directive (for pre-formatted) tells the
browser to render the lines between the <code>&lt;PRE&gt;</code> and <code>&lt;/PRE&gt;</code>
exactly as you typed them.  (Of course, <TT>asmdoc</TT> will remove
the leading semi-colons.)  For example:

<P>
<PRE>
;; @example
;; The following shows an elementary use of strlen.
;; &lt;PRE&gt;
;; msg: .asciz "Hello world";
;;    ....
;;    ldx #msg
;;    jsr strlen ;on return B &lt;-- 11; Carry is clear
;;    bcs tooBig
;; &lt;/PRE&gt;
</PRE>
<P>

<H2><A NAME="SECTION00071000000000000000">
Detailed description of asmdoc tags</A>
</H2>

<P>
<DL>
<DT><STRONG>@module:</STRONG>
<DD>The module tag is required.  There must be only one in
the source code file and it must appear on the first public comment
  line. The syntax for it use is:

<P>
<DIV><TT>;;     @module <EM>module_name</EM><BR>      <EM>Followed by paragraphs describing the module</EM><BR>      <EM>and possibly with the tags: @version, @author, @example</EM><BR>      <EM>The module section ends with the first @name tag.</EM><BR></TT></DIV>  
<DT><STRONG>@name:</STRONG>
<DD>Every documented subroutine begins with the
  <TT>@name</TT> tag:

<P>
<DIV><TT>;; @name <EM>subroutine_name</EM><BR>      <EM>Description follows...</EM><BR>  </TT></DIV><DT><STRONG>@version:</STRONG>
<DD>If used, there should only be one <TT>@version</TT>
  tag and it should be in the module section:

<P>
<DIV><TT>;; @version <EM>version_name</EM><BR>  </TT></DIV>
<P>
<DT><STRONG>@param:</STRONG>
<DD>Each parameter is described with this tag:

<P>
<DIV><TT>;; @param <EM>name and description for first parameter</EM><BR>    ;; @param <EM>name and description for second parameter</EM><BR>              <EM>etc....</EM><BR>  </TT></DIV>
<P>
<DT><STRONG>@since:</STRONG>
<DD><DT><STRONG>@author:</STRONG>
<DD><DT><STRONG>@return:</STRONG>
<DD><DT><STRONG>@side:</STRONG>
<DD><DT><STRONG>@example:</STRONG>
<DD></DL>
<H1><A NAME="SECTION00080000000000000000">&#160;</A>
<A NAME="smartAppen">&#160;</A><BR>
Assembler conventions
</H1>
There are several different syntaxes for assemblers.  Most of the
differences involve assembler directives.

<P>
Table&nbsp;<A HREF="CodingStdAsm.html#table:asmConv">1</A> shows some of the differences between the
DECUS and Motorola assemblers commonly used at Ryerson.

<P>
<BR>
<DIV ALIGN="CENTER"><A NAME="231">&#160;</A>
<TABLE>
<CAPTION><STRONG>Table 1:</STRONG>
Different assembler conventions</CAPTION>
<TR><TD>
  <DIV ALIGN="CENTER">
<TABLE CELLPADDING=3 BORDER="1" ALIGN="CENTER">
<TR><TD ALIGN="LEFT"><EM><B> <>Directive</B> </EM></></TD>
<TD ALIGN="CENTER"><TT><B> <>DECUS example</B> </TT></></TD>
<TD ALIGN="CENTER"><TT><B> <>Motorola example</B></TT></></TD>
</TR>
<TR><TD ALIGN="LEFT"><EM> 
      
      Equates </EM></TD>
<TD ALIGN="CENTER"><TT> FOO = 123 </TT></TD>
<TD ALIGN="CENTER"><TT> FOO EQU 123</TT></TD>
</TR>
<TR><TD ALIGN="LEFT"><EM> 
      
      Hex numbers </EM></TD>
<TD ALIGN="CENTER"><TT> $1A </TT></TD>
<TD ALIGN="CENTER"><TT> $1A</TT></TD>
</TR>
<TR><TD ALIGN="LEFT"><EM> 
      
      Defining bytes </EM></TD>
<TD ALIGN="CENTER"><TT> .db 123 </TT></TD>
<TD ALIGN="CENTER"><TT> FCB 123</TT></TD>
</TR>
<TR><TD ALIGN="LEFT"><EM> 
      
      Defining words </EM></TD>
<TD ALIGN="CENTER"><TT> .dw 123 </TT></TD>
<TD ALIGN="CENTER"><TT> FDB 123</TT></TD>
</TR>
<TR><TD ALIGN="LEFT"><EM> 
      
      Reserving bytes </EM></TD>
<TD ALIGN="CENTER"><TT> .ds 5 </TT></TD>
<TD ALIGN="CENTER"><TT> RMB 5</TT></TD>
</TR>
</TABLE>    
    <A NAME="table:asmConv">&#160;</A>    
  </DIV></TD></TR>
</TABLE>
</DIV><BR>
<P>
It should not be too difficult to write a text transformation program
to convert from one style to another.  Any volunteers?

<P>

<H2><A NAME="SECTION00081000000000000000">
A Structured Assembler</A>
</H2>
Traditional assemblers differ in conventions, but I believe a
<EM>structured assembler</EM> could make the assembly-language
programmer's life easier.

<P>
One aspect of most assembly languages I am aware of is the lack of
support for structured flow control.  This seems to be the ``natural''
consequence of the lack of this feature at the machine language level;
at this level the only way to change the program counter from its
default behavior is with the conditional or unconditional ``goto''
mechanism.  But this basic fact does <EM>not</EM> imply that assembly
language programs should be designed using unstructured flow control
nor that an assembly language cannot offer some help for such designs.
Let me be absolutely clear that the resulting assembly syntax is still
assembler: every syntactical convention of a traditional assembler is
still available and every line of source code translates into a single
machine language instruction or traditional assembler directive or
label.  It is an assembler, <EM>not</EM> a very primitive high-level
language.

<P>
I have not yet written this kind of structured assembler (but I hope a
student may consider the implementation for a senior project).

<P>
I can briefly explain the concept with some simple examples.

<P>
Consider first the simplest structured flow control statement: the
<EM>if statement</EM>.  We might design in pseudo-C something like:

<P>
<PRE>
  #define FOO 5
  if (AccA == FOO) {
     RegX++;
     AccB++;
  }
  RegY++;
</PRE>
<P>
This can be translated into assembler:

<P>
<PRE>
   FOO = 5
   cmpa #FOO
   bne endif
      inx
      incb
endif:
   iny
</PRE>
<P>
The translation is straightforward <EM>except</EM> for coming up with
the label <TT>endif</TT>.  (Sure, some assemblers allow local target
label names that can be reused.  While this is better than nothing,
the syntax is often obscure and the fundamental problem of forcing the
programmer to come with a label is not addressed.)

<P>
With a structured assembler, the assembly language code would be:

<P>
<PRE>
   FOO = 5
   cmpa #FOO
   if == {
      inx
      incb
   }
   iny
</PRE>
<P>
In this case the curly braces delimit the extent of the ``then
clause''.  The programmer, however, is relieved of the task of
generating a label for the first instruction following the
then-clause; the structured assembler will do this for her.

<P>
There are two other advantages:
<DL COMPACT>
<DT>1.
<DD>The ``sense'' of the original design is maintained.  The
structured assembler will translate the <TT>if ==</TT> instruction
  into the machine instruction corresponding to <TT>bne&nbsp;endif</TT>.

<P>
<DT>2.
<DD>The use of braces also allows clear indentation (possibly
  automatic) to increase the readability of the code.
</DL>
<P>
Let's now consider the next more complex flow control structure--the
<EM>if...else</EM> structure.  The pseudo-C design is:

<P>
<PRE>
  #define FOO 5
  if (AccA == FOO) {
     RegX++;
  } else {
     AccB++;
  }
  RegY++;
</PRE>
<P>
The traditional assembler implementation is:

<P>
<PRE>
   FOO = 5
   cmpa #FOO
   bne else
      inx
      bra endif
else:
      incb
endif:
   iny
</PRE>
<P>
With a structured assembler, we would write:

<P>
<PRE>
   FOO = 5
   cmpa #FOO
   if == {
      inx
   } else {
      incb
   }
   iny
</PRE>
<P>
Once again, the transformation from the structured syntax to
traditional forms is straightforward with labels added for the
beginning of the ``else clause'' and the continuation following the
``endif''.  Note that it is still assembler with one machine
instruction per assembler instruction; as before, the <TT>if&nbsp;==</TT>
structured instruction is transformed to a <TT>bne else</TT>
traditional instruction. Of course, there also has to be an
unconditional branch around the ``else'' part at the end of the
``then'' clause.  In effect, the structured instruction
<code>} else{</code> is transformed into the necessary branch.

<P>
<DIV><TT>clra<BR>while ( cc ) {         ;<EM>translated to</EM> bcs endWhile<BR>   ldx #"Hello"       ;<EM>read-only static string created</EM><BR>   putstr()             ;<EM>translated to</EM> jsr putstr<BR>   inca<BR>}                      ;<EM>translated to</EM> bra ... <EM>and endWhile label added</EM><BR></TT></DIV>
<P>
One advantage of using <TT>putstr()</TT> instead of
<TT>jsr&nbsp;putstr</TT> is the ability to translate the line either into a
<TT>jsr</TT> instruction or to expand it in-line (with flags in the
assembler or with pragmas).

<P>

<H2><A NAME="SECTIONREF">Bibliography</A>
</H2>
<DL COMPACT><DD><P></P><DT><A NAME="Clowes:CodingStdGen"><STRONG>Clo</STRONG></A>
<DD>
Ken Clowes.
<BR><EM>General Coding Standards</EM>.
<BR>file: <TT>CodingStdGen.ps</TT>.
</DL>

<P>

<H1><A NAME="SECTION000100000000000000000">
  About this document ... </A>
</H1> 
 <STRONG>Assembly Language Coding Standards</STRONG><P>
This document was generated using the
<A HREF="http://www-dsed.llnl.gov/files/programs/unix/latex2html/manual/"><STRONG>LaTeX</STRONG>2<tt>HTML</tt></A> translator Version 98.1p1 release (March 2nd, 1998)
<P>
Copyright &#169; 1993, 1994, 1995, 1996, 1997,
<A HREF="http://cbl.leeds.ac.uk/nikos/personal.html">Nikos Drakos</A>, 
Computer Based Learning Unit, University of Leeds.
<P>
The command line arguments were: <BR>
 <STRONG>latex2html</STRONG> <tt>-split 1 CodingStdAsm.tex</tt>.
<P>
The translation was initiated by Ken Clowes on 2000-11-11<HR>
<ADDRESS>
<I>Ken Clowes</I>
<BR><I>2000-11-11</I>
</ADDRESS>
</BODY>
</HTML>
