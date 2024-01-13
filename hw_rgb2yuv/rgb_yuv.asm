    SECTION .data
msg:
    db "Result: ", 10, 0

    SECTION .text
    global RGB2YUV
    extern printf

RGB2YUV:
    push rbp
;     mov ebp, esp
;     jmp end
    ; push msg
    ; mov rcx, msg
    ; call printf

    ; add rsp, 8

; YUV2RGB:
;     push ebp
;     mov ebp, esp
;     jmp end

end:
;     mov esp, ebp
    pop rbp
    ret