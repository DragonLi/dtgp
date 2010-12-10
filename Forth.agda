module Forth where
open import Data.Nat
open import Data.Bool
open import Data.List

data Term : Set where
  empty : Term
  true false Bool-POP AND NOT Nat-POP ADD LT GT :
    Term → Term
  nat : ℕ → Term → Term

data _∣_∣_∣_⊢_ : (Executed : Bool) (Exec : Term) (Bool Nat : ℕ) (t : Term) → Set where
  empty : false ∣ empty ∣ 0 ∣ 0 ⊢ empty

  I-true : ∀ {E B N t} →
    false ∣ E ∣ B ∣ N ⊢ t →
    false ∣ true E ∣ B ∣ N ⊢ true t

  E-true : ∀ {b E B N t} →
    b ∣ true E ∣ B ∣ N ⊢ t →
    true ∣ E ∣ suc B ∣ N ⊢ t

  I-false : ∀ {E B N t} →
    false ∣ E ∣ B ∣ N ⊢ t →
    false ∣ false E ∣ B ∣ N ⊢ false t

  E-false : ∀ {b E B N t} →
    b ∣ false E ∣ B ∣ N ⊢ t →
    true ∣ E ∣ suc B ∣ N ⊢ t

  I-Bool-POP : ∀ {E B N t} →
    false ∣ E ∣ B ∣ N ⊢ t →
    false ∣ Bool-POP E ∣ B ∣ N ⊢ Bool-POP t

  E-Bool-POP : ∀ {b E B N t} →
    b ∣ Bool-POP E ∣ suc B ∣ N ⊢ t →
    true ∣ E ∣ B ∣ N ⊢ t

  I-AND : ∀ {E B N t} →
    false ∣ E ∣ B ∣ N ⊢ t →
    false ∣ AND E ∣ B ∣ N ⊢ AND t

  E-AND : ∀ {b E B N t} →
    b ∣ AND E ∣ suc (suc B) ∣ N ⊢ t →
    true ∣ E ∣ suc B ∣ N ⊢ t

  I-NOT : ∀ {E B N t} →
    false ∣ E ∣ B ∣ N ⊢ t →
    false ∣ NOT E ∣ B ∣ N ⊢ NOT t

  E-NOT : ∀ {b E B N t} →
    b ∣ NOT E ∣ suc B ∣ N ⊢ t →
    true ∣ E ∣ suc B ∣ N ⊢ t

  I-nat : ∀ {E B N n t} →
    false ∣ E ∣ B ∣ N ⊢ t →
    false ∣ (nat n) E ∣ B ∣ N ⊢ (nat n) t

  E-nat : ∀ {b E B N n t} →
    b ∣ (nat n) E ∣ B ∣ N ⊢ t →
    true ∣ E ∣ B ∣ suc N ⊢ t

  I-Nat-POP : ∀ {E B N t} →
    false ∣ E ∣ B ∣ N ⊢ t →
    false ∣ Nat-POP E ∣ B ∣ N ⊢ Nat-POP t

  E-Nat-POP : ∀ {b E B N t} →
    b ∣ Nat-POP E ∣ B ∣ suc N ⊢ t →
    true ∣ E ∣ B ∣ N ⊢ t

  I-ADD : ∀ {E B N t} →
    false ∣ E ∣ B ∣ N ⊢ t →
    false ∣ ADD E ∣ B ∣ N ⊢ ADD t

  E-ADD : ∀ {b E B N t} →
    b ∣ ADD E ∣ B ∣ suc (suc N) ⊢ t →
    true ∣ E ∣ B ∣ suc N ⊢ t

  I-LT : ∀ {E B N t} →
    false ∣ E ∣ B ∣ N ⊢ t →
    false ∣ LT E ∣ B ∣ N ⊢ LT t

  E-LT : ∀ {b E B N t} →
    b ∣ LT E ∣ B ∣ suc (suc N) ⊢ t →
    true ∣ E ∣ suc B ∣ N ⊢ t

  I-GT : ∀ {E B N t} →
    false ∣ E ∣ B ∣ N ⊢ t →
    false ∣ GT E ∣ B ∣ N ⊢ GT t

  E-GT : ∀ {b E B N t} →
    b ∣ GT E ∣ B ∣ suc (suc N) ⊢ t →
    true ∣ E ∣ suc B ∣ N ⊢ t

eg-Term : Term
eg-Term = nat 3 (nat 4 (GT (true (AND empty))))

eg-I : false ∣ eg-Term ∣ 0 ∣ 0 ⊢ eg-Term
eg-I = I-nat (I-nat (I-GT (I-true (I-AND empty))))

eg-E : true ∣ empty ∣ 1 ∣ 0 ⊢ eg-Term
eg-E = E-AND (E-true (E-GT (E-nat (E-nat eg-I))))
