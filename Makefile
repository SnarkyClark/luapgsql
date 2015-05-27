# makefile for pgsql library for Lua
LIBNAME = pgsql
PREFIX ?= /usr/local
VERSION = 1.0.1

# Lua setup
LUAINC = $(PREFIX)/include/lua51
LUALIB = $(PREFIX)/lib/lua51
LUAEXT = $(PREFIX)/lib/lua/5.1

# libp setup
LIBINC = $(PREFIX)/include
LIBLIB = $(PREFIX)/lib
 
# probably no need to change anything below here
#CC = gcc
WARN = -ansi -pedantic -Wall
INCS = -I$(LUAINC) -I$(LIBINC)
LIBS = -L$(LUALIB) -L$(LIBLIB) -lpq
FLAGS = -shared $(WARN) $(INCS) $(LIBS) 
CFLAGS = -O2 -fPIC

SOURCES = lua$(LIBNAME).c
HEADERS = lua$(LIBNAME).h
OBJECTS = $(SOURCES:.c=.o)
TARGET = $(LIBNAME).so

all:	$(TARGET)

$(TARGET): $(SOURCES) $(HEADERS)
	$(CC) $(FLAGS) $(CFLAGS) -o $@ $(SOURCES)

clean:
	rm -f $(OBJECTS) $(TARGET) core core.* *.txz

install: $(TARGET)
	install -d $(DESTDIR)$(LUAEXT)
	install -vs $(TARGET) $(DESTDIR)$(LUAEXT)

uninstall:
	-rm $(DESTDIR)$(LUAEXT)/$(TARGET)

package:
	sh mkpkgng.sh $(LIBNAME) $(VERSION)
	cp *.txz /usr/ports/packages/All/