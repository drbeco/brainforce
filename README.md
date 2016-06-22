Brain Force Compiler
====================

An Esoteric Programming Language
--------------------------------

> &nbsp;&nbsp;&nbsp;&nbsp; The BrainForce Compiler was created by me to attend the necessity
of the great community that prefer the simplicity of the BF-like
programming languages. Untill now that community had no compiler to do
the job in a nice, professional way.

> &nbsp;&nbsp;&nbsp;&nbsp; The BF compiler have some options to tweek how the compiler will
handle various indetermined aspects regarding the language definition,
specially when talking about wrapping around cell values or the pointer,
and these options can also be seeing as an output of an C-Language
translated from ".bf" source code.

> &nbsp;&nbsp;&nbsp;&nbsp; It's easy to see the differences between all that options when you
can see the differences directly in a C code. Besides it's usabillity,
it was developed to be quiet (-q option) so to be used anywhere, even
being called by other applications or GUI's. All options can be given
directly by the command line.

> &nbsp;&nbsp;&nbsp;&nbsp; There is also special treatment if you want your target program to
be iterative, or to read/write streams from file. With the '-i' option,
you can make your program more userfriendly to get input from user
(keyboard). The must is that this switch can be exported to your target
code, making your own program to respond accordingly to the -i switch.
All that and add: it's portable, it's free released under GNU/GPL
License, generates binary output for all architectures (using external
gcc plugin), generates ASM (intel and AT&T syntax).

> &nbsp;&nbsp;&nbsp;&nbsp; All that and more in the documentation page.

>> &nbsp;&nbsp;&nbsp;&nbsp; My best regards,

>> &nbsp;&nbsp;&nbsp;&nbsp; Prof. Dr. Ruben Carlo Benante

---


Index
-----

