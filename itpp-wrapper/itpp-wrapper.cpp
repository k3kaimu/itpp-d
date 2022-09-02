#include <string>

namespace itpp
{

void* make_string(char const* str)
{
    return new std::string(str);;
}


void* make_string(char const* str, size_t n)
{
    return new std::string(str, n);
}


void delete_string(void *& p)
{
    std::string* ps = reinterpret_cast<std::string*>(p);
    delete ps;
    p = 0;
}

}