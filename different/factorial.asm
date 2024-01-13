;nasm -f elf32 factorial.asm -o asm.o && gcc -m32 asm.o -o asm && ./asm
    SECTION .data
msg:
    db "Factorial: %d", 10, 0
dbg:
    db "EDX: %d, EAX: %d", 10, 0

    SECTION .text
    extern printf
    global main
main:
    xor eax, eax
    mov ebx, 12

    mov al, 1
loop:
    mul ebx

    cmp edx, 0
    jne overflow                       ; OVERFLOW CHECK

    dec ebx
    cmp ebx, 0
    jne loop                           ; LOOP CHECK

    push eax
    push msg
    call printf
    add esp, 8

    mov eax, 0
    ret

overflow:
    mov eax, 1
    ret
