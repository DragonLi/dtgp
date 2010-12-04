module Push where
open import Data.Bool
open import Data.Nat
open import Data.Nat.DivMod
open import Data.Fin hiding (_+_)
open import Data.Vec
open import Relation.Binary.PropositionalEquality

delete : ∀ {A n} → Fin n → Vec A n → Vec A (Data.Nat.pred n)
delete zero (_ ∷ xs) = xs
delete (suc ()) (_ ∷ [])
delete (suc i) (x ∷ x' ∷ xs) = x ∷ delete i (x' ∷ xs)

yank : ∀ {A n} → Fin n → Vec A n → Vec A n
yank zero xs = lookup zero xs ∷ delete zero xs
yank (suc ()) (x ∷ [])
yank (suc i) (x ∷ x' ∷ xs) = lookup (suc i) (x ∷ x' ∷ xs) ∷ delete (suc i) (x ∷ x' ∷ xs)

n⊓suc : {n : ℕ} → Fin (n ⊓ n) → Fin (n ⊓ suc n)
n⊓suc {zero} ()
n⊓suc {suc n} zero = zero
n⊓suc {suc n} (suc i) = suc (n⊓suc {n} i)

_lt_ : ℕ → ℕ → Bool
zero lt (suc n) = true
(suc n) lt (suc m) = n lt m
_ lt _ = false

_gt_ : ℕ → ℕ → Bool
(suc n) gt zero = true
(suc n) gt (suc m) = n gt m
_ gt _ = false

data U : Set where
  EXEC BOOL : U
  FIN : ℕ → U

data Inst : Set where
  NOOP POP EQ : Inst
  ADD SUB MULT DIV : Inst
  LT GT : Inst
  NOT : Inst
  AND OR NAND NOR : Inst

mutual
  Lit : U → Set
  Lit EXEC = Expr
  Lit BOOL = Bool
  Lit (FIN n) = Fin n

  data Expr : Set where
    lit : {u : U} → Lit u → Expr
    inst : Inst → Expr

postulate
  eq-Lit : {u : U} → Lit u → Lit u → Bool

Stack : (u : U) → ℕ → Set
Stack u = Vec (Lit u)

data Prog : ∀ {n x y z} → Stack EXEC x → Stack BOOL y → Stack (FIN (n ⊓ y)) z → Set where
  I-EXEC : Prog {zero} [] [] []

  I-BOOL : ∀ {x y z} {es : Stack EXEC x} {bs : Stack BOOL y} {is : Stack (FIN (y ⊓ y)) z}
           (b : Lit BOOL) →
           Prog {y} es bs is → Prog {y} (lit b ∷ es) bs is

  E-BOOL : ∀ {x y z} {es : Stack EXEC x} {bs : Stack BOOL y} {is : Stack (FIN (y ⊓ y)) z}
           {b : Lit BOOL} →
           Prog {y} (lit b ∷ es) bs is → Prog {y} es (b ∷ bs) (map (n⊓suc {y}) is)

  -- I-FIN : ∀ {x y z} {es : Stack EXEC x} {bs : Stack BOOL y} {is : Stack (FIN y) z}
  --         (i : Lit (FIN y)) →
  --         Prog es bs is → Prog (lit i ∷ es) bs is

  -- E-FIN : ∀ {x y z} {es : Stack EXEC x} {bs : Stack BOOL y} {is : Stack (FIN y) z}
  --         {i : Lit (FIN y)} →
  --         Prog (lit i ∷ es) bs is → Prog es bs (i ∷ is)

  -- I-NOT : ∀ {x y z} {es : Stack EXEC x} {bs : Stack BOOL y} {is : Stack (FIN (suc y)) z}
  --         {b : Lit BOOL} →
  --         Prog es (b ∷ bs) is → Prog (inst NOT ∷ es) (b ∷ bs) is

  -- E-NOT : ∀ {x y z} {es : Stack EXEC x} {bs : Stack BOOL y} {is : Stack (FIN (suc y)) z}
  --         {b : Lit BOOL} →
  --         Prog (inst NOT ∷ es) (b ∷ bs) is → Prog es (not b ∷ bs) is

  -- E-AND : ∀ {x y z} {es : Stack EXEC x} {bs : Stack BOOL y} {is : Stack (FIN (suc (suc y))) z}
  --         {b₁ b₂ : Lit BOOL} →
  --         Prog (inst NOT ∷ es) (b₁ ∷ b₂ ∷ bs) is → Prog es (b₂ ∧ b₁ ∷ bs) is

  -- E-YANK : ∀ {x y z} {es : Stack EXEC x} {bs : Stack BOOL y} {is : Stack (FIN y) z}
  --          {i : Fin y} →
  --          Prog (inst LT ∷ es) bs (i ∷ is) → Prog es (yank i bs) is

