#include "radix_flt.h"

void radix_flt(float arr[], size_t arrSize)
{
    if(!arr || !arrSize)
        return;

    size_t ctr[BYTE_MAX] = {};
    size_t ofs[BYTE_MAX] = {};
    float* tmp = calloc(arrSize, sizeof(float)); 
    assert(tmp != NULL);

    size_t bytePos = 0;
    /*
        We go through all the bytes except the last one
    */
    for(; bytePos < sizeof(float) - 1; bytePos++)
    {
        memset(ctr, 0, sizeof(ctr));
        ofs[0] = 0;

        for(size_t pos = 0; pos < arrSize; pos++)
            ctr[get_byte(*((uint32_t*)(arr + pos)), bytePos)]++;
        for(size_t pos = 1; pos < BYTE_MAX; pos++)
            ofs[pos] = ofs[pos - 1] + ctr[pos - 1];
        for(size_t pos = 0; pos < arrSize; pos++)
        {
            size_t* nextPos = ofs + get_byte(*((uint32_t*)(arr + pos)), bytePos);
            tmp[(*nextPos)++] = arr[pos];
        }
        SWAP_T(float*, arr, tmp);
    }
    /*
        Let's go through the last byte
    */
    for(; bytePos < sizeof(float); bytePos++)
    {
        memset(ctr, 0, sizeof(ctr));
        /*
            Unlike the counter, 
            we don't have to fill the entire array
        */
        ofs[0] = 0, ofs[255] = 0;

        for(size_t pos = 0; pos < arrSize; pos++)
            ctr[get_byte(*((uint32_t*)(arr + pos)), bytePos)]++;

        /*
            We stuff the number of negative 
            numbers into ofs[0]. This works i.e. 
            the negative bit is the highest bit, 
            all negative numbers of the last byte 
            start with 10000000_2 = 128_10
        */
        for(size_t pos = 128; pos < BYTE_MAX; pos++)
            ofs[0] += ctr[pos];

        /*https://codercorner.com/RadixSortRevisited.htm*/
        /*
            It is clear that positive numbers 
            come after negative ones, so we 
            put the number of negative ones 
            in ofs[0], all positive ones will 
            be to the left of the negative ones
        */
        for(size_t pos = 1; pos < 128; pos++)
            ofs[pos] = ofs[pos - 1] + ctr[pos - 1];
        
        /*
            We do the same for negative ones, 
            but meanwhile  we correct their 
            incorrect position 
            (to understand which one, 
            you can use the usual radix for 
            floats and see what happens)
        */
        for(size_t pos = 0; pos < 127; pos++)
            ofs[254 - pos] = ofs[255 - pos] + ctr[255 - pos];
        for(size_t pos = 128; pos < 256; pos++)
            ofs[pos] += ctr[pos];
        
        for(size_t pos = 0; pos < arrSize; pos++)
        {
            // Positive in usual order
            size_t nextPosOfs = get_byte(*((uint32_t*)(arr + pos)), bytePos);
            if(nextPosOfs < 128) tmp[ofs[nextPosOfs]++] = arr[pos];
            // Negative in reverse order
            else                 tmp[--ofs[nextPosOfs]] = arr[pos];
        }
        SWAP_T(float*, arr, tmp);
    }
    free(tmp);
}