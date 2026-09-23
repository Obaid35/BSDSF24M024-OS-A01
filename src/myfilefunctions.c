// File: src/myfilefunctions.c
// Implementation of the file utility functions.

#include "../include/myfilefunctions.h"
#include <stdlib.h>         // malloc, realloc, free
#include <string.h>         // strstr, strlen, strcpy
#include <ctype.h>          // isspace

#define MAX_LINE 1024       // longest line mygrep() can read at once

// Reads the whole stream character by character and counts
// lines ('\n'), words (groups of non-space characters) and characters.
int wordCount(FILE* file, int* lines, int* words, int* chars) {
    int c;
    int inWord = 0;                 // 0 = we are between words, 1 = inside a word

    if (file == NULL || lines == NULL || words == NULL || chars == NULL)
        return -1;                  // failure

    *lines = 0;
    *words = 0;
    *chars = 0;

    while ((c = fgetc(file)) != EOF) {
        (*chars)++;                 // every character counts

        if (c == '\n')
            (*lines)++;             // a line ends at every newline

        if (isspace(c)) {
            inWord = 0;             // space ends the current word
        } else if (inWord == 0) {
            inWord = 1;             // first non-space character after a space
            (*words)++;             // => a new word has started
        }
    }

    return 0;                       // success
}

// Reads the file line by line, keeps a copy of every line that contains
// search_str and returns how many such lines were found.
// The array itself is allocated here, so the caller receives it through char***.
int mygrep(FILE* fp, const char* search_str, char*** matches) {
    char line[MAX_LINE];
    char** result = NULL;           // array of string pointers
    char** tmp;
    int count = 0;

    if (fp == NULL || search_str == NULL || matches == NULL)
        return -1;

    while (fgets(line, sizeof(line), fp) != NULL) {

        if (strstr(line, search_str) != NULL) {         // does the line contain it?

            tmp = realloc(result, (count + 1) * sizeof(char*));   // grow the array by one
            if (tmp == NULL) {
                freeMatches(result, count);
                return -1;
            }
            result = tmp;

            result[count] = malloc(strlen(line) + 1);   // +1 for the '\0'
            if (result[count] == NULL) {
                freeMatches(result, count);
                return -1;
            }
            strcpy(result[count], line);                // keep our own copy of the line
            count++;
        }
    }

    *matches = result;              // hand the array back to the caller
    return count;                   // number of matching lines
}

// Frees every string and then the array itself.
void freeMatches(char** matches, int count) {
    int i;

    if (matches == NULL)
        return;

    for (i = 0; i < count; i++)
        free(matches[i]);

    free(matches);
}
