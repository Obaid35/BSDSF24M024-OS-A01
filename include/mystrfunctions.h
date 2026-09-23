// File: include/mystrfunctions.h
// Custom implementations of common string manipulation functions.

#ifndef MYSTRFUNCTIONS_H
#define MYSTRFUNCTIONS_H

// Returns the number of characters in s, excluding the terminating '\0'.
// Returns -1 if s is NULL.
int mystrlen(const char* s);

// Copies the string src (including '\0') into dest.
// Returns the number of characters copied (excluding '\0'), -1 on failure.
int mystrcpy(char* dest, const char* src);

// Copies at most n characters of src into dest, padding with '\0' if src is shorter.
// Returns the number of characters actually copied from src, -1 on failure.
int mystrncpy(char* dest, const char* src, int n);

// Appends src at the end of dest.
// Returns the length of the resulting string in dest, -1 on failure.
int mystrcat(char* dest, const char* src);

#endif
