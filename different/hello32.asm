; nasm -f elf32 hello.asm
; ld -m elf_i386 -o hello32 hello32.o

section .data
    hello db 'Hello, World!', 0

section .text
    global _start

_start:
    ; Выводим сообщение на стандартный вывод
    mov eax, 4
    mov ebx, 1
    mov ecx, hello
    mov edx, 13
    int 0x80

    ; Завершаем программу
    mov eax, 1
    xor ebx, ebx
    int 0x80
