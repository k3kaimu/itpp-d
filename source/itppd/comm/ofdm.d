module itppd.comm.ofdm;

import itppd.base.binary;
import itppd.base.vec;
import itppd.base.mat;
import itppd.base.stdcpp.complex;


extern(C++, "itpp")
{

extern(C++, class)
struct OFDM
{
    this(int inNfft, int inNcp, int inNupsample = 1)
    {
        set_parameters(inNfft, inNcp, inNupsample);
    }


    int no_carriers() { return Nfft; }
    void set_parameters(const int Nfft, const int Ncp, const int inNupsample = 1);
    cvec modulate(ref const cvec input);
    void modulate(ref const cvec input, ref cvec output);
    cvec demodulate(ref const cvec input);
    void demodulate(ref const cvec input, ref cvec output);


  private:
    double norm_factor;
    bool setup_done = false;
    int Nfft, Ncp, Nupsample;
}

}

unittest
{
    auto a = OFDM(64, 16, 4);
}
