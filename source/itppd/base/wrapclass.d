module itppd.base.wrapclass;

import std.traits;
import std.typecons;
import std.meta;
import std.conv;
import core.lifetime;

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


    template generateFun(size_t i, string target, bool forClass = true)
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
        enum fbody = target~"."~name~"(forward!args)";

        static if(forClass)
        {
            enum generateFun =
                "extern(C++) override "~stc~"ReturnType!(TargetMembers["~n~"].type) "
                ~ name~"(Parameters!(TargetMembers["~n~"].type) args) "~mod~
                "{ return "~fbody~"; }";
        }
        else
        {
            enum generateFun =
                stc~"ReturnType!(TargetMembers["~n~"].type) "
                ~ name~"(Parameters!(TargetMembers["~n~"].type) args) "~mod~
                "{ return "~fbody~"; }";
        }
    }


    struct WrapCppObj
    {
        alias DStruct = typeof(this);
        alias DClass = WrapCppObjAsClass;
        alias CppClass = C;


        this(Args...)(auto ref Args args)
        {
            _payload = RefCounted!Payload(args);
        }


        static foreach (i; 0 .. TargetMembers.length) {
            static if(TargetMembers[i].name != "__dtor" && TargetMembers[i].name != "__aggrDtor")
                mixin(generateFun!(i, "_payload._wrap_source", false));
        }


        inout(C) cppInstance() inout
        {
            return _payload._wrap_source;
        }


        alias cppInstance this;


      private:
        RefCounted!Payload _payload;

        static struct Payload
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


            C _wrap_source;
        }
    }


    // Internal wrapper class
    class WrapCppObjAsClass : C
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


        inout(C) cppInstance() inout
        {
            return _wrap_source;
        }


      private:
        C _wrap_source;

      public:
        static foreach (i; 0 .. TargetMembers.length) {
            static if(TargetMembers[i].name != "__dtor" && TargetMembers[i].name != "__aggrDtor")
                mixin(generateFun!(i, "_wrap_source", true));
        }
    }
}
