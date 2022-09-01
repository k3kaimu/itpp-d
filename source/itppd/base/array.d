module itppd.base.array;

import itppd.base.factory;
import itppd.base.onstack;

import std.format : FormatSpec, formatValue;
import std.range : isOutputRange;
import std.typecons : Rebindable;

extern(C++, "itpp")
{
    extern(C++)
    class Array(T)
    {
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


        extern(D) inout(T)[] slice() inout { return this.data[0 .. this.ndata]; }


      private:
        void alloc(int n)
        {
            if(n > 0) {
                create_elements(data, n, factory);
                ndata = n;
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
