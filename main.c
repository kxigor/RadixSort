#include <stdio.h>
#include "./src/radix_uint64/radix_uint64.h"
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
    while(0)                                    \

int main(void)
{
    uint64_t arr[] = {
        0, 9, 8, 7, 6, 5, 4, 3, 2, 1, 2, 3, 4, 5, 4, 3, 2, 1, 5, 6, 7, 6, 5, 4, 3, 2, 1, 8, 9, 0
    };
    
    arr_out(arr, sizearr(arr), "%lu");
    radix_uint64(arr, sizearr(arr));
    arr_out(arr, sizearr(arr), "%lu");
}