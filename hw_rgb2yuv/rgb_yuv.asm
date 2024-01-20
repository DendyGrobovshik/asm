    SECTION .data
time: 
    db "Time:   %ld", 10, 0

align 32 ; vmovdqa to ymm

rspread  db 0, 128, 0, 128, 0, 128, 3, 128, 3, 128, 3, 128, 6, 128, 6, 128,  0, 128, 3, 128, 3, 128, 3, 128, 6, 128, 6, 128, 6, 128,   128, 128
gspread  db 1, 128, 1, 128, 1, 128, 4, 128, 4, 128, 4, 128, 7, 128, 7, 128,  1, 128, 4, 128, 4, 128, 4, 128, 7, 128, 7, 128, 7, 128,   128, 128
bspread  db 2, 128, 2, 128, 2, 128, 5, 128, 5, 128, 5, 128, 8, 128, 8, 128,  2, 128, 5, 128, 5, 128, 5, 128, 8, 128, 8, 128, 8, 128,   128, 128

rplus    db 77, 0, 0, 0, 128, 0, 77, 0, 0, 0, 128, 0, 77, 0, 0, 0, 128, 0, 77, 0, 0, 0, 128, 0, 77, 0, 0, 0, 128, 0, 0, 0
rminus   db 0, 0, 43, 0, 0, 0, 0, 0, 43, 0, 0, 0, 0, 0, 43, 0, 0, 0, 0, 0, 43, 0, 0, 0, 0, 0, 43, 0, 0, 0, 0, 0
gplus    db 150, 0, 0, 0, 0, 0, 150, 0, 0, 0, 0, 0, 150, 0, 0, 0, 0, 0, 150, 0, 0, 0, 0, 0, 150, 0, 0, 0, 0, 0, 0, 0
gminus   db 0, 0, 84, 0, 107, 0, 0, 0, 84, 0, 107, 0, 0, 0, 84, 0, 107, 0, 0, 0, 84, 0, 107, 0, 0, 0, 84, 0, 107, 0, 0, 0
bplus    db 29, 0, 128, 0, 0, 0, 29, 0, 128, 0, 0, 0, 29, 0, 128, 0, 0, 0, 29, 0, 128, 0, 0, 0, 29, 0, 128, 0, 0, 0, 0, 0
bminus   db 0, 0, 0, 0, 20, 0, 0, 0, 0, 0, 20, 0, 0, 0, 0, 0, 20, 0, 0, 0, 0, 0, 20, 0, 0, 0, 0, 0, 20, 0, 0, 0
extra    db 0, 0, 0, 128, 0, 128, 0, 0, 0, 128, 0, 128, 0, 0, 0, 128, 0, 128, 0, 0, 0, 128, 0, 128, 0, 0, 0, 128, 0, 128, 0, 0

yspread  db 128, 0, 128, 0, 128, 0, 128, 4, 128, 4, 128, 4, 128, 8, 128, 8,  128, 0, 128, 4, 128, 4, 128, 4, 128, 8, 128, 8, 128, 8,   128, 128
cbspread db 1, 128, 1, 128, 1, 128, 5, 128, 5, 128, 5, 128, 9, 128, 9, 128,  1, 128, 5, 128, 5, 128, 5, 128, 9, 128, 9, 128, 9, 128,   128, 128
crspread db 2, 128, 2, 128, 2, 128, 6, 128, 6, 128, 6, 128, 10, 128, 10, 128,  2, 128, 6, 128, 6, 128, 6, 128, 10, 128, 10, 128, 10, 128,   128, 128

cbplus   db 0, 0, 0, 0, 198, 1, 0, 0, 0, 0, 198, 1, 0, 0, 0, 0, 198, 1, 0, 0, 0, 0, 198, 1, 0, 0, 0, 0, 198, 1, 0, 0
cbminus  db 0, 0, 88, 0, 0, 0, 0, 0, 88, 0, 0, 0, 0, 0, 88, 0, 0, 0, 0, 0, 88, 0, 0, 0, 0, 0, 88, 0, 0, 0, 0, 0
crplus   db 103, 1, 0, 0, 0, 0, 103, 1, 0, 0, 0, 0, 103, 1, 0, 0, 0, 0, 103, 1, 0, 0, 0, 0, 103, 1, 0, 0, 0, 0, 0, 0
crminus  db 0, 0, 183, 0, 0, 0, 0, 0, 183, 0, 0, 0, 0, 0, 183, 0, 0, 0, 0, 0, 183, 0, 0, 0, 0, 0, 183, 0, 0, 0, 0, 0

n128     db 128, 0
n1       db 0, 1

    SECTION .text
    global  RGB2YUV
    global  YUV2RGB
    extern  printf

