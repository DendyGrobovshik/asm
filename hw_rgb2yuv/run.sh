nasm -f elf64 rgb_yuv.asm -o asm.o

gcc -no-pie -Wall -m64 \
    -include stdio.h \
    rgb_yuv.c -ljpeg asm.o -o main

./main
echo "Exit code: $?"
