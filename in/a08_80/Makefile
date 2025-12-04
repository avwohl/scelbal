# Wedit Makefile for project a08_80
SRCDIR=c:\lcc\projects\a08_80
CFLAGS=-I"c:\lcc\include"  -g2 
CC=$(LCCROOT)\bin\lcc.exe
LINKER=$(LCCROOT)\bin\lcclnk.exe
OBJS=\
	a8_80util.obj \
	a8_80eval.obj \
	a8_80.obj

LIBS=
EXE=a08_80.exe

$(EXE):	$(OBJS) Makefile
	$(LINKER)  -subsystem console -o $(SRCDIR)\lcc\a08_80.exe $(OBJS) $(LIBS)

# Build a8_80util.c
A8_80UTIL_C=\
	$(SRCDIR)\a8_80.h\

a8_80util.obj: $(A8_80UTIL_C) $(SRCDIR)\a8_80util.c
	$(CC) -c $(CFLAGS) $(SRCDIR)\a8_80util.c

# Build a8_80eval.c
A8_80EVAL_C=\
	$(SRCDIR)\a8_80.h\

a8_80eval.obj: $(A8_80EVAL_C) $(SRCDIR)\a8_80eval.c
	$(CC) -c $(CFLAGS) $(SRCDIR)\a8_80eval.c

# Build a8_80.c
A8_80_C=\
	$(SRCDIR)\a8_80.h\

a8_80.obj: $(A8_80_C) $(SRCDIR)\a8_80.c
	$(CC) -c $(CFLAGS) $(SRCDIR)\a8_80.c

link:
	$(LINKER)  -subsystem console -o $(SRCDIR)\lcc\a08_80.exe $(OBJS) $(LIBS)

clean:
	del $(OBJS) a08_80.exe
