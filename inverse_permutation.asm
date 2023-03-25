global inverse_permutation
;rdi - rozmiar tablicy
;rsi - wskaznik na tablice 
; na poczatku sprawdzic czy n dodatnie
;INT_MAX jeszcze może byc ->poprawić 
; połączyc loop z correct
inverse_permutation:
    mov  rbx, 0x0
    test rdi, rdi
    js   exit
    je   exit
    cmp  rdi, 0x7fffffff
    jns  exit
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
    mov  rbx, 0x0
correct:
    mov  eax, [rsi + 4*rbx]
    and  rax, 0x7fffffff
    mov  ecx, [rsi + 4*rax]
    test ecx, ecx
    js   repair 
    or   ecx, 0x80000000
    mov  [rsi + 4*rax],  ecx
    inc  QWORD rbx 
    cmp  rdi, rbx
    jne  correct
    mov  rbx, 0x0
permutation:
    mov  eax, [rsi + 4*rbx]
    test eax, eax
    jns  after_inverse
    ;and rax, 0x7fffffff 
    ;mov  [rsi + 4*rbx],eax
    ;x    -ecx
    ;edx  - aktualny indeks
    ;r8d  -pozycja
    mov  edx, ebx
    mov  r8d, ebx
inverse:
    and  eax, 0x7fffffff 
    mov  [rsi+4*rdx], r8d
    mov  r8d, edx
    mov  ecx, [rsi+4*rax]
    mov  edx, eax
    mov  eax, ecx
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
    mov  eax, 0x0
    ret
repair:
    mov  rbx, 0x0
repair_loop:
    mov  eax, [rsi+4*rbx]
    and  eax, 0x7fffffff
    mov  [rsi+4*rbx], eax 
    inc  QWORD rbx
    cmp  rdi, rbx
    jne  repair_loop
    mov  eax, 0x0
    ret
    