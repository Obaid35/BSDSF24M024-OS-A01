// File: src/main.c
// Driver program: tests every function of the libmyutils library.

#include <stdio.h>
#include <stdlib.h>
#include "../include/mystrfunctions.h"
#include "../include/myfilefunctions.h"

#define DATA_FILE     "data/sample.txt"              // normal place, inside the project
#define FALLBACK_FILE "/tmp/libmyutils_sample.txt"   // used after "make install", from any folder

// The file the file-functions will be tested on. createSampleFile() decides which one.
static const char* dataFile = DATA_FILE;

// Writes the four test lines into fp.
static void writeSampleLines(FILE* fp) {
    fprintf(fp, "Operating Systems is fun\n");
    fprintf(fp, "Arif Butt teaches OS\n");
    fprintf(fp, "Linux is an operating system\n");
    fprintf(fp, "Static and dynamic libraries\n");
}

// Makes sure a test file exists, so the program works from any directory.
static void createSampleFile(void) {
    FILE* fp = fopen(DATA_FILE, "r");

    if (fp != NULL) {                   // data/sample.txt already there
        fclose(fp);
        dataFile = DATA_FILE;
        return;
    }

    fp = fopen(DATA_FILE, "w");         // try to create it inside the project
    if (fp != NULL) {
        writeSampleLines(fp);
        fclose(fp);
        dataFile = DATA_FILE;
        return;
    }

    // We are not inside the project folder (e.g. the installed /usr/local/bin/client),
    // so there is no data/ directory here. Use a file in /tmp instead.
    fp = fopen(FALLBACK_FILE, "w");
    if (fp == NULL) {
        printf("Could not create a test file\n");
        return;
    }
    writeSampleLines(fp);
    fclose(fp);
    dataFile = FALLBACK_FILE;
}

int main(void) {
    char buffer[100];
    char small[10];
    int rv;

    printf("--- Testing String Functions ---\n");

    // mystrlen
    printf("mystrlen(\"Hello World\")  = %d\n", mystrlen("Hello World"));
    printf("mystrlen(\"\")             = %d\n", mystrlen(""));

    // mystrcpy
    rv = mystrcpy(buffer, "Operating Systems");
    printf("mystrcpy -> buffer       = \"%s\" (copied %d chars)\n", buffer, rv);

    // mystrncpy
    rv = mystrncpy(small, "Assignment", 5);
    small[5] = '\0';                // print safely: put an end marker after 5 chars
    printf("mystrncpy(5 of \"Assignment\") = \"%s\" (copied %d chars)\n", small, rv);

    // mystrcat
    rv = mystrcat(buffer, " Course");
    printf("mystrcat -> buffer       = \"%s\" (new length %d)\n", buffer, rv);

    printf("\n--- Testing File Functions ---\n");

    createSampleFile();

    // wordCount
    FILE* fp = fopen(dataFile, "r");
    if (fp == NULL) {
        printf("Cannot open %s\n", dataFile);
        return 1;
    }

    int lines = 0, words = 0, chars = 0;
    if (wordCount(fp, &lines, &words, &chars) == 0)
        printf("wordCount(%s): lines = %d, words = %d, chars = %d\n",
               dataFile, lines, words, chars);
    else
        printf("wordCount failed\n");
    fclose(fp);

    // mygrep
    fp = fopen(dataFile, "r");
    if (fp == NULL) {
        printf("Cannot open %s\n", dataFile);
        return 1;
    }

    char** matches = NULL;
    const char* needle = "is";
    int count = mygrep(fp, needle, &matches);

    if (count >= 0) {
        printf("mygrep(\"%s\"): %d matching line(s)\n", needle, count);
        for (int i = 0; i < count; i++)
            printf("   [%d] %s", i + 1, matches[i]);   // line already ends with '\n'
        freeMatches(matches, count);                   // never forget to free
    } else {
        printf("mygrep failed\n");
    }
    fclose(fp);

    printf("\nAll tests finished.\n");
    return 0;
}
