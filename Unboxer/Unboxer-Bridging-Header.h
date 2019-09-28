//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <string.h>


char* box_file_err = NULL;

void box_error_free() {
    if (box_file_err != NULL) {
        free(box_file_err);
        box_file_err = NULL;
    }
}

void box_error_callback(const char* msg) {
    size_t sz = strlen(msg) + 1;
    box_file_err = calloc(1, sz);
    memcpy(box_file_err, msg, sz);
}

void* box_file_reader_open(const char* path, void (*callback)(const char*));
void box_file_reader_extract_all(const void* handle, const char* path, void (*callback)(const char*));

