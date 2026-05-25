-- noncomputable def foo : {α : Type u} →
--     {motive : List α → Sort u_1} →
--     (t : List α) → ((t : List α) → @List.below α motive t → motive t) →
--     motive t ×' @List.below α motive t := @List.brecOn.go

def foo := @Nat.lt_pow_two_of_testBit
-- theorem foo : 'h' = 'h' := rfl
-- set_option pp.raw true
-- set_option pp.raw.maxDepth 10000
-- #print Char.ofNat._proof_1
-- def foo := @Char.ofNat._proof_1
