#include <float.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>

typedef struct {
  uint8_t r;
  uint8_t g;
  uint8_t b;
} RGB;

// gcc float_bug_m32.c -o bug && ./bug
// > x=255.000000, y=255, z=255

// gcc -m32 float_bug_m32.c -o bug && ./bug
// > x=255.000000, y=255, z=254
void foo(RGB rgb) {
  float x = (0.2990 * rgb.r + 0.5870 * rgb.g + 0.1140 * rgb.b);
  uint8_t y = (uint8_t)x;
  uint8_t z = (uint8_t)(0.2990 * rgb.r + 0.5870 * rgb.g + 0.1140 * rgb.b);
  printf("x=%f, y=%i, z=%i\n\n", x, y, z);
}

int main() {
  RGB rgb = {255, 255, 255};
  foo(rgb);

  return 0;
}