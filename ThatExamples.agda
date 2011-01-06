module ThatExamples where
open import Data.Nat
import That

data Word : Set where
  true false
    not and or 
    : Word

In : Word → ℕ
In true  = 0
In false = 0
In not   = 1
In and   = 2
In or    = 2

Out : Word → ℕ
Out true  = 1
Out false = 1
Out not   = 1
Out and   = 1
Out or    = 1

open That Word In Out

not∷[] : 1 ⟶ 1
not∷[] = not ∷ []

and∷[] : 2 ⟶ 1
and∷[] = and ∷ []

true∷[] : 0 ⟶ 1
true∷[] = true ∷ []

not∷not∷[] : 1 ⟶ 1
not∷not∷[] = not ∷ not ∷ []

true∷and∷[] : 2 ⟶ 2
true∷and∷[] = true ∷ and∷[]
