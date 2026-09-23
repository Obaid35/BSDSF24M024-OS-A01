# PA-01 — Report

**Name:** Obaid ur Rehman
**Roll Number:** BSDSF24M024
**Repository:** https://github.com/Obaid35/BSDSF24M024-OS-A01

---

## Feature 2 — Multi-file Project using Make

### Q1. Explain the linking rule `$(TARGET): $(OBJECTS)`. How does it differ from a Makefile rule that links against a library?

In this Makefile the target (the final executable) depends directly on **all the object files** of the project:

```make
$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $(OBJS)
```

The linker receives every `.o` file by name and merges their `.text`, `.data` and `.bss` sections into one executable. Every object file is unconditionally placed inside the final binary.

When linking **against a library** the rule instead looks like:

```make
$(TARGET): $(MAINOBJ) $(STATIC_LIB)
	$(CC) $(CFLAGS) -o $@ $(MAINOBJ) -Llib -lmyutils
```

Differences:

| Direct object linking | Linking against a library |
|---|---|
| Each `.o` listed explicitly | Library named once with `-l`, path given with `-L` |
| Linker includes **all** objects | Linker pulls **only those members of the archive that resolve undefined symbols** |
| No archive step | Needs an extra step (`ar`/`ranlib` for `.a`, `gcc -shared` for `.so`) |
| Order of `.o` files does not matter much | Libraries must come **after** the objects that use them |

### Q2. What is a `git tag` and why is it useful? Difference between a simple tag and an annotated tag?

A **tag** is a permanent, human readable name for one particular commit. Branches keep moving as new commits arrive, a tag does not: it marks "this exact state is version 0.1.1". This makes it possible to return to, build, or release a known version at any time in the future.

| Lightweight (simple) tag | Annotated tag |
|---|---|
| `git tag v0.1.1` | `git tag -a v0.1.1 -m "message"` |
| Just a pointer to a commit | A **full object** in the Git database |
| Stores no extra information | Stores tagger name, email, date and message, and can be GPG signed |
| Good for temporary, private marks | Recommended for **releases** — this assignment requires annotated tags |

Tags are not pushed by `git push` automatically; they must be pushed explicitly (`git push origin v0.1.1-multifile` or `git push --tags`).

### Q3. Purpose of a GitHub "Release"? Significance of attaching binaries?

A Release turns a tag into a **published, documented version** of the project: it has a title, release notes describing what changed, and a permanent download page.

Attaching the compiled binary matters because a user who only wants to *run* the program should not have to install a toolchain and compile the source. The attached `client` executable is exactly the artifact that was tested for that version, so everybody runs an identical binary. This is the same idea behind distributing `.deb`/`.rpm` packages rather than source tarballs.

---

## Feature 3 — Static Library

### Q4. Compare the Makefile from Part 2 and Part 3. Key differences?

**New variables**

```make
AR          = ar
ARFLAGS     = rcs
LIBDIR      = lib
LIBNAME     = myutils
STATIC_LIB  = $(LIBDIR)/lib$(LIBNAME).a
LIBOBJS     = $(OBJDIR)/mystrfunctions.o $(OBJDIR)/myfilefunctions.o
MAINOBJ     = $(OBJDIR)/main.o
```

The object files are now split into two groups: the **library objects** and `main.o`, because `main.o` must never become part of a library.

**New rule — building the archive**

```make
$(STATIC_LIB): objects
	$(AR) $(ARFLAGS) $@ $(LIBOBJS)
	ranlib $@
```

**Changed rule — linking**

```make
$(TARGET): $(STATIC_LIB) $(MAINOBJ)
	$(CC) $(CFLAGS) -o $@ $(MAINOBJ) -L$(LIBDIR) -l$(LIBNAME)
```

Instead of listing the utility objects, the link line now uses `-L` (where to search) and `-l` (which library). The executable is also renamed to `client_static`.

### Q5. Purpose of the `ar` command? Why is `ranlib` used immediately after?

`ar` is the **archiver**. It bundles several relocatable object files into a single archive file (`libmyutils.a`). An archive is simply a container — the objects inside it are unchanged.

