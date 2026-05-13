theorem natAddAddAddCommFixture (a b c d : Nat) :
    (a + b) + (c + d) = (a + c) + (b + d) :=
  Nat.add_add_add_comm a b c d
