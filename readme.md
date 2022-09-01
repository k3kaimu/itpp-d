# itpp-d: IT++ for dlang

## BER simulation on BPSK

```d
/+ dub.json:
{
	"name": "bpsk_ber_sim",
    "dependencies": {
        "itpp-d": { "path": ".." }
    },
}
+/
module examples.bpsk_ber_sim;

import std.math;
import std.stdio;
import std.range : iota;

import itppd.base.vec;
import itppd.base.random;
import itppd.comm.modulator;

void main()
{
    foreach(EbN0_dB; iota(0, 11)) {
        int N = 1_000_000;
        double N0 = 10.0^^(-EbN0_dB/10.0);

        BPSK bpsk = new BPSK();

        bvec bits, dec_bits;
        vec symbols, rec, noise;
        
        bits = randb(N);

        bpsk.modulate_bits(bits, symbols);

        rec.set_size(N);
        noise = randn(N);

        foreach(i; 0 .. N)
            rec[i] = symbols[i] + sqrt(N0/2) * noise[i];

        bpsk.demodulate_bits(rec, dec_bits);

        size_t cnt;
        foreach(i; 0 .. N)
            if(bits[i] != dec_bits[i])
                ++cnt;
        
        writefln!"%s (dB): %s"(EbN0_dB, cnt * 1.0 / N);
    }
}
```