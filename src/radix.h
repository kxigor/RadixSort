#ifndef RADIX_H
#define RADIX_H

#include <assert.h>
#include <malloc.h>
#include <stddef.h>
#include <stdint.h>
#include <limits.h>
#include <string.h>

#define BYTE_SHIFT_SIZE (3)

#define BYTE_MAX (UINT8_MAX + 1)

#define get_byte(num, pos)\
    ((num >> (pos << BYTE_SHIFT_SIZE)) & UINT8_MAX)

#define SWAP_T(T, a, b) \
    do                  \
    {                   \
        T temp = a;     \
        a = b;          \
        b = temp;       \
    } while (0)

#endif // ! RADIX_H