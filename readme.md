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

```sh
$ dub --single --compiler=ldc2 bpsk_ber_sim.d 
parsePackageRecipe dub.json
Running pre-generate commands for itpp-d...
mkdir: cannot create directory ‘cpptmp’: File exists
/home/linuxbrew/.linuxbrew/bin/clang++
Performing "debug" build using ldc2 for x86_64.
itpp-d ~master: building configuration "library"...
libstdc++ std::__cxx11::basic_string is not yet supported; the struct contains an interior pointer which breaks D move semantics!
bpsk_ber_sim ~master: building configuration "application"...
libstdc++ std::__cxx11::basic_string is not yet supported; the struct contains an interior pointer which breaks D move semantics!
Linking...
Running post-generate commands for itpp-d...
Running bpsk_ber_sim 
0 (dB): 0.078817
1 (dB): 0.056131
2 (dB): 0.037212
3 (dB): 0.023125
4 (dB): 0.012413
5 (dB): 0.005804
6 (dB): 0.002426
7 (dB): 0.000748
8 (dB): 0.000194
9 (dB): 3e-05
10 (dB): 3e-06
```
