# makefile for the package lxcunicon

UNICON=unicon
UC=$(UNICON)
UFLAGS=-c -u

RM= rm -f
MAKE=make

PKGNAME=lxcunicon

SAMPLES=hellolxc

UFILES=$(PKGNAME).u 

USRC=$(PKGNAME).icn 
CSRC=$(PKGNAME).c

TARGET=$(SAMPLES) 

all: $(TARGET) $(PKGNAME).so $(UFILES)

pure:
	$(MAKE) clean
	$(MAKE) all

samples: $(SAMPLES)

hellolxc: SO  $(UFILES)
	 $(UC) -u -o hellolxc $(UFILES)

SO: $(SSRC)
	gcc -std=c99 -shared -g -O0 -fpic -o $(PKGNAME).so $(PKGNAME).c -llxc

%.u:	%.icn
	 $(UC) $(UFLAGS) $<

zip:
	 zip $(PKGNAME).zip makefile *.icn *.c

clean:
	$(RM) *.u  $(TARGET) *~ $(PKGNAME).so uniclass.dir uniclass.pag



