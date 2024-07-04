section .text
global _radix_asm_flt

_radix_asm_flt:
    ; Получить адрес массива arr из RDI
    mov rdi, [rdi]
    ; Получить размер массива arr из RSI
    mov rsi, [rsi]

section .data