; TODO: yuv3 replace with yuv4
RGB2YUV:
    push rbp
    mov  rbp, rsp
    sub  rsp, 32

    mov [rbp + 1*8 + 8], rcx
    mov [rbp + 2*8 + 8], rdx
    mov [rbp + 3*8 + 8], r8
    mov [rbp + 4*8 + 8], r9
  
    rdtsc
    shl  rdx, 32
    or   rdx, rax
    push rdx

    push rbx
    push r11
    push r12
    push r13
    push r14
    push r15

    mov r8, [rbp + 1*8 + 8]
    mov r9, [rbp + 2*8 + 8]

    mov rbx, [rbp + 4*8 + 8] ; height
    loop_by_row:

    xor rcx, rcx
    mov r10, [rbp + 3*8 + 8] ; width
    
    mov rax, r10
    sub rax, rcx
    cmp rax, 15
    jge simd_rgb2yuv
    simd_rgb2yuv_back:

    sisd_rgb2yuv_back:
    cmp rcx, r10
    jge end_loop_by_row
    
    sisd_rgb2yuv:

    mov r13b, [r8 + rcx]     ; R
    mov r14b, [r8 + rcx + 1] ; G
    mov r15b, [r8 + rcx + 2] ; B

    mov ax,         r13w
    mov r12w,       77
    mul r12w
    mov r11w,       ax
    mov ax,         r14w
    mov r12w,       150
    mul r12w
    add r11w,       ax
    mov ax,         r15w
    mov r12w,       29
    mul r12w
    add r11w,       ax
    shr r11w,       8
    mov [r9 + rcx], r11b

    mov r11w,           32768
    mov ax,             r13w
    mov r12w,           43
    mul r12w
    sub r11w,           ax
    mov ax,             r14w
    mov r12w,           84
    mul r12w
    sub r11w,           ax
    mov ax,             r15w
    mov r12w,           128
    mul r12w
    add r11w,           ax
    shr r11w,           8
    mov [r9 + rcx + 1], r11b

    mov r11w,           32768
    mov ax,             r13w
    mov r12w,           128
    mul r12w
    add r11w,           ax
    mov ax,             r14w
    mov r12w,           107
    mul r12w
    sub r11w,           ax
    mov ax,             r15w
    mov r12w,           20
    mul r12w
    sub r11w,           ax
    shr r11w,           8
    mov [r9 + rcx + 2], r11b

    add rcx, 3
    jmp sisd_rgb2yuv_back

    simd_rgb2yuv:

    vmovdqu xmm0, [r8 + rcx]
    vinserti128 ymm0, [r8 + rcx + 6], 1
    vmovdqa ymm1, [rel + rspread]
    vpshufb ymm1, ymm0, ymm1
    vmovdqa ymm2, [rel + gspread]
    vpshufb ymm2, ymm0, ymm2
    vmovdqa ymm3, [rel + bspread]
    vpshufb ymm3, ymm0, ymm3

    vmovdqa ymm4,  [rel rplus]
    vpmullw ymm4,  ymm1
    vmovdqa ymm5,  [rel rminus]
    vpmullw ymm5,  ymm1
    vmovdqa ymm6,  [rel gplus]
    vpmullw ymm6,  ymm2
    vmovdqa ymm7,  [rel gminus]
    vpmullw ymm7,  ymm2
    vmovdqa ymm8,  [rel bplus]
    vpmullw ymm8,  ymm3
    vmovdqa ymm9,  [rel bminus]
    vpmullw ymm9,  ymm3
    vmovdqa ymm10, [rel extra]

    vpaddw ymm4, ymm6
    vpaddw ymm8, ymm10
    vpaddw ymm5, ymm7
    vpaddw ymm8, ymm4
    vpaddw ymm5, ymm9
    vpsubw ymm8, ymm5

    vpsrlw    ymm8,            8
    vextractf128 xmm6, ymm8, 1
    vpackuswb ymm8,            ymm6
    vmovq     r11,             xmm8
    mov       [r9 + rcx],      r11
    pextrq r11, xmm8, 1
    mov       [r9 + rcx + 8],  r11d
    shr       r11,             32
    mov       [r9 + rcx + 12], r11w
    shr       r11d,            16
    mov       [r9 + rcx + 14], r11b

    add rcx, 15
    sub rax, 15
    cmp rax, 15
    jge simd_rgb2yuv

    jmp simd_rgb2yuv_back

    end_loop_by_row:
    mov  rcx, [rbp + 5*8 + 8]
    add  r8,  rcx
    mov  r10, [rbp + 6*8 + 8]
    add  r9,  r10
    dec  rbx
    test rbx, rbx
    jnz  loop_by_row

    epilog:
    pop r15
    pop r14
    pop r13
    pop r12
    pop r11
    pop rbx

    rdtsc
    pop r8
    shl rdx, 32
    or  rdx, rax
    sub rdx, r8

    lea rcx, [rel time]

    call printf
    
    add rsp, 32
    pop rbp
    ret 



