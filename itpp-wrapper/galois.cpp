#include <itpp/comm/galois.h>


namespace itpp
{

void dummy_instantiate_GF_1()
{
    GF x;
    bvec bv;
    x.set(0, 0);
    x.set(0, bv);
    x.set_size(0);
    x.get_size();
    x.get_vectorspace();
    x.get_value();
}


void dummy_instantiate_GFX_1()
{
    GFX x;
    bvec bv;

    x.get_size();
    x.get_degree();
    x.set_degree(0, false);
    x.get_true_degree();
    x.set(0, "");
    x.set(0, std::string(""));
    x.set(0, ivec(""));
    x.clear();
}

}