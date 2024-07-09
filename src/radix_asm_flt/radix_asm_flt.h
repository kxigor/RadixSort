#ifndef RADIX_ASM_FLT_H
#define RADIX_ASM_FLT_H

#include <stddef.h>
/*
    Radix sorting for floats
    Written in assembly language, 
    implemented in radix_asm_flt.asm
*/
extern void radix_asm_flt(float arr[], size_t arrSize);

#endif //!RADIX_ASM_FLT_H