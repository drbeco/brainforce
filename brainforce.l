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

BrainForce Source File:
Command     Meaning
>           increment the data pointer (to point to the next cell to the right).
<           decrement the data pointer (to point to the next cell to the left).
+           increment (increase by one) the byte at the data pointer.
-           decrement (decrease by one) the byte at the data pointer.
.           output a character, the ASCII value of which being the byte at the data pointer.
,           accept one byte of input, storing its value in the byte at the data pointer.
[           if the byte at the data pointer is zero, then jump forward to the command after the matching ] command.
]           if the byte at the data pointer is nonzero, then jump back to the command after the matching [ command.
#           debug: print the first 10 cells
*/

%{
  #include <stdlib.h>
  #include <ctype.h>
  #include "brainforce.h"
  #include "y.tab.h"
%}

%option nounput noinput

%%

[-[\]+.,><#]  { return yytext[0]; }
.            { ; }

%%

int yywrap(void)
{
    return 1;
}

void yyerror(char *s)
{
    fprintf(stderr, "//Error: %s Token: '%s'.\n", s, yytext);
}

void givehelp(void)
{
    fprintf(stderr, "Usage:\n  ./brainforce input_file [-o output_file] [options]\n");
    fprintf(stderr, "Options:\n");
    fprintf(stderr, "  -zn     :\n");
    fprintf(stderr, "            n=0 default behavior: store ints, print chars\n");
    fprintf(stderr, "            n=1 set zero = '0' for pretty print of chars\n");
    fprintf(stderr, "            n=2 set cells to read/write integers\n");
    fprintf(stderr, "  -d      :\tprint the syntax tree of the input_file\n");
    fprintf(stderr, "  -v      :\tverbosity mode. Can pile up till level 10\n");
    fprintf(stderr, "  -q      :\tquiety mode\n");
    fprintf(stderr, "  -E      :\tstop after preprocessor and write output_file.i (not implemented)\n");
    fprintf(stderr, "  -S      :\tstop after assembler and write output_file.s (not implemented)\n");
    fprintf(stderr, "  -C      :\tstop after C generator and write output_file.c (default)\n");
    fprintf(stderr, "  -o file :\toutput file name (default .c)\n");
    fprintf(stderr, "  -h      :\tprint this help\n\n");
}

int main(int argc, char **argv)
{

    yyin=stdin;
    yyout=stdout;
    char *oarg, opt;
    int oflag=0, GENERATE='C', cflag=0, dflag=0, zflag=0, debug=0;

    fprintf(stderr, "\nBrainForce Compiler by Dr. Beco, version %s_%s\n", __DATE__, __TIME__);
    if (argc<1)
    {
        givehelp();
        exit(1);
    }

    opterr = 0;
    while ((opt = getopt(argc, argv, "CESdo:vqz:h")) != EOF)
        switch (opt)
        {
            case 'C':
                cflag=1;
                GENERATE='C';
                break;
            case 'E':
                GENERATE='E';
                break;
            case 'S':
                GENERATE='S';
                break;
            case 'd':
                dflag=1;
                TREE = 1;
                break;
            case 'o':
                oarg = optarg;
                oflag=1;
                break;
            case 'v':
                debug++;
                if (debug > 10) debug = 10;
                break;
            case 'q':
                debug = -1;
                break;
            case 'z':
                zflag = 1;
                ZERO=strtol(optarg, NULL, 10);
                break;
            case 'h':
                givehelp();
                exit(0);
            case '?':
            default:
                if (optopt == 'o')
                    fprintf (stderr, "Option -%c requires an argument.\n", optopt);
                else
                    if(isprint (optopt))
                        fprintf (stderr, "Unknown option '-%c'.\n", optopt);
                    else
                        fprintf (stderr, "Unknown option character '\\x%x'.\n", optopt);
                givehelp();
                exit(1);
        }

    if(argv[optind]==NULL)
    {
        fprintf(stderr, "You must supply a source file\n\n");
        exit(1);
    }

    if((yyin = fopen(argv[optind],"r"))==NULL)
    {
        fprintf(stderr, "I can't open %s for reading\n\n", argv[optind]);
        exit(1);
    }
    else
        fprintf(stderr, "input file: %s\n", argv[optind]);

    if(oflag)
    {
        if((yyout = fopen(oarg,"w"))==NULL)
        {
            fprintf(stderr, "I can't open %s for writing\n\n", oarg);
            exit(1);
        }
        else
            fprintf(stderr, "output file: %s\n", oarg);
    }

    if(dflag)
        fprintf(stderr, "-d : printing syntax tree\n");
    if(zflag)
    {
        if(ZERO!=0 && ZERO!=1 && ZERO!=2)
            ZERO=0;
        if(ZERO==0)
            fprintf(stderr, "-z0 : zero/input/output are standard\n");
        else
            if(ZERO==1)
                fprintf(stderr, "-z1 : zero is set to '0'\n");
            else
                fprintf(stderr, "-z2 : input/output of integers\n");
    }
    switch(GENERATE)
    {
        case 'C':
            if(cflag)
                fprintf(stderr, "-C : generating C source code\n");
            break;
        case 'E':
            fprintf(stderr, "-E : generating preprocessor output \".i\" (not implemented)\n\n");
            exit(1);
            break;
        case 'S':
            fprintf(stderr, "-S : generating ASM source code (not implemented)\n\n");
            exit(1);
    }
    if(debug)
        fprintf(stderr, "-v : verbosity level %d\n", debug);

    fprintf(stderr, "pass 1... (lexical analyzer)\n");
    if(yyparse()) //fail
    {
        fprintf(stderr, "Fail! I can't compile\n\n");
        if(yyout!=stdout)
            fprintf(yyout, "//Fail! I can't compile\n\n");
        exit(1);
    }
    return 0;
}
