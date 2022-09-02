module itppd.base.stdcpp.string;

public import core.stdcpp.string;

alias cppstring = basic_string!char;

extern(C++, "itpp")
{
    void* make_string(const(char)* str);
    void* make_string(const(char)* str, size_t n);
    void delete_string(ref void*);
}


ref cppstring ref_to_cppstring(void* p)
{
    return *cast(cppstring*)p;
}

// alias cppstring = basic_string!char;


// extern(C++, "itpp")
// {
//     cppstring make_string(const(char)* str);
// }


unittest
{
    auto str1 = make_string("123");
    delete_string(str1);
    auto str2 = make_string("123", 3);
    delete_string(str2);
}