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
        for(size_t pos = 0; pos < arrSize; pos++)
        {
            ctr[get_byte(arr[pos], bytePos) + 1]++;
        }
        for(size_t pos = 2; pos < BYTE_MAX + 1; pos++)
        {
            ctr[pos] += ctr[pos - 1];
        }
        for(size_t pos = 0; pos < arrSize; pos++)
        {
            size_t* nextPos = ctr + get_byte(arr[pos], bytePos);
            tmp[(*nextPos)++] = arr[pos];
        }
        for(size_t pos = 0; pos < arrSize; pos++)
        {
            arr[pos] = tmp[pos];
        }
    }

    free(tmp);
}