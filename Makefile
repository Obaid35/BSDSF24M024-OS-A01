# ============================================================
#  Makefile - Feature 3 : STATIC library build
#  Creates lib/libmyutils.a with ar, then links bin/client_static
# ============================================================

CC          = gcc
CFLAGS      = -Wall -g -Iinclude
AR          = ar
ARFLAGS     = rcs

SRCDIR      = src
OBJDIR      = obj
BINDIR      = bin
LIBDIR      = lib

LIBNAME     = myutils
STATIC_LIB  = $(LIBDIR)/lib$(LIBNAME).a
TARGET      = $(BINDIR)/client_static

LIBOBJS     = $(OBJDIR)/mystrfunctions.o $(OBJDIR)/myfilefunctions.o
MAINOBJ     = $(OBJDIR)/main.o

all: $(TARGET)

# link main.o against our own static library
$(TARGET): $(STATIC_LIB) $(MAINOBJ)
	$(CC) $(CFLAGS) -o $@ $(MAINOBJ) -L$(LIBDIR) -l$(LIBNAME)
	@echo "Built $@ (static)"

# create the archive from the utility objects (main.o is NOT part of a library)
$(STATIC_LIB): $(LIBOBJS)
	$(AR) $(ARFLAGS) $@ $(LIBOBJS)
	ranlib $@
	@echo "Created $@"

$(LIBOBJS) $(MAINOBJ): | objects

objects:
	$(MAKE) -C $(SRCDIR) all

run: $(TARGET)
	./$(TARGET)

# quick analysis targets (useful for REPORT.md)
analyze: $(TARGET)
	@echo "--- contents of the archive ---"
	$(AR) -t $(STATIC_LIB)
	@echo "--- is mystrlen inside the executable? ---"
	nm $(TARGET) | grep mystrlen
	@echo "--- size ---"
	ls -lh $(TARGET)

clean:
	$(MAKE) -C $(SRCDIR) clean
	rm -f $(BINDIR)/client_static $(STATIC_LIB)
	@echo "Cleaned"

.PHONY: all objects run analyze clean
