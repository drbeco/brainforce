/*
    BrainForce Compiler version Apr  6 2011_06:11:21, by Dr. Beco
    Email: rcb@beco.cc
    WebPage: www.beco.cc/compiler/brainforce
    License: CC-3.0 http://creativecommons.org/licenses/by-nc-sa/3.0/
*/
#include <stdlib.h>
#include <stdio.h>
#define MAX 10000

int main(void)
{
  unsigned int tape[MAX], *t, i;
  for(i=0; i<MAX; i++)
    tape[i]=0;

  t=tape;

  (*t)--;
  (*t)--;
  (*t)--;
  printf("[%u]=", (unsigned)(t-tape));
  scanf("%u", t);
  (*t)++;
  (*t)++;
  printf("[%u]=%u\n", (unsigned)(t-tape), *t);
  t++;
  (*t)++;
  (*t)++;
  printf("[%u]=%u\n", (unsigned)(t-tape), *t);
  for(i=0; i<10; i++)
    printf("#[%u]=%u\n", i, tape[i]);
  while(*t)
  {
    (*t)--;
  }
  printf("[%u]=%u\n", (unsigned)(t-tape), *t);
  t--;
  printf("[%u]=%u\n", (unsigned)(t-tape), *t);
  fputc('\n', stdout);
  return 0;
}
