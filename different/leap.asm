; calculate whether yeasr is leap
; nasm -f elf32 leap.asm -o leap.o && gcc -m32 leap.o -o asm && ./asm
    section .text
    global main
    global leap_year
main:
    mov eax, 1970
    jmp leap_year

leap_year:
    mov eax, edi
    mov ecx, eax
    mov ebx, 4
    xor edx, edx
    div ebx
    cmp edx, 0
    je leap                            ; divisible by 4
    mov eax, 0                         ; else not leap
    jmp end
leap:
    mov eax, ecx
    mov ebx, 100
    div ebx
    cmp edx, 0
    je div100
    mov eax, 1                         ; else non divisible by 100(and leap)
    ret
div100:
    mov eax, ecx
    mov ebx, 400
    div ebx
    cmp edx, 0
    je leap400                         ; divisible by 400 => leap
    mov eax, 0                         ; divisible by 100, 200, 300
    ret
leap400:
    mov eax, 1
    ret
end:
