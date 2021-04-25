#define DOING_UNIT_TESTS
#include <assert.h>
#include "kak-calc-scrollbar.c"

// Quick and dirty routine to test our helper functions
// (Though not a very profession example of unit testing!)
int main() {
    // Setup
	printf("Initializing test\n");
    window_height = 48;
    buffer_height = 100;
    bar_start = 21;
    bar_end = 68;
    bar_format = "#";
    sel_format1 = "S";
    sel_format2 = "$";
	flags_by_line = calloc(window_height, sizeof(int));
    window_height = window_height - 1; //important
	char input[] = "16.4,16.15 5.14,5.14 9.9,10.9";

	// 1) void swap_i
	printf("Testing: swap_i...\n");
	int x = 7, y = 99;
	swap_i(&x, &y);
	assert(x == 99);
	// Success?
    printf("Success!\n");
    
	// 2) int get_flag_pos
	printf("Testing: get_flag_pos...\n");
	assert(get_flag_pos(1) == 0);
	assert(get_flag_pos(100) == 47);
	// Success?
    printf("Success!\n");
    
	// 3) void get_scrollbar_flags
	printf("Testing: get_scrollbar_flags...\n");
	set_scrollbar_flags(1, 48);
	int i;
    for (i=0; i<window_height; i++) printf("%d ", flags_by_line[i]);
	// Success?
    printf("\nEnd of display.\n");

	// 4) void get_selection_flags
	printf("Testing: get_selection_flags... \n");
	set_selection_flags(input);
    for (i=0; i<window_height; i++) printf("%d ", flags_by_line[i]);
	// Success?
    printf("\nEnd of display.\n");

	// 5) char *get_flag_string
	printf("Testing: get_flag_string... \n");
	char *output = get_flag_string();
	printf("%s", output);
	// Success?
    printf("\nEnd of display.\n");
}
