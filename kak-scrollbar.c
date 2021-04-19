#include<stdio.h>
#include<stdlib.h>
// TODO:
	// Let's relax and get this whole routine working, methodically.
	// You've done everything you have to do now - get on with your day!
	// 1) Install the C language server and go through your surface-level errors,
	// missing semicolons, that sort of thing
	// 2) Have a go at trying to compile this thing, and see what kind of parameters
	// users will need to put in their kakrc.
	// 3) Write some unit tests - woohoo! - to assert the sort of behaviour you want to see. 
	// 4) Have a go at debugging this. No need to use kak - you can work from the command line
	// - try using the legendary third pane in your tmux setup.

	
// Dead simple swap routine.
// Nothing fancy - have faith in the compiler!
void swap_i(int* x, int* y) {
	int temp = *x;
	*x = *y;
	*y = temp;
}

// Convert line position in document to line position in our flags
int get_flag_pos(int doc_pos, int buffer_height, int window_height) {
	float rel_pos = doc_pos/buffer_height
	int flag_pos  = (int) (window_height*rel_pos + 0.5)
	return flag_pos
}

int main(int argc, char **argv) {
	// Arg 1: Scrollbar lines
	// Arg 2: Scrollbar format
	// Arg 3: Selection descs
	// Arg 4: Selection format
	// Arg 5: Buffer height 
	// Arg 6: Window height
	// Arg 7: Window range
	char bar_format = argv[2];
	char sel_format = argv[4];
	long buffer_height = strtol(argv[5], NULL, 10);
	long window_height = strtol(argv[6], NULL, 10);

	// Set up our array of flags (starting at 0)
	char* flags_by_line[window_height];

	// From now on we need to use a C-style range from 0 to (h-1)
	window_height--;

	// Get scrollbar start point
	char* token = strtok(argv[1], " ");
	const long bar_start = strtol(token, NULL, 10);
	// Get scrollbar end point
	token = strtok(NULL, " ");
	const long bar_end = strtol(token, NULL, 10);

	// Get window start point
	token = strtok(argv[7], " ");
	const window_start_pos = strtol(token, NULL< 10);
	
	// Process scrollbar flags
	{
		flags_start = get_flag_pos(bar_start, buffer_height, window_height);
		flags_end   = get_flag_pos(bar_end, buffer_height, window_height);
		for (i=flags_start ; i<=flags_end ; i++) {
			flags_by_line[i] = bar_format;
		}
	} 

	// Process our selections_desc
	while(1) {
		int* desc_start = strtol(strtok(argv[3], "."), NULL, 10);  
		if (desc_start* == '\0')
			break;
		strtok(NULL, ",");
		int* desc_end = strtol(strtok(argv[3], "."), NULL, 10);  
		strtok(NULL, " ");
		flags_start = get_flag_pos(desc_start, buffer_height, window_height)
		flags_end = get_flag_pos(desc_end, buffer_height, window_height)
		// Make sure we're looping low to high.
		if (flags_end < flags_start)
			swap_i(*flags_start, *flags_end);
		for (i=flags_start ; i<=flags_end ; i++) {
			flags_by_line[i] = sel_format;
		}
	}

	// We're going to use a streaming technique to get our string for output.
	// This is an efficient way to append to a string, and means we don't have to
	// define any upper limit.
	char* output = NULL;
	size_t outputSize = 0;
	FILE* stream = open_memstream(&output, &outputSize);

	for (i=1 ; i<=window_height ; i++) {
		fprintf(stream, "%d|%s ", (i+window_start_pos), flags_by_line[i]);
	}

	fclose(stream);
	return output;
}	
