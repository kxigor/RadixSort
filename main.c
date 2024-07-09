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
    //     -2.6f, -2.4f, 9999.f, -9992224324.f, 123.f, -111111.f, 2.5f, -2.5f, 0.001f, -0.001f
    // };
    // arr_out(arr, sizearr(arr), "%f");
    // radix_asm_flt(arr, sizearr(arr));
    // arr_out(arr, sizearr(arr), "%f");
    // printf("Exit the program succes...\n");
}