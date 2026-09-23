// File: src/mystrfunctions.c
// Implementation of the custom string functions.

#include "../include/mystrfunctions.h"
#include <stddef.h>          // for NULL

// Walk over the string until the terminating null byte and count the steps.
int mystrlen(const char* s) {
    int count = 0;

    if (s == NULL)                  // defensive check
        return -1;

    while (s[count] != '\0')        // '\0' marks the end of a C string
        count++;                    // it is NOT counted itself

    return count;
}

// Copy every character of src into dest and terminate dest with '\0'.
int mystrcpy(char* dest, const char* src) {
    int i = 0;

    if (dest == NULL || src == NULL)
        return -1;

    while (src[i] != '\0') {
        dest[i] = src[i];
        i++;
    }
    dest[i] = '\0';                 // must be added by hand, the loop stops before it

    return i;                       // number of characters copied
}

// Copy at most n characters. If src is shorter than n, pad the rest with '\0'
// (this is the behaviour of the standard strncpy).
int mystrncpy(char* dest, const char* src, int n) {
    int i = 0;
    int copied;

    if (dest == NULL || src == NULL || n < 0)
        return -1;

    while (i < n && src[i] != '\0') {
        dest[i] = src[i];
        i++;
    }
    copied = i;                     // how much really came from src

    while (i < n) {                 // pad the remaining room with '\0'
        dest[i] = '\0';
        i++;
    }

    return copied;
}

// Find the end of dest, then copy src from that position onwards.
int mystrcat(char* dest, const char* src) {
    int len;
    int i = 0;

    if (dest == NULL || src == NULL)
        return -1;

    len = mystrlen(dest);           // reuse our own function

    while (src[i] != '\0') {
        dest[len + i] = src[i];
        i++;
    }
    dest[len + i] = '\0';

    return len + i;                 // length of the resulting string
}
