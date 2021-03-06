module runtime;

/**
 * Returns the quotient for a floored division.
 */
long DIV(long D, long d) @nogc nothrow pure @safe
{
    long q = D / d;
    const r = D % d;

    if ((r > 0 && d < 0) || (r < 0 && d > 0))
        --q;
    return q;
}

@("compute DIV for floored division")
unittest
{
    assert(DIV(8, 3) == 2);
    assert(DIV(8, -3) == -3);
    assert(DIV(-8, 3) == -3);
    assert(DIV(-8, -3) == 2);
}

/**
 * Returns the remainder for a floored division.
 */
long MOD(long D, long d) @nogc nothrow pure @safe
{
    long r = D % d;

    if ((r > 0 && d < 0) || (r < 0 && d > 0))
        r += d;
    return r;
}

@("compute MOD for floored division")
unittest
{
    assert(MOD(8, 3) == 2);
    assert(MOD(8, -3) == -1);
    assert(MOD(-8, 3) == 1);
    assert(MOD(-8, -3) == -2);
}
