/*#undef __STDC__*/
#include <stdio.h>
#include <stdlib.h>


int *initArray(int size, int init)
{int i;
 int *a = (int *)malloc(size*sizeof(int));
 for(i=0;i<size;i++) a[i]=init;
 return a;
}

struct string {int length; unsigned char chars[1];};

int *allocRecord(struct string const *desc, int size)
{int i;
 int *p, *a;
 p = a = (int *)malloc(size);
 for(i=0;i<size;i+=sizeof(int)) *p++ = 0;
 return a;
}

int stringEqual(struct string *s, struct string *t)
{int i;
 if (s==t) return 1;
 if (s->length!=t->length) return 0;
 for(i=0;i<s->length;i++) if (s->chars[i]!=t->chars[i]) return 0;
 return 1;
}

long _Tiger_strcmp(struct string *s, struct string *t)
{int i, sn = s->length, tn = t->length, n = sn < tn ? sn:tn;
  for(i=0;i<n;i++) {
    unsigned c = s->chars[i];
    unsigned d = t->chars[i];
    if (c < d) return -1; else if (c > d) return 1;
  }
  return sn < tn ? -1 : sn == tn ? 0 : 1;
}

void print(struct string *s)
{int i; unsigned char *p=s->chars;
 for(i=0;i<s->length;i++,p++) putchar(*p);
}

void flush()
{
 fflush(stdout);
}

struct string consts[256];
struct string empty={0,""};

int main()
{
  extern int _Tiger_main(int);
  int i;
  for(i=0;i<256;i++)
   {consts[i].length=1;
    consts[i].chars[0]=i;
   }
 return _Tiger_main(0 /* static link!? */);
}

int ord(struct string *s)
{
 if (s->length==0) return -1;
 else return s->chars[0];
}

struct string *chr(int i)
{
 if (i<0 || i>=256) 
   {printf("chr(%d) out of range\n",i); exit(1);}
 return consts+i;
}

int size(struct string *s)
{ 
 return s->length;
}

struct string *substring(struct string *s, int first, int n)
{
 if (first<0 || first+n>s->length)
   {printf("substring([%d],%d,%d) out of range\n",s->length,first,n);
    exit(1);}
 if (n==1) return consts+s->chars[first];
 {struct string *t = (struct string *)malloc(sizeof(int)+n);
  int i;
  t->length=n;
  for(i=0;i<n;i++) t->chars[i]=s->chars[first+i];
  return t;
 }
}

struct string *concat(struct string *a, struct string *b)
{
 if (a->length==0) return b;
 else if (b->length==0) return a;
 else {int i, n=a->length+b->length;
       struct string *t = (struct string *)malloc(sizeof(int)+n);
       t->length=n;
       for (i=0;i<a->length;i++)
	 t->chars[i]=a->chars[i];
       for(i=0;i<b->length;i++)
	 t->chars[i+a->length]=b->chars[i];
       return t;
     }
}

int not(int i)
{ return !i;
}

/*#undef getchar*/

struct string *_Tiger_getchar()
{int i=getc(stdin);
 if (i==EOF) return &empty;
 else return consts+i;
}
