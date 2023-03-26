global inverse_permutation
;rdi - rozmiar tablicy
;rsi - wskaznik na tablice 
;INT_MAX jeszcze może byc ->poprawić
; zmienić na jb zamiast js
;xor z 0x8..
inverse_permutation:
    xor  rbx, rbx
    mov r9d, 0x7fffffff
    mov r8d, 0x80000000
    ;cmp rdi, 0x8...
    ; potem jnbe 
    ;cmp rdi, qword 0x1
    ;jb exit
    test edi, edi
    js   exit
    je   exit
    cmp rdi, r8
    jnbe exit
    ;cmp  r9, rdi
    ;js  exit
    ; moge korzystac z edi
    ; rbx tez moze być juz ebx
loop:
    ; patrzę czy rbx mniejsze od n, jezeli tak to idz do correct
    mov  eax, [rsi+4*rbx]
    test eax, eax
    ;cmp  eax, 0x0
    js   exit
    cmp  edi, eax
    jbe exit
    ;js   exit
    ;je   exit
    inc  ebx
    cmp  edi, ebx
    jne  loop
    xor  ebx, ebx
correct:
    mov  eax, [rsi + 4*rbx]
    and  eax, r9d
    ;xor eax, r8d
    mov  ecx, [rsi + 4*rax]
    test ecx, ecx
    js   repair 
    ;or   ecx, r8d
    ;mov  [rsi + 4*rax],  ecx
    or [rsi + 4*rax], r8d
    inc  ebx 
    cmp  edi, ebx
    jne  correct
    xor  ebx, ebx
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
    inc  ebx 
    cmp  edi, ebx
    jne  permutation
    mov  eax, 0x1
    ret
exit:
    xor  eax, eax
    ret
repair:
    xor  ebx, ebx
repair_loop:
    mov  eax, [rsi+4*rbx]
    and  eax, r9d
    mov  [rsi+4*rbx], eax 
    inc  QWORD rbx
    cmp  edi, ebx
    jne  repair_loop
    xor  eax, eax
    ret
    