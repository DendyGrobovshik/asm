mkdir -p .build
cd .build

NAME=$1

# stone
# cd /home/dust/assembler/hw4
# NAME=rgb_yuv

nasm -f elf64 $NAME.asm -o asm.o
gcc -no-pie -Wall -m64 \
    -include stdio.h \
    $NAME.c -ljpeg asm.o -o main
# clang -no-pie -Wall $NAME.c asm.o -ljpeg -include stdio.h -o main

./main
echo "Exit code: $?"
