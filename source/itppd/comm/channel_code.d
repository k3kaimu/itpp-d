module itppd.comm.channel_code;

import itppd.base.vec;
import itppd.base.binary;


extern(C++, "itpp")
{


interface Channel_Code
{
    void encode(ref const bvec uncoded_bits, ref bvec coded_bits);
    bvec encode(ref const bvec uncoded_bits);

    void decode(ref const bvec codedbits, ref bvec decoded_bits);
    bvec decode(ref const bvec coded_bits);

    void decode(ref const vec received_signal, ref bvec decoded_bits);
    bvec decode(ref const vec received_signal);

    double get_rate() const;
}


class Dummy_Code : Channel_Code
{
    this() {}

    override void encode(ref const bvec uncoded_bits, ref bvec coded_bits);
    override bvec encode(ref const bvec uncoded_bits);

    override void decode(ref const bvec codedbits, ref bvec decoded_bits);
    override bvec decode(ref const bvec coded_bits);

    override void decode(ref const vec received_signal, ref bvec decoded_bits);
    override bvec decode(ref const vec received_signal);

    override double get_rate() const;
}

}
