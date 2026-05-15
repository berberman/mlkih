namespace TutorialFixture
def basicDef : Type := Prop
def arrowType : Type := Prop → Prop
def dependentType : Prop := ∀ (p : Prop), p
def constType : Type → Type → Type := fun (x y : Type) => x
def betaReduction : constType Prop (Prop → Prop) := ∀ (p : Prop), p
def betaReduction2 : (p : Prop) → constType Prop (Prop → Prop) := fun (p : Prop) => p
def id.{u} : {α : Sort u} → (a : α) → α :=
  fun {α : Sort u} (a : α) => a
def forallSortWhnf : Prop :=
  ∀ (p : @id.{2} Type Prop) (a : p), p
def levelComp1 : Type :=
  Sort (imax 1 0)
def levelComp2 : Type 1 :=
  Sort (imax 0 1)
def levelComp3 : Type 2 :=
  Type (max 1 0)
def levelParamF.{u} : Sort u → Sort u → Sort u :=
  fun (α β : Sort u) => α
def levelParams : levelParamF.{1} Prop (Prop → Prop) :=
  ∀ (p : Prop), p
def levelComp5.{u} : Type u :=
  Sort u
def imax1 : (p : Prop) → Prop :=
  fun (p : Prop) => ∀ (a : Type), p
def imax2 : (α : Type) → Type 1 :=
  fun (α : Type) => Type → α
def inferVar : ∀ (f : Prop) (g : f), f :=
  fun (f : Prop) (g : f) => g
def defEqLambda :
    ∀ (f : (Prop → Prop) → Prop) (g : ∀ (a : Prop → Prop), f a),
      f fun (p : Prop) => p → p :=
  fun (f : (Prop → Prop) → Prop) (g : ∀ (a : Prop → Prop), f a) =>
    g fun (p : Prop) => p → p
def PN.{u_1} : Sort (imax (u_1 + 1) u_1) :=
  (α : Sort u_1) → (α → α) → α → α
def PN.succ.{u_1} : PN.{u_1} → PN.{u_1} :=
  fun (n : PN.{u_1}) (α : Sort u_1) (s : α → α) (z : α) => s (n α s z)
def PN.zero.{u_1} : PN.{u_1} :=
  fun (α : Sort u_1) (s : α → α) (z : α) => z
def PN.lit0.{u_1} : PN.{u_1} :=
  PN.zero.{u_1}
def PN.lit1.{u_1} : PN.{u_1} :=
  PN.succ.{u_1} PN.lit0.{u_1}
def PN.lit2.{u_1} : PN.{u_1} :=
  PN.succ.{u_1} PN.lit1.{u_1}
theorem peano1.{u} :
    ∀ (t : PN.{u} → Prop) (v : ∀ (n : PN.{u}), t n), t PN.lit2.{u} :=
  fun (t : PN.{u} → Prop) (v : ∀ (n : PN.{u}), t n) => v PN.lit2.{u}
end TutorialFixture
