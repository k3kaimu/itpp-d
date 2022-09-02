module itppd.base.vec;

import std.typecons : Rebindable;
import std.complex : Complex;

import itppd.base.stdcpp.complex;
import itppd.base.stdcpp.string;

import itppd.base.binary;
import itppd.base.mat;
import itppd.base.factory;
import itppd.base.copy_vector;


extern(C++, "itpp")
{

extern(C++, class)
struct Vec(T)
{
    extern(D) this(int size, const Factory f = defaultFactory)
    {
        factory = f;
        alloc(size);
    }


    // // copy ctor
    extern(D) this(ref return scope Vec!T v)
    {
        factory = v.factory;
        alloc(v.datasize);
        copy_vector(datasize, v.data, data);
    }


    extern(D) this(ref return scope Vec!T v, const Factory f)
    {
        factory = f;
        this(v);
    }


    static if(is(T == double) || is(T == complex!double) || is(T == int) || is(T == short) || is(T == bin))
    {
        extern(D) this(string str, const Factory f = defaultFactory)
        {
            factory = f;
            auto p = make_string(str.ptr, str.length);
            scope(exit) delete_string(p);

            set(ref_to_cppstring(p));
        }


        void set(ref const basic_string!char str);
    }


    extern(D) this(const(T)* c_array, int size, const Factory f = defaultFactory)
    {
        factory = f;
        alloc(size);
        copy_vector(size, c_array, data);
    }


    extern(D) this(const T[] slice, const Factory f = defaultFactory)
    in(slice.length < int.max)
    {
        factory = f;
        alloc(cast(int)slice.length);
        copy_vector(cast(int)slice.length, slice.ptr, data);
    }


    extern(D) ~this()
    {
        free();
    }


    extern(D) void set_size(size_t size, bool copy = false)
    in(size < int.max)
    {
        if(datasize == size)
            return;

        if(!copy) {
            free();
            alloc(size);
            return;
        }

        T* tmp = data;
        size_t old_datasize = datasize;
        size_t min_size = datasize < size ? datasize : size;
        alloc(size);
        copy_vector(cast(int)min_size, tmp, data);
        foreach(i; min_size .. size)
            data[i] = T(0);
        
        destroy_elements(tmp, old_datasize);
    }


    extern(D) void set_length(int size, bool copy = false) { set_size(size, copy); }


  static if(is(T == complex!double))
  {
    extern(D) inout(Complex!double)[] opIndex() inout
    {
        if(data)
            return (cast(inout(Complex!double)*)data)[0 .. datasize];
        else
            return null;
    }
  }
  else
  {
    extern(D) inout(T)[] opIndex() inout
    {
        if(data)
            return data[0 .. datasize];
        else
            return null;
    }
  }


    extern(D) auto ref opIndex(size_t i) inout
    in(i < datasize)
    {
        static if(is(T == complex!double))
            return (cast(inout(Complex!double)*)data)[i];
        else
            return data[i];
    }


    extern(D) inout(T)* ptr() inout
    {
        return data;
    }


    extern(D) size_t length() const
    {
        return datasize;
    }


    extern(D) const(Factory) getFactory() const
    {
        return factory;
    }


    extern(D) void zeros()
    {
        foreach(i; 0 .. datasize)
            data[i] = T(0);
    }


    extern(D) void clear()
    {
        zeros();
    }


    extern(D) void ones()
    {
        foreach(i; 0 .. datasize)
            data[i] = T(1);
    }


    // void clear();
    // void ones();





  private:
    int datasize;
    T* data;
    Rebindable!(const(Factory)) factory = defaultFactory;

    static assert(typeof(factory).sizeof == Factory.sizeof);

    extern(D) void alloc(size_t size)
    in(size < int.max)
    {
        if(size > 0) {
            create_elements(data, size, factory);
            datasize = cast(int)size;
        } else {
            data = null;
            datasize = 0;
        }
    }


    extern(D) void free()
    {
        destroy_elements(data, datasize);
        datasize = 0;
        data = null;
    }
}


alias vec = Vec!double;
alias cvec = Vec!(complex!double);
alias ivec = Vec!int;
alias svec = Vec!short;
alias bvec = Vec!bin;


}


unittest
{
    import std.stdio;
    Vec!int a = Vec!int("1,2,3");
    assert(a.datasize == 3);
    foreach(i; 0 .. 3)
        assert(a.data[i] == i+1);

    a.set_size(4, true);
    assert(a.datasize == 4);
    foreach(i; 0 .. 3)
        assert(a.data[i] == i+1);

    Vec!int b;
    b = a;  // call copy constructor
    assert(b.data != a.data);
    assert(b[] == a[]);
}
