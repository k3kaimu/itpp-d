#include <iostream>
#include <sstream>
#include <itpp/itbase.h>
#include <itpp/itcomm.h>


#define itppw_assert(t) itppw_assert_impl(t, __FILE__, __LINE__)


namespace itpp
{
namespace test
{


void itppw_assert_impl(bool cond, const char* filename, int line)
{
    if(!cond) {
        std::stringstream ss;
        ss << "Error!: " << filename << "(" << line << ")";
        it_assert(cond, ss.str().c_str());
    }
}


void test_BCH(BCH *obj, int desired_k)
{
    itppw_assert(obj->get_k() == desired_k);

    bvec input = randb(obj->get_k());
    bvec encoded = obj->encode(input);
    bvec err = encoded;

    err[1] ^= 1;
    err[2] ^= 1;
    // assert(input[] != err[]);
    // if(input == err) return false;
    itppw_assert(input != err);

    bvec decoded = obj->decode(err);
    // if(input != decoded) return false;
    itppw_assert(input == decoded);
}


}
}