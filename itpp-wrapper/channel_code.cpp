#include <itpp/comm/channel_code.h>

namespace itpp
{

void dummy_instantiation_for_Dummy_Code()
{
    Dummy_Code obj{};

    bvec a, b;
    vec c, d;

    obj.encode(a, b);
    obj.encode(a);

    obj.decode(a, b);
    obj.decode(a);

    obj.decode(c, a);
    obj.decode(c);

    obj.get_rate(); 
}

}