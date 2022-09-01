module itppd.base.copy_vector;

import itppd.base.stdcpp.complex;
import itppd.base.binary;

extern(C++, "itpp")
{
    void copy_vector(int n, const(int)* x, int* y);
    void copy_vector(int n, const(short)* x, short* y);
    void copy_vector(int n, const(bin)* x, bin* y);
    void copy_vector(int n, const(double)* x, double* y);
    void copy_vector(int n, const(complex!double)* x, complex!double* y);

    void copy_vector(int n, const(int)* x, int incx, int* y, int incy);
    void copy_vector(int n, const(short)* x, int incx, short* y, int incy);
    void copy_vector(int n, const(bin)* x, int incx, bin* y, int incy);
    void copy_vector(int n, const(double)* x, int incx, double* y, int incy);
    void copy_vector(int n, const(complex!double)* x, int incx, complex!double* y, int incy);

    void swap_vector(int n, int* x, int* y);
    void swap_vector(int n, short* x, short* y);
    void swap_vector(int n, bin* x, bin* y);
    void swap_vector(int n, double* x, double* y);
    void swap_vector(int n, complex!double* x, complex!double* y);

    void swap_vector(int n, int* x, int incx, int* y, int incy);
    void swap_vector(int n, short* x, int incx, short* y, int incy);
    void swap_vector(int n, bin* x, int incx, bin* y, int incy);
    void swap_vector(int n, double* x, int incx, double* y, int incy);
    void swap_vector(int n, complex!double* x, int incx, complex!double* y, int incy);

    void scal_vector(int n, double alpha, double* x);
    void scal_vector(int n, complex!double alpha, complex!double* x);

    void scal_vector(int n, double alpha, double* x, int incx);
    void scal_vector(int n, complex!double alpha, complex!double* x, int incx);

    void axpy_vector(int n, double alpha, const(double)* x, double* y);
    void axpy_vector(int n, complex!double alpha, const(complex!double)* x, complex!double* y);

    void axpy_vector(int n, double alpha, const(double)* x, int incx, double* y, int incy);
    void axpy_vector(int n, complex!double alpha, const(complex!double)* x, int incx, complex!double* y, int incy);

    extern(D)
    {
        void copy_vector(T)(int n, const(T)* x, T* y)
        {
            foreach(i; 0 .. n)
                y[i] = x[i];
        }


        void copy_vector(T)(int n, const(T)* x, int incx, T* y, int incy)
        {
            foreach(i; 0 .. n)
                y[i*incy] = x[i*incx];
        }


        void swap_vector(T)(int n, T* x, T* y)
        {
            foreach(i; 0 .. n)
                swap(x[i], y[i]);
        }


        void swap_vector(T)(int n, T* x, int incx, T* y, int incy)
        {
            foreach(i; 0 .. n)
                swap(x[i*incx], y[i*incy]);
        }


        void scal_vector(T)(int n, T alpha, T* x)
        {
            if(alpha != T(1)) {
                foreach(i; 0 .. n)
                    x[i] *= alpha;
            }
        }


        void scal_vector(T)(int n, T alpha, T* x, int incx)
        {
            if(alpha != T(1)) {
                foreach(i; 0 .. n)
                    x[i*incx] *= alpha;
            }
        }


        void axpy_vector(T)(int n, T alpha, const(T)* x, T* y)
        {
            if (alpha != T(1)) {
                foreach (i; 0 .. n) {
                    y[i] += alpha * x[i];
                }
            }
            else {
                foreach (i; 0 .. n) {
                    y[i] += x[i];
                }
            }
        }


        void axpy_vector(T)(int n, T alpha, const(T)* x, int incx, T* y, int incy)
        {
            if (alpha != T(1)) {
                foreach (i; 0 .. n) {
                    y[i*incy] += alpha * x[i*incx];
                }
            }
            else {
                foreach (i; 0 .. n) {
                    y[i*incy] += x[i*incx];
                }
            }
        }
    }
}


unittest
{
    int a, b;
    copy_vector(0, &a, &b);
}