YUV2RGB:
    push rbp
    mov  rbp, rsp
    sub  rsp, 32

    mov [rbp + 1*8 + 8], rcx
    mov [rbp + 2*8 + 8], rdx
    mov [rbp + 3*8 + 8], r8
    mov [rbp + 4*8 + 8], r9
    
    rdtsc
    shl  rdx, 32
    or   rdx, rax
    push rdx

    push rbx
    push r11
    push r12
    push r13
    push r14
    push r15

    mov r8, [rbp + 1*8 + 8]
    mov r9, [rbp + 2*8 + 8]

    mov rbx, [rbp + 4*8 + 8] ; height
    loop_by_row2:

    xor rcx, rcx
    mov r10, [rbp + 3*8 + 8] ; width
    
    mov rax, r10
    sub rax, rcx
    cmp rax, 20
    jge simd_yuv2rgb
    simd_yuv2rgb_back:

    sisd_yuv2rgb_back:
    cmp rcx, r10
    jz  end_loop_by_row2
    
    sisd_rgb2yuv2:

    mov r13b, [r8 + rcx]     ; Y
    mov r14b, [r8 + rcx + 1] ; Cb
    mov r15b, [r8 + rcx + 2] ; Cr

    push rcx
    shr  rcx, 1
    mov  rax, rcx
    shr  rax, 1
    add  rcx, rax

    mov r11b,       r13b
    shl r11w,       8
    mov ax,         r15w
    sub ax,         128
    mov r12w,       359
    mul r12w
    add r11w,       ax
    shr r11w,       8
    mov [r9 + rcx], r11b

    mov r11b,           r13b
    shl r11w,           8
    mov ax,             r14w
    sub ax,             128
    mov r12w,           88
    mul r12w
    sub r11w,           ax
    mov ax,             r15w
    sub ax,             128
    mov r12w,           183
    mul r12w
    sub r11w,           ax
    shr r11w,           8
    add r11b,           1
    mov [r9 + rcx + 1], r11b

    mov r11b,           r13b
    shl r11w,           8
    mov ax,             r14w
    sub ax,             128
    mov r12w,           454
    mul r12w
    add r11w,           ax
    shr r11w,           8
    add r11b,           1
    mov [r9 + rcx + 2], r11b

    pop rcx
    add rcx, 4
    jmp sisd_yuv2rgb_back

    simd_yuv2rgb:

    vmovdqu xmm0, [r8 + rcx]
    vinserti128 ymm0, [r8 + rcx + 8], 1

    push rcx
    shr  rcx, 1
    mov  r11, rcx
    shr  r11, 1
    add  rcx, r11

    vpbroadcastw ymm8, [rel n128]

    vmovdqa ymm1, [rel + yspread]
    vpshufb ymm1, ymm0, ymm1
    vmovdqa ymm2, [rel + cbspread]
    vpshufb ymm2, ymm0, ymm2
    vpsubw  ymm2, ymm8
    vmovdqa ymm3, [rel + crspread]
    vpshufb ymm3, ymm0, ymm3
    vpsubw  ymm3, ymm8

    vmovdqa ymm4, [rel cbplus]
    vpmullw ymm4, ymm2
    vmovdqa ymm5, [rel cbminus]
    vpmullw ymm5, ymm2
    vmovdqa ymm6, [rel crplus]
    vpmullw ymm6, ymm3
    vmovdqa ymm7, [rel crminus]
    vpmullw ymm7, ymm3

    vpaddw       ymm4, ymm6
    vpaddw       ymm5, ymm7
    vpaddw       ymm1, ymm4
    vpsubw       ymm1, ymm5
    vpbroadcastw ymm8, [rel n1]
    vpaddw       ymm1, ymm8

    vpsrlw    ymm1,            8
    vextractf128 xmm6, ymm1, 1
    vpackuswb ymm1,            ymm6
    vmovq     r11,             xmm1
    mov       [r9 + rcx],      r11
    pextrq r11, xmm1, 1
    mov       [r9 + rcx + 8],  r11d
    shr       r11,             32
    mov       [r9 + rcx + 12], r11w
    shr       r11d,            16
    mov       [r9 + rcx + 14], r11b

    pop rcx
    add rcx, 20
    sub rax, 20
    cmp rax, 20
    jge simd_yuv2rgb

    jmp simd_yuv2rgb_back

    end_loop_by_row2:
    mov  rcx, [rbp + 5*8 + 8]
    add  r8,  rcx
    mov  r10, [rbp + 6*8 + 8]
    add  r9,  r10
    dec  rbx
    test rbx, rbx
    jnz  loop_by_row2

    epilog2:
    pop r15
    pop r14
    pop r13
    pop r12
    pop r11
    pop rbx

    rdtsc
    pop r8
    shl rdx, 32
    or  rdx, rax
    sub rdx, r8

    lea rcx, [rel time]

    call printf
    
    add rsp, 32
    pop rbp
    ret
