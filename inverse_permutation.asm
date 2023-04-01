global inverse_permutation
; rdi - rozmiar tablicy
; rsi - wskaźnik na tablicę
; W programie występują fragmenty gdzie pozbywam się na chwilę najbardziej znaczącego
; bitu. Zabieg ten służy by dostać się do odpowiedniego miejsca w pamięci. W trakcie
; działania programu zapalam najbardziej znaczący bit, co zmienia wartość komórki.
; Natomiast bit ten służy mi wyłącznie do przechowywania informacji, czy dana liczba się powtórzyła.
; Mogę założyć, że bit ten nie jest używany dla tych liczb, ponieważ na początku w pętli
; sprawdzam czy wszystkie wartości są nieujemne (czyli ten bit nie jest zapalony).  
inverse_permutation:
    xor  rcx, rcx       ; Ustawiam wartość 0 na rcx. Rejestr ten posłuży mi jako licznik.
    mov r9d, 0x7fffffff 
    mov r8d, 0x80000000 ; r9d to INT MAX, a r8d to INT MAX + 1.
    test edi, edi       
    js   exit           ; Rozmiar tablicy nie może być ujemny.
    je   exit           ; Rozmiar tablicy nie może być zerem.
    cmp rdi, r8         ; Rozmiar tablicy nie może być większy od INT MAX + 1. 
    jnbe exit           ; Jeżeli rozmiar tablicy jest niepoprawny to kończę
                        ; działanie programu.
loop:
    mov  eax, [rsi+4*rcx]; Wartości w tablicy są intami, więc zmieszczą się na eax.
    test eax, eax        ; Sprawdzam czy wartość z tablicy jest ujemna,
    js   exit            ; jeżeli tak to kończę działanie programu. 
    cmp  edi, eax        ; Sprawdzam czy wartość komórki jest większa niż rozmiar,
    jbe exit             ; jeżeli tak, to kończę działanie programu.
    inc  ecx             
    cmp  edi, ecx        ; Sprawdzam czy przeszedłem już całą tablicę,
    jne  loop            ; jeżeli nie - to wywołuje kolejny obrót w pętli.
    xor  ecx, ecx        
correct:                 ; Jeżeli jakaś liczba wystąpiła w tablicy, to numerowi miejsca
                         ; równemu pobranej wartości zapalam najbardziej znaczący bit.
    mov  eax, [rsi+4*rcx]; Sprawdzam czy liczby z tablicy się powtórzyły:
    and  eax, r9d        ; pozbywam się na chwilę najbardziej znaczącego znaku
    mov  edx, [rsi+4*rax]
    test edx, edx        ; sprawdzam czy dana liczba jest ujemna, to znaczy, że ma
                         ; zapalony najbardziej znaczący bit, czyli już wystąpiła.
    js   repair          ; Jeżeli tak było (powtórzyła się), naprawiam dane z tablicy.
    or [rsi + 4*rax], r8d; W pozostałym przypadku zapalam najbardziej znaczący bit.
    inc  ecx             
    cmp  edi, ecx        ; Sprawdzam czy przeszedłem już całą tablicę.
    jne  correct         ; jeżeli nie - to wywołuje kolejny obrót w pętli.
    xor  ecx, ecx        
permutation:             
    mov  eax, [rsi+4*rcx]; Wiem, że dane są poprawne, przechodzę do odwracania permutacji.
    test eax, eax        ; Jeżeli najbardziej znaczący bit nie jest zapalony,
                         ; to liczba została już odwrócona w permutacji.
    jns  after_inverse   ; Wtedy pomijam dalszy proces odwracania.
    mov  edx, ecx        ; edx  - aktualny indeks
    mov  r8d, ecx        ; r8d  - pozycja z której przyszedłem
inverse:                 ; Odwracam permutację w cyklu, który ma początek 
                         ; pod adresem rsi + 4* rdx.
    and  eax, r9d        ; Pozbywam się najbardziej znaczącego bitu.
    mov  [rsi+4*rdx], r8d
    mov  r8d, edx        ; Zmieniam wartość pozycji z której przyszedłem.
    mov  edx, eax        ; Zmieniam aktualny numer indeksu.
    mov  eax, [rsi+4*rax]
    test eax, eax        ; Sprawdzam czy dana wartość została juz odwrócona,
    js   inverse         ; jeżeli nie, to wracam do odwracania cyklu.
    mov  [rsi+4*rdx], r8d; W przeciwnym przypadku zapisuje na początku cyklu odpowiednią wartość.
after_inverse:           ; Ten fragment wykonuje się po ewentualnej zmianie kolejności w permutacji.
    inc  ecx             
    cmp  edi, ecx        ; Sprawdzam czy przeszedłem całą tablicę,
    jne  permutation     ; jeżeli nie - to wywołuje kolejny obrót w pętli.
    mov  al, 0x1         ; Wiem, że wszystkie wartości już odwróciłem, więc na al zapisuje 1.
    ret                  ; Zwracam wartość true, czyli permutacja się udała.
exit:
    xor  al, al          ; Dane były niepoprawne, ustawiam wartość al na 0.
    ret                  ; Zwracam wartość false, permutacja się nie udała.
repair:                  ; Dane podczas zmiany niektórych komórek okazały się
     xor  ecx, ecx       ; niepoprane, należy odwrócić zmiany.       
repair_loop:
    mov  eax, [rsi+4*rcx]
    and  eax, r9d        ; Pozbywam się najbardziej znaczącego bitu.
    mov  [rsi+4*rcx], eax; Przypisuję komórce w tablicy zmienionią wartość. 
    inc  ecx             
    cmp  edi, ecx        ; Sprawdzam czy przeszedłem całą tablicę,
    jne  repair_loop     ; jeżeli nie - to wywołuje kolejny obrót w pętli.
    xor  al, al          ; Przeszedłem całą tablicę, więc ustawiam wartość al na 0,
    ret                  ; permutacja sie nie powiodła, więc zwracam wartość false.
    