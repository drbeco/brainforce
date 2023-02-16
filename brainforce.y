%{
/*
    BrainForce Compiler, An esoteric programming language compiler
    Copyright (C) 2011-2023  Ruben Carlo Benante <rcb [at] beco.cc>

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
    WebPage: <http://www.beco.cc/compiler/brainforce/>
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
                            derrprintf(1, "pass 2... (syntax tree)\n");
                            fprintf(yyout, "/*\n");
                            fprintf(yyout, "    BrainForce Compiler version %s_%s, An esoteric programming language.\n", __DATE__, __TIME__);
                            fprintf(yyout, "    Copyright (C) 2011  Ruben Carlo Benante <rcb [at] beco.cc>\n");
                            fprintf(yyout, "    WebPage: <http://www.beco.cc/compiler/brainforce>\n");
                            fprintf(yyout, "    License: GNU/GPL 2 <http://www.beco.cc/doc/gpl.html>\n");
                            fprintf(yyout, "*/\n\n");
							fprintf(yyout, "#include <stdio.h>\n");
							if(PRINTINT||RWRAP||PWRAP||SHARP>1)
								fprintf(yyout, "#include <stdlib.h>\n");
							fprintf(yyout, "#define MAX %d\n", MAXCELL);
							fprintf(yyout, "#define ZMIN %d\n#define ZMAX %d\n\n", ZEROMIN, ZEROMAX);
							if(!SIMPLE)
							{
								if(SHARP>1)
								{
									fprintf(yyout, "#define SHARP %d\n", SHARP/2);
									fprintf(yyout, "#define SHARPMIN (((i-SHARP)>0)?(i-SHARP):0)\n");
									fprintf(yyout, "#define SHARPMAX ((i+SHARP)<(MAX)?(i+SHARP):(MAX))\n\n");
								}
								switch(PRINTINT)
								{
									case 0: /*-p uchar */
										if(ITERA==0) /*-i off */
										{
											fprintf(yyout, "void dot(int i) {putc(i, stdout);}\n");
											fprintf(yyout, "int comma(void) {return getc(stdin);}\n\n");
										}
										else
											if(ITERA==1) /*-i on */
											{
												fprintf(yyout, "void dot(int i) {putc(i, stdout); putc('\\n', stdout);}\n");
												fprintf(yyout, "int comma(void) {int i, j; i=getc(stdin); j=getc(stdin); if(j!='\\n') ungetc(j, stdin); return i;}\n\n");
											}
											else /*-i switch */
											{
												fprintf(yyout, "void dot(int i) {putc(i, stdout);}\n");
												fprintf(yyout, "int comma(void) {return getc(stdin);}\n");
												fprintf(yyout, "void doti(int i) {putc(i, stdout); putc('\\n', stdout);}\n");
												fprintf(yyout, "int commai(void) {int i, j; i=getc(stdin); j=getc(stdin); if(j!='\\n') ungetc(j, stdin); return i;}\n\n");
											}
										break;
									case 1: /*-p uint */
										if(ITERA==0)
										{
											fprintf(yyout, "void dot(int i) {printf(\"%%d \", i);}\n");
											fprintf(yyout, "int comma(void) {int i; scanf(\"%%d\", &i); return i;}\n\n");
										}
										else
											if(ITERA==1) /*-i on */
											{
												fprintf(yyout, "void dot(int i) {printf(\"%%d\\n\", i);}\n");
												fprintf(yyout, "int comma(void) {int i; scanf(\"%%d\", &i); return i;}\n\n");
											}
											else /*-i switch */
											{
												fprintf(yyout, "void dot(int i) {printf(\"%%d \", i);}\n");
												fprintf(yyout, "int comma(void) {int i; scanf(\"%%d\", &i); return i;}\n");
												fprintf(yyout, "void doti(int i) {printf(\"%%d\\n\", i);}\n");
												fprintf(yyout, "int commai(void) {int i; scanf(\"%%d\", &i); return i;}\n\n");
											}
										break;
									case 2: /*-p both */
										if(ITERA==0)
										{
											fprintf(yyout, "void dot(int i) {printf(\"%%c %%d\\n\", i, i);}\n");
											fprintf(yyout, "int comma(void) {char c; int i; scanf(\"%%c %%d\\n\", &c, &i); return i;}\n\n");
										}
										else
											if(ITERA==1) /*-i on */
											{
												fprintf(yyout, "void dot(int i) {printf(\"%%c %%d\\n\", i, i);}\n");
												fprintf(yyout, "int comma(void) {int i; scanf(\"%%d\", &i); return i;}\n\n");
											}
											else /*-i switch */
											{
												fprintf(yyout, "void dot(int i) {printf(\"%%c %%d\\n\", i, i);}\n");
												fprintf(yyout, "int comma(void) {char c; int i; scanf(\"%%c %%d\\n\", &c, &i); return i;}\n");
												fprintf(yyout, "void doti(int i) {printf(\"%%c %%d\\n\", i, i);}\n");
												fprintf(yyout, "int commai(void) {int i; scanf(\"%%d\", &i); return i;}\n\n");
											}
								}
							}
							if(ITERA!=2)
								fprintf(yyout, "int main(void)\n{\n");
							else
							{
								fprintf(yyout, "int main(int ITERA, char *argv[])\n{\n");
								fprintf(yyout, "  ITERA--;\n");
							}
							fprintf(yyout, "  unsigned %s t[MAX]", (TYPECELL?(TYPECELL==1?"short":"int"):"char"));
							if(TYPECELL==TYPEPOINTER)
							{
								fprintf(yyout, ", i=0");
								if(SHARP>1)
									fprintf(yyout, ", s;\n\n");
								else
									fprintf(yyout, ";\n\n");
							}
							else
							{
								fprintf(yyout, ";\n  unsigned %s i=0", (TYPEPOINTER?(TYPEPOINTER==1?"short":"int"):"char"));
								if(SHARP>1)
									fprintf(yyout, ", s;\n\n");
								else
									fprintf(yyout, ";\n\n");
							}
	/*						fprintf(yyout, "  i=0;\n"); */
							fprintf(yyout, "  do t[i++]=ZMIN;\n"); /*t[i++]=0*/
							fprintf(yyout, "  while(");
							if((MAXCELL==256 && TYPEPOINTER==0) || MAXCELL==65536)
								fprintf(yyout, "i!=0);\n");
							else
								fprintf(yyout, "i<MAX);\n");

	/*						fprintf(yyout, "  for(i=0; i<MAX; i++)\n"); */
	/*						fprintf(yyout, "    t[i]=%d;\n\n", ZEROMIN); */
							fprintf(yyout, "  i=0;\n\n");
                            derrprintf(1, "pass 3... (semantic analizer and code generator)\n");
                            pass3($1,0);
							fprintf(yyout, "\n  ");
                            switch(ITERA)
                            {
								case 2:
									fprintf(yyout, "if(ITERA) ");
								case 1:
									fprintf(yyout, "putc('\\n', stdout);\n  ");
								case 0:
									fprintf(yyout, "return 0;\n}\n");
							}
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
		'>'									{ $$ = opr('>', 0); }
		| '<'								{ $$ = opr('<', 0); }
		| '+'								{ $$ = opr('+', 0); }
		| '-'								{ $$ = opr('-', 0); }
		| '.'								{ $$ = opr('.', 0); }
		| ','								{ $$ = opr(',', 0); }
		| '#'								{ $$ = opr('#', 0); }
		| '[' command_list ']'				{ $$ = opr('[', 1, $2); }
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
