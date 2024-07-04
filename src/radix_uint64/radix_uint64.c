#include "radix_uint64.h"

void radix_uint64(uint64_t arr[], size_t arrSize)
{
    if(!arr || !arrSize)
        return;

    size_t ctr[BYTE_MAX + 1] = {};
    uint64_t* tmp = calloc(arrSize, sizeof(uint64_t));
    assert(tmp != NULL);

    for(size_t bytePos = 0; bytePos < sizeof(uint64_t); bytePos++)
    {
        memset(ctr, 0, sizeof(ctr));
        /*
            Generally speaking, 
            we have two strategies, 
            one of them (reversible) 
            implies subtraction from the counter, 
            and I decided to use the size_t type, 
            so I decided to do this 
            (i.e. the ctr size is 1 larger, 
            and when we increment the counter, 
            we make a shift to the right by 1)
        */
        for(size_t pos = 0; pos < arrSize; pos++)
            ctr[get_byte(arr[pos], bytePos) + 1]++;
        for(size_t pos = 2; pos < BYTE_MAX + 1; pos++)
            ctr[pos] += ctr[pos - 1];
        for(size_t pos = 0; pos < arrSize; pos++)
        {
            size_t* nextPos = ctr + get_byte(arr[pos], bytePos);
            tmp[(*nextPos)++] = arr[pos];
        }
        /*
            An even number of iterations, 
            so at the end we get that tmp is copied to arr
        */
        SWAP_T(uint64_t*, arr, tmp);
    }
    free(tmp);
}