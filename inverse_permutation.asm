global inverse_permutation
;rdi - rozmiar tablicy
;rsi - wskaznik na tablice 
;nie używać rcx
inverse_permutation:
    xor  rcx, rcx       ;ustawiam wartosc rcx na 0
    mov r9d, 0x7fffffff ;przypisuje na rejestry pomocnicze zmienne 
    mov r8d, 0x80000000 ;r9d to INT MAX, a r8d to INT MAX + 1
    test edi, edi       
    js   exit           ; rozmiar tablicy nie może być ujemne
    je   exit           ; rozmiar tablicy nie może być zerem
    cmp rdi, r8         ; rozmiar tablicy nie może być większy od INT MAX + 1 
    jnbe exit           ; jeżeli rozmiar tablicy jest niepoprawny to kończę
                        ; działanie programu
loop:
    mov  eax, [rsi+4*rcx]; wartości w tablicy są intami, więc zmieszczą się na eax
    test eax, eax        ; sprawdzam czy wartosc z tablicy jest ujemna
    js   exit            ; jeżeli tak to kończę program
    cmp  edi, eax        ; sprawdzam czy wartosc komórki jest większy niż rozmiar
    jbe exit             ; jeżeli tak, to kończę program
    inc  ecx             ; zwiększam licznik o jeden
    cmp  edi, ecx        ; sprawdzam czy przeszedłem już całą tablicę
    jne  loop            ; jeżeli nie, to powracam do pętli
    xor  ecx, ecx        ; zeruję licznik
correct:                 ; jeżeli jakaś liczba wystąpiła w tablicy to
                         ; numerowi miejsca ustawiam najbardziej znaczący bit
    mov  eax, [rsi+4*rcx]; sprawdzam czy liczby z tablicy się powtórzyły
    and  eax, r9d        ; pozbywam się na chwilę najbardziej znaczącego znaku
    mov  edx, [rsi+4*rax]; żebym mógł dostać się do odpowiedniej komórki
    test edx, edx        ; sprawdzam czy dana liczba jest ujemna, to znaczy, że ma
                         ; zapalony najbardziej znaczący bit, czyli już wystąpiła
    js   repair          ; jeżeli tak było, naprawiam dane z tablicy
    or [rsi + 4*rax], r8d; zapalam najbardziej znaczący bit
    inc  ecx             ; zwiększam licznik o jeden
    cmp  edi, ecx        ; sprawdzam czy przeszedłem już całą tablicę
    jne  correct         ; jeżeli nie, to powracam do pętli
    xor  ecx, ecx        ; zeruję licznik
permutation:
    mov  eax, [rsi+4*rcx]; przechodzę po tablicy i odwracam permutację
    test eax, eax        ; jeżeli nie jest zapalony najbardziej znaczący bit
                         ; to liczba została już odwrócona w permutacji
    jns  after_inverse   ; wtedy pomijam dalszy proces odwracania
    mov  edx, ecx        ; edx  - aktualny indeks
    mov  r8d, ecx        ; r8d  - pozycja z której przyszedłem
inverse:                 ; odwracam permutację w cyklu, który początek ma 
                         ; w rsi + 4* rdx
    and  eax, r9d        ; pozbywam się najbardziej znaczącego bitu
    mov  [rsi+4*rdx], r8d; zapisuje komórce nową wartość
    mov  r8d, edx        ; zmieniam wartość pozycji z której przyszedłem
    mov  edx, eax        ; zmieniam aktualny numer indeksu
    mov  eax, [rsi+4*rax]; pobieram nową wartość z tablicy
    test eax, eax        ; sprawdzam czy dana wartość została juz odwrócona
    js   inverse         ; jeżeli nie, to wracam do odwracania cyklu
    mov  [rsi+4*rdx], r8d; zapisuje na początku cyklu odpowiednią wartość
after_inverse:           ; to się wykonuje po ewentualnej zmianie permutacji
    inc  ecx             ; zwiększam licznik o jeden
    cmp  edi, ecx        ; sprawdzam czy przeszedłem całą tablicę
    jne  permutation     ; jeżeli nie, to powracam do pętli
    mov  al, 0x1        ; na eax zapisuje 1, czy wartość true
    ret                  ; zwracam wartość true, czyli permutacja się udała
exit:
    xor  al, al        ; dane były niepoprawne, ustawiam wartość eax na 0
    ret                  ; zwracam wartośc false, permutacja się nie udała
repair:                  ; dane podczas zmiany niektórych komórek okazały się
                         ; niepoprane, należy odwrócić zmiany
    xor  ecx, ecx        ; ustawiam wartość licznika na 0
repair_loop:
    mov  eax, [rsi+4*rcx]; przypisuje na zmienną pomocniczą wartość
    and  eax, r9d        ; pozbywam się najbardziej znaczącego bitu
    mov  [rsi+4*rcx], eax; przypisuję komórce zmienienią wartość 
    inc  ecx             ; zwiększam licznik o jeden
    cmp  edi, ecx        ; sprawdzam czy przeszedłem całą tablicę
    jne  repair_loop     ; jeżeli nie, to powracam do pętli
    xor  al, al        ; ustawiam wartość eax na 0, permutacja sie nie powiodła
    ret                  ; zwracam wartość false
    
