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
    // float arr[] = {
    //     5.f, 4.f, 3.f, 2.f, -8.f, -8.5f, -8.4f, 5.5f, 2128506.f, -999.f
    // };
    // arr_out(arr, sizearr(arr), "%f");
    // radix_flt(arr, sizearr(arr));
    // arr_out(arr, sizearr(arr), "%f");
    // printf("Exit the program succes...\n");
}