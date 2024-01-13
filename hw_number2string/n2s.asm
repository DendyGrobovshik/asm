    SECTION .data
msg:
    db "Number: %s", 10, 0
number:
    times 10 db 48,
    db 0

    SECTION .text
    extern printf
    global main
main:
    mov ecx, 9                         ; pos to insert digit
    mov eax, 123456

    push ebx
loop:
    mov edx, 0                         ; clear dividend
    mov ebx, 10
    div ebx
    add dl, 48                         ; ascii shift
    mov byte[number + ecx], dl         ; insert digit
    dec ecx
    cmp eax, 0
    jne loop

    lea eax, [number + ecx + 1]

print:
    push eax
    push msg
    call printf
    add esp, 0x8

    pop ebx
    mov eax, 0
    ret
