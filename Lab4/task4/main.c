volatile unsigned *vga = (volatile unsigned *) 0x00004000; /* VGA adapter base address */
volatile char *display = (volatile char*) 0x00001010;
#include "vga_plot.c"

unsigned char pixel_list[] = {
#include "../misc/pixels.txt"
};
unsigned num_pixels = sizeof(pixel_list)/2;

#define BLACK 0
#define WHITE 255
#define VGA_SCREEN_LENGTH 160
#define VGA_SCREEN_HEIGHT 120
#define NEIGHBOUR_TABLE_LEN 5

#define SCALE 2

unsigned char weight_lookup_table[NEIGHBOUR_TABLE_LEN][NEIGHBOUR_TABLE_LEN] = {
	{1 * SCALE, 2 * SCALE, 4 * SCALE, 2 * SCALE, 1 * SCALE},
	{2 * SCALE, 4 * SCALE, 8 * SCALE, 4 * SCALE, 2 * SCALE},
	{4 * SCALE, 8 * SCALE, 16 * SCALE, 8 * SCALE, 4 * SCALE},
	{2 * SCALE, 4 * SCALE, 8 * SCALE, 4 * SCALE, 2 * SCALE},
	{1 * SCALE, 2 * SCALE, 4 * SCALE, 2 * SCALE, 1 * SCALE}
};

unsigned char pixel_list_map[VGA_SCREEN_LENGTH][VGA_SCREEN_HEIGHT] = {0};

unsigned char neighbour_weight(unsigned char x, unsigned char y) {
	short start_x = x - 2;
	short start_y = y - 2;

	unsigned char lookup_x = 0;
	unsigned char lookup_y = 0;

	unsigned char grey_delta = 0;

	for (short i = start_x; i < start_x + NEIGHBOUR_TABLE_LEN; i++) {
		if (i < 0 || i >= VGA_SCREEN_LENGTH) {
			lookup_x++;
			continue;
		}
		lookup_y = 0;
		for (short j = start_y; j < start_y + NEIGHBOUR_TABLE_LEN; j++) {
			if (j < 0 || j >= VGA_SCREEN_HEIGHT) {
				continue;
				lookup_y++;
			}
			
			if (pixel_list_map[i][j]) {
				grey_delta += weight_lookup_table[lookup_x][lookup_y];
			}
			lookup_y++;
		}
		lookup_x++;
	}

	return grey_delta;
}

int main()
{
	*display = 0xFF;

	for (unsigned short i = 0; i < sizeof(pixel_list); i = i + 2) {
		pixel_list_map[pixel_list[i]][pixel_list[i + 1]] = 1;
	}

	for (unsigned short i = 0; i < VGA_SCREEN_LENGTH; i++) {
		for (unsigned short j = 0; j < VGA_SCREEN_HEIGHT; j++) {
			vga_plot(i, j, BLACK);
		}
	}

	// Plot all the pixels of the image
	for (unsigned short i = 0; i < VGA_SCREEN_LENGTH; i++) {
		for (unsigned short j = 0; j < VGA_SCREEN_HEIGHT; j++) {
			unsigned char colour = neighbour_weight(i, j);
			vga_plot(i, j, colour);
		}
	}

	while (1) {}
}
