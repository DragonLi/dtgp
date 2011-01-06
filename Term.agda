open import Data.Nat
module Term (W : Set) (In Out : W → ℕ) where
open import Relation.Nullary
open import Relation.Binary.PropositionalEquality
open import Data.Product
open import Data.Function

infixl 2 _⟶_
infixr 5 _∷_ _++_

data _⟶_ (B : ℕ) : ℕ → Set where
  []  : B ⟶ B

  _∷_ : ∀ {k} →
    (w : W) → B ⟶ In w + k →
    B ⟶ Out w + k

_++_ : ∀ {Inw Outw B} →
  Inw ⟶ Outw →
  B ⟶ Inw →
  B ⟶ Outw
[] ++ ys = ys
(x ∷ xs) ++ ys = x ∷ (xs ++ ys)


