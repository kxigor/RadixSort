#include <stdio.h>
#include <stdlib.h>

#include "src/tests/tests_checker/tests_checker.h"

#include "./src/radix_uint64/radix_uint64.h"
#include "./src/radix_flt/radix_flt.h"
#include "./src/radix_asm_uint64/radix_asm_uint64.h"
#include "./src/radix_asm_flt/radix_asm_flt.h"

#define sizearr(arr) (sizeof(arr)/sizeof(*arr))
#define arr_out(arr, size, spec)                \
    do                                          \
    {                                           \
        for(size_t pos = 0; pos < size; pos++)  \
        {                                       \
            printf(spec " ", arr[pos]);         \
        }                                       \
        putchar('\n');                          \
    }                                           \
    while(0)

int main(void)
{
    testing();
    // uint64_t arr[] = {
    //     0, 9, 8, 7, 6, 5, 4, 3, 2, 1, 2, 3, 4, 5, 4, 3, 2, 1, 5, 6, 7, 6, 5, 4, 3, 2, 1, 8, 9, 0
    // };
    // arr_out(arr, sizearr(arr), "%lu");
    // radix_asm_uint64(arr, sizearr(arr));
    // arr_out(arr, sizearr(arr), "%lu");
    // printf("Exit the program succes...\n");
}