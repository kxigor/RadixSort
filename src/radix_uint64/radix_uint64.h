#ifndef RADIX_UINT64_H
#define RADIX_UINT64_H

#include <assert.h>
#include <malloc.h>
#include <stddef.h>
#include <stdint.h>
#include <limits.h>
#include <string.h>

#define BYTE_SHIFT_SIZE (3)
#define BYTE_MAX (UINT8_MAX + 1)
#define get_byte(num, pos)      \
    ((num >> (pos << BYTE_SHIFT_SIZE)) & UINT8_MAX)

void radix_uint64(uint64_t arr[], size_t arrSize);

#endif // ! RADIX_UINT64_H