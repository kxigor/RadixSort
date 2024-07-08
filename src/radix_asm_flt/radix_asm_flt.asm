global radix_asm_flt

extern calloc
extern free

section .text

;-------------------------
;
; FUNC: RADIX ASM UINT64 SORT
; void radix_asm_flt(float arr[], arrSize)
;
; OUTPUT:
;   NONE
;
; INPUT:
;   rdi = float arr[]
;   rsi = size_t arrSize
;
; SPOIL:
;   NONE
;
;-------------------------
radix_asm_flt:
    push rax    ; +
    push rbx    ; +
    push rcx    ; +
    push rdx    ; We   memorize  registers
    push r8     ; so as not to litter them
    push r9     ; +
    push r10    ; +
    push r11    ; +

    ;push rsi                   ;
    ;xor rax, rax               ;
    ;mov rsi, rdi               ; printf("%p\n", rdi);
    ;mov rdi, spec_p            ;
    ;call printf WRT ..plt      ;

    ;pop rsi                    ;
    ;xor rax, rax               ;
    ;mov rsi, rsi               ; printf("%lu\n", rsi);
    ;mov rdi, spec_lu           ;
    ;call printf WRT ..plt      ;

    test rdi, rdi   ; if(rdi == NULL)
    jz RAF_EXIT     ;   return;

    test rsi, rsi   ; if(rsi == NULL)
    jz RAF_EXIT     ;   return;

    push rdi                ;
    push rsi                ;
    mov rdi, rsi            ; rdi = rsi = arrSize
    mov rsi, 0x4            ; rsi = 0x4 = sizeof(float)
    call calloc WRT ..plt   ; rax = tmp = calloc(arrSize, sizeof(float))
    pop rsi                 ; rsi = arrSize
    pop rdi                 ; rdi = arr
    
    test rax, rax   ; if(rax == NULL)
    jz RAF_EXIT     ;   return

    xor rcx, rcx    ; size_t bytePos = 0;
    RAF_BYTE_LOOP:  ; for(; bytePos < 3; bytePos++) { 3 = sizeof(float) - 1

        push rcx                ;
        mov rcx, 256            ; rcx = 256 = sizeof(ctr)
        RAF_MEMSET_LOOP:        ;
            mov rbx, ctr        ; rbx = ctr
            mov qword [rbx], 0  ; [rbx] = 0 i.e. ctr[pos] = 0
            add rbx, 0x8        ; 0x8 = sizeof(size_t)
        loop RAF_MEMSET_LOOP    ;
        pop rcx                 ;

        mov qword [ofs], 0  ; ofs[0] = 0

        push rax    ;
        push rdi    ;

        push rcx                    ;
        mov rdx, rcx                ; rbx = bytePos
        mov rcx, rsi                ; rcx = rsi = arrSize
        RAF_COUNTER_LOOP:           ; for(size_t pos = 0; pos < arrSize; pos++) {
        
            xor rbx, rbx            ; rbx = arr[pos] with zeros filled in
            mov ebx, dword [rdi]    ; because there are different dimensions of 4 and 8 bytes

            push rcx                ;
            call get_byte           ; rax = get_byte(arr[pos], bytePos)
            pop rcx                 ;

            shl rax, 3              ; rax *= 8 i.e. pointer offset
            add rax, ctr            ; rax = ctr + get_byte
            inc qword [rax]         ; [rax]++ i.e. ctr[get_byte]++

            add rdi, 0x4            ; rdi += 0x4(sizeof(float))
        loop RAF_COUNTER_LOOP       ; }
        pop rcx                     ;

        push rcx                ;
        lea rax, [ofs + 8]      ; rax = ofs[pos]
        mov rbx, ofs            ; rbx = ofs[pos - 1]
        mov rdx, ctr            ; rdx = ctr[pos - 1]
        mov rcx, 255            ; for(size_t pos = 1; pos < 256; pos++)
        RAF_OFFSETS_LOOP:       ;

            add rax, 0x8        ; rax += 0x8(sizeof(size_t)) i.e. ptr offset
            add rbx, 0x8        ; rbx += 0x8(sizeof(size_t)) i.e. ptr offset
            add rdx, 0x8        ; rdx += 0x8(sizeof(size_t)) i.e. ptr offset
        loop RAF_OFFSETS_LOOP   ;
        pop rcx                 ;

    inc rcx         ; rcx++
    cmp rcx, 0x3    ; 3 = sizeof(float) - 1
    jb RAF_BYTE_LOOP; }

    pop rdi             ; rdi = tmp
    call free WRT ..plt ; free(rdi)

    RAF_EXIT:

    pop r11 ; +
    pop r10 ; +
    pop r9  ; +
    pop r8  ; Restoring registers
    pop rdx ; +
    pop rcx ; +
    pop rbx ; +
    pop rax ; +

    ret     ; return

;-------------------------
;
; FUNC: Get the corresponding byte from the number
; uint64_t get_byte(uint64_t number, uint64_t bytePos)
;
; OUTPUT:
;   rax
;
; INPUT:
;   rbx = number
;   rdx = bytePos
;
; SPOIL:
;   rcx
;-------------------------
get_byte:
    mov rax, rdx    ; rax = rdx = bytePos
    shl rax, 3      ; rax <<= 3(BYTE_SHIFT_SIZE)
    mov cl, al      ; cl = al
    mov rax, rbx    ; rax = rbx
    shr rax, cl     ; rax >> cl 
    and rax, 0xFF   ; rax &= 0xFF(UINT8_MAX)
    ret             ; ((num >> (bytePos << BYTE_SHIFT_SIZE)) & UINT8_MAX
section .data
    ; 256 = MAX_BYTE
    ctr: times 256 dq 0 ; the array of counters
    ofs: times 256 dq 0 ; the array of offsets