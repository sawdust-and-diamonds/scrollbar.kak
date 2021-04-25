#include<stdio.h>
#include<stdlib.h>
#include<string.h>

// We'll use global variables for our simple script-like program
int buffer_height, window_height, bar_start, bar_end;
char *bar_format, *sel_format1, *sel_format2, *sel_str, *saveptr;
int *flags_by_line;
    
// Dead simple swap routine. Nothing fancy - have faith in the compiler!
void swap_i(int* x, int* y) {
    int temp = *x;
    *x = *y;
    *y = temp;
}

// Convert a position a document to a position in our list of flags
int get_flag_pos(int doc_pos) {
    float rel_pos = (doc_pos-1) / (float)(buffer_height-1);
    int flag_pos  = (int) window_height*rel_pos + 0.5;
    return flag_pos;
}

// Set the base flags which represent our scrollbar
void set_scrollbar_flags(int start, int end) {
    int i;
    int flags_start = get_flag_pos(start);
    int flags_end   = get_flag_pos(end);
    for (i=flags_start ; i<=flags_end ; i++) {
        flags_by_line[i] = 1;
    }
} 

// Set the flags which represent our current selections
void set_selection_flags(char *input) {
    while(*input != '\0') {
        // Get start & end of selection from one selection_desc value
        long sel_start = strtol(strtok_r(input, ".", &saveptr), NULL, 10);  
        strtok_r(NULL, ",", &saveptr);
        long sel_end = strtol(strtok_r(NULL, ".", &saveptr), NULL, 10);  
        strtok_r(NULL, " ", &saveptr);

        // Convert to values in our flags list
        int flags_start = get_flag_pos(sel_start);
        int flags_end = get_flag_pos(sel_end);
        
        // Make sure we're looping low to high
        if (flags_end < flags_start) swap_i(&flags_start, &flags_end);

        // Loop through selected lines
        int i;
        for (i=flags_start ; i<=flags_end ; i++) {
            flags_by_line[i] |= 2; // Set to 3 if inside scrollbar 
        }
        // Move one selection_desc forward in the input string
        input = saveptr;
    }
}

// We're going to use a streaming technique to get our string ready for output.
// This is an efficient way to append to a string, and means we don't have to
// define any upper limit.
char *get_flag_string() {
    char* output = NULL;
    size_t outputSize = 0;
    FILE* stream = open_memstream(&output, &outputSize);

    int i;
    char *getfmt[4] = {"", bar_format, sel_format1, sel_format2};
    for (i=0 ; i<=window_height ; i++) {
        int fmt_i=flags_by_line[i];
        if (fmt_i) fprintf(stream, "%d|%s ", (i+bar_start), getfmt[fmt_i]);
    }
    fclose(stream);
    return output;
}

#ifndef DOING_UNIT_TESTS    // Don't call main() if we're running tests
// Our main process
int main(int argc, char **argv) {
    // Initialize argument variables
    bar_start = strtol(argv[1], NULL, 10);          // Arg 1: Scrollbar start pos
    bar_end = strtol(argv[2], NULL, 10);            // Arg 2: Scrollbar end pos
    bar_format = argv[3];                           // Arg 3: Scrollbar format
    sel_str = argv[4];                              // Arg 4: Selection descs
    sel_format1 = argv[5];                          // Arg 5: Selection format - in bar
    sel_format2 = argv[6];                          // Arg 6: Selection format - outside bar
    buffer_height = strtol(argv[7], NULL, 10);      // Arg 7: Buffer height 
    window_height = strtol(argv[8], NULL, 10);      // Arg 8: Window height

    // Set up our array of flags (starting at 0)
    flags_by_line = calloc(window_height, sizeof(int));

    // From now on, window_height needs to use a C-style range from 0 to (h-1)
    window_height--;

    // Also, increment bar_start, because for some reason window_range starts counting from 0
    bar_start = bar_start + 1;

    // Sanitize window height (can't paint lower than last line of buffer)
    if (bar_end > buffer_height) bar_end=(long)buffer_height;

    // Process scrollbar flags
    set_scrollbar_flags(bar_start, bar_end);

    // Process selection flags
    set_selection_flags(sel_str);
    
    // Output our formatted line-spec string
    char *output = get_flag_string();
    printf("%s", output);
    
    return 0;
}
#endif
