# ============================================================
#  Makefile - Feature 5 : FINAL (static + dynamic + install)
#  Targets: all, run, runshared, compare, analyze,
#           install, uninstall, clean
# ============================================================

CC          = gcc
CFLAGS      = -Wall -g -Iinclude
AR          = ar
ARFLAGS     = rcs

SRCDIR      = src
OBJDIR      = obj
BINDIR      = bin
LIBDIR      = lib
MANDIR      = man/man3

LIBNAME     = myutils
STATIC_LIB  = $(LIBDIR)/lib$(LIBNAME).a
SHARED_LIB  = $(LIBDIR)/lib$(LIBNAME).so

TARGET      = $(BINDIR)/client
TARGET_S    = $(BINDIR)/client_static
TARGET_D    = $(BINDIR)/client_dynamic

LIBOBJS     = $(OBJDIR)/mystrfunctions.o $(OBJDIR)/myfilefunctions.o
PICOBJS     = $(OBJDIR)/mystrfunctions.pic.o $(OBJDIR)/myfilefunctions.pic.o
MAINOBJ     = $(OBJDIR)/main.o

# where "make install" puts things
PREFIX      = /usr/local
BININSTALL  = $(PREFIX)/bin
MANINSTALL  = $(PREFIX)/share/man/man3

all: $(TARGET) $(TARGET_S) $(TARGET_D)

# ---------- plain multi-file build ----------
$(TARGET): $(MAINOBJ) $(LIBOBJS)
	$(CC) $(CFLAGS) -o $@ $(MAINOBJ) $(LIBOBJS)

# ---------- static ----------
$(TARGET_S): $(STATIC_LIB) $(MAINOBJ)
	$(CC) $(CFLAGS) -o $@ $(MAINOBJ) -L$(LIBDIR) -l$(LIBNAME)

$(STATIC_LIB): $(LIBOBJS)
	$(AR) $(ARFLAGS) $@ $(LIBOBJS)
	ranlib $@

# ---------- dynamic ----------
$(SHARED_LIB): $(PICOBJS)
	$(CC) -shared -o $@ $(PICOBJS)

$(PICOBJS): | picobjects

$(TARGET_D): $(SHARED_LIB) $(MAINOBJ)
	$(CC) $(CFLAGS) -o $@ $(MAINOBJ) -L$(LIBDIR) -l$(LIBNAME)

$(LIBOBJS) $(MAINOBJ): | objects

objects:
	$(MAKE) -C $(SRCDIR) all

picobjects:
	$(MAKE) -C $(SRCDIR) pic

# ---------- helpers ----------
run: $(TARGET_S)
	./$(TARGET_S)

runshared: $(TARGET_D)
	LD_LIBRARY_PATH=$(CURDIR)/$(LIBDIR) ./$(TARGET_D)

compare: all
	ls -lh $(BINDIR)/
	LD_LIBRARY_PATH=$(CURDIR)/$(LIBDIR) ldd $(TARGET_D)

analyze: $(TARGET_S)
	$(AR) -t $(STATIC_LIB)
	nm $(TARGET_S) | grep mystrlen
	readelf -h $(TARGET_S) | head -12

# ---------- install / uninstall ----------
install: $(TARGET_S)
	@cp $(TARGET_S) $(BININSTALL)/client
	@chmod 755 $(BININSTALL)/client
	@mkdir -p $(MANINSTALL)
	@cp $(MANDIR)/*.3 $(MANINSTALL)/
	@mandb -q
	@echo "Installed client in $(BININSTALL) and man pages in $(MANINSTALL)"

uninstall:
	@rm -f $(BININSTALL)/client
	@rm -f $(MANINSTALL)/mystrlen.3 $(MANINSTALL)/mystrcpy.3 $(MANINSTALL)/mystrncpy.3
	@rm -f $(MANINSTALL)/mystrcat.3 $(MANINSTALL)/wordCount.3 $(MANINSTALL)/mygrep.3
	@mandb -q
	@echo "Uninstalled client and man pages"

clean:
	$(MAKE) -C $(SRCDIR) clean
	rm -f $(TARGET) $(TARGET_S) $(TARGET_D) $(STATIC_LIB) $(SHARED_LIB)
	@echo "Cleaned"

.PHONY: all objects picobjects run runshared compare analyze install uninstall clean
