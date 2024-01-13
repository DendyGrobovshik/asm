nasm -f elf32 hex_to_dec.asm -o asm.o
gcc -Wall -m32 hex_to_dec.c asm.o -o main
./main
