# makefile for pgsql library for Lua
LIBNAME = pgsql
PREFIX ?= /usr/local
VERSION = 1.0.3

# Lua setup
LUA_VER ?= 5.2
LUA_VER_STR ?= 52
LUA_INCDIR ?= $(PREFIX)/include/lua$(LUA_VER_STR)
LUA_LIBDIR ?= $(PREFIX)/lib/lua$(LUA_VER_STR)
LUA_MODLIBDIR ?= $(PREFIX)/lib/lua/$(LUA_VER)
LUA_MODSHAREDIR ?= $(PREFIX)/share/lua/$(LUA_VER)

# libpq setup
PQ_INCDIR ?= $(PREFIX)/include
PQ_LIBDIR ?= $(PREFIX)/lib

# probably no need to change anything below here
#CC = gcc                                    
WARN = -ansi -pedantic -Wall                 
INCS = -I$(LUA_INCDIR) -I$(PQ_INCDIR)        
LIBS = -L$(LUA_LIBDIR) -L$(PQ_LIBDIR) -lpq   
FLAGS = -shared $(WARN) $(INCS) $(LIBS)      
CFLAGS = -O2 -fPIC                           
                                             
SOURCES = lua$(LIBNAME).c                    
HEADERS = lua$(LIBNAME).h                    
OBJECTS = $(SOURCES:.c=.o)                   
TARGET = $(LIBNAME).so                       
                                             
all:    $(TARGET)

$(TARGET): $(SOURCES) $(HEADERS)
        $(CC) $(FLAGS) $(CFLAGS) -o $@ $(SOURCES)

clean:
        rm -f $(OBJECTS) $(TARGET) core core.*

install: $(TARGET)
        install -d $(DESTDIR)$(LUA_MODLIBDIR)
        install -vs $(TARGET) $(DESTDIR)$(LUA_MODLIBDIR)

uninstall:
        -rm $(DESTDIR)$(LUA_MODLIBDIR)/$(TARGET)