`ranlib` adds an **index (symbol table) to the archive**: a map of "which symbol lives in which member". Without that index the linker would have to scan every member each time it needs a symbol, and older linkers refuse to use an archive that has no index at all. With the GNU tools, `ar` with the `s` flag (`ar rcs`) already writes the index, so `ranlib` is then only a harmless confirmation kept for portability.

### Q6. Running `nm` on `client_static` — are symbols like `mystrlen` present? What does that tell you?

Yes:

```
$ nm bin/client_static | grep mystrlen
0000000000401196 T mystrlen
```

`T` means the symbol is **defined in the text (code) section of this executable**. So during static linking the linker copied the machine code of `mystrlen` from `libmyutils.a` straight into the binary. Consequences:

* the executable is self-contained — it runs on a machine that does not have `libmyutils.a` at all;
* the executable is larger;
* if the library is fixed later, the program must be **re-linked** to get the fix.

---

## Feature 4 — Dynamic Library

### Q7. What is Position-Independent Code (`-fPIC`) and why is it required for shared libraries?

Position-Independent Code is machine code that executes correctly **no matter which address it is loaded at**. Instead of hard-coded absolute addresses it uses PC-relative addressing and reaches global data through the GOT (Global Offset Table).

A shared library is loaded into many different processes, and each process may map it at a different virtual address (especially with ASLR). If the code contained absolute addresses fixed at link time, it would have to be patched separately in every process — which would also destroy the main benefit of sharing, because a patched page can no longer be shared read-only between processes. With `-fPIC` one single copy of the library's code pages in physical memory can be mapped by every process.

### Q8. Explain the file size difference between the static and dynamic clients.

```
$ ls -lh bin/
-rwxr-xr-x 1 user user  25K client_static
-rwxr-xr-x 1 user user  17K client_dynamic
```

`client_static` physically contains the machine code of every library function it uses, so the library code counts towards its size. `client_dynamic` contains only a **reference** to `libmyutils.so` plus the PLT/GOT bookkeeping that lets the dynamic linker resolve the functions at run time; the actual code stays in the `.so` file. The more library code a program uses, the bigger the difference becomes — and system wide the saving is much larger still, because one copy of a shared library serves every process that uses it.

### Q9. What is `LD_LIBRARY_PATH`? Why was it necessary, and what does it tell you about the dynamic loader?

`LD_LIBRARY_PATH` is an environment variable holding a colon separated list of **extra directories that the dynamic loader searches for shared libraries before the standard locations**.

Running `./bin/client_dynamic` without it fails:

```
./bin/client_dynamic: error while loading shared libraries: libmyutils.so:
cannot open shared object file: No such file or directory
```

The path that was given at link time (`-Llib`) is used by the **static linker**, not at run time. At run time the loader (`ld-linux-x86-64.so.2`) searches `DT_RUNPATH`, `LD_LIBRARY_PATH`, the `ldconfig` cache (`/etc/ld.so.cache`) and finally `/lib` and `/usr/lib`. Our private `lib/` directory is in none of those, so the library is not found.

After

```bash
export LD_LIBRARY_PATH=$PWD/lib:$LD_LIBRARY_PATH
```

`ldd bin/client_dynamic` shows it resolving to our own copy and the program runs. This demonstrates that with dynamic linking the executable is **incomplete on disk**: part of the linking job is deferred to the operating system's loader every single time the program starts.

---

## Feature 5 — Man Pages and Installation

**What was done:** a `man/man3/` directory holds one groff formatted page per library function (`mystrlen.3`, `mystrcpy.3`, `mystrncpy.3`, `mystrcat.3`, `wordCount.3`, `mygrep.3`), each with `.TH`, `.SH NAME`, `.SH SYNOPSIS`, `.SH DESCRIPTION` and `.SH AUTHOR` sections. Section **3** was chosen because it is the manual section for library functions.

The Makefile's `install` target copies the executable to `/usr/local/bin/client` (a directory already on `PATH`, so the program can be started from anywhere), copies the pages to `/usr/local/share/man/man3/` and refreshes the index with `mandb`. `uninstall` removes both again.

```bash
sudo make install
client          # runs from any directory
man mystrlen    # shows the manual page
```
