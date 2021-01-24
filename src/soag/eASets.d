module soag.eASets;

import runtime;
import IO = eIO;
import ALists = soag.eALists;

const firstIndex = ALists.firstIndex;
const noelem = -1;

struct ASetDesc
{
    int Max;
    ALists.AList List;
}

alias ASet = ASetDesc;

ASet S;
int i;

/**
 * IN:  Referenzvariabel der Liste, anfängliche Laenge der Liste
 * OUT: Referenzvariabel der Liste
 * SEM: Anlegen einer neuen Liste (Speicherplatzreservierung)
 * SEF: -
 */
void New(ref ASet S, int MaxElem)
{
    S = ASet();
    ALists.New(S.List, MaxElem + 1);
    S.Max = MaxElem;
    for (i = firstIndex; i <= MaxElem; ++i)
    {
        S.List.Elem[i] = noelem;
    }
}

/**
 * IN:  Referenzvariabel der Liste
 * OUT: Referenzvariabel der Liste
 * SEM: Löschen des Listeninhalts
 * SEF: -
*/
void Reset(ref ASet S)
{
    int i;
    ALists.Reset(S.List);
    for (i = firstIndex; i <= S.Max; ++i)
    {
        S.List.Elem[i] = noelem;
    }
}

/**
 * IN:  Referenzvariabel der Menge
 * OUT: Referenzvariabel derMenge
 * SEM: Test, ob die Menge leer ist
 * SEF: -
 */
bool IsEmpty(ref ASet S)
{
    return S.List.Last < firstIndex;
}

/**
 * IN:  Referenzvariable der Menge, einzufügendes Element
 * OUT: Referenzvariable der Menge
 * SEM: fügt Element in die Menge ein
 * SEF: -
 */
void Insert(ref ASet S, int Elem)
{
    if (Elem <= S.Max)
    {
        if (Elem <= S.List.Last)
        {
            if (S.List.Elem[Elem] != Elem)
            {
                ++S.List.Last;
                if (S.List.Elem[S.List.Last] > noelem)
                {
                    S.List.Elem[S.List.Elem[S.List.Last]] = S.List.Elem[Elem];
                    S.List.Elem[S.List.Elem[Elem]] = S.List.Elem[S.List.Last];
                    S.List.Elem[S.List.Last] = S.List.Last;
                }
                else
                {
                    S.List.Elem[S.List.Last] = S.List.Elem[Elem];
                    S.List.Elem[S.List.Elem[Elem]] = S.List.Last;
                }
                S.List.Elem[Elem] = Elem;
            }
            // else same element already in the set
        }
        else
        {
            if (S.List.Elem[Elem] <= noelem)
            {
                ++S.List.Last;
                if (S.List.Elem[S.List.Last] > noelem)
                {
                    S.List.Elem[S.List.Elem[S.List.Last]] = Elem;
                    S.List.Elem[Elem] = S.List.Elem[S.List.Last];
                    S.List.Elem[S.List.Last] = S.List.Last;
                }
                else
                {
                    S.List.Elem[S.List.Last] = Elem;
                    S.List.Elem[Elem] = S.List.Last;
                }
            }
            // else same element already in the set
        }
    }
    else
    {
        throw new Exception("ERROR in eASet.Insert: element is greater than max element");
    }
}

/**
 * IN:  Referenzvariable der Menge, zu löschendes Element
 * OUT: Referenzvariable der Menge
 * SEM: löscht Element aus der Menge
 * SEF: -
 */
