/*
    BrainForce Compiler v.1.0, An esoteric programming language
    Author: Ruben Carlo Benante (Dr. Beco)
    Email: rcb [at] beco.cc
    Creation date: 05/Apr/2011
    Project based on the ideas of Urban Muller (http://fi.aminet.net/dev/lang)
    License: GPL v2
    WebPage: www.beco.cc/compiler/brainforce
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "brainforce.h"
#include "y.tab.h"

int ZERO=0;         /* ZERO value can be 0 or 48 */
int TREE=0;         /* Print the syntax tree */

char *pass3(nodo *tn, int n)
{
    char *q1=NULL, *q2=NULL, *qres=NULL, qtemp[20]="";

    if (tn==NULL)
        return strdup(qtemp);

    switch (tn->oper)
    {
        case 'l':
            pass3(tn->ptn[0], n);
            pass3(tn->ptn[1], n);
            break;
        break;
        case '>':
            fprintf(yyout, "%*st++;\n", 2*n+2, "  ");
        break;
        case '<':
            fprintf(yyout, "%*st--;\n", 2*n+2, "  ");
        break;
        case '+':
            fprintf(yyout, "%*s(*t)++;\n", 2*n+2, "  ");
        break;
        case '-':
            fprintf(yyout, "%*s(*t)--;\n", 2*n+2, "  ");
        break;
        case '.':
            if(!ZERO)
                fprintf(yyout, "%*sfputc(*t, stdout);\n", 2*n+2, "  ");
            else
                if(ZERO==1)
                    fprintf(yyout, "%*sfputc(*t+48, stdout);\n", 2*n+2, "  ");
                else
                    fprintf(yyout, "%*sprintf(\"[%%u]=%%u\\n\", (unsigned)(t-tape), *t);\n", 2*n+2, "  ");
        break;
        case ',':
            if(!ZERO)
                fprintf(yyout, "%*s*t=fgetc(stdin);\n", 2*n+2, "  ");
            else
                if(ZERO==1)
                    fprintf(yyout, "%*s*t=fgetc(stdin)-48;\n", 2*n+2, "  ");
                else
                {
                    fprintf(yyout, "%*sprintf(\"[%%u]=\", (unsigned)(t-tape));\n", 2*n+2, "  ");
                    fprintf(yyout, "%*sscanf(\"%%u\", t);\n", 2*n+2, "  ");
                }
        break;
        case '[':
            fprintf(yyout, "%*swhile(*t)\n%*s{\n", 2*n+2, "  ", 2*n+2, "  ");
            pass3(tn->ptn[0], n+1);
            fprintf(yyout, "%*s}\n", 2*n+2, "  ");
        break;
        case '#':
            fprintf(yyout, "%*sfor(i=0; i<10; i++)\n", 2*n+2, "  ");
            fprintf(yyout, "  %*sprintf(\"#[%%u]=%%u\\n\", i, tape[i]);\n", 2*n+2, "  ");
        break;
    }

    if (qres!=NULL)
        strcpy(qtemp,qres);
    free(q1);
    free(q2);
    free(qres);
    return strdup(qtemp);
}

void printNodo(nodo *tn, int n, char *var)
{
    if (!tn)
        return;

    if (n==0)
        printf("---------------------------- Syntax Tree ----------------------------\n");
    printf("(%d) %s->oper='%c'\n", n, var, tn->oper);
    if (tn->nops>0)
        printNodo(tn->ptn[0], n+1, "ptn[0]");
    if (tn->nops>1)
        printNodo(tn->ptn[1], n+1, "ptn[1]");
}
