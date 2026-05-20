-- noncomputable def foo : {α : Type u} →
--     {motive : List α → Sort u_1} →
--     (t : List α) → ((t : List α) → @List.below α motive t → motive t) →
--     motive t ×' @List.below α motive t := @List.brecOn.go

def foo := @Nat.succ_le_succ
