#include <complex>

#include <itpp/base/copy_vector.h>
#include <itpp/base/binary.h>


namespace itpp
{

template <typename T>
void dummy_instantiate_copy_swap_vector_1()
{
    T a, b;
    copy_vector(0, &a, &b);
    copy_vector(0, &a, 0, &b, 0);

    swap_vector(0, &a, &b);
    swap_vector(0, &a, 0, &b, 0);
}


template <typename T>
void dummy_instantiate_scal_axpy_vector_1()
{
    T a, x, y;
    scal_vector(0, a, &x);
    scal_vector(0, a, &x, 0);

    axpy_vector(0, a, &x, &y);
    axpy_vector(0, a, &x, 0, &y, 0);
}


void dummy_instantiate_copy_vector()
{
    dummy_instantiate_copy_swap_vector_1<int>();
    dummy_instantiate_copy_swap_vector_1<short>();
    dummy_instantiate_copy_swap_vector_1<bin>();
    dummy_instantiate_copy_swap_vector_1<double>();
    dummy_instantiate_copy_swap_vector_1<std::complex<double> >();

    dummy_instantiate_scal_axpy_vector_1<double>();
    dummy_instantiate_scal_axpy_vector_1<std::complex<double> >();
}

}