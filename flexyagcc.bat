::Batch Program
:: This script compiles the compiler BrainForce using flex, bison and gcc.
:: Optionally also runs the BrainForce compiler in a given BF source code
:: creating C source code and runs gcc to create the last binary target.
::
::/*
::     BrainForce Compiler Script, a make script to the compiler
::     Copyright (C) 2011  Ruben Carlo Benante <rcb [at] beco.cc>
::
::     This program is free software: you can redistribute it and/or modify
::     it under the terms of the GNU General Public License as published by
::     the Free Software Foundation, version 2 of the License.
::
::     This program is distributed in the hope that it will be useful,
::     but WITHOUT ANY WARRANTY; without even the implied warranty of
::     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
::     GNU General Public License for more details.
::
::     You should have received a copy of the GNU General Public License
::     along with this program. If not, see <http://www.beco.cc/doc/gpl.html>
::
::     Author: Ruben Carlo Benante (Dr. Beco)
::     Email: rcb [at] beco.cc
::     Creation date: 05/Apr/2011
::     WebPage: <http://www.beco.cc/compiler/brainforce/>
::*/
::
:: Example:
:: ./flexyagcc brainforce [file1] [args]
::
:: Note: do not use extensions in the script call.
::       file1 and args are passed to brainforce compiler
::
::
:: start the following process:
::      $flex brainforce.l                                 (creates lex.yy.c)
::      $bison -dy brainforce.y                            (creates yy.tab.c and yy.tab.h)
::      $gcc y.tab.c lex.yy.c brainforce.c -o brainforce   (creates the BrainForce Compiler)
::
:: Input:
::          brainforce.l  (lex source code for the lexical analyzer)
::          brainforce.y  (yacc source code for the syntactical analyzer)
::          brainforce.c  (c source code, the code generator of BrainForce)
::
:: Output:
::        lex.yy.c         (lex output, c source code)
::        y.tab.c          (yacc/bison output, c source code)
::        y.tab.h          (yacc/bison output, header file)
::        brainforce.bin   (gcc output, binary/executable BrainForce Compiler finally)
::
::
:: Optionally it can start (uncomment last lines):
::      $./brainforce.bin file1.bf -o file1.c [args]           (creates file1.c)
::      gcc file1.c -o file1.bin                               (creates executable file1.exe)
::
:: Optional Input:
::          file1       (brainforce source code)
::          args        (see bellow)
::
:: Optional output:
::        file.c         (brainforce output, c source code)
::        file1.bin      (gcc output, binary/executable user program)
::
:: To compile file.bf see the end of the script.
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
@echo off

echo --- flex --------- flex %1.l
flex %1.l
if ERRORLEVEL 1 goto errorend
echo --- bison -------- bison -dy %1.y
bison -dy %1.y
if ERRORLEVEL 1 goto errorend
echo --- gcc ---------- gcc y.tab.c lex.yy.c %1.c -o %1.exe -Wall
gcc y.tab.c lex.yy.c %1.c -o %1.exe -Wall
if ERRORLEVEL 1 goto errorend

::To compile the BF source file using your new BrainForce compiler, uncomment the last lines:
::
:: Start the following process:
::      $./brainforce.bin file1.bf -o file1.c [args]			(creates output_file.c)
::      gcc file1.c -o file1.bin      			          	(creates executable output_file)
::
:: Input:
::        file1.bf        (brainforce source code)
::
:: Output:
::        file1.c         (brainforce output, c source code)
::        file1.bin       (gcc output, binary/executable user program)
::
:: Args:
::		-z set zero = '0' for pretty print of chars
::		-d print the syntax tree of the input_file
::		-v verbosity mode. Can pile up till level 10
::		-q quiety mode
::		-E stop after preprocessor and write output_file.i (not implemented)
::		-S stop after assembler and write output_file.s (not implemented)
::		-C stop after C generator and write output_file.c (default)
::		-h print this help
:: Uncomment the last lines to run this part of the script:
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

echo --- brainforce --- ./%1.bin %2.bf -o %2.c %3 %4 %5 %6 %7 %8 %9
./%1.exe %2.bf -o %2.c %3 %4 %5 %6 %7 %8 %9
if ERRORLEVEL 1 goto errorend
echo --- gcc ---------- gcc %2.c -o %2.exe
gcc %2.c -o %2.exe
if ERRORLEVEL 1 goto errorend
echo --- Running! ----- ./$2.bin
./%2.exe
:okend
exit /b 0
:errorend
exit /b 1
