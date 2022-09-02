module itppd.comm.galois;

import itppd.base.vec;
import itppd.base.onstack;
import itppd.base.array;

extern(C++, "itpp")
{

extern(C++, class)
struct GF
{
    extern(D) this(int qvalue)
    {
        m = 0;
        if(qvalue == 0)
            value = -1;
        else
            set_size(qvalue);
    }


    extern(D) this(int qvalue, int inexp)
    {
        m = 0;
        set(qvalue, inexp);
    }


    extern(D) this(ref return scope GF rhs)
    {
        this.m = rhs.m;
        this.value = rhs.value;
    }


    void set(int qvalue, int inexp);
    void set(int qvalue, ref const bvec vectorspace);
    void set_size(int qvalue);
    int get_size() const;
    bvec get_vectorspace() const;
    int  get_value() const;


  private:
    ubyte m = 0;
    int value;
}


extern(C++, class)
struct GFX
{
    this(int qvalue)
    {
        q = qvalue;
    }


    this(int qvalue, int indegree)
    {
        q = qvalue;
        coeffs.set_size(indegree + 1, false);
        degree = indegree;
        foreach(i; 0 .. degree)
            coeffs[i].set(q, -1);
    }


    this(int qvalue, ref const ivec invalues)
    {
        set(qvalue, invalues);
    }


    this(int qvalue, const char* invalues)
    {
        set(qvalue, invalues);
    }


    // this(int qvalue, cppstring)

    int get_size() const;
    int get_degree() const;
    void set_degree(int indegree, bool copy = false);
    int get_true_degree() const;
    void set(int qvalue, const char* invalues);
    // void set(int qvalue, const std::string invalues);
    void set(int qvalue, ref const ivec invalues);
    void clear();

  private:
    int degree = -1, q = 0;
    OnStack!(Array!GF) coeffs;
}

}

unittest
{
    GF x = GF(4, 2);
}

unittest
{
    GFX x;
    x.get_size();
    static assert(GFX.sizeof == 40);
}
