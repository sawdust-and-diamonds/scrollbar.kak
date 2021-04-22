#define DOING_UNIT_TESTS
#include <assert.h>
#include "kak-scrollbar.c"

int main() {
	// 1) void swap_i(int *x, int *y)
	printf("Testing: swap_i... ");
	int x = 7, y = 99;
	swap_i(&x, &y);
	assert(x == 99);
    printf("Success!\n");
    
    // Setup for next secction: 
    window_height = 48;
    buffer_height = 100;
    window_start_pos = 20;
    bar_format = "#";
    sel_format = "O";
	flags_by_line = calloc(window_height, sizeof(int));
	char input[] = "16.4,16.15 5.14,5.14 9.9,10.9";

	// 2) int get_flag_pos
	printf("Testing: get_flag_pos... ");
	assert(get_flag_pos(1) == 0);
	assert(get_flag_pos(100) == 47);
    printf("Success!\n");
    
	// 3) get_scrollbar_flags
	printf("Testing: get_scrollbar_flags...\n");
	set_scrollbar_flags(1, 48);
	int i;
    for (i=0; i<window_height; i++) printf("%d ", flags_by_line[i]);
    printf("\nSuccess!\n");

	// 4) get_selection_flags
	printf("Testing: get_selection_flags... \n");
	set_selection_flags(input);
    for (i=0; i<window_height; i++) printf("%d ", flags_by_line[i]);

	// 5) get_flag_string
	printf("Testing: get_flag_string... ");
	char *output = get_flag_string();
	printf("%s", output);
}