void Delete(ref ASet S, int e)
{
    if (e <= S.Max)
    {
        const last = S.List.Last;

        if (e <= last)
        {
            if (S.List.Elem[e] == e)
            {
                if (e == last)
                {
                    S.List.Elem[last] = noelem;
                }
                else // e < last
                {
                    if (S.List.Elem[last] == last)
                    {
                        S.List.Elem[e] = last;
                        S.List.Elem[last] = e;
                    }
                    else
                    {
                        S.List.Elem[e] = S.List.Elem[last];
                        S.List.Elem[S.List.Elem[last]] = e;
                        S.List.Elem[last] = noelem;
                    }
                }
                --S.List.Last;
            }
            // else element already not in the set
        }
        else // e > last
        {
            if (S.List.Elem[e] > noelem)
            {
                if (S.List.Elem[last] == last)
                {
                    S.List.Elem[S.List.Elem[e]] = last;
                    S.List.Elem[last] = S.List.Elem[e];
                }
                else
                {
                    S.List.Elem[S.List.Elem[e]] = S.List.Elem[last];
                    S.List.Elem[S.List.Elem[last]] = S.List.Elem[e];
                    S.List.Elem[last] = noelem;
                }
                S.List.Elem[e] = noelem;
                --S.List.Last;
            }
            // else element already not in the set
        }
    }
    else
    {
        throw new Exception("ERROR in eASet.Delete: element is greater than max element");
    }
}

/**
 * IN:  Referenzvariable der Menge, Element
 * OUT: Referenzvariable der Menge
 * SEM: Testet, ob Element in der Menge ist
 * SEF: -
 */
bool In(ASet S, int Elem)
{
    if (Elem > S.List.Last)
    {
        return S.List.Elem[Elem] > noelem;
    }
    else
    {
        return S.List.Elem[Elem] == Elem;
    }
}

@("validate inserting 0 to reset set")
unittest
{
    ASet set;

    New(set, 10);
    for(int j = firstIndex; j < 10; ++j)
        Insert(set, j);
    Reset(set);
    Insert(set, 0);

    assert(!IsEmpty(set));
}

@("reproduce set deletion error in single-sweep.eag computation")
unittest
{
    ASet set1, set2;

    New(set1, 3);

    Insert(set1, 0);
    Insert(set1, 2);

    Delete(set1, 2);
    Delete(set1, 0);

    assert(IsEmpty(set1));

    Insert(set1, 0);

    assert(!IsEmpty(set1));

    New(set2, 3);

    Insert(set2, 0);
    Insert(set2, 2);

    // see above, only order of deletion is reverted here, but it fails
    Delete(set2, 0);
    Delete(set2, 2);

    Insert(set2, 0);

    assert(!IsEmpty(set2));

}

@("Delete: Given {0,1,2} as [0,1,2] with last = 2, delete 0 must result in {2,1} as [2,1,0]")
unittest
{
    ASet set;
    New(set, 2);
    Insert(set, 0);
    Insert(set, 1);
    Insert(set, 2);

    Delete(set, 0);

    assert(!In(set, 0));
    assert(In(set, 1));
    assert(In(set, 2));

    assert(set.List.Elem[0] == 2);
    assert(set.List.Elem[1] == 1);
}

@("Delete: Given {0,1,3} as [0,1,3,2] with last = 2, delete 0 must result in {3,1} as [3,1,-1,0]")
unittest
{
    ASet set;
    New(set, 3);
    Insert(set, 0);
    Insert(set, 1);
    Insert(set, 3);

    Delete(set, 0);

    assert(!In(set, 0));
    assert(In(set, 1));
    assert(!In(set, 2));
    assert(In(set, 3));

    assert(set.List.Elem[0] == 3);
    assert(set.List.Elem[1] == 1);
}

@("Delete: Given {3,1,2} as [3,1,2,0] with last = 2, delete 3 must result in {2,1} as [2,1,0,-1]")
unittest
{
    ASet set;
    New(set, 3);
    Insert(set, 3);
    Insert(set, 1);
    Insert(set, 2);

    Delete(set, 3);

    assert(!In(set, 0));
    assert(In(set, 1));
    assert(In(set, 2));
    assert(!In(set, 3));

    assert(set.List.Elem[0] == 2);
    assert(set.List.Elem[1] == 1);
}

