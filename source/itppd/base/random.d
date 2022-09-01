module itppd.base.random;

import itppd.base.random_dsfmt;
import itppd.base.binary;
import itppd.base.mat;
import itppd.base.vec;
import itppd.base.stdcpp.complex;

extern(C++, itpp)
{


void GlobalRNG_reset(uint seed);

void GlobalRNG_reset();

uint GlobalRNG_get_local_seed();

void GlobalRNG_randomize();

// void GlobalRNG_get_state(ivec &state);

// void GlobalRNG_set_state(const ivec &state);

extern(C++, class)
struct Random_Generator
{
    alias DSFMT = ActiveDSFMT;

    extern(D) static Random_Generator opCall()
    {
        Random_Generator ret = {DSFMT(lc_get())};
        if(!lc_is_initialized()) {
            ret._dsfmt.init_gen_rand(GlobalRNG_get_local_seed());
            lc_mark_initialized();
        }

        return ret;
    }

    double random_01();
    double random_01_lclosed();
    double random_01_rclosed();
    uint random_int();
    uint genrand_uint32();
    double genrand_close1_open2();
    double genrand_close_open();
    double genrand_open_close();
    double genrand_open_open();

  private:
    DSFMT _dsfmt;
}


extern(C++, class)
struct Bernoulli_RNG
{
    extern(D) static Bernoulli_RNG opCall()
    {
        Bernoulli_RNG ret = { 0.5, Random_Generator() };
        return ret;
    }


    extern(D) static Bernoulli_RNG opCall(double prob)
    {
        Bernoulli_RNG ret = { prob, Random_Generator() };
        return ret;
    }


    void setup(double prob);
    double get_setup() const;

    // bin sample();

    // extern(D) bin opCall() { ... }
    // extern(D) bvec opCall(int n) { ... }
    // extern(D) bmat opCall(int h, int w) { ... }

    // void sample_vector(int size, ref bvec out);
    // void sample_matrix(int rows, int cols, ref bmat out);

  private:
    double p = 0.5;
    Random_Generator RNG;
}


// void callConstructor(ref Random_Generator);

}

unittest
{
    Random_Generator impl = Random_Generator();

    enum uint AVG = 10_000;
    enum uint DIV = 10;
    size_t[DIV] count;
    foreach(i; 0 .. AVG * DIV)
        count[cast(uint)(impl.random_01() * DIV)] += 1;

    foreach(e; count) {
        assert(AVG * 0.8 < e);
        assert(e < AVG * 1.2);
    }
}


extern(C++, "itpp")
{
/// Generates a random bit (equally likely 0s and 1s)
bin randb();
/// Generates a random bit vector (equally likely 0s and 1s)
void randb(int size, ref bvec out_);
/// Generates a random bit vector (equally likely 0s and 1s)
bvec randb(int size);
/// Generates a random bit matrix (equally likely 0s and 1s)
void randb(int rows, int cols, ref bmat out_);
/// Generates a random bit matrix (equally likely 0s and 1s)
bmat randb(int rows, int cols);

/// Generates a random uniform (0,1) number
double randu();
/// Generates a random uniform (0,1) vector
void randu(int size, ref vec out_);
/// Generates a random uniform (0,1) vector
vec randu(int size);
/// Generates a random uniform (0,1) matrix
void randu(int rows, int cols, ref mat out_);
/// Generates a random uniform (0,1) matrix
mat randu(int rows, int cols);

/// Generates a random integer in the interval [low,high]
int randi(int low, int high);
/// Generates a random ivec with elements in the interval [low,high]
ivec randi(int size, int low, int high);
/// Generates a random imat with elements in the interval [low,high]
imat randi(int rows, int cols, int low, int high);

/// Generates a random Rayleigh vector
vec randray(int size, double sigma = 1.0);

/// Generates a random Rice vector (See J.G. Poakis, "Digital Communications, 3rd ed." p.47)
vec randrice(int size, double sigma = 1.0, double s = 1.0);

/// Generates a random complex Gaussian vector
vec randexp(int size, double lambda = 1.0);

/// Generates a random Gaussian (0,1) variable
double randn();
/// Generates a random Gaussian (0,1) vector
void randn(int size, ref vec out_);
/// Generates a random Gaussian (0,1) vector
vec randn(int size);
/// Generates a random Gaussian (0,1) matrix
void randn(int rows, int cols, ref mat out_);
/// Generates a random Gaussian (0,1) matrix
mat randn(int rows, int cols);

/*! \brief Generates a random complex Gaussian (0,1) variable

The real and imaginary parts are independent and have variances equal to 0.5
*/
complex!double randn_c();
/// Generates a random complex Gaussian (0,1) vector
void randn_c(int size, ref cvec out_);
/// Generates a random complex Gaussian (0,1) vector
cvec randn_c(int size);
/// Generates a random complex Gaussian (0,1) matrix
void randn_c(int rows, int cols, ref cmat out_);
/// Generates a random complex Gaussian (0,1) matrix
cmat randn_c(int rows, int cols);

}

unittest
{
    // bin b = randb();
    import std.stdio;
    import std.complex;
    import std.math;

    int N = 10000;
    cvec v;
    randn_c(N, v);

    import std.algorithm;
    Complex!double mean = v[].sum() / N;
    double sigma2 = v[].map!sqAbs.sum() / N;

    assert(mean.re.abs < 0.1);
    assert(mean.im.abs < 0.1);
    assert(abs(sigma2 - 1) < 0.1);
}
