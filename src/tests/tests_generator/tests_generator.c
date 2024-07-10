#include <assert.h>
#include <limits.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>

#include "../../dirs/dirs.h"

#define ONE_ARG (1)

#define ON_SILENT(mode, ...)    \
    do                          \
    if(mode == NORMAL_MODE)     \
        {__VA_ARGS__}           \
    while(0)                

typedef enum Mode
{
    NORMAL_MODE = 0,
    SILENT_MODE = 1
} Mode;

typedef enum RequestType
{
    UINT64_TYPE = 0,
    FLT_TYPE    = 1
} RequestType;

typedef struct Request
{
    char path[PATH_MAX];

    RequestType type;
    int64_t min;
    int64_t max;

    uint64_t from;
    uint64_t to;
    uint64_t step;

    /*
        We have three values from to step. 
        Then the number of files will 
        be counted as (to - from) / step. 
        And the amount of "repetition" 
        increases it by k times
    */
    uint64_t repetitions;
} Request;

Request RequestMake(Mode mode);
void RequestExecute(Request req, Mode mode);

uint64_t    GenRandUint64   (int64_t min, int64_t max);
float       GenRandFlt      (int64_t min, int64_t max);

int main(int argc, char* argv[])
{
    struct timeval tv;
    gettimeofday(&tv,NULL);
    srand(
        (((uint32_t)tv.tv_sec)*1000)+((uint32_t)tv.tv_usec/1000)
    );
    /*
        Let's assume that if there is 
        at   least   some   argument, 
        then silent  mode  is enabled
    */
    Mode mode = 
        (argc == ONE_ARG)   ? 
        NORMAL_MODE         : 
        SILENT_MODE         ;
    Request req = RequestMake(mode);
    RequestExecute(req, mode);
}

Request RequestMake(Mode mode)
{
    Request req = {};

    ON_SILENT(mode,
        printf(
            "Enter the path for the tests\n"
            "(format: str)\n"
        );
    );
    assert(scanf("%s", req.path));

    ON_SILENT(mode,
        printf(
            "Enter the type of request:\n"
            "0 - UINT64_TYPE\n"
            "1 - FLOAT_TYPE\n"
            "(format: 0/1)\n"
        );
    );
    assert(
        scanf("%u", &req.type) == 1
    );

    ON_SILENT(mode,
        printf(
            "Enter the minimum number:\n"
            "(format: int)\n"
        );
    );
    assert(
        scanf("%ld", &req.min) == 1
    );

    ON_SILENT(mode,
        printf(
            "Enter the maximum number(integer):\n"
            "(format: int)\n"
        );
    );
    assert(
        scanf("%ld", &req.max) == 1
    );

    ON_SILENT(mode,
        printf(
            "Enter from to step:\n"
            "(format: uint uint uint)\n"
        );
    );
    assert(
        scanf(
            "%lu %lu %lu", 
            &req.from, &req.to, &req.step
        ) == 3
    );
    
    ON_SILENT(mode,
        printf(
            "Enter the number of repetitions\n"
            "(format: uint)\n"
        );
    );
    assert(
        scanf("%lu", &req.repetitions) == 1
    );

    return req;
}

void RequestExecute(Request req, Mode mode)
{
    DirInit(req.path);

    char fileName[PATH_MAX] = {};

    for(uint64_t k = 0; k < req.repetitions; k++)
    {
        for(
            uint64_t    size  = req.from; 
                        size <= req.to; 
                        size += req.step
        )
        {
            snprintf(
                fileName,
                sizeof(fileName),
                /*4047 to make it impossible to overflow the buffer*/
                "%.4047s/%lu_%lu.stress",
                req.path, size, k
            );
            FILE* file = fopen(fileName, "w");
            assert(file != NULL);

            fprintf(file, "%lu\n", size);

            if(req.type == UINT64_TYPE)
                for(uint64_t i = 0; i < size; i++)
                    fprintf(
                        file,
                        "%lu\n",
                        GenRandUint64(req.min, req.max)
                    );
            else /*req.type == FLT_TYPE*/
                for(uint64_t i = 0; i < size; i++)
                    fprintf(
                        file,
                        "%f ",
                        GenRandFlt(req.min, req.max)
                    );
                
            fclose(file);
        }
    }
    ON_SILENT(mode,
        printf("The request was completed successfully!\n");
    );
}

/*
    Generate a random uint32 [a, b]
*/
uint64_t GenRandUint64(int64_t min, int64_t max)
{
    if(min > max)
    {
        return (uint64_t)min;
    }
    return (uint64_t)(min + (rand() % (max - min + 1)));
}

/*
    Generate a random float [a, b]
*/
float GenRandFlt(int64_t min, int64_t max)
{
    if(min >= max)
    {
        return (float)min;
    }
    return (float)min + (float)rand() / (float)RAND_MAX * (float)(max - min);
}