module itppd.comm.bch;

import itppd.comm.channel_code;
import itppd.base.vec;
import itppd.comm.galois;

import std.traits;
import std.meta;


extern(C++, "itpp")
{

BCH new_BCH(int in_n, int in_k, int in_t, ref const ivec genpolynom, bool sys);
BCH new_BCH(int in_n, int in_t, bool sys);
void delete_BCH(ref BCH);


class BCH : Channel_Code
{
    extern(D) this(int in_n, int in_k, int in_t, ref const ivec genpolynom, bool sys)
    {
        // hacking
        auto src = new_BCH(in_n, in_k, in_t, genpolynom, sys);
        scope(exit) delete_BCH(src);

        this.n = src.n;
        this.k = src.k;
        this.t = src.t;
        this.g = src.g;
        this.systematic = sys;
    }


    extern(D) this(int in_n, int in_t, bool sys)
    {
        // hacking
        auto src = new_BCH(in_n, in_t, sys);
        scope(exit) delete_BCH(src);

        this.n = src.n;
        this.k = src.k;
        this.t = src.t;
        this.g = src.g;
        this.systematic = sys;
    }


    ~this();


    override void encode(ref const bvec uncoded_bits, ref bvec coded_bits);
    override bvec encode(ref const bvec uncoded_bits);

    override void decode(ref const bvec coded_bits, ref bvec decoded_bits);
    override bvec decode(ref const bvec coded_bits);
    
    override void decode(ref const vec received_signal, ref bvec output);
    override bvec decode(ref const vec received_signal);
    
    override double get_rate() const;

    bool decode(ref const bvec coded_bits, ref bvec decoded_message, ref bvec cw_isvalid);
    int get_k() const;


  private:
    int n, k, t, _dummy1_;
    GFX g;
    union { ulong _dummy2_; bool systematic; }
}

}


unittest
{
    static assert(__traits(classInstanceSize, BCH) == 72);

    import itppd.base.random;
    import std.stdio;

    BCH bch = new BCH(31, 2, true);
    bvec input = randb(21);
    bvec encoded;
    bch.encode(input, encoded);
    bvec err = encoded;

    err[1].tupleof[0] ^= 1;
    err[2].tupleof[0] ^= 1;
    assert(input[] != err[]);

    bvec decoded;
    bch.decode(err, decoded);
    assert(input[] == decoded[]);
}