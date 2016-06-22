%{
/*
    BrainForce Compiler v.1.0, An esoteric programming language
    Author: Ruben Carlo Benante (Dr. Beco)
    Email: rcb [at] beco.cc
    Creation date: 05/Apr/2011
    Project based on the ideas of Urban Muller (http://fi.aminet.net/dev/lang)
    WebPage: www.beco.cc/compiler/brainforce
    License: GPL v2 
*/

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include "brainforce.h"

%}

%union {  nodo *pNodo; };
%type <pNodo> command command_list

%%

program:
    command_list         {
                            fprintf(stderr, "pass 2... (creating header)\n");
                            fprintf(yyout, "/*\n");
                            fprintf(yyout, "    BrainForce Compiler version %s_%s, by Dr. Beco\n", __DATE__, __TIME__);
                            fprintf(yyout, "    Email: rcb@beco.cc\n");
                            fprintf(yyout, "    WebPage: www.beco.cc/compiler/brainforce\n");
                            fprintf(yyout, "    License: CC-3.0 http://creativecommons.org/licenses/by-nc-sa/3.0/\n");
                            fprintf(yyout, "*/\n");
                            if(ZERO==2)
                                fprintf(yyout, "#include <stdlib.h>\n");
                            fprintf(yyout, "#include <stdio.h>\n"
                                    "#define MAX 10000\n\n"
                                    "int main(void)\n{\n"
                                    "  unsigned int tape[MAX], *t, i;\n"
                                    "  for(i=0; i<MAX; i++)\n");
                            fprintf(yyout, "    tape[i]=0;\n\n");
                            fprintf(yyout, "  t=tape;\n\n");
                            fprintf(stderr, "pass 3... (semantic analizer and code generator)\n");
                            pass3($1,0);
                            fprintf(yyout, "  fputc('\\n', stdout);\n  return 0;\n}\n");
                            fprintf(stderr, "Success!\n\n");
                            if(TREE)
                                printNodo($1, 0, "T");
                            freeNodos($1);
                            return 0;
                         }
    ;

command_list:
    command                    { $$ = $1; }
    | command_list  command    { $$ = opr('l', 2, $1, $2); }
    ;

command:
        '>'                                 { $$ = opr('>', 0); }
        | '<'                               { $$ = opr('<', 0); }
        | '+'                               { $$ = opr('+', 0); }
        | '-'                               { $$ = opr('-', 0); }
        | '.'                               { $$ = opr('.', 0); }
        | ','                               { $$ = opr(',', 0); }
        | '#'                               { $$ = opr('#', 0); }
        | '[' command_list ']'              { $$ = opr('[', 1, $2); }
        ;

%%

nodo *opr(int oper, int nops, ...)
{
    va_list ap;
    nodo *tn;
    size_t tam;
    int i;
    tam = sizeof(nodo) + nops * sizeof(nodo *);
    if((tn=malloc(tam))==NULL)
        yyerror("Memory Fault (cod. 1)");
    tn->oper = oper;
    tn->nops = nops;
    va_start(ap, nops);
    for(i=0; i<nops; i++)
        tn->ptn[i] = va_arg(ap, nodo*);
    va_end(ap);
    return tn;
}

void freeNodos(nodo *tn)
{
    int i;
    if(!tn)
        return;
    for(i=0; i<tn->nops; i++)
        freeNodos(tn->ptn[i]);
    free(tn);
}
