#include <itpp/comm/bch.h>
#include <iostream>

namespace itpp
{

BCH* new_BCH(int in_n, int in_k, int in_t, const ivec &genpolynom, bool sys)
{
    BCH *p = new BCH(in_n, in_k, in_t, genpolynom, sys);

    return p;
}


BCH* new_BCH(int in_n, int in_t, bool sys)
{
    BCH *p = new BCH(in_n, in_t, sys);

    return p;
}


void delete_BCH(BCH *& obj)
{
    delete obj;
    obj = 0;
}

}