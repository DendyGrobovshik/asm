function highlight_errors {
    sed 's,.*error.*\|.*warning.*,\x1b[33m&\x1b[0m,'
}

mkdir -p .build
cd .build

/home/dust/go/bin/nasmfmt -ii 4 $1 &&
    nasm -f elf32 $1 -o asm.o &&
    gcc -m32 asm.o -o asm 2>&1 | highlight_errors &&
    ./asm
echo $?