@("Delete: Given {4,1,3} as [4,1,3,2,0] with last = 2, delete 4 must result in {3,1} as [3,1,-1,0,-1]")
unittest
{
    ASet set;
    New(set, 4);
    Insert(set, 4);
    Insert(set, 1);
    Insert(set, 3);

    Delete(set, 4);

    assert(!In(set, 0));
    assert(In(set, 1));
    assert(!In(set, 2));
    assert(In(set, 3));
    assert(!In(set, 4));

    assert(set.List.Elem[0] == 3);
    assert(set.List.Elem[1] == 1);
}

@("Insert elements continuously increasing by 1")
unittest
{
    ASet set;
    const elemCount = 10;

    New(set, elemCount);

    for(int j = firstIndex; j <= set.Max; ++j)
        Insert(set, j);

    assert(set.List.Last == elemCount);

    for(int j = firstIndex; j <= set.List.Last; ++j)
    {
        assert(In(set, j));
        assert(set.List.Elem[j] == j);
    }
}

@("Insert elements continuously increasing, even only")
unittest
{
    import std.format : format;

    ASet set;
    const elemCount = 11;

    New(set, elemCount);

    for(int j = firstIndex; j <= set.Max; j = j + 2)
        Insert(set, j);

    assert(set.List.Last == elemCount / 2);
    for(int j = firstIndex; j <= set.List.Last; ++j)
    {
        assert(In(set, j * 2), format!"failed for element %s"(j * 2));
        assert(!In(set, j * 2 + 1), format!"failed for element %s"(j * 2 + 1));
        assert(In(set, set.List.Elem[j]), format!"failed for element %s"(j));
    }
}

@("Insert elements continuously decreasing by 1")
unittest
{
    import std.format : format;

    ASet set;
    const elemCount = 10;

    New(set, elemCount);

    for(int j = set.Max; j >= firstIndex; --j)
        Insert(set, j);

    assert(set.List.Last == elemCount);
    for(int j = firstIndex; j <= set.List.Last; ++j)
    {
        assert(In(set, j), format!"failed for element %s"(j));
        assert(In(set, set.List.Elem[j]), format!"failed for element %s"(j));
    }
}

@("Delete elements continuously increasing by 1")
unittest
{
    import std.format : format;

    ASet set;
    const elemCount = 10;

    New(set, elemCount);

    for(int j = firstIndex; j <= set.Max; ++j)
        Insert(set, j);

    for(int j = firstIndex; j <= set.Max; ++j)
    {
        Delete(set, j);
        for(int k = j+1; k <= set.Max; k++)
        {
            assert(In(set, k), format!"In(set, %s) unexpectedly"(k));
        }
    }

    assert(IsEmpty(set), "set is unexpectedly not empty");
    assert(set.List.Last == -1, "List.Last is unexpectedly not -1");

    for(int j = firstIndex; j < set.Max; ++j)
    {
        assert(set.List.Elem[j] == noelem, format!"List.Elem[%s] is not noelem"(j));
    }
}

@("Delete elements continuously decreasing by 1")
unittest
{
    import std.format : format;

    ASet set;
    const elemCount = 10;

    New(set, elemCount);

    for(int j = firstIndex; j <= set.Max; ++j)
        Insert(set, j);

    for(int j = set.Max; j >= firstIndex; --j)
    {
        Delete(set, j);
        for(int k = firstIndex; k < j; k++)
        {
            assert(In(set, k), format!"failed for element %s"(k));
            assert(In(set, set.List.Elem[k]), format!"failed for element %s"(k));
        }
    }

    assert(IsEmpty(set), "set is unexpectedly not empty");
    assert(set.List.Last == -1, "List.Last is unexpectedly not 0");

    for(int j = firstIndex; j < set.Max; ++j)
    {
        assert(set.List.Elem[j] == noelem, format!"List.Elem[%s] is not noelem"(j));
    }
}
