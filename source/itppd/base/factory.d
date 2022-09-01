module itppd.base.factory;

import itppd.base.stdcpp.complex;
import itppd.base.binary;

import core.stdcpp.new_;
import core.lifetime;

import std.traits;
import core.attribute;


static const Factory defaultFactory = new Factory();

extern(C++, "itpp")
{
    extern(C++) class Factory
    {
        @weak ~this() nothrow {}
    }


    // pragma(msg, mangledName!DEFAULT_FACTORY);


    extern(D) void create_elements(T)(ref T* ptr, size_t n, const(Factory))
    {
        static if(isIntegral!T || is(T == bin))
        {
            void* p = __cpp_new(T.sizeof * n);
            ptr = cast(T*)p;

            foreach(i; 0 .. n)
                ptr[i] = T.init;
            return;
        }
        else static if(is(T == double) || is(T == complex!double))
        {
            void* p0 = __cpp_new(T.sizeof * n + 16);
            void* p1 = cast(void*)((cast(size_t)(p0) + 16) & (~(size_t(15))));
            *(cast(void**)(p1) - 1) = p0;
            ptr = cast(T*)(p1);

            foreach(i; 0 .. n)
                ptr[i] = T.init;
        }
        else
        {
            void* p = __cpp_new(T.sizeof * n);
            ptr = cast(T*)p;

            foreach(i; 0 .. n)
                emplace(ptr + i);
        }
    }


    extern(D) void destroy_elements(T)(ref T* ptr, size_t n)
    {
        if(ptr)
        {
            static if(isIntegral!T || is(T == bin))
            {
                __cpp_delete(ptr);
            }
            else static if(is(T == double) || is(T == complex!double))
            {
                void* p = *(cast(void**)(ptr) - 1);
                __cpp_delete(p);
            }
            else
            {
                __cpp_delete(ptr);
            }

            ptr = null;
        }
    }
}

unittest
{
    int* p;
    create_elements(p, 10, defaultFactory);

    complex!double* p2;
    create_elements(p2, 10, defaultFactory);
}
