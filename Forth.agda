module Forth where
open import Data.Nat
open import Data.Bool
open import Data.List

infixr 2 _∣_∣_∣_⊢_

data Word : Set where
  true false Bool-POP AND NOT Nat-POP ADD LT GT : Word
  nat : ℕ → Word

Term : Set
Term = List Word

data _∣_∣_∣_⊢_ : (Executed : Bool) (Exec : Term) (Bool Nat : ℕ) (t : Term) → Set where
  [] : false ∣ [] ∣ 0 ∣ 0 ⊢ []

  push : ∀ {B N t w} →
    false ∣ t ∣ B ∣ N ⊢ t →
    false ∣ w ∷ t ∣ B ∣ N ⊢ w ∷ t

  true : ∀ {b E B N t} →
    b ∣ true ∷ E ∣ B ∣ N ⊢ t →
    true ∣ E ∣ suc B ∣ N ⊢ t

  false : ∀ {b E B N t} →
    b ∣ false ∷ E ∣ B ∣ N ⊢ t →
    true ∣ E ∣ suc B ∣ N ⊢ t

  Bool-POP : ∀ {b E B N t} →
    b ∣ Bool-POP ∷ E ∣ suc B ∣ N ⊢ t →
    true ∣ E ∣ B ∣ N ⊢ t

  AND : ∀ {b E B N t} →
    b ∣ AND ∷ E ∣ suc (suc B) ∣ N ⊢ t →
    true ∣ E ∣ suc B ∣ N ⊢ t

  NOT : ∀ {b E B N t} →
    b ∣ NOT ∷ E ∣ suc B ∣ N ⊢ t →
    true ∣ E ∣ suc B ∣ N ⊢ t

  nat : ∀ {b E B N n t} →
    b ∣ (nat n) ∷ E ∣ B ∣ N ⊢ t →
    true ∣ E ∣ B ∣ suc N ⊢ t

  Nat-POP : ∀ {b E B N t} →
    b ∣ Nat-POP ∷ E ∣ B ∣ suc N ⊢ t →
    true ∣ E ∣ B ∣ N ⊢ t

  ADD : ∀ {b E B N t} →
    b ∣ ADD ∷ E ∣ B ∣ suc (suc N) ⊢ t →
    true ∣ E ∣ B ∣ suc N ⊢ t

  LT : ∀ {b E B N t} →
    b ∣ LT ∷ E ∣ B ∣ suc (suc N) ⊢ t →
    true ∣ E ∣ suc B ∣ N ⊢ t

  GT : ∀ {b E B N t} →
    b ∣ GT ∷ E ∣ B ∣ suc (suc N) ⊢ t →
    true ∣ E ∣ suc B ∣ N ⊢ t

eg-Term : Term
eg-Term = nat 3 ∷ nat 4 ∷ GT ∷ true ∷ AND ∷ []

eg-push : false ∣ eg-Term ∣ 0 ∣ 0 ⊢ eg-Term
eg-push = push (push (push (push (push []))))

eg-exec : true ∣ [] ∣ 1 ∣ 0 ⊢ eg-Term
eg-exec = AND (true (GT (nat (nat eg-push))))
