module itppd.comm.modulator;


import itppd.base.binary;
import itppd.base.vec;
import itppd.base.mat;
import itppd.base.stdcpp.complex;


extern(C++, "itpp")
{

enum Soft_Method {
    LOGMAP,
    APPROX
}


class Modulator(T)
{
    extern(D) this()
    {
        setup_done = false;
        k = 0;
        M = 0;
        bitmap = bmat("");
        bits2symbols = ivec("");
        symbols = Vec!T("");
        S0 = imat("");
        S1 = imat("");
    }


    extern(D) this(ref const Vec!T symbols, ref const ivec bits2symbols)
    {
        set(symbols, bits2symbols);
    }


    ~this();

    void set(ref const Vec!T symbols, ref const ivec bits2symbols);
    int get_k() const;
    int get_M() const;
    Vec!T get_symbols() const;
    ivec get_bits2symbols() const;

    void modulate(ref const ivec symbolnumbers, ref Vec!T output) const;
    Vec!T modulate(ref const ivec symbolnumbers) const;

    void demodulate(ref const Vec!T signal, ref ivec output) const;
    ivec demodulate(ref const Vec!T signal) const;

    void modulate_bits(ref const bvec bits, ref Vec!T output) const;
    Vec!T modulate_bits(ref const bvec bits) const;

    void demodulate_bits(ref const Vec!T signal, ref bvec bits) const;
    bvec demodulate_bits(ref const Vec!T signal) const;

    void demodulate_soft_bits(ref const Vec!T rx_symbols, double N0,
                                    ref vec soft_bits,
                                    Soft_Method method = Soft_Method.LOGMAP) const;

    vec demodulate_soft_bits(ref const Vec!T rx_symbols, double N0,
                                   Soft_Method method = Soft_Method.LOGMAP) const;

    void demodulate_soft_bits(ref const Vec!T rx_symbols,
                                    ref const Vec!T channel,
                                    double N0, ref vec soft_bits,
                                    Soft_Method method = Soft_Method.LOGMAP) const;

    vec demodulate_soft_bits(ref const Vec!T rx_symbols,
                                   ref const Vec!T channel,
                                   double N0,
                                   Soft_Method method = Soft_Method.LOGMAP) const;


  protected:
    bool setup_done;
    int k;
    int M;
    bmat bitmap;
    ivec bits2symbols;
    Vec!T symbols;
    imat S0;
    imat S1;

    final void calculate_softbit_matrices();
}


alias Modulator_1D = Modulator!double;
alias Modulator_2D = Modulator!(complex!double);

unittest
{
    auto a = new Modulator_1D();
}


class QAM : Modulator!(complex!double)
{
    extern(D) this() { super(); }
    extern(D) this(int M) { super(); set_M(M); }
    ~this();

    void set_M(int M);

    override void demodulate_bits(ref const cvec signal, ref bvec bits) const;
    override bvec demodulate_bits(ref const cvec signal) const;

  protected:
    int L;
    double scaling_factor;
}


class PSK : Modulator!(complex!double)
{
    extern(D) this() { super(); }
    this(int M) { super(); set_M(M); }
    ~this();

    void set_M(int M);

    override void demodulate_bits(ref const cvec signal, ref bvec bits) const;
    override bvec demodulate_bits(ref const cvec signal) const;
}


class QPSK : PSK
{
    extern(D) this() { super(4); }
    ~this();


    override void demodulate_soft_bits(ref const cvec rx_symbols, double N0,
                                    ref vec soft_bits,
                                    Soft_Method method = Soft_Method.LOGMAP) const;

    override vec demodulate_soft_bits(ref const cvec rx_symbols, double N0,
                           Soft_Method method = Soft_Method.LOGMAP) const;

    override void demodulate_soft_bits(ref const cvec rx_symbols,
                                    ref const cvec channel, double N0,
                                    ref vec soft_bits,
                                    Soft_Method method = Soft_Method.LOGMAP) const;

    override vec demodulate_soft_bits(ref const cvec rx_symbols, ref const cvec channel,
                           double N0, Soft_Method method = Soft_Method.LOGMAP) const;

}


class BPSK_c : PSK
{
    extern(D) this() { super(2); }
    ~this();


    override void modulate_bits(ref const bvec bits, ref cvec output) const;
    override cvec modulate_bits(ref const bvec bits) const;
    override void demodulate_bits(ref const cvec signal, ref bvec output) const;
    override bvec demodulate_bits(ref const cvec signal) const;

    override void demodulate_soft_bits(ref const cvec rx_symbols, double N0,
                                    ref vec soft_bits,
                                    Soft_Method method = Soft_Method.LOGMAP) const;
    override vec demodulate_soft_bits(ref const cvec rx_symbols, double N0,
                           Soft_Method method = Soft_Method.LOGMAP) const;

    override void demodulate_soft_bits(ref const cvec rx_symbols,
                                    ref const cvec channel, double N0,
                                    ref vec soft_bits,
                                    Soft_Method method = Soft_Method.LOGMAP) const;

    override vec demodulate_soft_bits(ref const cvec rx_symbols, ref const cvec channel,
                           double N0, Soft_Method method = Soft_Method.LOGMAP) const;
}


class BPSK : Modulator!double
{
    extern(D) this()
    {
        Vec!double a = Vec!double("1.0 -1.0");
        ivec b = ivec("0 1");
        super(a, b);
    }

    ~this();


    override void modulate_bits(ref const bvec bits, ref vec output) const;
    override vec modulate_bits(ref const bvec bits) const;
    override void demodulate_bits(ref const vec signal, ref bvec output) const;
    override bvec demodulate_bits(ref const vec signal) const;

    override void demodulate_soft_bits(ref const vec rx_symbols, double N0,
                                    ref vec soft_bits,
                                    Soft_Method method = Soft_Method.LOGMAP) const;

    override vec demodulate_soft_bits(ref const vec rx_symbols, double N0,
                           Soft_Method method = Soft_Method.LOGMAP) const;

    override void demodulate_soft_bits(ref const vec rx_symbols,
                                    ref const vec channel, double N0,
                                    ref vec soft_bits,
                                    Soft_Method method = Soft_Method.LOGMAP) const;

    override vec demodulate_soft_bits(ref const vec rx_symbols, ref const vec channel,
                           double N0, Soft_Method method = Soft_Method.LOGMAP) const;
}


class PAM_c : Modulator!(complex!double)
{
    this() { super(); }
    this(int M) { super(); set_M(M); }
    ~this();

    void set_M(int M);

    override void demodulate_bits(ref const cvec signal, ref bvec output) const;
    override bvec demodulate_bits(ref const cvec signal) const;

    override void demodulate_soft_bits(ref const cvec rx_symbols, double N0,
                                    ref vec soft_bits,
                                    Soft_Method method = Soft_Method.LOGMAP) const;

    override vec demodulate_soft_bits(ref const cvec rx_symbols, double N0,
                                   Soft_Method method = Soft_Method.LOGMAP) const;

    override void demodulate_soft_bits(ref const cvec rx_symbols,
                                    ref const cvec channel, double N0,
                                    ref vec soft_bits,
                                    Soft_Method method = Soft_Method.LOGMAP) const;

    override vec demodulate_soft_bits(ref const cvec rx_symbols,
                                    ref const cvec channel, double N0,
                                    Soft_Method method = Soft_Method.LOGMAP) const;

  protected:
    double scaling_factor;
}


class PAM : Modulator!double
{
    this() { super(); }
    this(int M) { super(); set_M(M); }
    ~this();

    void set_M(int M);

    override void demodulate_bits(ref const vec signal, ref bvec output) const;
    override bvec demodulate_bits(ref const vec signal) const;

protected:
  double scaling_factor;
}

}