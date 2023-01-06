// extern volatile unsigned *vga;

void vga_plot(unsigned x, unsigned y, unsigned colour)
{
    *vga = ((y & 0x7F) << 24) | ((x & 0xFF) << 16) | (colour & 0xFF);
}
