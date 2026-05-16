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
def PN.add.{u_1} : PN.{u_1} → PN.{u_1} → PN.{u_1} :=
  fun (n m : PN.{u_1}) (α : Sort u_1) (s : α → α) (z : α) => n α s (m α s z)
theorem peano2.{u} :
    ∀ (t : PN.{u} → Prop) (v : ∀ (n : PN.{u}), t n), t PN.lit2.{u} :=
  fun (t : PN.{u} → Prop) (v : ∀ (n : PN.{u}), t n) =>
    v (PN.add.{u} PN.lit1.{u} PN.lit1.{u})
def PN.lit3.{u_1} : PN.{u_1} :=
  PN.succ.{u_1} PN.lit2.{u_1}
def PN.lit4.{u_1} : PN.{u_1} :=
  PN.succ.{u_1} PN.lit3.{u_1}
def PN.mul.{u_1} : PN.{u_1} → PN.{u_1} → PN.{u_1} :=
  fun (n m : PN.{u_1}) (α : Sort u_1) (s : α → α) (z : α) => n α (m α s) z
theorem peano3.{u} :
    ∀ (t : PN.{u} → Prop) (v : ∀ (n : PN.{u}), t n), t PN.lit4.{u} :=
  fun (t : PN.{u} → Prop) (v : ∀ (n : PN.{u}), t n) =>
    v (PN.mul.{u} PN.lit2.{u} PN.lit2.{u})
def letType : Type :=
  let x : Type := Prop;
  x
axiom aDepProp : Type → Prop
axiom mkADepProp : ∀ (t : Type), aDepProp t
def letTypeDep : aDepProp Prop :=
  let x : Type := Prop;
  mkADepProp x
axiom aProp : Prop
def letRed :
    let x : Type := Prop;
    x :=
  aProp
inductive Empty : Type
def empty : Type :=
  Empty
inductive Bool : Type where
  | false : Bool
  | true : Bool
def boolType : Type :=
  Bool
inductive TwoBool : Type where
  | mk : (b1 b2 : Bool) → TwoBool
def twoBool : Type :=
  TwoBool
inductive And (a : Prop) (b : Prop) : Prop where
  | intro (left : a) (right : b) : And a b
def andType : (a b : Prop) → Prop :=
  And
inductive Prod.{u, v} (α : Type u) (β : Type v) : Type (max u v) where
  | mk (fst : α) (snd : β) : Prod α β
def prodType : Type → Type → Type :=
  Prod.{0, 0}
inductive Eq.{u_1} {α : Sort u_1} (a : α) : α → Prop where
  | refl : Eq a a
def eqType.{u_1} : {α : Sort u_1} → α → α → Prop :=
  Eq.{u_1}
inductive N : Type where
  | zero : N
  | succ : N → N
def natDef : Type :=
  N
inductive Color : Type where
  | r : Color
  | b : Color
inductive RBTree.{u} (α : Type u) : Color → N → Type u where
  | leaf : RBTree α Color.b N.zero
  | red {n} : RBTree α Color.b n → α → RBTree α Color.b n → RBTree α Color.r (N.succ n)
  | black {n c1 c2} : RBTree α c1 n → α → RBTree α c2 n → RBTree α Color.b (N.succ n)
def rbTreeDef.{u} : (α : Type u) → Color → N → Type u :=
  RBTree.{u}
end TutorialFixture
