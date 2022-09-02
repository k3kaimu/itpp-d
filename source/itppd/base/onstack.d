module itppd.base.onstack;

import std.traits;
import std.typecons;
import std.meta;


enum bool isOnStackable(T) = is(T == class) && is(typeof((ref return scope T t){
    OnStack!T s;
    T.emplaceCC(s, t);  // copy constructor
    T.emplaceDC(s);     // default constructor
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
            T.emplaceDC(this);
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


/+
// copy from https://github.com/dlang/phobos/blob/v2.100.1/std/typecons.d#L6261
template GetOverloadedMethods(T)
{
    import std.meta : Filter;

    alias allMembers = __traits(allMembers, T);
    template follows(size_t i = 0)
    {
        static if (i >= allMembers.length)
        {
            alias follows = AliasSeq!();
        }
        else static if (!__traits(compiles, mixin("T."~allMembers[i])))
        {
            alias follows = follows!(i + 1);
        }
        else
        {
            enum name = allMembers[i];

            template isMethod(alias f)
            {
                static if (is(typeof(&f) F == F*) && is(F == function))
                    enum isMethod = !__traits(isStaticFunction, f);
                else
                    enum isMethod = false;
            }
            alias follows = AliasSeq!(
                Filter!(isMethod, __traits(getOverloads, T, name)),
                follows!(i + 1));
        }
    }
    alias GetOverloadedMethods = follows!();
}

unittest
{
    import itppd.comm.bch;
    // pragma(msg, GetOverloadedMethods!BCH_itpp);
    static foreach(X; GetOverloadedMethods!BCH_itpp) {
        pragma(msg, X.stringof);
        pragma(msg, typeof(X).stringof);
    }
}


// class WrapCppObj(T) : T
// {
//     this(Args...)(auto ref Args args)
//     {
//         _cppobj = T.newInstance(forward!args);
//     }


//     ~this()
//     {
//         if(_cppobj) {
//             T.deleteInstance(_cppobj);
//             _cppobj = null;
//         }
//     }


//     extern(C++)
//     {
        
//     }


//   private:
//     T _cppobj;
// }
+/


// https://github.com/dlang/phobos/blob/v2.100.1/std/typecons.d#L6261
template GetOverloadedMethods(T)
{
    import std.meta : Filter;

    alias allMembers = __traits(allMembers, T);
    template follows(size_t i = 0)
    {
        static if (i >= allMembers.length)
        {
            alias follows = AliasSeq!();
        }
        else static if (!__traits(compiles, mixin("T."~allMembers[i])))
        {
            alias follows = follows!(i + 1);
        }
        else
        {
            enum name = allMembers[i];

            template isMethod(alias f)
            {
                static if (is(typeof(&f) F == F*) && is(F == function))
                    enum isMethod = !__traits(isStaticFunction, f);
                else
                    enum isMethod = false;
            }
            alias follows = AliasSeq!(
                Filter!(isMethod, __traits(getOverloads, T, name)),
                follows!(i + 1));
        }
    }
    alias GetOverloadedMethods = follows!();
}


// https://github.com/dlang/phobos/blob/v2.100.1/std/typecons.d#L6401
template DerivedFunctionType(T...)
{
    static if (!T.length)
    {
        alias DerivedFunctionType = void;
    }
    else static if (T.length == 1)
    {
        static if (is(T[0] == function))
        {
            alias DerivedFunctionType = T[0];
        }
        else
        {
            alias DerivedFunctionType = void;
        }
    }
    else static if (is(T[0] P0 == function) && is(T[1] P1 == function))
    {
        alias FA = FunctionAttribute;

        alias F0 = T[0], R0 = ReturnType!F0, PSTC0 = ParameterStorageClassTuple!F0;
        alias F1 = T[1], R1 = ReturnType!F1, PSTC1 = ParameterStorageClassTuple!F1;
        enum FA0 = functionAttributes!F0;
        enum FA1 = functionAttributes!F1;

        template CheckParams(size_t i = 0)
        {
            static if (i >= P0.length)
                enum CheckParams = true;
            else
            {
                enum CheckParams = (is(P0[i] == P1[i]) && PSTC0[i] == PSTC1[i]) &&
                                   CheckParams!(i + 1);
            }
        }
        static if (R0.sizeof == R1.sizeof && !is(CommonType!(R0, R1) == void) &&
                   P0.length == P1.length && CheckParams!() && TypeMod!F0 == TypeMod!F1 &&
                   variadicFunctionStyle!F0 == variadicFunctionStyle!F1 &&
                   functionLinkage!F0 == functionLinkage!F1 &&
                   ((FA0 ^ FA1) & (FA.ref_ | FA.property)) == 0)
        {
            alias R = Select!(is(R0 : R1), R0, R1);
            alias FX = FunctionTypeOf!(R function(P0));
            // @system is default
            alias FY = SetFunctionAttributes!(FX, functionLinkage!F0, (FA0 | FA1) & ~FA.system);
            alias DerivedFunctionType = DerivedFunctionType!(FY, T[2 .. $]);
        }
        else
            alias DerivedFunctionType = void;
    }
    else
        alias DerivedFunctionType = void;
}


// https://github.com/dlang/phobos/blob/v2.100.1/std/typecons.d#L5812
template WrapCppObj(C)
if(is(C == class))
{
    import std.meta : staticMap;

    template FuncInfo(string s, F)
    {
        enum name = s;
        alias type = F;
    }

    // https://issues.dlang.org/show_bug.cgi?id=12064: Remove NVI members
    template OnlyVirtual(members...)
    {
        enum notFinal(alias T) = !__traits(isFinalFunction, T);
        import std.meta : Filter;
        alias OnlyVirtual = Filter!(notFinal, members);
    }

    // Remove duplicated functions based on the identifier name and function type covariance
    template Uniq(members...)
    {
        static if (members.length == 0)
            alias Uniq = AliasSeq!();
        else
        {
            alias func = members[0];
            enum  name = __traits(identifier, func);
            alias type = FunctionTypeOf!func;
            template check(size_t i, mem...)
            {
                static if (i >= mem.length)
                    enum ptrdiff_t check = -1;
                else
                {
                    enum ptrdiff_t check =
                        __traits(identifier, func) == __traits(identifier, mem[i]) &&
                        !is(DerivedFunctionType!(type, FunctionTypeOf!(mem[i])) == void)
                        ? i : check!(i + 1, mem);
                }
            }
            enum ptrdiff_t x = 1 + check!(0, members[1 .. $]);
            static if (x >= 1)
            {
                alias typex = DerivedFunctionType!(type, FunctionTypeOf!(members[x]));
                alias remain = Uniq!(members[1 .. x], members[x + 1 .. $]);

                static if (remain.length >= 1 && remain[0].name == name &&
                            !is(DerivedFunctionType!(typex, remain[0].type) == void))
                {
                    alias F = DerivedFunctionType!(typex, remain[0].type);
                    alias Uniq = AliasSeq!(FuncInfo!(name, F), remain[1 .. $]);
                }
                else
                    alias Uniq = AliasSeq!(FuncInfo!(name, typex), remain);
            }
            else
            {
                alias Uniq = AliasSeq!(FuncInfo!(name, type), Uniq!(members[1 .. $]));
            }
        }
    }
    alias TargetMembers = Uniq!(OnlyVirtual!(GetOverloadedMethods!C));             // list of FuncInfo
    // alias SourceMembers = GetOverloadedMethods!Source;  // list of function symbols

    // // Check whether all of SourceMembers satisfy covariance target in TargetMembers
    // template hasRequireMethods(size_t i = 0)
    // {
    //     static if (i >= TargetMembers.length)
    //         enum hasRequireMethods = true;
    //     else
    //     {
    //         enum hasRequireMethods =
    //             findCovariantFunction!(TargetMembers[i], Source, SourceMembers) != -1 &&
    //             hasRequireMethods!(i + 1);
    //     }
    // }

    // Internal wrapper class
    class WrapCppObj : C
    {
        this(Args...)(auto ref Args args)
        {
            _wrap_source = C.makeInstance(forward!args);
        }


        ~this()
        {
            if(_wrap_source) {
                C.deleteInstance(_wrap_source);
                _wrap_source = null;
            }
        }


    private:
        C _wrap_source;

        import std.conv : to;
        import core.lifetime : forward;
        template generateFun(size_t i)
        {
            enum name = TargetMembers[i].name;
            enum fa = functionAttributes!(TargetMembers[i].type);
            static @property stc()
            {
                string r;
                if (fa & FunctionAttribute.property)    r ~= "@property ";
                if (fa & FunctionAttribute.ref_)        r ~= "ref ";
                if (fa & FunctionAttribute.pure_)       r ~= "pure ";
                if (fa & FunctionAttribute.nothrow_)    r ~= "nothrow ";
                if (fa & FunctionAttribute.trusted)     r ~= "@trusted ";
                if (fa & FunctionAttribute.safe)        r ~= "@safe ";
                return r;
            }
            static @property mod()
            {
                alias type = AliasSeq!(TargetMembers[i].type)[0];
                string r;
                static if (is(type == immutable))       r ~= " immutable";
                else
                {
                    static if (is(type == shared))      r ~= " shared";
                    static if (is(type == const))       r ~= " const";
                    else static if (is(type == inout))  r ~= " inout";
                    //else  --> mutable
                }
                return r;
            }
            enum n = to!string(i);
            static if (fa & FunctionAttribute.property)
            {
                static if (Parameters!(TargetMembers[i].type).length == 0)
                    enum fbody = "_wrap_source."~name;
                else
                    enum fbody = "_wrap_source."~name~" = forward!args";
            }
            else
            {
                    enum fbody = "_wrap_source."~name~"(forward!args)";
            }
            enum generateFun =
                "extern(C++) override "~stc~"ReturnType!(TargetMembers["~n~"].type) "
                ~ name~"(Parameters!(TargetMembers["~n~"].type) args) "~mod~
                "{ return "~fbody~"; }";
        }

    public:
        static foreach (i; 0 .. TargetMembers.length) {
            static if(TargetMembers[i].name != "__dtor")
                mixin(generateFun!i);
        }
    }
}
