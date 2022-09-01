module itppd.base.random_dsfmt;


extern(C++, "itpp") extern(C++, "random_details") extern(C++, class)
struct DSFMT(int MEXP, int POS1, int SL1, ulong MSK1, ulong MSK2, ulong FIX1_V, ulong FIX2_V, ulong PCV1_V, ulong PCV2_V)
{
    enum int N = (MEXP - 128) / 104 + 1;
    enum ulong FIX1 = FIX1_V;
    enum ulong FIX2 = FIX2_V;
    enum ulong PCV1 = PCV1_V;
    enum ulong PCV2 = PCV2_V;


    version(D_SIMD)
    {
        enum uint MSK32_1 = cast(uint)((MSK1 >> 32) & (0xffffffffUL));
        enum uint MSK32_2 = cast(uint)(MSK1 & (0xffffffffUL));
        enum uint MSK32_3 = cast(uint)((MSK2 >> 32) & (0xffffffffUL));
        enum uint MSK32_4 = cast(uint)(MSK2 & (0xffffffffUL));
    }


    static struct Context
    {
        static union W128_T
        {
            ulong[2] u;
            uint[4] u32;
            double[2] d;
        }

        alias w128_t = W128_T;
        w128_t[N + 1] status;
        int index;
        uint last_seed;
    }


    this(ref Context c)
    {
        _context = &c;
    }


    void init_gen_rand(uint seed);
    uint genrand_uint32();
    double genrand_close1_open2();
    double genrand_open_open();



  private:
    enum int Nx2 = N * 2;
    enum uint SR = 12U;

    version(bigEndian)
        enum bool bigendian = true;
    else
        enum bool bigendian = false;

    Context* _context;


    static int idxof(int i);
    void initial_mask();
    void period_cerification();
    static void do_recursion(Context.w128_t *r, Context.w128_t *a, Context.w128_t *b, Context.w128_t *lung);
    void dsfmt_gen_rand_all();
}



alias DSFMT !( 521, 3, 25,
        0x000fbfefff77efffUL, 0x000ffeebfbdfbfdfUL,
        0xcfb393d661638469UL, 0xc166867883ae2adbUL,
        0xccaa588000000000UL, 0x0000000000000001UL ) DSFMT_521_RNG;

alias DSFMT !( 1279, 9, 19,
        0x000efff7ffddffeeUL, 0x000fbffffff77fffUL,
        0xb66627623d1a31beUL, 0x04b6c51147b6109bUL,
        0x7049f2da382a6aebUL, 0xde4ca84a40000001UL ) DSFMT_1279_RNG;

alias DSFMT !( 2203, 7, 19,
        0x000fdffff5edbfffUL, 0x000f77fffffffbfeUL,
        0xb14e907a39338485UL, 0xf98f0735c637ef90UL,
        0x8000000000000000UL, 0x0000000000000001UL ) DSFMT_2203_RNG;

alias DSFMT !( 4253, 19, 19,
        0x0007b7fffef5feffUL, 0x000ffdffeffefbfcUL,
        0x80901b5fd7a11c65UL, 0x5a63ff0e7cb0ba74UL,
        0x1ad277be12000000UL, 0x0000000000000001UL ) DSFMT_4253_RNG;

alias DSFMT !( 11213, 37, 19,
        0x000ffffffdf7fffdUL, 0x000dfffffff6bfffUL,
        0xd0ef7b7c75b06793UL, 0x9c50ff4caae0a641UL,
        0x8234c51207c80000UL, 0x0000000000000001UL ) DSFMT_11213_RNG;

alias DSFMT !( 19937, 117, 19,
        0x000ffafffffffb3fUL, 0x000ffdfffc90fffdUL,
        0x90014964b32f4329UL, 0x3b8d12ac548a7c7aUL,
        0x3d84e1ac0dc82880UL, 0x0000000000000001UL ) DSFMT_19937_RNG;


alias DSFMT_19937_RNG ActiveDSFMT;

extern(C++, "itpp") extern(C++, "random_details")
{
ref ActiveDSFMT.Context lc_get();
bool lc_is_initialized();
void lc_mark_initialized();
}

unittest
{
    import std.stdio;
    ActiveDSFMT impl = ActiveDSFMT(lc_get());

    impl.init_gen_rand(0);

    enum uint AVG = 10_000;
    enum uint DIV = 10;
    size_t[DIV] count;
    foreach(i; 0 .. AVG * DIV)
        count[cast(uint)(impl.genrand_open_open() * DIV)] += 1;

    foreach(e; count) {
        assert(AVG * 0.8 < e);
        assert(e < AVG * 1.2);
    }
}
