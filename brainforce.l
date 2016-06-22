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
    WebPage: <http://www.beco.cc/compiler/brainforce/>
*/

%{
 #include <stdlib.h>
 #include <ctype.h>
 #include <sys/wait.h>
 #include <stdarg.h>

  #include "brainforce.h"
  #include "y.tab.h"
%}

%option nounput noinput

%%

[-[\]+.,><#]  { return yytext[0]; }
\n  		  ; /* nothing to do */
.			  ; /* nothing to do */

%%

int yywrap(void)
{
	return 1;
}

void yyerror(char *s)
{
    fprintf(stderr, "//Error: %s Token: '%s'.\n", s, yytext);
}

void derrprintf(int dlevel, const char * msg, ...)
{
    va_list ap;
    va_start(ap, msg);
	if(debug>=dlevel)
		vfprintf(stderr, msg, ap);
    va_end(ap);
}

void header(void)
{
	static int ok=0;

	if(!ok)
	{
		fprintf(stderr, "BrainForce Compiler, version %s_%s. An esoteric programming language.\n", __DATE__, __TIME__);
		fprintf(stderr, "Copyright (C) 2011 Ruben Carlo Benante <rcb%cbeco.cc>.\n\n",'@');
		fprintf(stderr, "This program comes with ABSOLUTELY NO WARRANTY; for details type 'brainforce -cw'.\n");
		fprintf(stderr, "This is free software, and you are welcome to redistribute it\n");
		fprintf(stderr, "under certain conditions; type 'brainforce -cc' for details.\n\n");
		ok=1;
	}
}

void givewarranty_gpl(int excode)
{
	fprintf(stderr, "THERE IS NO WARRANTY FOR THE PROGRAM, TO THE EXTENT PERMITTED BY APPLICABLE LAW.\n");
	fprintf(stderr, "EXCEPT WHEN OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES PROVIDE\n");
	fprintf(stderr, "THE PROGRAM \"AS IS\" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT\n");
	fprintf(stderr, "NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.\n");
	fprintf(stderr, "THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE PROGRAM IS WITH YOU.\n");
	fprintf(stderr, "SHOULD THE PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR OR CORRECTION.\n");

	fprintf(stderr, "\n\nThis program requires preservation of author attributions.\n");
	fprintf(stderr, "You should have received a copy of the GNU General Public License\n");
	fprintf(stderr, "along with this program.  If not, see <http://www.beco.cc/doc/gpl.html>\n\n");

		exit(excode);
}

void givelicense_gpl(int excode)
{
	FILE *gpl;
	int c;
	header();
	fprintf(stderr, "This program is free software: you can redistribute it and/or modify\n");
	fprintf(stderr, "it under the terms of the GNU General Public License as published by\n");
	fprintf(stderr, "the Free Software Foundation, version 2 of the License.\n");

	fprintf(stderr, "This program is distributed in the hope that it will be useful,\n");
	fprintf(stderr, "but WITHOUT ANY WARRANTY; without even the implied warranty of\n");
	fprintf(stderr, "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n");
	fprintf(stderr, "GNU General Public License for more details.\n");

	if((gpl=fopen("LICENSE", "r"))!=NULL)
	{
		fprintf(stderr, "\n\n");
		while((c=getc(gpl))!=EOF)
			putc(c, stderr);
		fclose(gpl);
	}

	fprintf(stderr, "\n\nThis program requires preservation of author attributions.\n");
	fprintf(stderr, "You should have received a copy of the GNU General Public License\n");
	fprintf(stderr, "along with this program.  If not, see <http://www.beco.cc/doc/gpl.html>\n\n");

	exit(excode);
}

void givehelp(int excode)
{
	header();
	fprintf(stderr, "Usage:\n  ./brainforce input_file -o output_file [options]\n\n");
	fprintf(stderr, "Compiler options:\n");
	fprintf(stderr, " -y          : print the syntax tree of the input_file\n");
	fprintf(stderr, " -v          : verbosity mode. Can pile up till level 10\n");
	fprintf(stderr, " -q          : quiety mode. Success/failure is reported in $? or ERRORLEVEL\n");
	fprintf(stderr, " -o file     : output file name\n");
	fprintf(stderr, " -g          : generate binary file with debug symbols to be used with gdb\n");
	fprintf(stderr, " -cw         : show warranty\n");
	fprintf(stderr, " -c[c]       : show copying license\n");
	fprintf(stderr, " -h          : print this help. -v -h for other options.\n");
	fprintf(stderr, "\nCode generation options:\n");
	derrprintf(2,   " -E          : stop after gcc preprocessor and write output_file.i (not implemented)\n");
	fprintf(stderr, " -S [syntax] : stop after gcc assembler and write output_file.s in the selected syntax.\n");
	fprintf(stderr, "               Syntax is:\n");
	fprintf(stderr, "               [-S [att]]   (default) %% prefix regs, addresses use (), op order src->dst, etc.\n");
	fprintf(stderr, "               -S intel     keywords for data size, addresses use [], op order dst<-src, etc.\n");
	fprintf(stderr, " -C          : stop after native C generator and write output_file.c\n");
	fprintf(stderr, " -K          : keep intermediate C source code output_file.c\n");
	fprintf(stderr, "               If none is given, outputs executable binary (depends on existing GCC in the PATH)\n");
	derrprintf(2,   " -B          : compile and write output_file.bin  (default)\n");

	fprintf(stderr, "\nRuntime options:\n");
	fprintf(stderr, "  -z opt     : minimum and maximum value of a cell (default -z 0,%d). Options are:\n", UCHARMAX);
	fprintf(stderr, "                 -z n,m      n=minimum (>= 0), m=maximum (<= %d) and n<m\n", UINTMAX);
	derrprintf(2,   "                             The maximum value may change with architecture,\n");
	derrprintf(2,   "                              being it the size of an unsigned int minus 1 (usually 4 bytes)\n");
	derrprintf(2,   "                             if n>=0, %d<m<=%d set -t ushort\n", UCHARMAX, USHORTMAX);
	derrprintf(2,   "                             if n<0 or m>%d set -t uint\n", USHORTMAX);
	derrprintf(2,   "                             unless told otherwise explicitaly by -t\n");
	fprintf(stderr, "                 -z bit      same as -z 0,1\n");
	fprintf(stderr, "                 -z print    same as -z 32,126 (ASCII printable).\n");
	fprintf(stderr, "                             Nice print if used with -p uchar or -p both, and -r on\n");
	fprintf(stderr, "                 -z number   same as -z 48,57  (ASCII '0' to '9')\n");
	fprintf(stderr, "                 -z letter   same as -z 65,90  (ASCII 'A' to 'Z')\n");
	fprintf(stderr, "                 [-z uchar]  same as -z 0,%d  (default)\n", UCHARMAX);
	fprintf(stderr, "                 -z ushort   same as -z 0,%d\n", USHORTMAX);
	derrprintf(2,   "                             set -t ushort, unless told otherwise explicitaly by -t\n");
	fprintf(stderr, "                 -z uint     same as -z 0,%x (~ 4 billions)\n", UINTMAX);
	derrprintf(2,   "                             set -t uint, unless told otherwise explicitaly by -t\n");
	fprintf(stderr, "               If -r on or -r off is used, it is useful to read warnings given by\n");
	fprintf(stderr, "                verbosity level 1 or more (-v)\n");

	derrprintf(2,   "  -t type    : type of array. The type of array must hold the range of values set by -z options\n");
	derrprintf(2,   "               Type is one of:\n");
	derrprintf(2,   "               [-t uchar]    (default) in the interval of [0, %d] (1 byte)\n", UCHARMAX);
	derrprintf(2,   "               -t ushort     in the interval of [0, %d] (2 bytes)\n", USHORTMAX);
	derrprintf(2,   "               -t uint        in the interval of [0, %d] (4 bytes)\n", UINTMAX);
	derrprintf(3,   "               This values are architecture dependent.\n");

	fprintf(stderr, "  -a n       : array size (number of cells), n=[1, %d], default -a %d.\n", USHORTMAX+1, USHORTMAX+1);
	fprintf(stderr, "               The pointer is type ushort unless:\n");
	fprintf(stderr, "               -a %d or less is used, and not -w off, the pointer is made uchar\n", UCHARMAX+1);
	fprintf(stderr, "               -a %d or less is used, and -w off, the pointer is made uchar\n", UCHARMAX);
	fprintf(stderr, "               See -w to understand the proprierties of sizes %d and %d\n", UCHARMAX+1, USHORTMAX+1);

	fprintf(stderr, "  -# [n]     : debug mode on: interpret # command to dump array\n");
	fprintf(stderr, "               [-# 0]      (default) debug mode off, ignore all #'s in resulted C source and compiled binary\n");
	fprintf(stderr, "               -# 1        debug mode off, ignore all #'s in the resulted binary, but show it as comments in C source\n");
	fprintf(stderr, "               -#          same as -# 11, debug mode on with 11 cells dump\n");
	fprintf(stderr, "               -# n        n=[3, 5, 7, 9, 13, ... 99] debug mode on with n cells dump\n");
	fprintf(stderr, "               Debug mode on: interpret # command to dump array\n");
	fprintf(stderr, "               Better if set together with -p both\n");
	derrprintf(11,  "               ToDo: symbol to save (! or w)/read(? or r) tape to/from file. Symbol to quit (q exit code is cell value). Symbol to call procedure (:)\n");

	fprintf(stderr, "  -r wrap    : set option for wrapping around cell values when they reach a limit. Wrap can be:\n");
	fprintf(stderr, "                 -r on        causes wrap around if cell overflow or underflow\n");
	fprintf(stderr, "                 -r off       causes error if cell overflow or underflow\n");
	fprintf(stderr, "                 [-r none]    do not check bounds.\n");
	fprintf(stderr, "                              (Be careful. Bounds depends on type size of the target machine)\n");
	fprintf(stderr, "               If -r is not given, [-r none] is the default\n");
	fprintf(stderr, "               Cell maximum and minimum values are set by -z option\n");
	fprintf(stderr, "               Not checking bounds around the limits of uchar or ushort produces better code\n");
	fprintf(stderr, "                (see options -z uchar or -z ushort)\n");
	fprintf(stderr, "               Not checking bounds around int (-z uint) is perfectably possible but\n");
	fprintf(stderr, "                can give you negative numbers.\n");
	derrprintf(2,   "               Unlike -w, where -a option is checked, -r don't auto check -z (or -t). That means that if you set -r on or -r off, \n");
	derrprintf(2,   "                and set for example -z 200,255, overflow errors cannot be checked! That is because cell will wrap to 0 before check, \n");
	derrprintf(2,   "                and then leaving the cell with an invalid value (zero). The same goes to -z 0,100, for example, and underflow error.\n");
	derrprintf(2,   "                Suggestion: use a bigger type to hold a number outside the chosen range, so checks can occurr. Example:\n");
	derrprintf(2,   "                   To have -z n,%d  and -r on/off, set -t ushort\n", UCHARMAX);
	derrprintf(2,   "                   To have -z n,%d -r on/off, set -t uint\n", USHORTMAX);
	derrprintf(2,   "                   Don't worry about -z uint, it's guaranteed to work.\n");

	fprintf(stderr, "  -w wrap    : set option for wrapping around the pointer when it reachs any limit. Wrap can be:\n");
	fprintf(stderr, "                 -w on        causes wrap around if pointer overflow or underflow\n");
	fprintf(stderr, "                              If array size (-a) is %d or %d, see -w none to create simple code.\n", UCHARMAX+1, USHORTMAX+1);
	fprintf(stderr, "                              With -w on conditionals are written to check bounds\n");
	derrprintf(2,   "                              Conditional used : if(pointer>=MAX)\n");
	derrprintf(2,   "                               both underflow or overflow might have happen.\n");
	derrprintf(2,   "                              If MAX is unreacheble by pointer, wrap occurr before the test.\n");
	derrprintf(2,   "                               In this case, use -w none to wipe unnecessary code.\n");
	derrprintf(3,   "                              With -a n and 1<=n<=%d, pointer is type uchar.\n", UCHARMAX+1);
	derrprintf(3,   "                              With %d<n<=%d, pointer is type ushort.\n", UCHARMAX+1, USHORTMAX+1);
	fprintf(stderr, "                 -w off       causes (controled) error if pointer overflow or underflow.\n");
	fprintf(stderr, "                               Need conditionals to test for bounds\n");
	fprintf(stderr, "                              Maximum array size for this option is -a %d\n", USHORTMAX);
	fprintf(stderr, "                              (the last number is used as overflow/underflow error code)\n");
	derrprintf(2,   "                              Conditional used : if(i>=MAX), for underflow or overflow.\n");
	derrprintf(2,   "                              MAX cannot be unreacheble by the pointer to guarantee\n");
	derrprintf(2,   "                               the desired behavior.\n");
	derrprintf(3,   "                              With -a n and 1<=n<=%d, pointer is type uchar.\n", UCHARMAX);
	derrprintf(3,   "                              With %d<n<=%d, pointer is type ushort. It is forbidden -a %d.\n", UCHARMAX, USHORTMAX, USHORTMAX+1);
	fprintf(stderr, "                 [-w none]    do not check for limis. Creates simpler code\n");
	fprintf(stderr, "                              WARNING! If -a is not %d or %d, the pointer can raise real\n", UCHARMAX+1, USHORTMAX+1);
	fprintf(stderr, "                               Segmentation Fault errors depending on the BrainForce user code!\n");
	fprintf(stderr, "                              How nice: If -a is set to those magic numbers, \n");
	fprintf(stderr, "                               overflow/underflow just wraps around like -w on\n");
	derrprintf(2,   "                 -w expand    (not implemented) if pointer reaches the right limit, redimension\n");
	derrprintf(2,   "                               array, till it gets the maximum size (or the memory is over).\n");
	derrprintf(2,   "                              When it cannot allocates more memory, it becomes -w off.\n");
	fprintf(stderr, "               If -w is not given, [-w none] is the default\n");
	fprintf(stderr, "               Pointer maximum limit is (n-1) set by -a n. Minimum is allways cell number 0.\n");

	fprintf(stderr, " -p style    : set how to print and read. Style can be:");
	fprintf(stderr, "                 -p uchar\n");
	derrprintf(3,   "                    uses putchar() and getchar()\n");
	fprintf(stderr, "                 -p uint (default)\n");
	derrprintf(3,   "                    uses printf(\"%%d\") and scanf(\"%%d\")\n");
	fprintf(stderr, "                 -p both\n");
	derrprintf(3,   "                    uses printf(\"%%c %%d\") and scanf(\"%%c %%d\")\n");

	fprintf(stderr, " -i [opt]    : iterative mode, set input/output from/to file or iterativelly (keyboard/monitor).\n");
	fprintf(stderr, "               Options are:\n");
	fprintf(stderr, "                 -i on        read/write from keyboard/screen\n");
	derrprintf(2,   "                    uses ungetc(), or simplified scanf(), depending on -p\n");
	fprintf(stderr, "                 -i off       (default) read/write from/to file. Its necessary to use\n");
	fprintf(stderr, "                               redirection symbols '<' and '>' from SO command line\n");
	derrprintf(2,   "                               matching getchar()/putchar() or scanf()/printf() (see -p)\n");
	fprintf(stderr, "                 -i switch    program inherit '-i' switch to chose from command line.\n");
	derrprintf(2,   "                              set argc/argv to read switch that changes mode.\n");
	derrprintf(3,   "                              yet to be implemented: inherit '-p' switch also.\n");

	fprintf(stderr, " -e          : simplified source code (good to use with -S), disable functions.\n");
	fprintf(stderr, "                Also set -z ushort, -t ushort, -a %d, debug mode (#) off, -r none, -w none,\n", USHORTMAX+1);
	fprintf(stderr, "                 -p uchar, -i off. Its incompatible with any other runtime option.\n");
	fprintf(stderr, " To see advanced help, use -v -h\n");
	derrprintf(2,   " To see expert help, use -vv -h\n");
	derrprintf(2,   "\n");
	derrprintf(2,   "Notes:\n");
	derrprintf(2,   "    Maximum int value may varie from machine to machine.\n");
	derrprintf(2,   "\n");
	derrprintf(2,   "Contact info:\n");
	derrprintf(2,   "    Author: Ruben Carlo Benante.\n");
	derrprintf(2,   "    Email: rcb%cbeco.cc\n", '@');
	derrprintf(2,   "    Webpage: http://www.beco.cc/compiler/brainforce\n");
	derrprintf(3,   "Technical info:\n");
	derrprintf(3,   "    This program assumes char 1 byte, short 2 bytes and int 4 bytes.\n");
	derrprintf(3,   "    Other architectures may not run or present undefined behavior\n");
	fprintf(stderr, "\n");
	exit(excode);
}

int main(int argc, char **argv)
{
	int recv, cpid;
	char opt;

    /* runtime */
    int zflag=0, tflag=0, aflag=0, sharpflag=0, rflag=0, wflag=0, pflag=0, iflag=0, eflag=0;
	int zzwarn=0, awarn=0, swarn=0, dl=0;
	char *targ, *rarg, *warg, *parg, *zmax, *zarg, *iarg;
    /* compiler */
    int yflag=0, oflag=0, gflag=0;
    char GENERATE='B', KEEP='N';
    char *oarg, *syntax;

	derrprintf(0, "\n");

	opterr = 0;
	while ((opt = getopt(argc, argv, "yvqo:gc:hES:CKBz:t:a:#:r:w:p:i:e")) != EOF)
		switch (opt)
		{
			/* compiler */
			case 'y':
				yflag = 1;
				TREE = 1;
				break;
 			case 'v':
 				debug++;
				if (debug > 11) debug = 11;
 				break;
 			case 'q':
 				debug = 0;
 				break;
			case 'o':
				oflag = 1;
				oarg = optarg;
				break;
 			case 'g':
 				gflag = 1;
 				break;
 			case 'c':
				header();
				if(optarg[0]=='w')
					givewarranty_gpl(0);
				else
					givelicense_gpl(0);
			case 'h':
				givehelp(0);
			/* Generate */
			case 'B':
				GENERATE = 'B';
				break;
			case 'E':
				GENERATE = 'E';
				break;
			case 'S':
				if(GENERATE=='S')
					break;
				syntax=optarg;
				GENERATE = 'S';
				break;
			case 'C':
				GENERATE = 'C';
				break;
			case 'K':
				KEEP = 'K';
				break;
			/* runtime */
			case 'z':
				zflag = 1;
				zarg=optarg;
				break;
			case 't':
				tflag = 1;
				targ = optarg;
				break;
			case 'a':
				if(optarg[0]=='-')
				{
					header();
					derrprintf(0, "Unknown argument %s for option -a.\n", optarg);
					derrprintf(2, "Valid -a n, n=[1, 2GiB]. Use -h for more help.\n");
					exit(1);
				}
				aflag = 1;
				MAXCELL = strtoul(optarg, NULL, 10);
				break;
			case '#':
				if(optarg[0]=='-')
				{
					header();
					derrprintf(0, "Unknown argument %s for option -#.\n", optarg);
					derrprintf(2, "Valid -# n, n=[0, 99]. Use -h for more help.\n");
					exit(1);
				}
				sharpflag = 1;
				SHARP = strtol(optarg, NULL, 10);
				break;
			case 'r':
				rflag = 1;
				rarg = optarg;
				break;
			case 'w':
				wflag = 1;
				warg = optarg;
				break;
			case 'p':
				pflag = 1;
				parg = optarg;
				break;
			case 'i':
				iflag = 1;
				iarg = optarg;
				break;
			case 'e':
				eflag=1;
				break;
			case '?':
			default:
				switch(optopt)
				{
					case 'o':
					case 'z':
					case 't':
					case 'a':
					case 'r':
					case 'w':
					case 'p':
					case 'i':
						header();
						derrprintf(0, "Option -%c requires an argument.\n", optopt);
						givehelp(1);
					case 'c':
						header();
						givelicense_gpl(0);
					case '#':
						sharpflag = 1;
						SHARP = 11;
						break;
					case 'S':
						if(GENERATE=='S')
							break;
						GENERATE = 'S';
						syntax=malloc(4);
						strcpy(syntax, "att");
						break;
					default:
					    header();
						if(isprint (optopt))
							derrprintf(0, "Unknown option '-%c'.\n", optopt);
						else
							derrprintf(0, "Unknown option character '\\x%x'.\n", optopt);
						givehelp(1);
				}
		}

	if(debug) header();

	/* compiler options */
	derrprintf(3, "Compiler options --------------\n");
	derrprintf(3, "-v : verbosity level %d", debug-1);
	derrprintf(4, " (debug==%d)", debug);
	derrprintf(3, "\n");
	if(argv[optind] == NULL)
	{
		header();
		derrprintf(0, "You must supply an input file\n\n");
		exit(1);
	}
	if((yyin = fopen(argv[optind],"r")) == NULL)
	{
		header();
		derrprintf(0, "I can't open %s for reading\n\n", argv[optind]);
		exit(1);
	}
	else
		derrprintf(2, "input file: %s\n", argv[optind]);

	if(!oflag)
	{
		header();
		derrprintf(0, "You must supply an output file\n\n");
		exit(1);
	}
	if(oarg[0]=='-' || (yyout = fopen(oarg,"w")) == NULL)
	{
		header();
		derrprintf(0, "I can't open %s for writing\n\n", oarg);
		exit(1);
	}
	else
		derrprintf(2, "output file: %s\n", oarg);

	if(KEEP=='K')
		derrprintf(2, "-K : compiling and keeping the intermediate C source code\n");
	switch(GENERATE)
	{
		case 'C':
			derrprintf(2, "-C : generating C source code. ");
			if(KEEP=='K')
				derrprintf(2, "Warning : -K not necessary");
			derrprintf(2, "\n");
			break;
		case 'E':
			header();
			derrprintf(0, "-E : generating preprocessor output (not implemented)\n\n");
			exit(1);
			break;
		case 'S':
			if(strcmp(syntax, "att") && strcmp(syntax, "intel"))
			{
				header();
				derrprintf(0, "Unknown argument %s for option -S.\n", syntax);
				derrprintf(2, "Valid -S syntax are att or intel. Use -h for more help.\n");
				exit(1);
			}
			derrprintf(2, "-S %s : generating ASM source code with %s syntax\n", syntax, syntax);
			break;
		case 'B':
			derrprintf(3, "-B : (hidden option) generating binary only (default)\n");
	}
	if(yflag)
		derrprintf(2, "-y : printing yacc syntax tree\n");
	else
		derrprintf(3, "-y : yacc syntax tree not to be printed\n");

	if(!gflag) derrprintf(3, "-g : compiling binary without debug symbols\n");
	if(gflag && (GENERATE == 'S' || GENERATE == 'B' || GENERATE == 'K'))
		derrprintf(2, "-g : compiling with debug symbols\n");
	else
		if(gflag)
		{
			derrprintf(2, "-g : warning! ignoring switch -g not compatible with -E, -C\n");
			gflag=0;
		}

    /* runtime options */
	derrprintf(3, "Run-time options --------------\n");
	if(eflag)
	{
		if(zflag||tflag||aflag||sharpflag||rflag||wflag||pflag||iflag)
		{
			header();
			derrprintf(0, "-e : incompatible with other runtime options. \n");
			derrprintf(2, "Do not use -e together with -z, -t, -a, -#, -r, -w, -p or -i (runtime options). Use -h for more help.\n");
			exit(1);
		}
		ZEROMIN=0;       		/*zero*/
		ZEROMAX=USHORTMAX;		/*65535*/
		TYPECELL=1;				/*ushort*/
		MAXCELL=USHORTMAX+1;	/*0..65535*/
		TYPEPOINTER=1;			/*ushort*/
		SHARP=0;				/*sharp debug off*/
		RWRAP=0;				/*wrap cell off*/
		PWRAP=0;				/*wrap pointer off*/
		PRINTINT=0;				/*print/read chars with putchar/getchar*/
		ITERA=0;				/*do not bother ungetc*/
		SIMPLE=1;				/*do not use dot() and comma(). read/write inline*/
	}
	else
		derrprintf(3, "-e : not simplified... reading all options\n");

	if(zflag)
	{
		zmax = strchr(zarg,',');
		if(zmax!=NULL)
		{
			*zmax = '\0';
			zmax++;
			ZEROMIN = strtoul(zarg, NULL, 10);
			ZEROMAX = strtoul(zmax, NULL, 10);
			if((ZEROMAX<=ZEROMIN)||(ZEROMIN < 0)||(ZEROMAX > UINTMAX))
			{
				zzwarn=1;
				ZEROMIN = 0;
				ZEROMAX = UCHARMAX;
			}
		}
		else
			if(!strcmp(zarg, "bit"))
			{
				ZEROMIN = 0;
				ZEROMAX = 1;
			}
			else
				if(!strcmp(zarg, "print"))
				{
					ZEROMIN = ' ';
					ZEROMAX = '~';
				}
				else
					if(!strcmp(zarg, "number"))
					{
						ZEROMIN = '0';
						ZEROMAX = '9';
					}
					else
						if(!strcmp(zarg, "letter"))
						{
							ZEROMIN = 'A';
							ZEROMAX = 'Z';
						}
						else
							if(!strcmp(zarg, "uchar"))
							{
								ZEROMIN = 0;
								ZEROMAX = UCHARMAX;
							}
							else
								if(!strcmp(zarg, "ushort"))
								{
									ZEROMIN = 0;
									ZEROMAX = USHORTMAX;
									TYPECELL=1;
								}
								else
									if(!strcmp(zarg, "uint"))
									{
										ZEROMIN = 0;
										ZEROMAX = UINTMAX;
										TYPECELL=2;
									}
									else
									{
										header();
										derrprintf (0, "Unknown argument %s for option -z.\n", zarg);
										derrprintf(2, "Valid -z options are: n,m, bit, print, number, letter, uchar, ushort or uint. Use -h for more help.\n");
										exit(1);
									}
		derrprintf(2, "-z %u,%u : min,max cell values. ", ZEROMIN, ZEROMAX);
		if(zzwarn)
			derrprintf(2, "Warning! Wrong min,max values.");
		derrprintf(2, "\n");
		if(ZEROMIN<0||ZEROMAX>USHORTMAX)
			TYPECELL=2;
		else
			if(ZEROMAX>UCHARMAX)
				TYPECELL=1;
	}
	else
		derrprintf(3, "-z %d,%d: cell values.\n", ZEROMIN, ZEROMAX);


	if(tflag)
	{
		if(!strcmp(targ,"uchar"))
		{
			TYPECELL = 0;
			derrprintf(2, "-t uchar : array type. ");
			if(ZEROMIN<0||ZEROMAX>UCHARMAX)
				derrprintf(2, " Warning! This type can't hold cell values given by -z option");
			derrprintf(2, "\n");
		}
		else
			if(!strcmp(targ,"ushort"))
			{
				TYPECELL = 1;
				derrprintf(2, "-t ushort : array type. ");
				if(ZEROMIN<0||ZEROMAX>USHORTMAX)
					derrprintf(2, " Warning! This type can't hold cell values given by -z option");
				derrprintf(2, "\n");
			}
			else
				if(!strcmp(targ,"uint"))
				{
					TYPECELL = 2;
					derrprintf(2, "-t uint : array type\n");
				}
				else
				{
					header();
					derrprintf(0, "Unknown argument %s for option -t.\n", targ);
					derrprintf(2, "Valid -t options are: uchar, ushort or uint. Use -h for more help.\n");
					exit(1);
				}
	}
	else
		switch(TYPECELL)
		{
			case 0:
				derrprintf(3, "-t uchar : type of array\n");
				break;
			case 1:
				derrprintf(3, "-t ushort : type of array\n");
				break;
			case 2:
				derrprintf(3, "-t uint : type of array\n");
				break;
		}

	if(aflag)
	{
		if(MAXCELL<1)
		{
			awarn=1;
			MAXCELL=1;
		}
		else
			if(MAXCELL>USHORTMAX+1)
			{
				awarn=2;
				MAXCELL=USHORTMAX+1;
			}
		derrprintf(2, "-a %d : array size. ", MAXCELL);
		if(awarn==1)
			derrprintf(2, "Warning! wrong value chosen: too low");
		else
			if(awarn==2)
				derrprintf(2, "Warning! wrong value chosen: too high");
		derrprintf(2, "\n");
	}
	else
		derrprintf(3, "-a %d : default array size\n", MAXCELL);

	if(sharpflag)
	{
		if(SHARP>99)
		{
			swarn=1;
			SHARP=11;
		}
		if(!(SHARP%2) && SHARP!=0)
		{
			swarn=2;
			SHARP++;
		}
		if(SHARP>1)
			derrprintf(2, "-# %d : debug enabled for %d cells surrounding pointer. ", SHARP, SHARP);
		else
		{
			derrprintf(2, "-# : debug disabled. ");
			if(SHARP)
				derrprintf(3, "Option 1: Source code has comments on positon. ");
			else
				derrprintf(3, "Option 0: No trace of sharp. ");
		}
		if(swarn)
			derrprintf(swarn+1, "Warning! ");
		switch(swarn)
		{
			case 1:
				derrprintf(2, "Wrong value was corrected. ");
				break;
			case 2:
				derrprintf(3, "Even value changed to odd. ");
				break;
		}
		derrprintf(2, "\n");
	}
	else
		derrprintf(3, "-# 0 : default debug disabled.\n");

	if(rflag)
	{
		if(!strcmp(rarg,"none"))
			RWRAP = 0;
		else
			if(!strcmp(rarg,"on"))
				RWRAP = 1;
			else
				if(!strcmp(rarg,"off"))
					RWRAP = 2;
				else
				{
					header();
					derrprintf (0, "Unknown argument %s for option -r.\n", rarg);
					derrprintf(2, "Valid -r options are: none, on or off. Use -h for more help.\n");
					exit(1);
				}
		derrprintf(2, "-r %s : wrap around. ", rarg);
		if(RWRAP && ((ZEROMAX==UCHARMAX && TYPECELL==0) || (ZEROMAX==USHORTMAX && TYPECELL==1)))
			derrprintf(2, " Warning! Wrap cannot happen. Try using a greater type with -t. Use -v -h for more help about -r.");
		derrprintf(2,   "\n");
	}
	else
		derrprintf(3, "-r none : default wrap around cells. \n");

	if(wflag)
	{
		if(!strcmp(warg,"none"))
			PWRAP = 0;
		else
			if(!strcmp(warg,"on"))
				PWRAP = 1;
			else
				if(!strcmp(warg,"off"))
					PWRAP = 2;
				else
					if(!strcmp(warg,"expand"))
						PWRAP = 3;
					else
					{
						header();
						derrprintf (0, "Unknown argument %s for option -w.\n", warg);
						derrprintf(2, "Valid -w options are: none, on, off or expand. Use -h for more help.\n");
						exit(1);
					}
	}

	if(MAXCELL<=255)
		TYPEPOINTER=0;
	else
		if(MAXCELL==256)
			if(PWRAP!=2)
				TYPEPOINTER=0;
			else
				TYPEPOINTER=1;
		else
			if(MAXCELL<=65535)
				TYPEPOINTER=1;
			else
				if(PWRAP!=2)
					TYPEPOINTER=1;
				else
					{
						header();
						derrprintf (0, "Fatal: can't set -w on/off with -a %d\n", MAXCELL);
						derrprintf(2, "Size of array is too big for -w on/off. Use -h for more help.\n");
						exit(1);
					}

	if(wflag)
	{
		derrprintf(2, "-w %s : wrap around. Array pointer type (-a): ", warg);
		dl=2;
	}
	else
	{
		derrprintf(3, "-w none : default wrap around pointer. Array pointer type (-a): ");
		dl=3;
	}
	switch(TYPEPOINTER)
	{
		case 0:
			derrprintf(dl, "uchar. ");
			break;
		case 1:
			derrprintf(dl, "ushort. ");
			break;
	}
	if(TYPEPOINTER==TYPECELL)
		derrprintf(3, "Nice C code. ;)");
	else
		derrprintf(4, "Type cell and type pointer are not the same.");
	derrprintf(dl, "\n");

	if(pflag)
	{
		if(!strcmp(parg,"uchar"))
			PRINTINT = 0;
		else
			if(!strcmp(parg,"uint"))
				PRINTINT = 1;
			else
				if(!strcmp(parg,"both"))
					PRINTINT = 2;
				else
				{
					header();
					derrprintf(0, "Unknown argument %s for option -p.\n", parg);
					derrprintf(2, "Valid -p options are: uchar, uint or both. Use -h for more help.\n");
					exit(1);
				}
		derrprintf(2, "-p %s : printing cell values as characters, integers or both side by side\n", parg);
	}
	else
		derrprintf(3, "-p uchar : default print option\n");

	if(iflag)
	{
		if(!strcmp(iarg,"off"))
			ITERA = 0;
		else
			if(!strcmp(iarg,"on"))
				ITERA = 1;
			else
				if(!strcmp(iarg,"switch"))
					ITERA = 2;
				else
				{
					header();
					derrprintf (0, "Unknown argument %s for option -i.\n", iarg);
					derrprintf(2, "Valid -i options are: on, off, or switch. Use -h for more help.\n");
					exit(1);
				}
		derrprintf(2, "-i %s : iterative mode\n", iarg);
	}
	else
		derrprintf(3, "-i off : iterative mode\n");

	derrprintf(3, "Compiling --------------\n");
	/*-*\-----------------------------------------------------------\*-*/
    /*-*/ derrprintf(1, "pass 1... (lexical analyzer)\n");      	/*-*/
    /*-*/ if(yyparse())												/*-*/
    /*-*/ {															/*-*/
    /*-*/     derrprintf(0, "Fail! I can't compile\n\n");			/*-*/
    /*-*/     if(yyout!=stdout)										/*-*/
    /*-*/         fprintf(yyout, "//Fail! I can't compile\n\n");	/*-*/
	/*-*/	 exit(1);												/*-*/
    /*-*/  }														/*-*/
	/*-*\-----------------------------------------------------------\*-*/

	fclose(yyin);
	if(oflag)
		fclose(yyout);
	derrprintf(4, "Generated %s c source file.\n", oarg);
	switch(GENERATE)
	{
		case 'C':
			derrprintf(1, "The translation to C was a great success!\n\n");
			return 0;
		case 'S':
			if((cpid=fork()))
			{
				derrprintf(3, "Checking for GCC...\n");
				derrprintf(4, "Parent pid %d waiting gcc child pid %d\n", getpid(), cpid);
				wait(&recv);
				if(WIFEXITED(recv))
					if(WEXITSTATUS(recv)!=0)
					{
						derrprintf(0, "I can't generate ASM file. GCC error %d\n", WEXITSTATUS(recv));
						if(WEXITSTATUS(recv)==10)
							derrprintf(2, "Check to see if gcc directory (probably /usr/bin or c:\\Dev-Cpp\\bin) is in your PATH.\n");
						exit(1);
					}
					else
					{
						if(KEEP!='K')
						{
							derrprintf(3, "Removing temporary file temp.c\n");
							remove("temp.c");
						}
						else
							derrprintf(3, "Keeping temporary file temp.c\n");
						derrprintf(1, "The translation ASM was a great success!\n\n");
					}
				else
				{
					derrprintf(0, "Abnormal exit.\n");
					derrprintf(3, "Fail in execlp() made it return error code %d.\n", WIFEXITED(recv));
					exit(1);
				}
			}
			else
			{
				derrprintf(4, "renaming %s to temp.c\n", oarg);
				rename(oarg, "temp.c");
				char masm[13]="-masm=";
				strcat(masm,syntax);
				if(gflag)
				{
					derrprintf(4, "-g option selected. no optimization.\n");
					derrprintf(3, "gcc -S temp.c -o %s -Wall %s\n", oarg, masm);
					execlp("gcc", "gcc", "-S", "temp.c", "-o", oarg, "-Wall", masm, NULL);
				}
				else
				{
					derrprintf(4, "-g option deselected. optimization for size -Os.\n");
					derrprintf(3, "gcc -Os -S temp.c -o %s -Wall %s\n", oarg, masm);
					execlp("gcc", "gcc", "-Os", "-S", "temp.c", "-o", oarg, "-Wall", masm, NULL);
				}
				derrprintf(0, "I can't run gcc -S. Dumped temp.c file\n");
				derrprintf(4, "Child pid %d error code 10\n", getpid());
				exit(10);		//die alone in the mud
			}
			return 0;
		case 'B': /* creating binary file */
		case 'K': /* keeping intermediate c source file */
			if((cpid=fork()))
			{
				derrprintf(3, "Checking for GCC...\n");
				derrprintf(4, "Parent pid %d waiting gcc child pid %d\n", getpid(), cpid);
				wait(&recv);
				if(WIFEXITED(recv))
					if(WEXITSTATUS(recv)!=0)
					{
						derrprintf(0, "I can't generate binary file. GCC error %d\n", WEXITSTATUS(recv));
						if(WEXITSTATUS(recv)==10)
							derrprintf(2, "Check to see if gcc directory (probably /usr/bin or c:\\Dev-Cpp\\bin) is in your PATH.\n");
						exit(1);
					}
					else
					{
						if(KEEP!='K')
						{
							derrprintf(3, "Removing temporary file temp.c\n");
							remove("temp.c");
						}
						else
							derrprintf(3, "Keeping temporary file temp.c\n");
						derrprintf(1, "The compilation was a great success!\n\n");
					}
				else
				{
					derrprintf(0, "Abnormal exit.\n");
					derrprintf(3, "Fail in execlp() made it return error code %d.\n", WIFEXITED(recv));
					exit(1);
				}
			}
			else
			{
				derrprintf(4, "renaming %s to temp.c\n", oarg);
				rename(oarg, "temp.c");
				if(gflag)
				{
					derrprintf(4, "-g option selected. no optimization.\n");
					derrprintf(3, "gcc temp.c -o %s -Wall -g\n", oarg);
					execlp("gcc", "gcc", "temp.c", "-o", oarg, "-Wall", "-g", NULL);
				}
				else
				{
					derrprintf(4, "-g option deselected. optimization for size -Os.\n");
					derrprintf(3, "gcc -Os temp.c -o %s -Wall\n", oarg);
					execlp("gcc", "gcc", "-Os", "temp.c", "-o", oarg, "-Wall", NULL);
				}
				derrprintf(0, "I can't run gcc. Dumped temp.c file\n");
				derrprintf(4, "Child pid %d error code 10\n", getpid());
				exit(10);		//die alone in the mud
			}
			return 0;
	}
	return 0;
}
