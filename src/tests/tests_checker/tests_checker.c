#include "tests_checker.h"

/*
    Comparator for uint64_t (for qsort)
*/
static int uint64_comparator(const void*, const void*);
/*
    Comparator for flt (for qsort)
*/
static int flt_comparator(const void*, const void*);

/*
    Launching the testing system
*/
void testing()
{
    /*
        Test directories for sorting type uint64_t
    */
    const char* testing_uint64_dirs[] = {
        "./src/tests/TESTING/SIMPLE_UINT64",
        "./src/tests/TESTING/UINT64"
    };
    const size_t testing_uint64_dirs_num = 
        sizeof(testing_uint64_dirs) / sizeof(*testing_uint64_dirs);
    
    /*
        Test directories for sorting type float
    */
    const char* testing_flt_dirs[] = {
        "./src/tests/TESTING/SIMPLE_FLT",
        "./src/tests/TESTING/FLT"
    };
    const size_t testing_flt_dirs_num = 
        sizeof(testing_flt_dirs) / sizeof(*testing_flt_dirs);

    TESTING_SORT(
        testing_uint64_dirs,
        radix_uint64,
        "%lu",
        uint64_t,
        uint64_comparator
    );
    
    TESTING_SORT(
        testing_uint64_dirs,
        radix_asm_uint64,
        "%lu",
        uint64_t,
        uint64_comparator
    );

    TESTING_SORT(
        testing_flt_dirs,
        radix_flt,
        "%f",
        float,
        flt_comparator
    );

    TESTING_SORT(
        testing_flt_dirs,
        radix_asm_flt,
        "%f",
        float,
        flt_comparator
    );
}

static int uint64_comparator(const void* a_p, const void* b_p)
{
    assert(a_p != NULL);
    assert(b_p != NULL);
    return
        (*((const uint64_t*)(b_p)) < *((const uint64_t*)(a_p))) - 
        (*((const uint64_t*)(a_p)) < *((const uint64_t*)(b_p)));
}
static int flt_comparator(const void* a_p, const void* b_p)
{
    assert(a_p != NULL);
    assert(b_p != NULL);
    return
        (*((const float*)(b_p)) < *((const float*)(a_p))) - 
        (*((const float*)(a_p)) < *((const float*)(b_p)));
}