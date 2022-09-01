#include <string>

namespace itpp
{

struct Cppstring;

Cppstring* make_string(char const* str)
{
    std::string *p = new std::string(str);
    return reinterpret_cast<Cppstring*>(p);
}


Cppstring* make_string(char const* str, size_t n)
{
    std::string *p = new std::string(str, n);
    return reinterpret_cast<Cppstring*>(p);
}


void delete_string(Cppstring *& p)
{
    std::string* str = reinterpret_cast<std::string*>(p);
    delete str;
    p = 0;
}

}