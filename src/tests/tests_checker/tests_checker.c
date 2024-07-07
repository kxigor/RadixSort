#include "tests_checker.h"

static int uint64_comparator(const void*, const void*);
static float flt_comparator(const void*, const void*);
void testing()
{
    const char* testing_flt_dir[] = {
        "./src/tests/TESTING/SIMPLE_FLT",
        "./src/tests/TESTING/FLT"
    };
    const size_t testing_flt_dirs_num = 
        sizeof(testing_flt_dir) / sizeof(*testing_flt_dir);

    const char* testing_uint64_dir[] = {
        "./src/tests/TESTING/SIMPLE_UINT64",
        "./src/tests/TESTING/UINT64"
    };
    const size_t testing_uint64_dirs_num = 
        sizeof(testing_uint64_dir) / sizeof(*testing_uint64_dir);

    for(
        size_t dirNum = 0; 
        dirNum < testing_uint64_dirs_num; 
        dirNum++
    )
    {
        Dir* dir = DirCtor(testing_uint64_dir[dirNum]);
        char* nextFileName = NULL;
        for(
            nextFileName  = DirGetNextFileName(dir);
            nextFileName != NULL;
            nextFileName  = DirGetNextFileName(dir)
        )
        {
            printf("%s start...\n", nextFileName);
            FILE* file = fopen(nextFileName, "r");
            assert(file != NULL);

            {
                size_t size = 0;
                fscanf(file, "%lu", &size);
                uint64_t* arr_my_sort       = calloc(size, sizeof(uint64_t));
                uint64_t* arr_stable_sort   = calloc(size, sizeof(uint64_t));
                assert(arr_my_sort != NULL);
                assert(arr_stable_sort != NULL);
                for(size_t pos = 0; pos < size; pos++)
                {
                    fscanf(file, "%lu", arr_my_sort + pos);
                }
                memcpy(
                    arr_stable_sort, 
                    arr_my_sort, 
                    size * sizeof(uint64_t)
                );

                radix_asm_uint64(arr_my_sort, size);
                qsort(
                    arr_stable_sort, 
                    size, 
                    sizeof(uint64_t), 
                    uint64_comparator
                );

                // for(size_t pos = 0; pos < size; pos++)
                // {
                //     printf("%lu ", arr_my_sort[pos]);
                // }
                // putchar('\n');

                // for(size_t pos = 0; pos < size; pos++)
                // {
                //     printf("%lu ", arr_stable_sort[pos]);
                // }
                // putchar('\n');

                if(memcmp(arr_my_sort, arr_stable_sort, size * sizeof(uint64_t)) != 0)
                {
                    printf("Your sorting is shit!\n");
                    abort();
                }
                free(arr_my_sort);
                free(arr_stable_sort);
            }

            fclose(file);
            printf("%s success!\n", nextFileName);
            free(nextFileName);
        }
    }
}

static int uint64_comparator(const void* a_p, const void* b_p)
{
    assert(a_p != NULL);
    assert(b_p != NULL);
    return
        (*((const uint64_t*)(b_p)) < *((const uint64_t*)(a_p))) - 
        (*((const uint64_t*)(a_p)) < *((const uint64_t*)(b_p)));
}

static float flt_comparator(const void* a_p, const void* b_p)
{
    assert(a_p != NULL);
    assert(b_p != NULL);
    return
        (*((const float*)(b_p)) < *((const float*)(a_p))) - 
        (*((const float*)(a_p)) < *((const float*)(b_p)));
}
