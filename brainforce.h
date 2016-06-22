/*
    BrainForce Compiler v.1.0, An esoteric programming language
    Author: Ruben Carlo Benante (Dr. Beco)
    Email: rcb [at] beco.cc
    Creation date: 05/Apr/2011
    Project based on the ideas of Urban Muller (http://fi.aminet.net/dev/lang)
    WebPage: www.beco.cc/compiler/brainforce
    License: GPL v2

Usage:
   ./brainforce input_file [-o output_file] [options]

    input_file : a input file with source code in BrainForce language (.bf)
    output_file : a generated C source code from the input file (.c)

    Options:
        -zn :
            n=0 default behavior
            n=1 set zero = '0' for pretty print of chars
            n=2 set cells to read/write integers
        -d  : print the syntax tree of the input_file
        -v  : verbosity mode. Can pile up till level 10
        -q  : quiety mode
        -E  : stop after preprocessor and write output_file.i (not implemented)
        -S  : stop after assembler and write output_file.s (not implemented)
        -C  : stop after C generator and write output_file.c (default)
        -o file : output file name (default .c)\n");
        -h  : print this help

*/

#ifndef _PORTUGOL_H_
#define _PORTUGOL_H_

typedef struct uNodo
{
    int line;              /* creation line */
    int nops;              /* numero de operandos */
    int oper;              /* operator */
    struct uNodo *ptn[];   /* leafs of the syntax tree */
} nodo;

extern int TREE;
extern int ZERO;          /* ZERO value: 0 (integer) or '0' (char 48) (option -z) */
extern FILE *yyin, *yyout;

void yyerror(char *s);
int yylex(void);
int yyparse(void);
char *pass3(nodo *tn, int n);
void printNodo(nodo *tn, int n, char *var);
nodo *opr(int oper, int nops, ...);
void freeNodos(nodo *tn);

#endif
