module itppd.base.mat;

import std.typecons : Rebindable;

import itppd.base.binary;
import itppd.base.vec;
import itppd.base.factory;
import itppd.base.stdcpp.complex;
import itppd.base.stdcpp.string;
import itppd.base.copy_vector;


extern(C++, "itpp")
{

extern(C++, class)
struct Mat(T)
{
    extern(D) this(size_t rows, size_t cols, const Factory f = defaultFactory)
    {
        factory = f;
        alloc(rows, cols);
    }


    // copy constructor
    extern(D) this(ref return scope Mat!T m)
    {
        factory = m.getFactory;
        alloc(m.no_rows, m.no_cols);
        copy_vector(m.datasize, m.data, data);
    }


    extern(D) this(ref return scope Mat!T m, const Factory f)
    {
        factory = f;
        alloc(m.no_rows, m.no_cols);
        copy_vector(m.datasize, m.data, data);
    }


    extern(D) this(ref const Vec!T v, const Factory f = defaultFactory)
    in(v.length <= int.max)
    {
        alloc(v.length, 1);
        copy_vector(cast(int)v.length, v.ptr, data);
    }



    // extern(D) this(string str, const Factory f = defaultFactory);
    // extern(D) this(const T* c_array, int rows, int cols, bool row_major = true, const Factory f = defaultFactory)

    // extern(D) ~this();

    static if(is(T == double) || is(T == complex!double) || is(T == int) || is(T == short) || is(T == bin))
    {
        extern(D) this(string str, const Factory f = defaultFactory)
        {
            factory = f;
            Cppstring* p = make_string(str.ptr, str.length);
            scope(exit) delete_string(p);

            set(ref_to_cppstring(p));
        }


        void set(ref const basic_string!char str);
    }


    extern(D) inout(T)* ptr() inout { return data; }
    extern(D) size_t rows() const { return no_rows; }
    extern(D) size_t cols() const { return no_cols; }
    extern(D) size_t size() const { return datasize; }


    ref inout(T) opIndex(size_t r, size_t c) inout
    in(r < no_rows && c < no_cols)
    {
        return data[r+c*no_rows];
    }


    extern(D) const(Factory) getFactory() const
    {
        return factory;
    }


    extern(D) void set_size(int rows, int cols, bool copy = false)
    in(rows >= 0 && cols >= 0)
    {
        if(no_rows == rows && no_cols == cols)
            return;
        
        if(rows == 0 || cols == 0) {
            free();
            return;
        }

        if(!copy) {
            if(datasize == rows * cols) {
                no_rows = rows;
                no_cols = cols;
            } else {
                free();
                alloc(rows, cols);
            }

            return;
        }

        T* tmp = data;
        int old_datasize = datasize;
        int old_rows = no_rows;
        int min_r = (no_rows < rows) ? no_rows : rows;
        int min_c = (no_cols < cols) ? no_cols : cols;

        alloc(rows, cols);
        foreach(i; 0 .. min_c) {
            copy_vector(min_r, &tmp[i*old_rows], &data[i*no_rows]);
        }

        foreach(i; min_r .. rows)
            foreach(j; 0 .. cols)
                data[i+j*rows] = T(0);

        foreach(j; min_c .. cols)
            foreach(i; 0 .. min_r)
                data[i+j*rows] = T(0);
    }


  private:
    int datasize, no_rows, no_cols;
    T* data;
    Rebindable!(const(Factory)) factory = defaultFactory;

    static assert(typeof(factory).sizeof == Factory.sizeof);


    extern(D) void alloc(size_t rows, size_t cols)
    in(rows * cols <= int.max)
    {
        if(rows > 0 && cols > 0) {
            datasize = cast(int)(rows * cols);
            no_rows = cast(int)rows;
            no_cols = cast(int)cols;
            create_elements(data, datasize, factory);
        } else {
            data = null;
            datasize = 0;
            no_rows = 0;
            no_cols = 0;
        }
    }


    extern(D) void free()
    {
        destroy_elements(data, datasize);
        data = null;
        datasize = 0;
        no_rows = 0;
        no_cols = 0;
    }
}


alias mat = Mat!double;
alias cmat = Mat!(complex!double);
alias imat = Mat!int;
alias smat = Mat!short;
alias bmat = Mat!bin;


}


unittest
{
    import std.stdio;
    Mat!int a = Mat!int("0 1 2;3 4 5");
    assert(a.no_rows == 2);
    assert(a.no_cols == 3);

    foreach(i; 0 .. 3) {
        assert(a[0, i] == i);
        assert(a[1, i] == i+3);
    }

    a.set_size(3, 3, true);
    foreach(i; 0 .. 3) {
        assert(a[0, i] == i);
        assert(a[1, i] == i+3);
        assert(a[2, i] == 0);
    }
}
