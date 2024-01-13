#include <stdio.h>
#include <string.h>

int main()
{
    int x;
    char *h = "-0x1A";
    sscanf(h, "%x", &x);
    printf("|%+-5i|\n", x);
}

// x/4xbc h
// 4 b - byte, from h

// gcc -g read_hex.c && gdb -ex "b main" -ex "layout src" -ex "r" ./a.out