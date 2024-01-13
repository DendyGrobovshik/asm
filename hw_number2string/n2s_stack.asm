    SECTION .data
msg:
    db "Number: %s", 10, 0

    SECTION .text
    extern printf
    global main
main:
    mov eax, 1474836478

    push ebp
    mov ebp, esp

    push byte 0
loop:
    xor edx, edx                       ; clear dividend
    mov ecx, 10
    div ecx
    add dl, 48                         ; ascii shift
    dec esp
    mov byte[esp], dl                  ; move digit on stack
    cmp eax, 0
    jne loop

print:
    push esp
    push msg
    call printf

    mov esp, ebp
    pop ebp

    xor eax, eax
    ret
