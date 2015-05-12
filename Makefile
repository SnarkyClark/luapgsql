# makefile for pgsql library for Lua
PREFIX ?= /usr/local
VERSION = 1.0.1

# Lua setup
LUAINC = $(PREFIX)/include/lua51
LUALIB = $(PREFIX)/lib/lua51
LUAEXT = $(PREFIX)/lib/lua/5.1

# libpq setup
LPQINC = $(PREFIX)/include
LPQLIB = $(PREFIX)/lib
 
# probably no need to change anything below here
#CC = gcc
WARN = -ansi -pedantic -Wall
INCS = -I$(LUAINC) -I$(LPQINC)
LIBS = -L$(LUALIB) -L$(LPQLIB) -lpq
FLAGS = -shared $(WARN) $(INCS) $(LIBS) 
CFLAGS = -O2 -fPIC

LIBNAME = pgsql
SOURCES = lua$(LIBNAME).c
HEADERS = lua$(LIBNAME).h
OBJECTS = $(SOURCES:.c=.o)
TARGET = $(LIBNAME).so

all:	$(TARGET)

$(TARGET): $(SOURCES) $(HEADERS)
	$(CC) $(FLAGS) $(CFLAGS) -o $@ $(SOURCES)

clean:
	rm -f $(OBJECTS) $(TARGET) core core.*

install: $(TARGET)
	install -d $(DESTDIR)$(LUAEXT)
	install -vs $(TARGET) $(DESTDIR)$(LUAEXT)

uninstall:
	-rm $(DESTDIR)$(LUAEXT)/$(TARGET)

package:
	sh mkpkgng.sh $(LIBNAME) $(VERSION)