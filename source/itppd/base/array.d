module itppd.base.array;

import itppd.base.factory;
import itppd.base.onstack;

import std.format : FormatSpec, formatValue;
import std.range : isOutputRange;
import std.typecons : Rebindable;
import std.traits : hasIndirections;

extern(C++, "itpp")
{
    extern(C++)
    final class Array(T)
    {
        static if(hasIndirections!T) {
            pragma(msg, "Please note that `itppd.base.Array` does not yet support storing pointers or objects!");
        }

        extern(D)
        {
            this(const(Factory) f = defaultFactory)
            {
                ndata = 0;
                data = null;
                factory = f;
            }


            this(int n, const(Factory) f = defaultFactory)
            {
                ndata = 0;
                data = null;
                factory = f;
                alloc(n);
            }
        }


        //  emplace copy constructor
        extern(D)
        static void emplaceCC(ref OnStack!Array this_, return scope Array rhs)
        {
            import core.lifetime : emplace;
            import std.traits : Unqual;

            emplace!(typeof(this))(this_._data, rhs.ndata);
            foreach(i; 0 .. rhs.ndata)
                this_.data[i] = rhs.data[i];
        }


        ~this()
        {
            free();
        }


        extern(D) inout(T)[] opSlice() inout { return this.data[0 .. this.ndata]; }


        extern(D) ref inout(T) opIndex(size_t n) inout
        in(n < ndata)
        {
            return this.data[n];
        }


        inout(T)* ptr() inout { return data; }


        size_t length() const { return ndata; }


        const(Factory) getFactory() const { return factory; }


        extern(D) void set_size(size_t size, bool copy = false)
        {
            if(size == ndata)
                return;
            
            if(!copy) {
                free();
                alloc(size);
                return;
            }

            T* tmp = data;
            int old_ndata = ndata;
            int min = cast(int)((ndata < size) ? ndata : size);

            alloc(size);
            data[0 .. min] = tmp[0 .. min];

            T tzero;
            data[min .. size] = tzero;
            destroy_elements(tmp, old_ndata);
        }


        extern(D) void opOpAssign(string op : "~")(T obj)
        {
            this.set_size(ndata + 1, true);
            this[ndata - 1] = obj;
        }


        extern(D) void opOpAssign(string op : "~", E)(E[] arr)
        if(is(E : T))
        {
            immutable old_ndata = ndata;
            this.set_size(ndata + arr.length, true);
            foreach(i; old_ndata .. ndata) {
                this[i] = arr[i - old_ndata];
            }
        }


        extern(D) void opOpAssign(string op : "~", E)(Array!E arr)
        if(is(E : T))
        {
            immutable old_ndata = ndata;
            this.set_size(ndata + arr.length, true);
            foreach(i; old_ndata .. ndata) {
                this[i] = arr[i - old_ndata];
            }
        }


      private:
        void alloc(size_t n)
        in(n <= int.max)
        {
            if(n > 0) {
                create_elements(data, n, factory);
                ndata = cast(int)n;
            } else {
                data = null;
                ndata = 0;
            }
        }


        void free()
        {
            destroy_elements(data, ndata);
            ndata = 0;
        }


        bool in_range(int i) const {
            return ((i < ndata) && (i >= 0));
        }


        int ndata;
        T* data;
        Rebindable!(const(Factory)) factory;

        static assert(typeof(factory).sizeof == Factory.sizeof);
    }

    // static assert(__traits(classInstanceSize, Array!int) == 32);
}


unittest
{
    auto arr = OnStack!(Array!int)(4);
    assert(arr.length == 4);

    arr[0] = 1;
    arr[1] = 2;
    arr[2] = 3;
    arr[3] = 4;

    arr.set_size(10, true);
    assert(arr.length == 10);
    assert(arr[] == [1, 2, 3, 4, 0, 0, 0, 0, 0, 0]);
}

unittest
{
    auto arr = OnStack!(Array!int)(1);
    assert(arr.length == 1);
    arr[0] = 1;

    arr ~= [2, 3, 4];
    assert(arr.length == 4);
    assert(arr[] == [1, 2, 3, 4]);

    arr ~= 5;
    assert(arr.length == 5);
    assert(arr[] == [1, 2, 3, 4, 5]);

    arr ~= arr;
    assert(arr.length == 10);
    assert(arr[] == [1, 2, 3, 4, 5, 1, 2, 3, 4, 5]);
}