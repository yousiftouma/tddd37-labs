# Lab 1, Viktor Holmgren (vikho394) and Yousif Touma (youto814)

## Question 1
We have the relation `R(A, B, C, D)`

```
a) A,B primary key
  FD1: A,B -> C, D
  FD2: B -> C

b) A,B primary key
  FD1: A,B -> C,D
  FD2: C -> D


b) A,B primary key
  FD1: A,B -> C,D
  FD2: A -> B
```

## Question 2

### 2A
Using the bottom-up approach we discover that AB and BD are potential candidate
keys. Using the inference rules we check that these are correct:

```
Using the following FDs:
FD1: A,B -> C
FD2: A -> D
FD3: D -> A,E
FD4: E -> F

AB proof:
  A,B -> C (augmentation)
  A,B -> A,C (decomposition)
  A,B -> A (transitivity FD2)
  A,B -> D (union with FD1)
  A,B -> C,D  (*)
  A,B -> D (transitivity FD3)
  A,B -> A,E (decomposition)
  A,B -> E (transitivity FD4) (**)
  A,B -> F (union with * and **)
  A,B -> C,D,E,F

BD proof:
  D -> A,E (augmentation)
  D,B -> A,B,E (decomposition) (*)
  D,B -> A,B (transitivity FD1)
  D,B -> C (**)
  D,B -> A,B,E (decomposition)
  D,B -> E (transitvity FD4)
  D,B -> F (union with * and **)
  D,B -> A,B,C,E,F (decomposition)
  D,B -> A,C,E,F
```

### 2B
We first infer all the relevant FDs that is needed:

```
FD1: A,B -> C
FD2: A -> D
FD3: D -> A,E
FD4: E -> F
FD5: D -> E
FD6: D -> F
```

We now convert to 2NF using the algorithm given in the lectures

```
R(A,B,C,D,E,F)

FD6 breaks 2NF, decompose into new relations:
  R1(A,B,C,D,F):
    FDs: 1,2,3,6
    Candidate key: AB and BD
  R2(D,E):
    FDs: 5
    Candidate key: D
    In BCNF, nothing more to be done

Continue with R1
FD6 breaks 2NF for R1, decompose into new realtions:
  R1X(A,B,C,D):
    FDs: 1,2,3
    Candidate key: AB and BD
    In 2NF, nothing more to be done
  R1Y(D,F):
    FDs: 6
    Candidate key: D
    In BCNF, nothing more to be done

Final relations are R1X, R1Y and R2
```

### 2C
We first infer all the relevant FDs that is needed:

```
FD1: A,B -> C
FD2: A -> D
FD3: D -> A,E
FD4: E -> F
FD5: D -> E
FD6: D -> F
FD7: D -> A (new)
```
We now convert to 3NF using the algorithm given in the lectures

```
R1X(A,B,C,D): FDs: 1,2,7, Candidate key: AB and BD
R1Y(D,F): BCNF, nothing to be done
R2(D,E): BCNF, nothing to be done

R1X already in 3NF, nothing to be done.
Final relations are R1X, R1Y and R2
```

### 2D
We first infer all the relevant FDs that is needed:

```
FD1: A,B -> C
FD2: A -> D
FD3: D -> A,E
FD4: E -> F
FD5: D -> E
FD6: D -> F
FD7: D -> A
```
We now convert to BCNF using the algorithm given in the lectures

```
R1X(A,B,C,D): FDs: 1,2,7, Candidate key: AB and BD
R1Y(D,F): BCNF, nothing to be done
R2(D,E): BCNF, nothing to be done

FD2 breaks BCNF for R1X, decompose into new relations:
  R1X1(A,B,C):
    FDs: 1
    Candidate key: AB
    In BCNF, nothing more to be done
  R1X2(A,D):
    FDs: 2,7
    Candidate key: A and D
    In BCNF, nothing more to be done

Final relations are R1X1, R1X2, R1Y and R2
```

## Question 3
We introduce some abbreviations for the attributes:

```
Title#      = t#
Title       = t
Author#     = a#
Booktype    = bt
Price       = pr
Authorname  = an
Publisher   = pu
```

The FDs given:

```
FD1: t# -> t, bt, pu
FD2: a# -> an
FD3: bt -> pr
FD4: t# -> pr (infered)
```

### 3A

The relation is in 1NF atleast since we do not have any multivalued attributes
It is not 2NF, due to FD2 since an is non-prime and a# is part of a candidate key

### 3B

```
FD2 breaks 2NF, decompose into new relations:
  R1(t#, a#, t, bt, pu, pr):
    FDs: 1,3,4
    Candidate key: (t#, a#)
  R2(a#, an):
    FDs: 2
    Candidate key: a#
    In BCNF, nothing more to be done

FD1 breaks 2NF for R1, decompose into new relations:
  R1X(t#, a#, pr):
    FDs: 4
    Candidate key: (t#, a#)
  R1Y(t#, t, bt, pu)
    FDs: 1
    Candidate key: t#
    In BCNF, nothing more to be done

FD4 breaks 2NF for R1X, decompose into new relations:
  R1X1(t#, a#):
    FDs: None,
    Candidate key: (t#, a#)
    In BCNF, nothing more to be done
  R1X2(t#, pr):
    FDs: 4,
    Candidate key: t#
    In BCNF, nothing more to be done

Final relations are R1X1, R1X2, R1Y and R2
```
