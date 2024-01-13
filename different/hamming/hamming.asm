    section .text
    global distance

; 64 bit version
; rsi, rdi for arguments
distance:
    xor rcx, rcx ; index
    xor rdx, rdx ; counter
    xor rax, rax ; symbols code
    loop:
    mov ah, [rsi+rcx]
    mov al, [rdi+rcx]
    inc rcx
    cmp ah, al
    je checkend
    cmp ah, 0
    je differentlen
    cmp al, 0
    je differentlen
    inc rdx ; symbols not match
    jmp loop
    differentlen:
        mov rax, -1
        ret
    checkend:
    cmp ah, 0
    jne loop
    end:
    mov rax, rdx
    ret