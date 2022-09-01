module itppd.base.array;

import itppd.base.factory;
import core.attribute;

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


        /*
        this(string values, const Factory f)
        {
            ndata = 0;
            data = null;
            factory = f;
            this.from_string(values);
        }
        */
        @weak ~this();


        // final void set_size(int size, bool copy);


        // extern(D) void set_size(size_t size, bool copy)
        // {
        //     assert(size < int.max);
        //     this.set_size(cast(int)size, copy);
        // }


        // extern(D) void from_string(Range)(auto ref Range r)
        // {
        //     import std.conv : parse;
        //     T[] vs = parse!(T[])(r, '{', '}', ',');
        //     this.set_size(vs.length, false);
        //     this.data[0 .. this.ndata] = vs[];
        // }


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
}


final class ItppArrayFromSlice(T) : Array!T
{
    this(T[] src, const Factory f = defaultFactory)
    in(src.length < int.max)
    {
        super(f);
        this.data = src.ptr;
        this.ndata = cast(int)src.length;
    }


    ~this()
    {
        this.data = null;
        this.ndata = 0;
    }
}


struct ItppArray(T)
{
    @disable this();


    this(T[] src)
    {
        _instance = scopedItppArrayFromSlice(src);
    }


    this(const Array!T src)
    {
        this(src.data[0 .. src.ndata].dup);
    }


    @disable this(this);
    @disable this(ref ItppArray);


    inout(T)[] opIndex() inout { return _instance.slice(); }


    const(Array!T) instance() const { return _instance; }


    Array!T dupInstance() const
    {
        const(T)[] vs = this.opIndex();
        Array!T arr = new Array!T(cast(int)vs.length);
        foreach(i, e; vs)
            arr.data[i] = e;

        return arr;
    }


    inout(T)* ptr() inout { return _instance.data; }


    size_t length() const { return _instance.ndata; }


    static 
    ItppArray!T from_string(Range)(auto ref Range r)
    {
        import std.conv : parse;

        return ItppArray!T(parse!(T[])(r, '{', '}', ','));
    }


    void toString(W)(ref W writer, scope const ref FormatSpec!char f)
    if (isOutputRange!(W, char))
    {
        put(writer, "{");
        T[] vs = this.opIndex();
        foreach(i, e; vs) {
            formatValue(writer, e, f);
            if(i != vs.length - 1)
                put(writer, ", ");
        }
        put(writer, "}");
    }


  private:
    typeof(scopedItppArrayFromSlice!T(null)) _instance;

    static
    auto scopedItppArrayFromSlice(T)(T[] src)
    {
        import std.typecons;
        return scoped!(ItppArrayFromSlice!T)(src, defaultFactory);
    }
}



unittest
{
    auto a = ItppArray!int([1, 2, 3]);
    assert(a[] == [1, 2, 3]);

    Array!int b = a.dupInstance;
    assert(b.slice == [1, 2, 3]);
}