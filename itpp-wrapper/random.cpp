#include <itpp/base/ittypes.h>
#include <itpp/base/random.h>
#include <itpp/base/random_dsfmt.h>


namespace itpp
{
namespace random_details
{

/*
template  <typename T>
void DSFMT_init_gen_rand(T &obj, unsigned int seed)
{
    obj.init_gen_rand(seed);
}
*/


template <typename T>
void dummy_for_DSFMT_initialization_1()
{
    typename T::Context ctx;
    T obj(ctx);

    /*
    DSFMT_init_gen_rand(obj, 0); */
    obj.init_gen_rand(0);
    obj.genrand_uint32();
    obj.genrand_close1_open2();
    obj.genrand_open_open();
}


void dummy_for_DSFMT_initialization_2()
{

    dummy_for_DSFMT_initialization_1<DSFMT_521_RNG>();
    dummy_for_DSFMT_initialization_1<DSFMT_1279_RNG>();
    dummy_for_DSFMT_initialization_1<DSFMT_2203_RNG>();
    dummy_for_DSFMT_initialization_1<DSFMT_4253_RNG>();
    dummy_for_DSFMT_initialization_1<DSFMT_11213_RNG>();
    dummy_for_DSFMT_initialization_1<DSFMT_19937_RNG>();
}


}



void dummy_for_Random_Generator_initialization_1()
{
    Random_Generator obj{};
    obj.random_01();
    obj.random_01_lclosed();
    obj.random_01_rclosed();
    obj.random_int();
    obj.genrand_uint32();
    obj.genrand_close1_open2();
    obj.genrand_close_open();
    obj.genrand_open_close();
    obj.genrand_open_open();
}


void dummy_for_rand_instantiation()
{
    bvec bv;
    bmat bm;
    randb();
    randb(0, bv);
    randb(0);
    randb(0, 0, bm);
    randb(0, 0);

    vec dv;
    mat dm;
    randu();
    randu(0, dv);
    randu(0);
    randu(0, 0, dm);
    randu(0, 0);

    randi(0, 0);
    randi(0, 0, 0);
    randi(0, 0, 0, 0);

    randray(0, 0);
    randrice(0, 0, 0);
    randexp(0, 0);
    randn();
    randn(0, dv);
    randn(0);
    randn(0, 0, dm);
    randn(0, 0);

    cvec cv;
    cmat cm;
    randn_c();
    randn_c(0, cv);
    randn_c(0);
    randn_c(0, 0, cm);
    randn_c(0, 0);
}

// void callConstructor(Random_Generator &obj)
// {
//     new(&obj) Random_Generator();
// }

}