    SECTION .data

align 32 ; vmovdqa to ymm

rspread    db 0, 128, 0, 128, 0, 128, 3, 128, 3, 128, 3, 128, 6, 128, 6, 128,  0, 128, 3, 128, 3, 128, 3, 128, 6, 128, 6, 128, 6, 128,   128, 128
gspread    db 1, 128, 1, 128, 1, 128, 4, 128, 4, 128, 4, 128, 7, 128, 7, 128,  1, 128, 4, 128, 4, 128, 4, 128, 7, 128, 7, 128, 7, 128,   128, 128
bspread    db 2, 128, 2, 128, 2, 128, 5, 128, 5, 128, 5, 128, 8, 128, 8, 128,  2, 128, 5, 128, 5, 128, 5, 128, 8, 128, 8, 128, 8, 128,   128, 128

rplus      db 77, 0, -43, -1, 128, 0, 77, 0, -43, -1, 128, 0, 77, 0, -43, -1, 128, 0, 77, 0, -43, -1, 128, 0, 77, 0, -43, -1, 128, 0, 0, 0
gplus      db 150, 0, -84, -1, -107, -1, 150, 0, -84, -1, -107, -1, 150, 0, -84, -1, -107, -1, 150, 0, -84, -1, -107, -1, 150, 0, -84, -1, -107, -1, 0, 0
bplus      db 29, 0, 128, 0, -20, -1, 29, 0, 128, 0, -20, -1, 29, 0, 128, 0, -20, -1, 29, 0, 128, 0, -20, -1, 29, 0, 128, 0, -20, -1, 0, 0
extra      db 0, 0, 0, 128, 0, 128, 0, 0, 0, 128, 0, 128, 0, 0, 0, 128, 0, 128, 0, 0, 0, 128, 0, 128, 0, 0, 0, 128, 0, 128, 0, 0

yspread    db 128, 0, 128, 0, 128, 0, 128, 4, 128, 4, 128, 4, 128, 8, 128, 8,  128, 0, 128, 4, 128, 4, 128, 4, 128, 8, 128, 8, 128, 8,   128, 128
cbspread   db 1, 128, 1, 128, 1, 128, 5, 128, 5, 128, 5, 128, 9, 128, 9, 128,  1, 128, 5, 128, 5, 128, 5, 128, 9, 128, 9, 128, 9, 128,   128, 128
crspread   db 2, 128, 2, 128, 2, 128, 6, 128, 6, 128, 6, 128, 10, 128, 10, 128,  2, 128, 6, 128, 6, 128, 6, 128, 10, 128, 10, 128, 10, 128,   128, 128

cb         db 0, 0, -44, -1, 227, 0, 0, 0, -44, -1, 227, 0, 0, 0, -44, -1, 227, 0, 0, 0, -44, -1, 227, 0, 0, 0, -44, -1, 227, 0, 0, 0
cr         db 179, 0, -91, -1, 0, 0, 179, 0, -91, -1, 0, 0, 179, 0, -91, -1, 0, 0, 179, 0, -91, -1, 0, 0, 179, 0, -91, -1, 0, 0, 0, 0

yuv3toyuv4 db 0, 1, 2, 128, 3, 4, 5, 128, 6, 7, 8, 128, 9, 10, 11, 128, 12, 13, 14, 128

n128       db 128, 0

    SECTION .text
    global  RGB2YUV
    global  YUV2RGB

