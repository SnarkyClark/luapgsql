# makefile for pgsql library for Lua

# Lua setup
LUA= /usr/local
LUAINC= $(LUA)/include/lua51
LUALIB= $(LUA)/lib/lua51

# these will probably work if Lua has been installed globally
#LUA= /usr/local/
#LUAINC= $(LUA)/include
#LUALIB= $(LUA)/lib
#LUABIN= $(LUA)/bin

# libpq setup
LPQ= /usr/local
LPQINC= $(LPQ)/include
LPQLIB= $(LPQ)/lib
 
# probably no need to change anything below here
CC= gcc
CFLAGS= $(INCS) $(WARN) -O2 $G
WARN= -ansi -pedantic -Wall
INCS= -I$(LUAINC) -I$(LPQINC)
LIBS= -L$(LUALIB) -L$(LPQLIB) -lpq

MYNAME= pgsql
MYLIB= lua$(MYNAME)

OBJS= $(MYLIB).o
#STATIC_OBJS= foobar.o
T= $(MYNAME).so

all:	so

o:	$(MYLIB).o

so:	$T

$T:	$(OBJS)
	$(CC) -o $@ -shared $(OBJS) $(STATIC_OBJS) $(LIBS) 

clean:
	rm -f $(OBJS) $T core core.*

#doc:
#	@echo "$(MYNAME) library:"
#	@fgrep '/**' $(MYLIB).c | cut -f2 -d/ | tr -d '*' | sort | column

# distribution

D= $(MYNAME)
A= $(MYLIB).tgz
TOTAR= Makefile,$(MYLIB).c,test.lua

tar:	clean
	tar zcvf $A -C .. $D
#	tar zcvf $A -C .. $D/{$(TOTAR)}

distr:	tar
	touch -r $A .stamp

# eof
