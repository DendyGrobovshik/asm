#include <stdio.h>

extern int distance(const char *a, const char *b);

int main()
{
    printf("Result: %d\n", distance("ABD", "BBC"));
}