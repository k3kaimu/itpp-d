module itppd.base.onstack;

import std.traits;


enum bool isOnStackable(T) = is(T == class) && is(typeof((ref return scope T t){
    OnStack!T s;
    T.emplaceCC(s, t);
}));


struct OnStack(T)
if (is(T == class) && isFinalClass!T)
{
    this(Args...)(auto ref Args args)
    {
        import core.lifetime : emplace, forward;
        emplace!(Unqual!T)(_data, forward!args);
    }


    this(ref return scope OnStack rhs)
    {
        if(_vtable())
            .destroy(this.payload());

        T.emplaceCC(this, rhs.payload());
    }


    ~this()
    {
        if(_vtable()) {
            .destroy(this.payload());
            (cast(ubyte[])(_data[]))[] = 0;
        }
    }


    T payload()
    {
        if(!_vtable()) {
            _data[] = __traits(initSymbol, T)[];
        }

        return cast(T) _data.ptr;
    }


    const(T) payload() const
    {
        if(!_vtable()) {
            return cast(const(T)) __traits(initSymbol, T).ptr;
        }

        return cast(const(T)) _data.ptr;
    }


    alias payload this;


    void[__traits(classInstanceSize, T)] _data;


    const(void)* _vtable() const {
        return (cast(void*[1])_data[0 .. size_t.sizeof])[0];
    }
}

unittest
{
    import itppd.base.array;

    OnStack!(Array!int) arr;
    arr = OnStack!(Array!int)(123);
    assert(arr.length == 123);

    arr = OnStack!(Array!int)(4);
    assert(arr.length == 4);

    OnStack!(Array!int) arr2;
    assert(arr2._vtable == null);

    arr2.set_size(4);
    assert(arr2.length == 4);
    assert(arr2._vtable != null);
    .destroy(arr2);
    assert(arr2._vtable == null);
}