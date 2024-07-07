global radix_asm_uint64

extern calloc
extern free

section .text

;-------------------------
;
; FUNC: RADIX ASM UINT64 SORT
; void radix_asm_uint64(arr[], arrSize)
;
; OUTPUT:
;   NONE
;
; INPUT:
;   rdi = uint64_t arr[]
;   rsi = size_t arrSize
;
; SPOIL:
;   NONE
;
;-------------------------
radix_asm_uint64:
    push rax    ; +
    push rbx    ; +
    push rcx    ; +
    push rdx    ; We   memorize  registers
    push r8     ; so as not to litter them
    push r9     ; +
    push r10    ; +
    push r11    ; +

    test rdi, rdi   ; if(rdi == NULL)
    jz RAU64_EXIT   ;   return;

    test rsi, rsi   ; if(rsi == NULL)
    jz RAU64_EXIT   ;   return;

    push rdi                ;
    push rsi                ;
    mov rdi, rsi            ; rdi = arrSize
    mov rsi, 8              ; rsi = 0x8 = sizeof(uint64_t)
    call calloc WRT ..plt   ; rax = tmp = calloc(rdi, rsi)
    pop rsi                 ; rsi = arrSize
    pop rdi                 ; rdi = arr

    test rax, rax           ; if(rax == NULL)
    jz RAU64_EXIT           ;   return;
    push rax                ;

    xor rcx, rcx        ; rcx = bytePos
    RAU64_BYTE_LOOP:    ; for(size_t bytePos = 0; bytePos < sizeof(uint64_t); bytePos++) {
        
        push rcx                    ;
        mov rcx, 257                ; rcx = 257 = sizeof(ctr)
        mov rax, ctr                ; rax = ctr
        RAU64_MEMSET_LOOP:          ; memset(ctr, 0, sizeof(ctr));
            mov qword [rax], 0      ; [rax] = ctr[pos] = 0
            add rax, 8              ; rax += 0x8(sizeof(size_t))
        loop RAU64_MEMSET_LOOP      ;
        pop rcx                     ;

        push rdi            ;
        push rcx            ;
        mov rdx, rcx        ; rdx = bytePos
        mov rcx, rsi        ; rcx = arrSize
        RAU64_INC_LOOP:     ; for(size_t pos = 0; pos < arrSize; pos++) {
            mov rbx, [rdi]  ; rbx = [rdi] = arr[pos]

            push rcx        ;
            call get_byte   ; rax = get_byte(arr[pos], bytePos)
            pop rcx         ;

            inc rax         ; rax += 1
            shl rax, 3      ; rax *= 8 i.e. ptr offset
            mov rbx, ctr    ; rbx = ctr
            add rbx, rax    ; rbx += rax i.e. rax = ctr[get_byte + 1]
            inc qword [rbx] ; [rbx]++

            add rdi, 0x8    ; rdi += 0x8(sizeof(uint64_t))
        loop RAU64_INC_LOOP ; }
        pop rcx             ;

        push rcx                ;
        mov rcx, 2              ; rcx = 2 = pos
        RAU64_LOOP_PREFSUM:     ; for(size_t pos = 2; pos < BYTE_MAX + 1; pos++) {
            mov rax, ctr        ; rax = ctr
            mov rbx, rcx        ; rbx = rcx = pos
            shl rbx, 3          ; rbx *= 8 i.e. ptr offset
            sub rbx, 0x8        ; rbx -= 0x8(sizeof(size_t))
            add rax, rbx        ; rax += rbx i.e. rax = ctr + pos - 1
            mov rbx, [rax]      ; rbx = [rax] i.e. rbx = ctr[pos - 1]
            add rax, 0x8        ; rax += 0x8(sizeof(size_t)) i.e. ptr offset
            add qword [rax], rbx; [rax] += rbx i.e. ctr[pos] += ctr[pos - 1];
        inc rcx                 ; rcx++
        cmp rcx, 256            ; 256 = BYTE_MAX
        jb RAU64_LOOP_PREFSUM   ; }
        pop rcx                 ;


        pop rdi         ; rdi = arr
        sub rsp, 0x8    ;

        push rcx                ;
        mov rcx, rsi            ; rcx = rsi = arrSize
        RAU64_TMP_LOOP:         ; for(size_t pos = 0; pos < arrSize; pos++) {
            mov rbx, [rdi]      ; rbx = [rdi] = arr[pos]

            push rcx            ;
            call get_byte       ; rax = get_byte(arr[pos], bytePos)
            pop rcx             ;

            shl rax, 3          ; rax *= 8 i.e. ptr offset
            add rax, ctr        ; rax += ctr i.e. rax = ctr + get_byte
                                ; nextPos = ctr[get_byte] 

            add rsp, 16         ;
            pop rbx             ; rbx = tmp
            sub rsp, 24         ;

            push rax            ;
            mov rax, [rax]      ; rax = [rax] = ctr[get_bye]
            shl rax, 3          ; rax *= 8 i.e. ptr offset
            add rbx, rax        ; rbx += rax i.e. rbx = tmp + nextPos
            pop rax             ;

            push rdi            ;
            mov rdi, [rdi]      ; rdi = [rdi] i.e. rdi = arr[pos]
            mov qword [rbx], rdi; [rbx] = rdi = arr[pos] 
            pop rdi             ;

            inc qword [rax]     ; [rax]++ i.e. nextPos++

            add rdi, 0x8        ; rdi += 0x8(sizeof(uint64_t))
        loop RAU64_TMP_LOOP     ; }
        pop rcx                 ;

        pop rdi         ; rdi = arr
        pop rax         ; rax = tmp
        sub rsp, 16     ; 

        push rcx                    ;
        mov rcx, rsi                ; rcx = rsi = arrSize
        RAU64_COPY_LOOP:            ; for(size_t pos = 0; pos < arrSize; pos++) {
            mov rbx, [rax]          ; rbx = [rax] i.e. rbx = tmp[pos]
            mov qword [rdi], rbx    ; [rdi] = rbx i.e. arr[pos] = tmp[pos]
            add rax, 0x8            ; rax += 0x8 i.e. ptr offset
            add rdi, 0x8            ; rdi += 0x8 i.e. ptr offset
        loop RAU64_COPY_LOOP        ; }
        pop rcx                     ;

        pop rdi ; rdi = arr
        
    inc rcx             ; rcx++
    cmp rcx, 0x8        ; 0x8 = sizeof(uint64_t)
    jb RAU64_BYTE_LOOP  ; }

    pop rdi             ; rdi = tmp
    call free WRT ..plt ; free(rdi)

    RAU64_EXIT:

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
    ctr: times 257 dq 0 ; 257 = 256(MAX_BYTE_SIZE) + 1