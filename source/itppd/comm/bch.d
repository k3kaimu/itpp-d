module itppd.comm.bch;

import itppd.comm.channel_code;
import itppd.base.vec;
import itppd.comm.galois;
// import itppd.base.onstack;
import itppd.base.wrapclass;

import std.traits;
import std.meta;


extern(C++, "itpp")
{

BCH_itpp new_BCH(int in_n, int in_k, int in_t, ref const ivec genpolynom, bool sys);
BCH_itpp new_BCH(int in_n, int in_t, bool sys);
void delete_BCH(ref BCH_itpp);

pragma(mangle, "BCH")
class BCH_itpp : Channel_Code
{
    extern(D)
    {
        static BCH_itpp makeInstance(int in_n, int in_k, int in_t, ref const ivec genpolynom, bool sys)
        {
            return new_BCH(in_n, in_k, in_t, genpolynom, sys);
        }

        static BCH_itpp makeInstance(int in_n, int in_t, bool sys)
        {
            return new_BCH(in_n, in_t, sys);
        }

        static void deleteInstance(BCH_itpp obj)
        {
            delete_BCH(obj);
        }
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


//   private:
//     int n, k, t, _dummy1_;
//     GFX g;
//     union { ulong _dummy2_; bool systematic; }
}

}


alias BCH = WrapCppObj!BCH_itpp;


unittest
{
    import itppd.base.random;

    static void test(T)(T obj, int desired_k)
    {
        assert(obj.get_k == desired_k);

        bvec input = randb(obj.get_k);
        assert(obj.get_k == 21);
        bvec encoded = obj.encode(input);
        bvec err = encoded;

        err[1].tupleof[0] ^= 1;
        err[2].tupleof[0] ^= 1;
        assert(input[] != err[]);

        bvec decoded = obj.decode(err);
        assert(input[] == decoded[]);

        // cpp test
        test_BCH(obj, desired_k);
    }

    BCH bch = new BCH(31, 2, true);
    BCH_itpp bch_c = bch.cppInstance;
    
    test(bch, 21);
    test(bch_c, 21);
    
    BCH_itpp cppobj = new_BCH(31, 2, true);
    scope(exit) delete_BCH(cppobj);

    test(cppobj, 21);
}


version(unittest)
{
    extern(C++, "itpp") extern(C++, "test")
    void test_BCH(BCH_itpp obj, int desired_k);
}