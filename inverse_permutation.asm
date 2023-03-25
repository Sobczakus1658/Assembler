global inverse_permutation
;rdi - rozmiar tablicy
;rsi - wskaznik na tablice 
;INT_MAX jeszcze może byc ->poprawić 
inverse_permutation:
    xor  rbx, rbx
    mov r9, 0x7fffffff
    test rdi, rdi
    js   exit
    je   exit
    cmp  r9, rdi
    js  exit
loop:
    ; patrzę czy rbx mniejsze od n, jezeli tak to idz do correct
    mov  eax, [rsi+4*rbx]
    cmp  eax, 0x0
    js   exit
    cmp  rdi, rax
    js   exit
    je   exit
    inc  QWORD rbx
    cmp  rdi, rbx
    jne  loop
    xor  rbx, rbx
correct:
    mov  eax, [rsi + 4*rbx]
    and  rax, r9
    mov  ecx, [rsi + 4*rax]
    test ecx, ecx
    js   repair 
    or   ecx, 0x80000000
    mov  [rsi + 4*rax],  ecx
    inc  QWORD rbx 
    cmp  rdi, rbx
    jne  correct
    xor  rbx, rbx
permutation:
    mov  eax, [rsi + 4*rbx]
    test eax, eax
    jns  after_inverse
    ;edx  - aktualny indeks
    ;r8d  -pozycja
    mov  edx, ebx
    mov  r8d, ebx
inverse:
    and  eax, r9d
    mov  [rsi+4*rdx], r8d
    mov  r8d, edx
    mov  edx, eax
    mov  eax, [rsi + 4*rax]
    test eax, eax
    js   inverse
    mov  [rsi + 4*rdx], r8d
after_inverse:
    inc  QWORD rbx 
    cmp  rdi, rbx
    jne  permutation
    mov  eax, 0x1
    ret
exit:
    xor  eax, eax
    ret
repair:
    xor  rbx, rbx
repair_loop:
    mov  eax, [rsi+4*rbx]
    and  eax, r9d
    mov  [rsi+4*rbx], eax 
    inc  QWORD rbx
    cmp  rdi, rbx
    jne  repair_loop
    xor  eax, eax
    ret
    