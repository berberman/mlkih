theorem natAddSuccFixture (n m : Nat) : n + Nat.succ m = Nat.succ (n + m) :=
  Nat.add_succ n m

theorem natRecZeroFixture :
    Nat.rec (motive := fun _ => Nat) Nat.zero (fun _ ih => Nat.succ ih) Nat.zero = Nat.zero :=
  rfl