RGB2YUV:
    push rbp
    mov  rbp, rsp
    sub  rsp, 32

    mov [rbp + 1*8 + 8], rcx
    mov [rbp + 2*8 + 8], rdx
    mov [rbp + 3*8 + 8], r8
    mov [rbp + 4*8 + 8], r9
  
    push rbx
    push r11
    push r12
    push r13
    push r14
    push r15

    mov r8, [rbp + 1*8 + 8]
    mov r9, [rbp + 2*8 + 8]

    vmovdqa ymm1, [rel + rspread]
    vmovdqa ymm2, [rel + gspread]
    vmovdqa ymm3, [rel + bspread]

    vmovdqa ymm4, [rel rplus]
    vmovdqa ymm5, [rel gplus]
    vmovdqa ymm6, [rel bplus]

    vmovdqa ymm7,  [rel extra]
    vmovdqa xmm14, [rel + yuv3toyuv4]

    mov rbx, [rbp + 4*8 + 8] ; height
    loop_by_row:

    xor rcx, rcx
    xor r12, r12
    mov r10, [rbp + 3*8 + 8] ; width
    shl r10, 2

    mov rax, r10
    sub rax, rcx
    cmp rax, 20
    jge simd_rgb2yuv
    simd_rgb2yuv_back:

    sisd_rgb2yuv_back:
    cmp rcx, r10
    jg  end_loop_by_row
    
    mov r12, rcx
    shr r12, 1
    mov r11, r12
    shr r11, 1
    add r12, r11
    sisd_rgb2yuv:

    mov r13b, [r8 + r12]     ; R
    mov r14b, [r8 + r12 + 1] ; G
    mov r15b, [r8 + r12 + 2] ; B

    mov ax,         r13w
    mov r12w,       77
    mul r12b
    mov r11w,       ax
    mov ax,         r14w
    mov r12w,       150
    mul r12b
    add r11w,       ax
    mov ax,         r15w
    mov r12w,       29
    mul r12b
    add r11w,       ax
    shr r11w,       8
    mov [r9 + rcx], r11b

    mov r11w,           32768
    mov ax,             r13w
    mov r12w,           43
    mul r12b
    sub r11w,           ax
    mov ax,             r14w
    mov r12w,           84
    mul r12b
    sub r11w,           ax
    mov ax,             r15w
    mov r12w,           128
    mul r12b
    add r11w,           ax
    shr r11w,           8
    mov [r9 + rcx + 1], r11b

    mov r11w,           32768
    mov ax,             r13w
    mov r12w,           128
    mul r12b
    add r11w,           ax
    mov ax,             r14w
    mov r12w,           107
    mul r12b
    sub r11w,           ax
    mov ax,             r15w
    mov r12w,           20
    mul r12b
    sub r11w,           ax
    shr r11w,           8
    mov [r9 + rcx + 2], r11b

    add r12, 3
    add rcx, 4
    jmp sisd_rgb2yuv_back

    simd_rgb2yuv:

    vmovdqu xmm0, [r8 + r12]
    vinserti128 ymm0, [r8 + r12 + 6], 1
    vpshufb ymm8, ymm0, ymm1
    vpshufb ymm9, ymm0, ymm2
    vpshufb ymm10, ymm0, ymm3

    vpmullw ymm11, ymm4,  ymm8
    vpmullw ymm12, ymm5,  ymm9
    vpmullw ymm13, ymm6,  ymm10

    vpaddw ymm11, ymm12
    vpaddw ymm13, ymm7
    vpaddw ymm13, ymm11

    vpsrlw    ymm13,      8
    vextractf128 xmm15, ymm13, 1
    vpackuswb ymm13,      ymm15
    vmovdqa   xmm15,      xmm13
    vpshufb   xmm13,      xmm14
    movdqu    [r9 + rcx], xmm13
 
    pextrd r11d, xmm15, 3
    mov [r9 + rcx + 16], r11d

    add r12, 15
    add rcx, 20
    sub rax, 20
    cmp rax, 20
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

    epilog_rgb2yuv:
    pop r15
    pop r14
    pop r13
    pop r12
    pop r11
    pop rbx
    
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

    push rbx
    push r11
    push r12
    push r13
    push r14
    push r15

    mov r8, [rbp + 1*8 + 8]
    mov r9, [rbp + 2*8 + 8]

    vmovdqa ymm1, [rel + yspread]
    vmovdqa ymm2, [rel + cbspread]
    vmovdqa ymm3, [rel + crspread]

    vpbroadcastw ymm8, [rel n128]

    vmovdqa ymm4, [rel cb]
    vmovdqa ymm6, [rel cr]

    mov rbx, [rbp + 4*8 + 8] ; height
    loop_by_row2:

    xor rcx, rcx
    xor r12, r12
    mov r10, [rbp + 3*8 + 8] ; width
    shl r10, 2
    
    mov rax, r10
    sub rax, rcx
    cmp rax, 20
    jge simd_yuv2rgb
    simd_yuv2rgb_back:

    sisd_yuv2rgb_back:
    cmp rcx, r10
    jg  end_loop_by_row2

    mov r11, rcx
    shr r11, 1
    mov rax, r11
    shr rax, 1
    add r11, rax
    
    sisd_rgb2yuv2:

    xor r13d, r13d
    xor r14d, r14d
    xor r15d, r15d
    mov r13b, [r8 + rcx]     ; Y
    mov r14b, [r8 + rcx + 1] ; Cb
    mov r15b, [r8 + rcx + 2] ; Cr

    mov ax,         r15w
    sub ax,         128
    mov r12w,       179
    mul r12w
    cmp ax,         0
    jge positive_r
    shr ax,         7
    add al,         r13b
    jc  end_r
    underflow_r:
    mov al,         0
    jmp end_r
    positive_r:
    shr ax,         7
    add al,         r13b
    jnc end_r
    overflow_r:
    mov al,         255
    end_r:
    mov [r9 + r11], al

    mov ax,             r15w
    sub ax,             128
    mov r12w,           -91
    mul r12w
    mov r15w,           ax
    mov ax,             r14w
    sub ax,             128
    mov r12w,           -44
    mul r12w
    add ax,             r15w
    ; folding
    cmp ax,             0
    jge positive_g
    negative_g:
    shr ax,             7
    add al,             r13b
    jc  end_g
    underflow_g:
    mov al,             0
    jmp end_g
    positive_g:
    shr ax,             7
    add al,             r13b
    jnc end_g
    overflow_g:
    mov al,             255
    end_g:
    mov [r9 + r11 + 1], al

    mov ax,             r14w
    sub ax,             128
    mov r12w,           227
    mul r12w
    cmp ax,             0
    jge positive_b
    negative_b:
    shr ax,             7
    add al,             r13b
    jc  end_b
    underflow_b:
    mov al,             0
    jmp end_b
    positive_b:
    shr ax,             7
    add al,             r13b
    jnc end_b
    overflow_b:
    mov al,             255
    end_b:
    mov [r9 + r11 + 2], al

    add r11, 3
    add rcx, 4
    jmp sisd_yuv2rgb_back

    simd_yuv2rgb:

    vmovdqu xmm0, [r8 + rcx]
    vinserti128 ymm0, [r8 + rcx + 8], 1

    vpshufb ymm9, ymm0, ymm1
    vpsrlw ymm9,  1
    vpshufb ymm10, ymm0, ymm2
    vpsubw ymm10, ymm8
    vpshufb ymm11, ymm0, ymm3
    vpsubw ymm11, ymm8

    vpmullw ymm12, ymm4, ymm10
    vpmullw ymm13, ymm6, ymm11

    vpaddsw ymm9, ymm12
    vpaddsw ymm9, ymm13

    vpsraw    ymm9,            7
    vextractf128 xmm14, ymm9, 1
    vpackuswb ymm9,            ymm14
    vmovq     r11,             xmm9
    mov       [r9 + r12],      r11
    pextrq r11, xmm9, 1
    mov       [r9 + r12 + 8],  r11d
    shr       r11,             32
    mov       [r9 + r12 + 12], r11w
    shr       r11d,            16
    mov       [r9 + r12 + 14], r11b

    add r12, 15
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

    epilog_yuv2rgb:
    pop r15
    pop r14
    pop r13
    pop r12
    pop r11
    pop rbx

    add rsp, 32
    pop rbp
    ret
