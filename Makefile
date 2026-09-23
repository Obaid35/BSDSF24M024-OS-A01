# ============================================================
#  Makefile - Feature 4 : STATIC + DYNAMIC library build
#  lib/libmyutils.a   -> bin/client_static
#  lib/libmyutils.so  -> bin/client_dynamic   (needs -fPIC)
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
SHARED_LIB  = $(LIBDIR)/lib$(LIBNAME).so

TARGET_S    = $(BINDIR)/client_static
TARGET_D    = $(BINDIR)/client_dynamic

LIBOBJS     = $(OBJDIR)/mystrfunctions.o $(OBJDIR)/myfilefunctions.o
PICOBJS     = $(OBJDIR)/mystrfunctions.pic.o $(OBJDIR)/myfilefunctions.pic.o
MAINOBJ     = $(OBJDIR)/main.o

all: $(TARGET_S) $(TARGET_D)

# ---------- static ----------
$(TARGET_S): $(STATIC_LIB) $(MAINOBJ)
	$(CC) $(CFLAGS) -o $@ $(MAINOBJ) -L$(LIBDIR) -l$(LIBNAME)
	@echo "Built $@ (static)"

$(STATIC_LIB): $(LIBOBJS)
	$(AR) $(ARFLAGS) $@ $(LIBOBJS)
	ranlib $@

# ---------- dynamic ----------
# -shared turns position independent objects into a shared object
$(SHARED_LIB): $(PICOBJS)
	$(CC) -shared -o $@ $(PICOBJS)

$(PICOBJS): | picobjects
	@echo "Created $@"

# NOTE: the linker prefers the .so when both exist, so we link the
# dynamic client against the shared library explicitly.
$(TARGET_D): $(SHARED_LIB) $(MAINOBJ)
	$(CC) $(CFLAGS) -o $@ $(MAINOBJ) -L$(LIBDIR) -l$(LIBNAME)
	@echo "Built $@ (dynamic)  -> run 'make runshared'"

$(LIBOBJS) $(MAINOBJ): | objects

objects:
	$(MAKE) -C $(SRCDIR) all

picobjects:
	$(MAKE) -C $(SRCDIR) pic

# run the dynamic client after telling the loader where our .so lives
runshared: $(TARGET_D)
	LD_LIBRARY_PATH=$(CURDIR)/$(LIBDIR) ./$(TARGET_D)

compare: all
	@echo "--- size difference ---"
	ls -lh $(BINDIR)/
	@echo "--- shared library dependencies ---"
	LD_LIBRARY_PATH=$(CURDIR)/$(LIBDIR) ldd $(TARGET_D)

clean:
	$(MAKE) -C $(SRCDIR) clean
	rm -f $(BINDIR)/client $(BINDIR)/client_static $(BINDIR)/client_dynamic
	rm -f $(STATIC_LIB) $(SHARED_LIB)
	@echo "Cleaned"

.PHONY: all objects picobjects runshared compare clean
