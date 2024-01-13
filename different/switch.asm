; it's not valid code, it's more about idea
; google branch table for more information
SECTION .rdata
    table:
        dd end,
        X,
        X,
        Y,
        end,
        Z
   
    SECTION .text
    global main
main:
; switch (eax) {
    ; case 1:
    ; case 2:
        ; X
        ; break;
    ; case 3:
        ; Y
    ; case 5:
        ; Z
; }
    cmp eax, 5
    ja end
    jmp [table+eax*4]
X:
    jmp end
Y: 
Z:

end: