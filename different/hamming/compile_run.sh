nasm -f elf64 hamming.asm -o asm.o
gcc -Wall -m64 hamming.c asm.o -o main
./main
