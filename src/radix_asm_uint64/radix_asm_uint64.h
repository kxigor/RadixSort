#ifndef RADIX_UINT64_H
#define RADIX_UINT64_H

#include <stdint.h>
#include <stddef.h>
/*
    Radix sorting for uint64_t
    Written in assembly language, 
    implemented in radix_asm_uint64.asm
*/
extern void radix_asm_uint64(uint64_t arr[], size_t arrSize);

#endif //RADIX_UINT64_H