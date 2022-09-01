#include <itpp/base/vec.h>

namespace itpp
{

template <typename T>
void dummy_instantiate_vec_1()
{
    Vec<T> v;
    v.set_size(0, false);
    v.set_length(0, false);
    v.zeros();
    v.clear();
    v.ones();

    T t;
    v.set(0, t);

    v.transpose();
    v.T();
    v.hermitian_transpose();
    v.H();
}


void dummy_instantiate_vec_2()
{
    dummy_instantiate_vec_1<int>();
    dummy_instantiate_vec_1<short>();
    dummy_instantiate_vec_1<bin>();
    dummy_instantiate_vec_1<double>();
    dummy_instantiate_vec_1<std::complex<double> >();
}

}