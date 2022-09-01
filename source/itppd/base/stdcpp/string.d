module itppd.base.stdcpp.string;

public import core.stdcpp.string;

extern(C++, "itpp")
{
    struct Cppstring;
    Cppstring* make_string(const(char)* str);
    Cppstring* make_string(const(char)* str, size_t n);
    void delete_string(ref Cppstring*);
}


ref basic_string!char ref_to_cppstring(Cppstring* p)
{
    return *cast(basic_string!char*)p;
}

// alias cppstring = basic_string!char;


// extern(C++, "itpp")
// {
//     cppstring make_string(const(char)* str);
// }


unittest
{
    Cppstring* str1 = make_string("123");
    delete_string(str1);
    Cppstring* str2 = make_string("123", 3);
    delete_string(str2);
}