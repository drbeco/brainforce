/*
    BrainForce Compiler version Apr 15 2011_20:02:21, An esoteric programming language.
    Copyright (C) 2011  Ruben Carlo Benante <rcb [at] beco.cc>
    WebPage: <http://www.beco.cc/compiler/brainforce>
    License: GNU/GPL 2 <http://www.beco.cc/doc/gpl.html>
*/

#include <stdio.h>
#include <stdlib.h>
#define MAX 200
#define ZMIN 0
#define ZMAX 200

#define SHARP 1
#define SHARPMIN (((i-SHARP)>0)?(i-SHARP):0)
#define SHARPMAX ((i+SHARP)<(MAX)?(i+SHARP):(MAX))

void dot(int i) {putc(i, stdout);}
int comma(void) {return getc(stdin);}

int main(void)
{
  unsigned char t[MAX], i, s;

  for(i=0; i<MAX; i++)
    t[i]=0;

  i=0;

  t[i]--;
  t[i]++;
  t[i]=comma();
  dot(t[i]);
  i++;
  t[i]=comma();
  t[i]++;
  dot(t[i]);
  i++;
  t[i]=comma();
  t[i]++;
  dot(t[i]);
  i--;
  t[i]++;
  t[i]++;
  dot(t[i]);
/*---------------------------------------------*/
  fprintf(stderr, "\n# debug: pointer at %d", i);
  for(s=SHARPMIN; s<SHARPMAX; s++)
    fprintf(stderr, "\n#[%u]=%u", s, t[s]);
  fprintf(stderr, "\n");
/*---------------------------------------------*/
  while(t[i])
  {
    t[i]--;
  }
  dot(t[i]);
  i--;
  dot(t[i]);

  return 0;
}
