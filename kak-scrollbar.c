#include<stdio.h>
#include<stdlib.h>
#include<string.h>
// TODO:
	// Let's relax and get this whole routine working, methodically.
	// You've done everything you have to do now - get on with your day!
	// 2) Have a go at trying to compile this thing, and see what kind of parameters
	// users will need to put in their kakrc.
	// 3) Write some unit tests - woohoo! - to assert the sort of behaviour you want to see. 
	// 4) Have a go at debugging this. No need to use kak - you can work from the command line
	// - try using the legendary third pane in your tmux setup.

int buffer_height, window_height, window_start_pos;
char *bar_format, *sel_format, *bar_str, *sel_str;
int *flags_by_line;
char *save;
	
// Dead simple swap routine.
// Nothing fancy - have faith in the compiler!
void swap_i(int* x, int* y) {
	int temp = *x;
	*x = *y;
	*y = temp;
}

// Convert line position in document to line position in our flags
int get_flag_pos(int doc_pos) {
	float rel_pos = (doc_pos-1) / (float)(buffer_height-1);
	int flag_pos  = (int) window_height*rel_pos + 0.5;
	return flag_pos;
}

void set_scrollbar_flags(int start, int end) {
	int i;
	int flags_start = get_flag_pos(start);
	int flags_end   = get_flag_pos(end);
	for (i=flags_start ; i<=flags_end ; i++) {
		flags_by_line[i] = 1;
	}
} 

// We're going to use a streaming technique to get our string for output.
// This is an efficient way to append to a string, and means we don't have to
// define any upper limit.
void set_selection_flags(char *input) {
	while(*input != '\0') {
		long sel_start = strtol(strtok_r(input, ".", &save), NULL, 10);  
		strtok_r(NULL, ",", &save);
		long sel_end = strtol(strtok_r(NULL, ".", &save), NULL, 10);  
		strtok_r(NULL, " ", &save);
				int flags_start = get_flag_pos(sel_start);
		int flags_end = get_flag_pos(sel_end);
		// Make sure we're looping low to high.
		if (flags_end < flags_start)
			swap_i(&flags_start, &flags_end);
		int i;
		for (i=flags_start ; i<=flags_end ; i++) {
			flags_by_line[i] = 2;
		}
		input = save;
	}
}

char *get_flag_string() {
    char* output = NULL;
	size_t outputSize = 0;
	FILE* stream = open_memstream(&output, &outputSize);

    int i;
    char *getfmt[3] = {"", bar_format, sel_format};
	for (i=1 ; i<=window_height ; i++) {
    	int fmt_i=flags_by_line[i];
    	if (fmt_i) fprintf(stream, "%d|%s ", (i+window_start_pos), getfmt[fmt_i]);
	}
	fclose(stream);
	return output;
}

#ifndef DOING_UNIT_TESTS    // Don't call main() if we're running tests
int main(int argc, char **argv) {
	bar_str = argv[1];	    // Arg 1: Scrollbar lines
	bar_format = argv[2];	// Arg 2: Scrollbar format
	sel_str = argv[3];		// Arg 3: Selection descs
	sel_format = argv[4];	// Arg 4: Selection format
	buffer_height = strtol(argv[5], NULL, 10);		// Arg 5: Buffer height 
	window_height = strtol(argv[6], NULL, 10);	    // Arg 6: Window height
	window_start_pos = strtol(argv[7], NULL, 10);	// Arg 7: Window y position

	// Set up our array of flags (starting at 0)
	flags_by_line = calloc(window_height, sizeof(int));

	// From now on we need to use a C-style range from 0 to (h-1)
	window_height--;

	// Get scrollbar start and end point
	char *token = strtok_r(argv[1], ",", &save);
	long bar_start = strtol(token, NULL, 10);
	token = strtok_r(NULL, " ", &save);
	long bar_end = strtol(token, NULL, 10);

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
