# File: src/Makefile   (compiles every .c into obj/ ; called by the root Makefile)

CC       = gcc
CFLAGS   = -Wall -g -I../include
OBJDIR   = ../obj

OBJS     = $(OBJDIR)/main.o $(OBJDIR)/mystrfunctions.o $(OBJDIR)/myfilefunctions.o
PICOBJS  = $(OBJDIR)/mystrfunctions.pic.o $(OBJDIR)/myfilefunctions.pic.o

all: $(OBJS)

pic: $(PICOBJS)

# position independent objects (needed for the shared library)
$(OBJDIR)/%.pic.o: %.c
	$(CC) $(CFLAGS) -fPIC -c $< -o $@

# normal objects
$(OBJDIR)/%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJDIR)/*.o

.PHONY: all pic clean
