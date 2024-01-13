# Description
32-bit x86 assembler code convert number to string

# Compile and Run
1. compile asm
```bash
nasm -f elf32 FILE.asm -o asm.o
```

2. build executable using gcc
```bash
gcc -m32 asm.o -o asm
```

3. run
```bash
./asm
```