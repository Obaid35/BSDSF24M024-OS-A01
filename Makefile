# ============================================================
#  Makefile - Feature 2 : multi-file build (no library yet)
#  Root makefile. It calls src/Makefile (recursive approach).
# ============================================================

CC      = gcc
CFLAGS  = -Wall -g -Iinclude
SRCDIR  = src
OBJDIR  = obj
BINDIR  = bin
TARGET  = $(BINDIR)/client
OBJS    = $(OBJDIR)/main.o $(OBJDIR)/mystrfunctions.o $(OBJDIR)/myfilefunctions.o

all: $(TARGET)

# link step: all object files -> one executable
$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $(OBJS)
	@echo "Built $@"

# ye objects sub-make banata hai (order-only prerequisite se timestamp sahi rehta hai)
$(OBJS): | objects

# recursive make: build the objects inside src/
objects:
	$(MAKE) -C $(SRCDIR) all

run: $(TARGET)
	./$(TARGET)

clean:
	$(MAKE) -C $(SRCDIR) clean
	rm -f $(BINDIR)/client
	@echo "Cleaned"

.PHONY: all objects run clean
