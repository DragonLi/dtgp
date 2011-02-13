open import Data.Nat hiding (_≥_)
module Stash (W : Set) (In Out : W → ℕ → ℕ) where
open import Data.Function
open import Data.Nat.DivMod
open import Relation.Nullary
open import Relation.Binary.PropositionalEquality
open import Data.Fin hiding (_+_; raise)
open import Data.Maybe
open import Data.Product hiding (map; swap)
open import Data.Function
open import Data.Vec hiding (_++_; _>>=_)
open import Rand

infixr 5 _∷_ _++_ _++'_

data Term (A : ℕ) : ℕ → Set where
  []  : Term A A

  _∷_ : ∀ {k} →
    (w : W) → Term A (In w k) →
    Term A (Out w k)

_++_ : ∀ {A B C} →
  Term B C →
  Term A B →
  Term A C
[] ++ ys = ys
(x ∷ xs) ++ ys = x ∷ (xs ++ ys)

data Split {A C : ℕ} (B : ℕ) : Term A C → Set where
  _++'_ :
    (xs : Term B C)
    (ys : Term A B) →
    Split B (xs ++ ys)

swap₁ : ∀ {A B C} {xs ys : Term A C} →
  Split B xs → Split B ys → Term A C
swap₁ (xs ++' ys) (as ++' bs) = xs ++ bs

swap₂ : ∀ {A B C} {xs ys : Term A C} →
  Split B xs → Split B ys → Term A C
swap₂ (xs ++' ys) (as ++' bs) = as ++ ys

swaps : ∀ {A B C} {xs ys : Term A C} →
  Split B xs → Split B ys →
  Term A C × Term A C
swaps xs ys = swap₁ xs ys , swap₂ xs ys

split : ∀ {A C} (n : ℕ) (xs : Term A C) → ∃ λ B → Split B xs
split zero xs = _ , [] ++' xs
split (suc n) [] = _ , [] ++' []
split (suc n) (x ∷ xs) with split n xs
split (suc A) (x ∷ ._) | _ , xs ++' ys = _ , (x ∷ xs) ++' ys

splits : ∀ {A C} (n : ℕ) (B : ℕ) → (xs : Term A C) → ∃ (Vec (Split B xs))
splits zero B xs with split zero xs
... | B' , ys with B ≟ B'
... | yes p rewrite p = _ , ys ∷ []
... | no p = _ , []
splits (suc n) B xs with split (suc n) xs
... | B' , ys with B ≟ B' | splits n B xs
... | yes p | _ , yss rewrite p = _ , ys ∷ yss
... | no p | _ , yss = _ , yss

length : ∀ {A C} → Term A C → ℕ
length [] = 0
length (x ∷ xs) = suc (length xs)

split♀ : ∀ {A C} → (xs : Term A C) → Rand (∃ λ B → Split B xs)
split♀ xs = 
  rand >>= λ r →
  let i = r mod (suc (length xs))
  in return (split (toℕ i) xs)

split♂ : ∀ {A C} (xs : Term A C) (B : ℕ) →
  Maybe (Rand (Split B xs))
split♂ xs B
  with splits (length xs) B xs
... | zero , [] = nothing
... | suc n , xss = just (
  rand >>= λ r →
  return (lookup (r mod suc n) xss)
 )

crossover : ∀ {A C} (♀ ♂ : Term A C) →
  Rand (Term A C × Term A C)
crossover ♀ ♂ =
  split♀ ♀ >>= λ B,xs →
  maybe
    (_=<<_ (return ∘ (swaps (proj₂ B,xs))))
    (return (♀ , ♂))
    (split♂ ♂ (proj₁ B,xs))

Population : (A C n : ℕ) → Set
Population A C n = Vec (Term A C) n

open import Data.Bool

_≥_ : ℕ → ℕ → Bool
zero ≥ zero = true
zero ≥ (suc n) = false
(suc m) ≥ zero = true
(suc m) ≥ (suc n) = m ≥ n

module GP (score : ∀ {A C} → Term A C → ℕ) where

  select : ∀ {A C n} →
    Population A C (2 + n) → Rand (Term A C)
  select {n = n} xss =
    rand >>= λ ii →
    rand >>= λ jj →
    let ♀ = lookup (ii mod (2 + n)) xss
        ♂ = lookup (jj mod (2 + n)) xss
    in return (
      if score ♀ ≥ score ♂
      then ♀ else ♂
    )

  evolve2 : ∀ {A C n} →
    Population A C (2 + n) →
    Rand (Term A C × Term A C)
  evolve2 xss =
    select xss >>= λ ♀ →
    select xss >>= λ ♂ →
    crossover ♀ ♂

  evolveN : ∀ {A C m} → (n : ℕ) →
    Population A C (2 + m) →
    Rand (Vec (Term A C) (n * 2))
  evolveN zero xss = return []
  evolveN (suc n) xss =
    evolve2 xss >>= λ offspring →
    evolveN n xss >>= λ ih →
    return (proj₁ offspring ∷ proj₂ offspring ∷ ih)

  evolve : ∀ {A C n} → (seed : ℕ) →
    Population A C (2 + n) → Population A C (⌊ (2 + n) /2⌋ * 2)
  evolve {n = n} seed xss =
    runRand (evolveN (⌊ 2 + n /2⌋) xss) seed
