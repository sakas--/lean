/-
Copyright (c) 2016 Microsoft Corporation. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Leonardo de Moura
-/
prelude
import init.meta.declaration init.meta.exceptional

meta_constant environment : Type₁

namespace environment
/- Create a standard environment using the given trust level -/
meta_constant mk_std          : nat → environment
/- Create a HoTT environment -/
meta_constant mk_hott         : nat → environment
/- Return the trust level of the given environment -/
meta_constant trust_lvl       : environment → nat
/- Return tt iff it is a standard environment -/
meta_constant is_std          : environment → bool
/- Add a new declaration to the environment -/
meta_constant add             : environment → declaration → exceptional environment
/- Retrieve a declaration from the environment -/
meta_constant get             : environment → name → exceptional declaration
/- Add a new inductive datatype to the environment
   name, universe parameters, number of parameters, type, constructors (name and type) -/
meta_constant add_inductive   : environment → name → list name → nat → expr → list (name × expr) → exceptional environment
/- Return tt iff the given name is an inductive datatype -/
meta_constant is_inductive    : environment → name → bool
/- Return tt iff the given name is a constructor -/
meta_constant is_constructor  : environment → name → bool
/- Return tt iff the given name is a recursor -/
meta_constant is_recursor     : environment → name → bool
/- Return the constructors of the inductive datatype with the given name -/
meta_constant constructors_of : environment → name → list name
/- Return the recursor of the given inductive datatype -/
meta_constant recursor_of     : environment → name → option name
/- Return the number of parameters of the inductive datatype -/
meta_constant inductive_num_params : environment → name → nat
/- Return the number of indices of the inductive datatype -/
meta_constant inductive_num_indices : environment → name → nat
/- Return tt iff the inductive datatype recursor supports dependent elimination -/
meta_constant inductive_dep_elim : environment → name → bool
/- Fold over declarations in the environment -/
meta_constant fold {A :Type} : environment → A → (declaration → A → A) → A
end environment

meta_definition environment.has_to_string [instance] : has_to_string environment :=
has_to_string.mk (λ e, "[environment]")