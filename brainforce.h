/*
    BrainForce Compiler, An esoteric programming language
    Copyright (C) 2011  Ruben Carlo Benante <rcb [at] beco.cc>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, version 2 of the License.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program. If not, see <http://www.beco.cc/doc/gpl.html>

    Author: Ruben Carlo Benante (Dr. Beco)
    Email: rcb [at] beco.cc
    Creation date: 05/Apr/2011
    Project based on the ideas of Urban Muller (http://fi.aminet.net/dev/lang)
    WebPage: <http://www.beco.cc/compiler/brainforce/>

Usage:
   ./brainforce input_file -o output_file [options]

	input_file : a input file with source code in BrainForce language (.bf)
	output_file : a generated C source code from the input file (.c)

	Options:
		-zn,m   : minimum/maximum cell value
		-an     : last cell index (excludent limit)
		-d      : print the syntax tree of the input_file
		-v      : verbosity mode. Can pile up till level 10
		-q      : quiety mode
		-S      : stop after assembler and write output_file.s
		-C      : stop after C generator and write output_file.c (default)
		-o file : output file name (default .c)
		-h      : print this help
		-cc     : copy license
		-cw     : warranty
	For all options, please consult <http://www.beco.cc/compiler/brainforce/usage.html>
*/

#ifndef _PORTUGOL_H_
#define _PORTUGOL_H_

//#define SINTMAX 2000000000
//#define UINTMAX 4000000000
#define UINTMAX 0xFFFFFFFE
#define USHORTMAX 65535
#define UCHARMAX 255

typedef struct uNodo
{
    int line;              /* creation line */
    int nops;              /* numero de operandos */
    int oper;              /* operator */
    struct uNodo *ptn[];   /* leafs of the syntax tree */
} nodo;

extern int TREE;                			/* -y true or false, print syntax tree */
extern int debug;							/* -v verbosity */
extern FILE *yyin, *yyout;					/* input_file -o output_file */
extern int ZEROMIN, ZEROMAX;	            /* Value limits of each cell def. [0,255], lim. [-SINT, SINT] */
extern int TYPECELL;   						/* Type of array 0-uchar, 1-ushort, 2-int */
extern int TYPEPOINTER;   					/* Type of the pointer 0-uchar, 1-ushort */
extern int MAXCELL;   						/* Value limit of array def. 65536, lim. [0, SINTMAX] */
extern int SHARP;			   				/* -# 0=ignore debug command in source, 1=ignore only in binary, or print cells [3,99]*/
extern int RWRAP;			   				/* -r wrap around cells 0-none, 1-on, 2-off */
extern int PWRAP;			   				/* -w wrap around pointers 0-none, 1-on, 2-off, 3-expand */
extern int PRINTINT;						/* -p print 0-chars, 1-integers or 2-both */
extern int ITERA;							/* -i iterative shell 0-off, 1-on, 2-switchable by '-i' */
extern int SIMPLE;							/* -e simple code 0=funcs allowed, 1-simple code, no funcs */

void yyerror(char *s);
int yylex(void);
int yyparse(void);
char *pass3(nodo *tn, int n);
void printNodo(nodo *tn, int n, char *var);
nodo *opr(int oper, int nops, ...);
void freeNodos(nodo *tn);
void derrprintf(int dlevel, const char * msg, ...);

#endif
