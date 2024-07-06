global radix_asm_uint64

extern printf
extern calloc
extern free

section .text

;-------------------------
;
; RADIX ASM UINT64 SORT
;
; void radix_asm_uint64(arr[], arrSize)
; rdi = uint64_t arr[]
; rsi = size_t arrSize
;
;-------------------------
radix_asm_uint64:

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

    push rax
    push rbx
    push rcx
    push rdx

    test rdi, rdi   ; if(rdi == NULL)
    jz RAU64_EXIT   ;   return;

    test rsi, rsi   ; if(rsi == NULL)
    jz RAU64_EXIT   ;   return;

    push rdi        ; error
    push rsi        ;

    mov rdi, rsi            ; rdi = arrSize
    mov rsi, 0x8            ; rsi = 0x8 = sizeof(uint64_t)
    call calloc WRT ..plt   ; tmp = rax = calloc(rdi, rsi)

    ;pop rdi
    ;pop rsi

    test rax, rax           ; if(rax == NULL)
    jz RAU64_EXIT           ;   return;
    push rax

    xor rcx, rcx
    RAU64_BYTE_LOOP:    ; for(size_t rcx = 0; rcx < sizeof(uint64_t); rcx++) {

        push rcx                    ;
        mov rcx, 257                ; 257 = sizeof(ctr)
        mov rax, ctr                ;
        RAU64_MEMSET_LOOP:          ;
            mov qword [rax], 0x0    ; memset(ctr, 0, sizeof(ctr));
            add rax, 0x8            ; 0x8 = sizeof(size_t)
        loop RAU64_MEMSET_LOOP      ;
        pop rcx                     ;

        pop rax
        pop rsi
        pop rdi
        push rax
        push rdi
        push rsi

        push rcx
        mov rdx, rcx ; rdx = bytePos
        mov rcx, rsi ; rcx = arrSize
        RAU64_INC_LOOP:
            mov rbx, [rdi]  ; rbx = arr[rcx]

            push rcx
            call get_byte
            pop rcx

            inc rax         ; get_byte + 1
            shl rax, 3      ; rax * 8 i.e. ptr offset
            mov rbx, ctr    ; rbx = ctr
            add rbx, rax    ; rbx = ctr[get_bye + 1]
            inc qword [rbx] ; rbx++

            add rdi, 0x8    ; 0x8 = sizeof(uint64_t)
        loop RAU64_INC_LOOP
        pop rcx

        push rcx                ;
        mov rcx, 2              ; for(size_t pos = 2; pos < BYTE_MAX + 1; pos++) {
        RAU64_LOOP_PREFSUM:     ;
            mov rax, ctr        ;
            mov rbx, rcx        ;
            shl rbx, 3          ;
            sub rbx, 0x8        ; 0x8 = sizeof(size_t)
            add rax, rbx        ;
            mov rbx, [rax]      ;
            add rax, 0x8        ; 0x8 = sizeof(size_t)
            add qword [rax], rbx; ctr[pos] += ctr[pos - 1];
        inc rcx                 ;
        cmp rcx, 256            ; 256 = BYTE_MAX
        jb RAU64_LOOP_PREFSUM   ; }
        pop rcx                 ;

        pop rsi
        pop rdi
        sub rsp, 0x8

        push rcx            ; for(size_t pos = 0; pos < arrSize; pos++) {
        xor rcx, rcx        ;
        RAU64_TMP_LOOP:     ;
            mov rbx, [rdi]  ;

            push rcx        ;
            call get_byte   ;
            pop rcx         ;

            shl rax, 3      ; rax * 8
            add rax, ctr    ; rax = ctr + get_byte(arr[pos], bytePos);

            add rsp, 16
            pop rbx
            sub rsp, 24

            push rax
            mov rax, [rax]
            shl rax, 3
            add rbx, rax
            pop rax
            push rdi
            mov rdi, [rdi]
            mov qword [rbx], rdi
            pop rdi
            inc qword [rax]

            add rdi, 0x8    ; 0x8 = sizeof(uint64_t)
        inc rcx             ;
        cmp rcx, rsi        ;
        jb RAU64_TMP_LOOP   ;
        pop rcx             ; }

        pop rdi
        pop rax
        push rdi
        push rsi
        push rax

        push rcx
        mov rcx, rsi
        RAU64_COPY_LOOP:
            mov rbx, [rax]
            mov qword [rdi], rbx
            add rax, 0x8
            add rdi, 0x8
        loop RAU64_COPY_LOOP
        pop rcx

    inc rcx             ;
    cmp rcx, 0x8        ; 0x8 = sizeof(uint64_t)
    jb RAU64_BYTE_LOOP  ; }

    pop rdi             ;
    call free WRT ..plt ; free(rdi)
    
    pop rsi
    pop rdi

    RAU64_EXIT:

    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret     ; return

;-------------------------
; OUTPUT:
;   rax
; INPUT:
;   rbx = number
;   rdx = bytePos
; SPOIL:
;   rcx
;-------------------------
get_byte:
    mov rax, rdx    ;
    shl rax, 3      ;
    mov cl, al      ;
    mov rax, rbx    ; BYTE_SHIFT_SIZE = 3
    shr rax, cl     ; UINT8_MAX = 255
    and rax, 0xFF   ; ((num >> (pos << BYTE_SHIFT_SIZE)) & UINT8_MAX
    ret

section .data
    spec_p  : db "%p",  10, 0   ; specifier for pointer
    spec_lu : db "%lu", 10, 0   ; specifier for size_t
    ctr     : times 257 dq 0    ; 257 = MAX_BYTE_SIZE + 1