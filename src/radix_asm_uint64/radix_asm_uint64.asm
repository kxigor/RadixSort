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

    test rdi, rdi   ; if(rdi == NULL)
    jz RAU64_EXIT   ;   return;

    test rsi, rsi   ; if(rsi == NULL)
    jz RAU64_EXIT   ;   return;

    push rdi
    push rsi

    mov rdi, rsi            ; rdi = arrSize
    mov rsi, 0x8            ; rsi = 0x8 = sizeof(uint64_t)
    call calloc WRT ..plt   ; tmp = rax = calloc(rdi, rsi)

    test rax, rax           ; if(rax == NULL)
    jz RAU64_EXIT           ;   return;
    push rax

    ;pop rdi
    ;pop rsi

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


    inc rcx             ;
    cmp rcx, 0x8        ; 0x8 = sizeof(uint64_t)
    jb RAU64_BYTE_LOOP  ; }


    ;mov rdi, rax            ; rdi = rax = tmp
    call free WRT ..plt     ; free(rdi)

    RAU64_EXIT:
    ret     ; return

section .data
    spec_p  : db "%p",  10, 0   ; specifier for pointer
    spec_lu : db "%lu", 10, 0   ; specifier for size_t
    ctr     : times 257 dq 0    ; 257 = MAX_BYTE_SIZE + 1