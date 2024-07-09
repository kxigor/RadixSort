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

    ;-------------------------
    ; We go through all the bytes except the last one
    ;-------------------------

    xor rcx, rcx    ; size_t bytePos = 0;
    RAF_BYTE_LOOP:  ; for(; bytePos < 3; bytePos++) { 3 = sizeof(float) - 1

        push rcx                ;
        mov rbx, ctr            ; rbx = ctr
        mov rcx, 256            ; rcx = 256 = sizeof(ctr)
        RAF_MEMSET_LOOP:        ;
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
        mov rcx, 255            ; for(size_t pos = 1; pos < 256; pos++) {
        RAF_OFFSETS_LOOP:       ;
            mov rdi, qword [rbx]; rdi  = [rbx](ofs[pos - 1])
            mov qword [rax], rdi; [rax]  = rdi(ofs[pos - 1])
            mov rdi, qword [rdx]; rdi  = [rdx](ctr[pos - 1])
            add qword [rax], rdi; [rax] += rdi(ctr[pos - 1])
            add rax, 0x8        ; rax += 0x8(sizeof(size_t)) i.e. ptr offset
            add rbx, 0x8        ; rbx += 0x8(sizeof(size_t)) i.e. ptr offset
            add rdx, 0x8        ; rdx += 0x8(sizeof(size_t)) i.e. ptr offset
        loop RAF_OFFSETS_LOOP   ; }
        pop rcx                 ;

        pop rdi     ; rdi = arr
        push rdi    ;

        push rcx                    ;
        mov rdx, rcx                ; rdx = bytePos
        mov rcx, rsi                ; rcx = arrSize
        RAF_TMP_LOOP:               ; for(size_t pos = 0; pos < arrSize; pos++) {

            xor rbx, rbx            ; rbx = 0
            mov ebx, dword [rdi]    ; ebx = arr[pos]

            push rcx                ;
            call get_byte           ; rax = get_byte(rbx, rdx)
            pop rcx                 ;     = get_byte(arr[pos], byte_pos)

            shl rax, 3              ; rax *= 8(sizeof(size_t)) i.e. pointer offset
            mov rbx, ofs            ; rbx = ofs
            add rbx, rax            ; rbx = ofs + rax = ofs + get_byte

            add rsp, 16             ;
            pop rax                 ; rax = tmp
            sub rsp, 24             ;

            push rdx                ;
            mov rdx, qword [rbx]    ;
            shl rdx, 2              ; rdx *= 4(sizeof(float)) i.e. pointer offset
            add rax, rdx            ; rax += [rbx] i.e. tmp[ofs + get_byte]
            xor rdx, rdx            ; rdx = 0
            mov edx, dword [rdi]    ; edx = arr[pos]
            mov dword [rax], edx    ; tmp[nextPos] = arr[pos]
            inc qword [rbx]         ; [rbx]++ i.e. nextPos++
            pop rdx                 ;

            add rdi, 0x4            ; rdi += 0x4(sizeof(float))
        loop RAF_TMP_LOOP           ; }
        pop rcx                     ;

        pop rdi     ; rdi = arr
        pop rax     ; rax = tmp
        sub rsp, 16 ;

        push rcx                    ;
        mov rcx, rsi                ; rcx = arrSize
        RAF_EQ_LOOP:                ; for(size_t pos = 0; pos < arrSize; pos++ {)
            mov ebx, dword [rax]    ; rbx = tmp[pos]
            mov dword [rdi], ebx    ; arr[pos] = rbx = tmp[pos]
            add rax, 0x4            ; rax += 0x4(sizeof(float))
            add rdi, 0x4            ; rdi += 0x4(sizeof(float))
        loop RAF_EQ_LOOP            ; }
        pop rcx                     ;

        pop rdi ;
        pop rax ;

    inc rcx         ; rcx++
    cmp rcx, 0x3    ; 3 = sizeof(float) - 1
    jb RAF_BYTE_LOOP; }

    ;-------------------------
    ; Let's go through the last byte
    ;-------------------------

    ;-------------------------

    mov rbx, ctr                ; rbx = ctr
    mov rcx, 256                ; rcx = 256 = sizeof(ctr)
    RAF_LAST_MEMSET_LOOP:       ;
        mov qword [rbx], 0      ; [rbx] = 0 i.e. ctr[pos] = 0
        add rbx, 0x8            ; 0x8 = sizeof(size_t)
    loop RAF_LAST_MEMSET_LOOP   ;

    mov rbx, ofs                ;
    mov qword [rbx], 0          ; ofs[0] = 0
    lea rbx, [ofs + 255 * 8]    ;
    mov qword [rbx], 0          ; ofs[255] = 0

    push rax    ;
    push rdi    ;

    mov rcx, rsi                ; rcx = arrSize
    mov rdx, 0x3                ; i.e. last byte pos
    RAF_LAST_COUNTER_LOOP:      ; for(size_t pos = 0; pos < arrSize; pos++) {
        
        xor rbx, rbx            ;
        mov ebx, dword [rdi]    ; rbx = arr[pos]

        push rcx                ;
        call get_byte           ; rax = get_byte(arr[pos], 3)
        pop rcx                 ;

        shl rax, 3              ; rax *= 8 i.e. pointer offset
        add rax, ctr            ; rax = ctr + get_byte
        inc qword [rax]         ; [rax]++ i.e. ctr[get_byte]++

        add rdi, 0x4            ; rdi += 0x4(sizeof(float))
    loop RAF_LAST_COUNTER_LOOP  ; }

    mov rcx, 128                ; rcx = 128 i.e. 256 - 128
    lea rax, [ctr + 128 * 8]    ; *8 i.e. pointer offset
    RAF_LAST_ZERO_OFS_LOOP:     ; for(size_t pos = 128; pos < 256; pos++) {
        mov rbx, qword [rax]    ;
        add qword [ofs], rbx    ; ofs[0] += ctr[pos]
        add rax, 0x8            ; rax += 0x8(sizeof(size_t))
    loop RAF_LAST_ZERO_OFS_LOOP ; }

    lea rax, [ofs + 1 * 8]              ; rax = ofs[pos]
    mov rbx, ofs                        ; rbx = ofs[pos - 1]
    mov rdx, ctr                        ; rcx = ofs[pos - 1]
    mov rcx, 127                        ; rcx = 127 i.e. 128 - 1
    RAF_LAST_FIRST_OFFSETS_LOOP:        ; for(size_t pos = 1; pos < 128; pos++)
        mov rdi, qword [rbx]            ; rdi  = [rbx](ofs[pos - 1])
        mov qword [rax], rdi            ; [rax]  = rdi(ofs[pos - 1])
        mov rdi, qword [rdx]            ; rdi  = [rdx](ctr[pos - 1])
        add qword [rax], rdi            ; [rax] += rdi(ctr[pos - 1])
        add rax, 0x8                    ; rax += 0x8(sizeof(size_t)) i.e. ptr offset
        add rbx, 0x8                    ; rbx += 0x8(sizeof(size_t)) i.e. ptr offset
        add rdx, 0x8                    ; rdx += 0x8(sizeof(size_t)) i.e. ptr offset
    loop RAF_LAST_FIRST_OFFSETS_LOOP    ; }

    lea rax, [ofs + 254 * 8]            ; rax = ofs[254 - pos]
    lea rbx, [ofs + 255 * 8]            ; rbx = ofs[255 - pos]
    lea rdx, [ctr + 255 * 8]            ; rcx = ofs[255 - pos]
    mov rcx, 127                        ; rcx = 127
    RAF_LAST_SECOND_OFFSETS_LOOP:       ; for(size_t pos = 0; pos < 127; pos++)
        mov rdi, qword [rbx]            ; rdi  = [rbx](ofs[255 - pos]) 
        mov qword [rax], rdi            ; [rax]  = rdi(ofs[255 - pos])
        mov rdi, qword [rdx]            ; rdi  = [rdx](ctr[255 - pos])
        add qword [rax], rdi            ; [rax] += rdi(ctr[255 - pos])
        sub rax, 0x8                    ; rax -= 0x8(sizeof(size_t)) i.e. ptr offset
        sub rbx, 0x8                    ; rbx -= 0x8(sizeof(size_t)) i.e. ptr offset
        sub rdx, 0x8                    ; rdx -= 0x8(sizeof(size_t)) i.e. ptr offset
    loop RAF_LAST_SECOND_OFFSETS_LOOP   ; }

    lea rax, [ofs + 128 * 8]            ; rax = ofs[pos]
    lea rbx, [ctr + 128 * 8]            ; rbx = ctr[pos]
    mov rcx, 128                        ; i.e. 256 - 128
    RAF_LAST_THIRD_OFFSETS_LOOP:        ; for(size_t pos = 128; pos < 256; pos++)
        mov rdx, qword [rbx]            ; rdx = ctr[pos]
        add qword [rax], rdx            ; ofs[pos] += ctr[pos]
        add rax, 0x8                    ; rax += 0x8(sizeof(size_t))
        add rbx, 0x8                    ; rbx += 0x8(sizeof(size_t))
    loop RAF_LAST_THIRD_OFFSETS_LOOP    ; }

    pop rdi         ; rdi = arr
    pop rax         ; rax = tmp
    sub rsp, 16     ;

    mov rcx, rsi                        ; rcx = arrSize
    RAF_LAST_TMP_LOOP:                  ; for(size_t pos = 0; pos < arrSize; pos++) {

        xor rbx, rbx                    ;
        mov ebx, dword [rdi]            ; ebx = arr[pos]

        mov rdx, 0x3                    ; rdx = 0x3 = bytePos i.e last byte
        push rcx                        ;
        call get_byte                   ; rax = get_byte(ebx, rdx)
        pop rcx                         ;

        cmp rax, 128                    ; if(nextPosOfs >= 128) {
        jb RAF_LAST_IF_POSITIVE         ;
        ; RAF_LAST_IF_NEGETIVE          ;
            shl rax, 3                  ; rax *= 8 i.e. pointer offset
            add rax, ofs                ; rax = ofs + rax = ofs[nextPosOfr]
            dec qword [rax]             ; ofs[nextPosOfr]--
            mov rdx, qword [rax]        ; rdx = ofs[nextPosOfr]
            jmp RAF_LAST_IF_POSNEG_END  ;
        ; RAF_LAST_IF_POSITIVE          ;
        RAF_LAST_IF_POSITIVE:           ; } else {
            shl rax, 3                  ; rax *= 8 i.e. pointer offset
            add rax, ofs                ; rax = ofs + rax = ofs[nextPosOfr]
            mov rdx, qword [rax]        ; rdx = ofs[nextPosOfr]
            inc qword [rax]             ; ofs[nextPosOfr]++
        RAF_LAST_IF_POSNEG_END:         ; }

        add rsp, 8                      ;
        pop rax                         ; rax = tmp
        sub rsp, 16                     ;

        shl rdx, 2                      ; rdx *= 4(sizeof(float)) i.e. pointer offser
        add rax, rdx                    ; rax = tmp[ofsNextPos]

        mov dword [rax], ebx            ; tmp[ofsNextPos] = arr[pos]

        add rdi, 0x4                    ;
    loop RAF_LAST_TMP_LOOP              ; }

    pop rdi     ; rdi = arr
    pop rax     ; rax = tmp
    push rax    ;

    mov rcx, rsi                ; rcx = arrSize
    RAF_LAST_EQ_LOOP:           ; for(size_t pos = 0; pos < arrSize; pos++) {
        mov ebx, dword [rax]    ; ebx = tmp[pos]
        mov dword [rdi], ebx    ; arr[pos] = tmp[pos]
        add rax, 0x4            ; rax += 0x4(sizeof(float)) i.e. pointer offset
        add rdi, 0x4            ; rax += 0x4(sizeof(float)) i.e. pointer offset
    loop RAF_LAST_EQ_LOOP       ; }

    ;-------------------------

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