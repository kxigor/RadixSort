#ifndef TESTS_CHECKER_H
#define TESTS_CHECKER_H

#include <assert.h>
#include <malloc.h>
#include <limits.h>
#include <stddef.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>

#include "../../dirs/dirs.h"
#include "../../radix_uint64/radix_uint64.h"
#include "../../radix_asm_uint64/radix_asm_uint64.h"
#include "../../radix_flt/radix_flt.h"
#include "../../radix_asm_flt/radix_asm_flt.h"

#define ASSERT(condition, message)              \
    do {                                        \
        if(!(condition))                        \
        {                                       \
            printf(                             \
                "%s: %s(%d) fatal error!\n"     \
                "Condition: " #condition "\n"   \
                "Message: " message "\n",       \
                __FILE__,                       \
                __PRETTY_FUNCTION__,            \
                __LINE__                        \
            );                                  \
            abort();                            \
        }                                       \
                                                \
    } while(0)

void testing();

/*
    Testing the sorting

    P.S.    It  is  not  the  most  optimal 
            file organization because it is 
            not   a   byte   representation
*/
#define TESTING_SORT(testing_uint64_dirs, sort, specifier, type, comparator)\
    do                                                                      \
    {                                                                       \
        printf("%s testing start ...\n", #sort);                            \
        for(                                                                \
            size_t dirNum = 0;                                              \
            dirNum < testing_uint64_dirs##_num;                             \
            dirNum++                                                        \
        )                                                                   \
        {                                                                   \
            Dir* dir = DirCtor(testing_uint64_dirs[dirNum]);                \
            char* nextFileName = NULL;                                      \
            for(                                                            \
                nextFileName  = DirGetNextFileName(dir);                    \
                nextFileName != NULL;                                       \
                nextFileName  = DirGetNextFileName(dir)                     \
            )                                                               \
            {                                                               \
                FILE* file = fopen(nextFileName, "r");                      \
                ASSERT(                                                     \
                    file != NULL,                                           \
                    "Error opening the test file!"                          \
                );                                                          \
                                                                            \
                size_t size = 0;                                            \
                fscanf(file, "%lu", &size);                                 \
                                                                            \
                type* arr_my_sort     = calloc(size, sizeof(type));         \
                type* arr_stable_sort = calloc(size, sizeof(type));         \
                ASSERT(                                                     \
                    arr_my_sort != NULL,                                    \
                    "Memory allocation!"                                    \
                );                                                          \
                ASSERT(                                                     \
                    arr_stable_sort != NULL,                                \
                    "Memory allocation!"                                    \
                );                                                          \
                                                                            \
                for(size_t pos = 0; pos < size; pos++)                      \
                    fscanf(file, specifier, arr_my_sort + pos);             \
                                                                            \
                memcpy(                                                     \
                    arr_stable_sort,                                        \
                    arr_my_sort,                                            \
                    size * sizeof(type)                                     \
                );                                                          \
                                                                            \
                sort(arr_my_sort, size);                                    \
                qsort(                                                      \
                    arr_stable_sort,                                        \
                    size,                                                   \
                    sizeof(type),                                           \
                    comparator                                              \
                );                                                          \
                ASSERT(                                                         \
                    !memcmp(arr_my_sort, arr_stable_sort, size * sizeof(type)), \
                    "Your sorting is shit!"                                     \
                );                                                              \
                free(arr_my_sort);                                              \
                free(arr_stable_sort);                                          \
                                                                                \
                fclose(file);                                                   \
                free(nextFileName);                                             \
            }                                                                   \
            DirDtor(dir);                                                       \
        }                                                                       \
        printf("%s testing success!\n", #sort);                                 \
    }                                                                           \
    while(0)
#endif //!TESTS_CHECKER_H