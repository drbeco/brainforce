/*
    BrainForce Compiler, An esoteric programming language
    Copyright (C) 2011  Ruben Carlo Benante <rcb [at] beco.cc>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 2 of the License.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program. If not, see <http://www.beco.cc/doc/gpl.html>

    Author: Ruben Carlo Benante (Dr. Beco)
    Email: rcb [at] beco.cc
    Creation date: 05/Apr/2011
    WebPage: <http://www.beco.cc/compiler/brainforce/>
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "brainforce.h"
#include "y.tab.h"

int TREE=0;                					/* -y true or false, print syntax tree */
int debug=1;								/* -v verbosity */
int ZEROMIN=0, ZEROMAX=UCHARMAX;			/* -z Value limits of each cell (0,255)*/
int TYPECELL=0;   							/* -t Type of array 0-uchar, 1-ushort, 2-int */
int TYPEPOINTER=1;							/* Type of the pointer 0-uchar, 1-ushort */
int MAXCELL=USHORTMAX+1;   					/* -a Value limit of array (def. 65536, interval [0, SINTMAX]) */
int SHARP=0;	    		   				/* -# 0=ignore debug command in source, 1=ignore only in binary, or print cells [3,99]*/
int RWRAP=0;				   				/* -r wrap around cells 0-none, 1-on, 2-off */
int PWRAP=0;				   				/* -w wrap around pointers 0-none, 1-on, 2-off, 3-expand */
int PRINTINT=0;								/* -p print 0-char, 1-integers or 2-both */
int ITERA=0;								/* -i iterative shell 0-no, 1-yes, 2-switchable by '-i' */
int SIMPLE=0;								/* -e simple code 0=funcs allowed, 1-simple code, no funcs */

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
			switch(PWRAP)
			{
				case 0: /* none */
					fprintf(yyout, "%*si++;\n", 2*n+2, "  ");
					break;
				case 1: /* wrap on */
					fprintf(yyout, "%*si++; if(i>=MAX) i=0;\n", 2*n+2, "  ");
					break;
				case 2: /* wrap off */
				case 3: /* wrap expand */
					fprintf(yyout, "%*si++; if(i>=MAX) {fprintf(stderr, \"error: pointer overflow\\n\"); exit(1);}", 2*n+2, "  ");
			}
		break;
		case '<':
			switch(PWRAP)
			{
				case 0: /* none */
					fprintf(yyout, "%*si--;\n", 2*n+2, "  ");
					break;
				case 1: /* wrap on */
					fprintf(yyout, "%*si--; if(i>=MAX) i=MAX-1;\n", 2*n+2, "  "); /* >MAX because i is unsigned*/
					break;
				case 2: /* wrap off */
				case 3: /* wrap expand */
					fprintf(yyout, "%*si--; if(i>=MAX) {fprintf(stderr, \"error: pointer underflow\\n\"); exit(1);}", 2*n+2, "  ");
			}
		break;
		case '+':
			switch(RWRAP)
			{
				case 0: /* none */
					fprintf(yyout, "%*st[i]++;\n", 2*n+2, "  ");
					break;
				case 1: /* wrap on */
					fprintf(yyout, "%*st[i]++; if(t[i]>ZMAX) t[i]=ZMIN;\n", 2*n+2, "  ");
					break;
				case 2: /* wrap off */
					fprintf(yyout, "%*st[i]++; if(t[i]>ZMAX) {fprintf(stderr, \"error: cell %%d overflow\\n\", i); exit(1);}\n", 2*n+2, "  ");
			}
		break;
		case '-':
			switch(RWRAP)
			{
				case 0: /* none */
					fprintf(yyout, "%*st[i]--;\n", 2*n+2, "  ");
					break;
				case 1: /* wrap on */
					if(ZEROMIN!=0)
						fprintf(yyout, "%*st[i]--; if(t[i]<ZMIN) t[i]=ZMAX;\n", 2*n+2, "  ");
					else
						fprintf(yyout, "%*st[i]--; if(t[i]>ZMAX) t[i]=ZMAX;\n", 2*n+2, "  ");
					break;
				case 2: /* wrap off */
					if(ZEROMIN!=0)
						fprintf(yyout, "%*st[i]--; if(t[i]<ZMIN) {fprintf(stderr, \"error: cell %%d underflow\\n\", i); exit(1);}\n", 2*n+2, "  ");
					else
						fprintf(yyout, "%*st[i]--; if(t[i]>ZMAX) {fprintf(stderr, \"error: cell %%d underflow\\n\", i); exit(1);}\n", 2*n+2, "  ");
			}
		break;
		case '.':
						if(SIMPLE)
								fprintf(yyout, "%*sputc(t[i], stdout);\n", 2*n+2, "  ");
						else
							if(ITERA==2)
								fprintf(yyout, "%*sif(ITERA) doti(t[i]); else dot(t[i]);\n", 2*n+2, "  ");
							else
								fprintf(yyout, "%*sdot(t[i]);\n", 2*n+2, "  ");
		break;
		case ',':
			if(SIMPLE)
				fprintf(yyout, "%*st[i]=getc(stdin);\n", 2*n+2, "  ");
			else
				if(ITERA==2)
					fprintf(yyout, "%*sif(ITERA) t[i]=commai(); else t[i]=comma();\n", 2*n+2, "  ");
				else
					fprintf(yyout, "%*st[i]=comma();\n", 2*n+2, "  ");
		break;
		case '[':
			if(ZEROMIN!=0)
				fprintf(yyout, "%*swhile(t[i]!=ZMIN)\n%*s{\n", 2*n+2, "  ", 2*n+2, "  ");
			else
				fprintf(yyout, "%*swhile(t[i])\n%*s{\n", 2*n+2, "  ", 2*n+2, "  ");
            pass3(tn->ptn[0], n+1);
			fprintf(yyout, "%*s}\n", 2*n+2, "  ");
		break;
		case '#':
			/* -# 0=ignore debug command in source, 1=ignore only in binary, or print cells [3,99]*/
			if(SHARP>1)
			{
				fprintf(yyout, "/*---------------------------------------------*/\n");
				fprintf(yyout, "%*sfprintf(stderr, \"\\n# debug: pointer at %%d\", i);\n", 2*n+2, "  ");
				fprintf(yyout, "%*sfor(s=SHARPMIN; s<SHARPMAX; s++)\n", 2*n+2, "  ");
				fprintf(yyout, "%*s  fprintf(stderr, \"\\n#[%%u]=%%u\", s, t[s]);\n", 2*n+2, "  ");
				fprintf(yyout, "%*sfprintf(stderr, \"\\n\");\n", 2*n+2, "  ");
				fprintf(yyout, "/*---------------------------------------------*/\n");
			}
			else
				if(SHARP==1)
				{
					fprintf(yyout, "/*---------------------------------------------*/\n");
					fprintf(yyout, "/* %*sfprintf(stderr, \"\\n# debug: pointer at %%d\", i); */\n", 2*n+2, "  ");
					fprintf(yyout, "/* %*sfor(s=SHARPMIN; s<SHARPMAX; s++) */\n", 2*n+2, "  ");
					fprintf(yyout, "/* %*s  fprintf(stderr, \"\\n#[%%u]=%%u\", s, t[s]); */\n", 2*n+2, "  ");
					fprintf(yyout, "/* %*sfprintf(stderr, \"\\n\"); */\n", 2*n+2, "  ");
					fprintf(yyout, "/*---------------------------------------------*/\n");
				}
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
	char v[256]={0};
    if (!tn)
        return;

    if (n==0)
        printf("---------------------------- Syntax Tree ----------------------------\n");
	printf("(%03d) %s->oper='%c'\n", n, var, tn->oper);
	if (tn->nops>0)
	{
		strcpy(v, var);
		strcat(v, "->ptn[0]");
		printNodo(tn->ptn[0], n+1, v);
	}
	if (tn->nops>1)
	{
		strcpy(v, var);
		strcat(v, "->ptn[1]");
		printNodo(tn->ptn[1], n+1, v);
	}
}