[Usage](#usage)

[Options](#options)

-   [Compiler Options](#compiler-options:)
-   [Code generation Options](#code_generation_options:)
-   [Run-time Options](#Runtime_options:)

[Notes](#Notes)

[Description of the Brain Force
language](#Description_of_the_Brain_Force_language)

-   [Extension of the language](#Extension_of_the_language:)
-   [Future extensions](#Future_extensions:)

[Downloads](#Downloads)

[Bugs](#Bugs)

[Log](#Log)

[Author](#Author)

---

Usage
-----

    brainforce input-file -o output-file [options]

### Options

### Compiler options:

| flag  | description  |
|---    |---           |
| -y | Print the syntax tree of the input_file.<br> This is the structure of the syntax parse tree made by bison/yacc |
| -v | Verbosity mode. Can pile up till level 10. |
| -q | Quiety mode. Success/failure is reported in $? or ERRORLEVEL. |
| -o output-file | Output file name. |
| -g | Generate binary file with debug symbols to be used with gdb. |
| -cw | Show warranty. |
| -c[c] | Show copying license. |
| -h | Print this help.<br>-v -h for advanced help.<br>-vv for expert help.<br>-vv... for debug information. |

### Code generation options:

| flag  | usage | description  |
|---    |---    |---           |
| -E    | | (not implemented) stop after gcc preprocessor and write output_file.i. |
| -S [syntax] | | stop after gcc assembler and write output_file.s in the selected syntax. |
|       | [-S [att]] | (default) %% prefix regs, addresses use (), op order src->dst, etc. |
|       | -S intel | keywords for data size, addresses use [], op order dst<-src, etc. |
| -C    | | stop after native C generator and write output_file.c. |
| -K    | | keep intermediate C source code output_file.c. |
| -B    | | (default) compile and write output_file.bin. |

> If none is given, outputs executable binary (depends on existing GCC in the PATH).

### Runtime options:

| flag  | usage | description  |
|---    |---    |---           |
| -z opt | | Minimum and maximum value of a cell. Options are: |
| | -z n,m | n=minimum (>= 0), m=maximum (<= UINTMAX) and n<m <br> The maximum value may change with architecture, <br> being it the size of an unsigned int minus 1 (usually 4 bytes). <br> Unless told otherwise explicitaly by -t we have: <br> -   if m<=UCHARMAX set -t uchar <br> -   if UCHARMAX<m<=USHORTMAX set -t ushort <br> -   if m>USHORTMAX set -t uint |
| | -z bit | Same as -z 0,1 |
| | -z print | Same as -z 32,126 (ASCII printable). <br> Nice print if used with -p uchar or -p both, and -r on |
| | -z number | Same as -z 48,57  (ASCII '0' to '9') |
| | -z letter | Same as -z 65,90  (ASCII 'A' to 'Z') |
| | [-z uchar] | (default) Same as -z 0,UCHARMAX |
| |-z ushort | Same as -z 0,USHORTMAX. <br> Set -t ushort, unless told otherwise explicitaly by -t |
| | -z uint | Same as -z 0,UINTMAX (\~ 4 billions). <br> Set -t uint, unless told otherwise explicitaly by -t |
| | | If -r on or -r off is used, it is useful to read warnings given by verbosity level 1 or more (-v) |
| -t type | | Type of array. The type of array must hold the range of values set by -z options. <br> (This values are architecture dependent.) <br> Type is one of: |
| | [-t uchar] | (default) In the interval of [0, UCHARMAX] \(1 byte) |
| | -t ushort | In the interval of [0, USHORTMAX] \(2 bytes) |
| | -t uint | In the interval of [0, UINTMAX] \(4 bytes) |
| -a n | | (default) -a USHORTMAX+1. Array size (quantity of cells), n=[1,USHORTMAX+1] <br> The pointer is type ushort unless: <br> -a UCHARMAX+1 or less is used, and -w none the pointer is made uchar. <br> -a UCHARMAX or less is used, and -w on/off, the pointer is made uchar. <br> See -w to understand the proprierties of sizes UCHARMAX+1 and USHORTMAX+1 |
| -# [n] | | Debug mode on: interpret # command to dump array. |
| | [-# 0] | (default) Debug mode off, ignore all #'s in resulted C source and compiled binary. |
| | -# 1 | Debug mode off, ignore all #'s in the resulted binary, but show it as comments in C source. |
| | -# | Same as -# 11, debug mode on with 11 cells dump. |
| | -# n | n=[3, 5, 7, 9, 13, ... 99] debug mode on with n cells dump. |
| | | Debug mode on: interpret # command to dump array is better if set together with -p both. |
| -r wrap | | Set option for wrapping around cell values when they reach a limit. <br> Wrap can be: |
| | -r on | Causes wrap around if cell overflow or underflow. |
| | -r off | Causes error if cell overflow or underflow. |
| | [-r none] | (default) Do not check bounds. Be careful: bounds depends on type size of the target machine. <br> If -r is not given, [-r none] is the default. Cell maximum and minimum values are set by **-z option** <br> Not checking bounds around the limits of the types produces better code <br> (see options -z uchar, -z ushort or -z uint) <br> Unlike -w, where -a option is checked, -r don't auto check -z (or -t). <br> That means that if you set -r on or -r off,  and set for example -z 200,255, overflow errors <br> cannot be checked! That is because cell will wrap to 0 before check, and then leaving <br> the cell with an invalid value (zero). The same goes to -z 0,100, for example, and underflow error. <br> Suggestion: use a bigger type to hold a number outside the chosen range, so checks can occurr. <br> Example: <br> -   To have -z n,UCHARMAX  and -r on/off, set -t ushort <br> -   To have -z n,USHORTMAX -r on/off, set -t uint <br> -   Don't worry about -z uint, it's guaranteed to work, because UINTMAX is one less than the full type. |
| -w wrap | | Set option for wrapping around the pointer when it reachs any limit. <br> If -w is not given, [-w none] is the default. <br> Pointer maximum limit is (n-1) set by -a n. Minimum is allways cell number 0. <br> Wrap can be: |
| | -w on | Causes wrap around if pointer overflow or underflow <br> If array size (-a) is UCHARMAX or USHORTMAX, see -w none to create simple code. <br> With -w on conditionals are written to check bounds <br> Conditional used : if(pointer\>=MAX). Both underflow or overflow might have happen. <br> If MAX is unreacheble by pointer, wrap occurr before the test. <br> In this case, use -w none to wipe unnecessary code. <br> With -a n and: <br> - 1\<=n\<=UCHARMAX, pointer is type uchar. <br> - UCHARMAX+1\<n\<=USHORTMAX+1, pointer is type ushort. <br> - Pointers cannot be uint. |
| | -w off | Causes (controled) error if pointer overflow or underflow. <br> Need conditionals to test for bounds <br> Maximum array size for this option is -a USHORTMAX <br> (the last number is used as overflow/underflow error code) <br> Conditional used : if(i>=MAX), for underflow or overflow. <br> MAX cannot be unreacheble by the pointer to guarantee the desired behavior. <br> With -a n and: <br> - 1<=n<=UCHARMAX, pointer is type uchar. <br> - UCHARMAX+1<n<=USHORTMAX+1, pointer is type ushort. <br> - Pointers cannot be uint. |
| | [-w none] | (default) Do not check for limis. Creates simpler code <br> WARNING! If -a is not UCHARMAX+1 or USHORTMA+1, the pointer can raise <br> real Segmentation Fault errors depending on the BrainForce user source code! <br> How nice: If -a is set to those magic numbers, overflow/underflow just wraps around like -w on |
| | -w expand | (not implemented) If pointer reaches the right limit, redimension <br> array, till it gets the maximum size (or the memory is over). <br> When it cannot allocates more memory, it becomes -w off. |
| -p style | | Set how to print and read. <br> Style can be: |
| | -p uchar | Uses putc() and getc() |
| | -p uint | (default) uses printf("%d") and scanf("%d") |
| | -p both | uses printf("%c %d") and scanf("%c %d") (or scanf("%d") if iterative
mode on -- see -i on) |
|-i [opt] | Iterative mode, set input/output from/to file or iterativelly (keyboard/monitor). <br> Options are: |
| | -i on | Read/write from keyboard/screen. <br> Uses ungetc(), or simplified scanf("%d"), depending on -p |
| | -i off | (default) read/write from/to file. Its necessary to use <br> redirection symbols '<' and '>' from SO command line. <br> Match getc()/putc() or scanf()/printf() (see -p) |
| | -i switch | The compiled program inherit '-i' switch to chose from command line
before each execution. <br> Set argc/argv to read the switch that changes mode. <br> So after compiling a test.bf, lets say: <br> `$brainforce test.bf -o test.exe -i switch` <br> One can run test.exe in both forms: <br> - read/write simplified mode (from/to file): `$test.exe` <br> - read/write iteratively (from/to keyboard/screen): `$test.exe -i` |
| -e | | Simplified source code (good to use with -S), disable read/write
functions. <br> Also set -z ushort, -t ushort, -a USHORTMAX+1, debug mode off -# 0, <br> -r none, -w none, -p uchar, -i off. <br> Its incompatible with any other runtime option. |

### Notes

(\*) This values may change depending on the architecture. The
BrainForce compiler tries to not hold on that, but there was no test.
 The values used in the host machine are:

-   UCHARMAX 255
-   USHORTMAX 65535
-   UINTMAX 0xFFFFFFFE

If some problems wrapping occurr, a sugestion is to change this values
according to the machine in use. UCHARMAX is usually one byte long. If
the byte of the machine is not 8 bits, or if char is more than 1 byte,
the value must be the maximum that unsigned char can hold on that
machine. The same goes to USHORTMAX, as the maximum for unsigned short.
But UINTMAX is set to 1 less than the maximum value that the type can
hold. In the host machine, int is 4 bytes, maximum value is 0xFFFFFFFF,
but value set is 0xFFFFFFFE, that is because 1 unit is needed to check
bounds by -r on/off.

---

Description of the Brain Force language
---------------------------------------

Brain Force complains with the [language
definition](http://en.wikipedia.org/wiki/Brainfuck) by Urban Mueller. It
the most simple language capable of executing all Turing class of
algorithms (that is: its Turing-Complete). The language consists in only
8 commands, that manipulate to data: a pointer to a tape composed of
theorically infinity number of cells, each of one holding a symbol
(meaning here a numerical code that represents a symbol). The
implementation limits the tape to have at maximum USHORTMAX cells (65535
for a machine with a short type of 2 bytes), and the values of cells any
positive number from 0 to UINTMAX-1 (more than 4 billions).

The 8 commands can be summarized in this table:

| Command | Effect | Equivalent in C | BrainForce Compiler switch that affect the command |
| --- | --- | --- | --- |
| + | Increases element under pointer | t[i]++; | -z to chose the minimu/maximum value of the cell |
| | | | -t to chose the type of the array |
| | | | -r to wrap around, cause errors, or don't check |
| - | Decrases element under pointer | t[i]--; | Same as + |
| > | Increases the pointer (move it to the right) | i++; | -a to chose the maximum value of the pointer
| | | | -w to wrap around, cause errors, or don't check |
| < | Decreases the pointer (move it to the left) | i--; | Same as `>` |
| [ | Starts a loop if the value under the pointer is not zero | while(t[i]) { | Can be made while(t[i]!=ZMIN) if minimum chosen by -z is different of zero |
| ] | Loop back to the begginning of the loop | } | |
| . | Print the cell value under the pointer | putchar(t[i]) | -p to print decimal values instead of characters, or both |
| | | | -i to print newlines in iterative mode
| , | Read a value from the standard input and saves it in the cell under the pointer | getchar(t[i]) | -p to read decimal values instead of characters |
| | | |-i to read from file when iterative mode is off |

### Extension of the language:

-   Debug mode: Besides this 8 commands, Brain Force ignores all other
    characters. But there is a exception of the debug character # that
    can be used to dump a number of cells around the pointer at a given
    time. If debug mode is on (see -#) BF will not ignore #'s.

#### Future extensions:

-   Procedure Brain: There are also some other characters for future
    release, to care of the pbrain language extension (procedure brain),
    as described [here](http://www.parkscomputing.com/code/pbrain/). It
    uses '(' and ')' to open, close a procedure (function) that can be
    called by the function call command ':'. The procedure 'name' (or
    reference) is the cell value at the time of '(', and the procedure
    call will call the cell value procedure, or give an undefined
    procedure if none is find under that 'name'.
-   Save to File: symbol to save '!' and to read '?' the complete tape
    to/from file.
-   Quit: As a good Turing Machine, it may be able to stop processing
    and exit SUCCESS or FAILURE (the exit code being the one under the
    pointer). The symbol to quit would be '='.
-   Repeat Macro: A macro for preprocessing numbers before symbols to
    repeat them. So to subtract 3 from the current cell, you should be
    able to write '3-' that would be expanded in the preprocessing phase
    to '---'.

---

Downloads
---------

Release 1: the first release is not available right now, but it had lots
of bugs and limited options anyway. Don't worry about that. I'll put it
here soon, just for the record.

Release 2:

-   [The Complete Package
    R-2.1](http://www.beco.cc/downloads/brainforce-r2-1.zip): contain
    all source codes, instructions on how to compile, and a binary
    version for ubuntu 64bits and windows. Small bug fix from R-2.\
-   [The Linux Package
    R-2](http://www.beco.cc/downloads/brainforce-r2.zip): contain all
    source codes, instructions on how to compile, and a binary version
    for ubuntu 64bits.
-   The Windows Package: just get the complete package.

---

Bugs
----

The language was all written using the powerfull tools flex/bison
(lex/yacc gnu compatibles). The compiler raises errors during the
compilation time alerting problems with unbalanced brackets, and nothing
else (as it ignores all chars, and all commands are single char, there
is not much syntax error beside that).

As for today there is no know bugs, but you are welcome to test and send
bug reports. Be brave and do beta-test on the Brain Force Compiler if
you can. ;)

I would really appreciate your efforts, comments or suggestions.

---

Log
---

Version 1.0, 07/Apr/2011: the minimal compiler, using lex/yacc gnu
counterparts (flex/bison)

Version 2.0, 15/Apr/2011: included options to take care of most of the
undefined behavior of the language, including, but not restrict to:
rounding cell values, rounding pointer value, dealing with input/output
from keyboard and/or files. (The Linux Package R-2)

Version 2.1, 16/Apr/2001:

-   bug fix: infinit loop may occur if MAX is out of type range.
-   released first windows version, substituting fork() and wait() for CreateProcess() and WaitForSingleObject()

---

Author {style="font-weight: bold;"}
------

Prof. Dr. Ruben Carlo Benante

### Contact info:

> Email: rcb [at] beco.cc

> Webpage: http://www.beco.cc/compiler/brainforce

> Creation date: 05/Apr/2011

> Project based on the ideas of Urban Muller (http://fi.aminet.net/dev/lang)

> WebPage: www.beco.cc/compiler/brainforce

> Copyright 2011-... License GNU GPL v2
