    SECTION .text
    global print

print:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi

    sub esp, 24 ; flags,    width,  128bit decimal
                ; [ebp-16] [ebp-20]

    xor ecx, ecx
    xor esi, esi
    xor edi, edi
    xor edx, edx

check_minus:
    mov ebx, [ebp + 16]
    mov al, byte[ebx]
    cmp al, '-'
    jne no_need_to_invert
    or ch, 16
    inc ebx

no_need_to_invert:
    mov [ebp - 16], ecx
    xor ecx, ecx
    xor eax, eax
test_0x_prefix:
    mov cl, byte[ebx]
    cmp cl, '0'
    jne hex2dec_loop
    mov cl, byte[ebx + 1]
    cmp cl, 'x'
    je handle_0x
    cmp cl, 'X'
    jne hex2dec_loop
handle_0x:
    add ebx, 2
    mov cl, byte[ebx]

hex2dec_loop:
    mov cl, byte[ebx]
    test cl, cl
    jz hex_parsed
    shld esi, edi, 4
    shld edi, edx, 4
    shld edx, eax, 4
    shl eax, 4
test_digit:
    sub cl, '0'
    cmp cl, 9
    ja test_capital_letter
    jmp hex2dec_loop_end
test_capital_letter:
    cmp cl, 23
    ja test_lower_letter
    sub cl, 7
    jmp hex2dec_loop_end
test_lower_letter:
    sub cl, ' ' + 7
    jmp hex2dec_loop_end
hex2dec_loop_end:
    or eax, ecx
    inc ebx
    jmp hex2dec_loop

hex_parsed:
    mov ecx, [ebp - 16]
    test esi, (1 << 31)
    jz save_number
invert:
    xor ch, 16
    not esi
    not edi
    not edx
    not eax
    clc
    adc eax, 1
    adc edx, 0
    adc edi, 0
    adc esi, 0
    test esi, (1 << 31)
    jz save_number
    or ch, 16
    mov [ebp - 16], ecx
save_number:
    mov [ebp - 24], eax
    mov [ebp - 28], edx
    mov [ebp - 32], edi
    mov [ebp - 36], esi
    xor eax, eax
parse_format:
    mov ebx, [ebp + 12]
    dec ebx
format_loop:
    inc ebx
    mov cl, byte[ebx]
    test cl, cl
    jz fill_out_buffer_with_save_flags
    sub cl, '1'
    test cl, cl
    js minus_check
fill_width:
    xor cl, cl
    mov [ebp - 16], ecx
fill_width_loop:
    xor ecx, ecx
    mov cl, byte[ebx]
    test cl, cl
    jz fill_out_buffer
    mov edx, 10
    mul edx
    sub cl, '0'
    add eax, ecx
    inc ebx
    jmp fill_width_loop
minus_check:
    add cl, '1'
    cmp cl, '-'
    jne plus_check
    or ch, 1
    jmp format_loop
plus_check:
    cmp cl, '+'
    jne check_space
    or ch, 2
    jmp format_loop
check_space:
    cmp cl, ' '
    jne check_zero
    or ch, 4
    jmp format_loop
check_zero:
    or ch, 8
    jmp format_loop

fill_out_buffer_with_save_flags:
    mov [ebp - 16], ecx
fill_out_buffer:
    mov [ebp - 20], eax

print_number:
    xor esi, esi
    mov ecx, 10
put_digit_on_stack_loop:
    xor edx, edx

    mov eax, [ebp - 36]
    div ecx
    mov [ebp - 36], eax
    mov eax, [ebp - 32]
    div ecx
    mov [ebp - 32], eax
    mov eax, [ebp - 28]
    div ecx
    mov [ebp - 28], eax
    mov eax, [ebp - 24]
    div ecx
    mov [ebp - 24], eax

    add dl, '0'
    dec esp
    mov byte[esp], dl
    inc esi

    cmp dword[ebp - 36], 0
    jne put_digit_on_stack_loop
    cmp dword[ebp - 32], 0
    jne put_digit_on_stack_loop
    cmp dword[ebp - 28], 0
    jne put_digit_on_stack_loop
    cmp dword[ebp - 24], 0
    jne put_digit_on_stack_loop

test_zero:
    cmp esi, 1
    jne do_print
    cmp byte[esp], '0'
    jne do_print
there_is_no_minus_zero:
    mov ecx, [ebp - 16]
    mov cl, 1
    shl cl, 4
    not cl
    and ch, cl
    mov [ebp - 16], ecx

do_print:
    mov ecx, [ebp - 16]
    mov edx, [ebp - 20]
    mov ebx, [ebp + 8]
    sub edx, esi
    test ch, 1
    jnz fill_sign_number
    test ch, 8
    jz fill_sign_number
fill_sign_zero_number:
    call print_sign
fill_zero_loop:
    test edx, edx
    jle take_digits_from_stack
    mov byte[ebx], '0'
    inc ebx
    dec edx
    jmp fill_zero_loop

fill_sign_number:
    test ch, 1
    jnz fill_number
    test ch, 22
    jz fill_space_loop
    dec edx
fill_space_loop:
    test edx, edx
    jle fill_number
    mov byte[ebx], ' '
    inc ebx
    dec edx
    jmp fill_space_loop

fill_number:
    call print_sign
take_digits_from_stack:
    test esi, esi
    jz fill_suffix
    mov cl, byte[esp]
    inc esp
    dec esi
    mov byte[ebx], cl
    inc ebx
    jmp take_digits_from_stack

fill_suffix:
    test edx, edx
    jle end
    mov byte[ebx], ' '
    inc ebx
    dec edx
    jmp fill_suffix

print_sign:
    test ch, 16
    jz test_plus
    mov byte[ebx], '-'
    inc ebx
    dec edx
    jmp fill_sign_end
test_plus:
    test ch, 2
    jz test_space
    mov byte[ebx], '+'
    inc ebx
    dec edx
    jmp fill_sign_end
test_space:
    test ch, 4
    jz fill_sign_end
add_space:
    mov byte[ebx], ' '
    inc ebx
    dec edx
fill_sign_end:
    ret

end:
    mov byte[ebx], 0
    add esp, 24
    pop edi
    pop esi
    pop ebx
    mov esp, ebp
    pop ebp
    ret