section .text
global _radix_asm_uint64

_radix_asm_uint64:
    ; Получить адрес массива arr из RDI
    mov rdi, [rdi]
    ; Получить размер массива arr из RSI
    mov rsi, [rsi]
    
section .data