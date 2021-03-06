/-
Copyright (c) 2015 Jacob Gross. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jacob Gross, Jeremy Avigad

Open and closed sets, seperation axioms and generated topologies.
-/
import data.set data.nat
open algebra eq.ops set nat

structure topology [class] (X : Type) :=
  (opens : set (set X))
  (univ_mem_opens : univ ∈ opens)
  (sUnion_mem_opens : ∀ {S : set (set X)}, S ⊆ opens → ⋃₀ S ∈ opens)
  (inter_mem_opens : ∀₀ s ∈ opens, ∀₀ t ∈ opens, s ∩ t ∈ opens)

namespace topology

variables {X : Type} [topology X]

/- open sets -/

definition Open (s : set X) : Prop := s ∈ opens X

theorem Open_empty : Open (∅ : set X) :=
have ∅ ⊆ opens X, from empty_subset _,
have ⋃₀ ∅ ∈ opens X, from sUnion_mem_opens this,
show ∅ ∈ opens X, by rewrite -sUnion_empty; apply this

theorem Open_univ : Open (univ : set X) :=
univ_mem_opens X

theorem Open_sUnion {S : set (set X)} (H : ∀₀ t ∈ S, Open t) : Open (⋃₀ S) :=
sUnion_mem_opens H

theorem Open_Union {I : Type} {s : I → set X} (H : ∀ i, Open (s i)) : Open (⋃ i, s i) :=
have ∀₀ t ∈ s ' univ, Open t,
  from take t, suppose t ∈ s ' univ,
    obtain i [univi (Hi : s i = t)], from this,
    show Open t, by rewrite -Hi; exact H i,
using this, by rewrite Union_eq_sUnion_image; apply Open_sUnion this

theorem Open_union {s t : set X} (Hs : Open s) (Ht : Open t) : Open (s ∪ t) :=
have ∀ i, Open (bin_ext s t i), by intro i; cases i; exact Hs; exact Ht,
show Open (s ∪ t), by rewrite -Union_bin_ext; exact Open_Union this

theorem Open_inter {s t : set X} (Hs : Open s) (Ht : Open t) : Open (s ∩ t) :=
inter_mem_opens X Hs Ht

theorem Open_sInter_of_finite {s : set (set X)} [fins : finite s] (H : ∀₀ t ∈ s, Open t) :
  Open (⋂₀ s) :=
begin
  induction fins with a s fins anins ih,
    {rewrite sInter_empty, exact Open_univ},
  rewrite sInter_insert,
  apply Open_inter,
    show Open a, from H (mem_insert a s),
  apply ih, intros t ts,
  show Open t, from H (mem_insert_of_mem a ts)
end

/- closed sets -/

attribute [reducible]
definition closed (s : set X) : Prop := Open (-s)

theorem closed_iff_Open_compl (s : set X) : closed s ↔ Open (-s) := !iff.refl

theorem Open_iff_closed_compl (s : set X) : Open s ↔ closed (-s) :=
by rewrite [closed_iff_Open_compl, compl_compl]

theorem closed_compl {s : set X} (H : Open s) : closed (-s) :=
by rewrite [-Open_iff_closed_compl]; apply H

theorem closed_empty : closed (∅ : set X) :=
by rewrite [↑closed, compl_empty]; exact Open_univ

theorem closed_univ : closed (univ : set X) :=
by rewrite [↑closed, compl_univ]; exact Open_empty

theorem closed_sInter {S : set (set X)} (H : ∀₀ t ∈ S, closed t) : closed (⋂₀ S) :=
begin
  rewrite [↑closed, compl_sInter],
  apply Open_sUnion,
  intro t,
  rewrite [mem_image_compl, Open_iff_closed_compl],
  apply H
end

theorem closed_Inter {I : Type} {s : I → set X} (H : ∀ i, closed (s i : set X)) :
  closed (⋂ i, s i) :=
by rewrite [↑closed, compl_Inter]; apply Open_Union; apply H

theorem closed_inter {s t : set X} (Hs : closed s) (Ht : closed t) : closed (s ∩ t) :=
by rewrite [↑closed, compl_inter]; apply Open_union; apply Hs; apply Ht

theorem closed_union {s t : set X} (Hs : closed s) (Ht : closed t) : closed (s ∪ t) :=
by rewrite [↑closed, compl_union]; apply Open_inter; apply Hs; apply Ht

theorem closed_sUnion_of_finite {s : set (set X)} [fins : finite s] (H : ∀₀ t ∈ s, closed t) :
  closed (⋂₀ s) :=
begin
  rewrite [↑closed, compl_sInter],
  apply Open_sUnion,
  intro t,
  rewrite [mem_image_compl, Open_iff_closed_compl],
  apply H
end

theorem open_diff {s t : set X} (Hs : Open s) (Ht : closed t) : Open (s \ t) :=
Open_inter Hs Ht

theorem closed_diff {s t : set X} (Hs : closed s) (Ht : Open t) : closed (s \ t) :=
closed_inter Hs (closed_compl Ht)

section
local attribute classical.prop_decidable [instance]

theorem Open_of_forall_exists_Open_nbhd {s : set X} (H : ∀₀ x ∈ s, ∃ tx : set X, Open tx ∧ x ∈ tx ∧ tx ⊆ s) :
        Open s :=
  let Hset : X → set X := λ x, if Hxs : x ∈ s then some (H Hxs) else univ in
  let sFam := image (λ x, Hset x) s in
  have H_union_open : Open (⋃₀ sFam), from Open_sUnion
    (take t : set X, suppose t ∈ sFam,
     have H_preim : ∃ t', t' ∈ s ∧ Hset t' = t, from this,
     obtain t' (Ht' : t' ∈ s)  (Ht't : Hset t' = t), from H_preim,
     have HHsett : t = some (H Ht'), from Ht't ▸ dif_pos Ht',
     show Open t, from and.left (HHsett⁻¹ ▸ some_spec (H Ht'))),
  have H_subset_union : s ⊆ ⋃₀ sFam, from
    (take x : X, suppose x ∈ s,
     have HxHset : x ∈ Hset x, from (dif_pos this)⁻¹ ▸ (and.left (and.right (some_spec (H this)))),
     show x ∈ ⋃₀ sFam, from mem_sUnion HxHset (mem_image this rfl)),
  have H_union_subset : ⋃₀ sFam ⊆ s, from
    (take x : X, suppose x ∈ ⋃₀ sFam,
     obtain (t : set X) (Ht : t ∈ sFam) (Hxt : x ∈ t), from this,
     have H_preim : ∃ t', t' ∈ s ∧ Hset t' = t, from Ht,
     obtain t' (Ht' : t' ∈ s)  (Ht't : Hset t' = t), from H_preim,
     have HHsett : t = some (H Ht'), from Ht't ▸ dif_pos Ht',
     have t ⊆ s, from and.right (and.right (HHsett⁻¹ ▸ some_spec (H Ht'))),
     show x ∈ s, from this Hxt),
  have H_union_eq : ⋃₀ sFam = s, from eq_of_subset_of_subset H_union_subset H_subset_union,
  show Open s, from  H_union_eq ▸ H_union_open

end

end topology

/- separation -/

structure T0_space [class] (X : Type) extends topology X :=
 (T0 : ∀ {x y}, x ≠ y → ∃ U, U ∈ opens ∧ ¬(x ∈ U ↔ y ∈ U))

namespace topology
  variables {X : Type} [T0_space X]

  theorem separation_T0 {x y : X} : x ≠ y ↔ ∃ U, Open U ∧ ¬(x ∈ U ↔ y ∈ U) :=
  iff.intro
    (T0_space.T0)
    (assume H, obtain U [OpU xyU], from H,
     suppose x = y,
     have x ∈ U ↔ y ∈ U, from iff.intro
       (assume xU, this ▸ xU)
       (assume yU, this⁻¹ ▸ yU),
     absurd this xyU)
end topology

structure T1_space [class] (X : Type) extends topology X :=
  (T1 : ∀ {x y}, x ≠ y → ∃ U, U ∈ opens ∧ x ∈ U ∧ y ∉ U)

attribute [trans_instance]
protected definition T0_space.of_T1 {X : Type} [T : T1_space X] :
  T0_space X :=
⦃T0_space, T,
  T0 := abstract
          take x y, assume H,
          obtain U [Uopens [xU ynU]], from T1_space.T1 H,
          exists.intro U (and.intro Uopens
            (show ¬ (x ∈ U ↔ y ∈ U), from assume H, ynU (iff.mp H xU)))
        end ⦄

namespace topology
  variables {X : Type} [T1_space X]

  theorem separation_T1 {x y : X} : x ≠ y ↔ (∃ U, Open U ∧ x ∈ U ∧ y ∉ U) :=
  iff.intro
    (T1_space.T1)
    (suppose ∃ U, Open U ∧ x ∈ U ∧ y ∉ U,
     obtain U [OpU xU nyU], from this,
     suppose x = y,
     absurd xU (this⁻¹ ▸ nyU))

  theorem closed_singleton {a : X} : closed '{a} :=
  let T := ⋃₀ {S| Open S ∧ a ∉ S} in
  have Open T, from Open_sUnion (λS HS, and.elim_left HS),
  have T = -'{a}, from ext(take x, iff.intro
    (assume xT, assume xa,
     obtain S [[OpS aS] xS], from xT,
     have ∃ U, Open U ∧ x ∈ U ∧ a ∉ U, from
       exists.intro S (and.intro OpS (and.intro xS aS)),
     have x ≠ a, from (iff.elim_right separation_T1) this,
     absurd ((iff.elim_left !mem_singleton_iff) xa) this)
    (assume xa,
     have x ≠ a, from not.intro(
       assume H, absurd ((iff.elim_right !mem_singleton_iff) H) xa),
     obtain U [OpU xU aU], from (iff.elim_left separation_T1) this,
     show _, from exists.intro U (and.intro (and.intro OpU aU) xU))),
  show _, from this ▸ `Open T`
end topology

structure T2_space [class] (X : Type) extends topology X :=
  (T2 : ∀ {x y}, x ≠ y → ∃ U V, U ∈ opens ∧ V ∈ opens ∧ x ∈ U ∧ y ∈ V ∧ U ∩ V = ∅)

attribute [trans_instance]
protected definition T1_space.of_T2 {X : Type} [T : T2_space X] :
  T1_space X :=
⦃T1_space, T,
  T1 := abstract
          take x y, assume H,
          obtain U [V [Uopens [Vopens [xU [yV UVempty]]]]], from T2_space.T2 H,
          exists.intro U (and.intro Uopens (and.intro xU
            (show y ∉ U, from assume yU,
              have y ∈ U ∩ V, from and.intro yU yV,
              show y ∈ ∅, from UVempty ▸ this)))
        end ⦄

namespace topology
  variables {X : Type} [T2_space X]

  theorem seperation_T2 {x y : X} : x ≠ y ↔ ∃ U V, Open U ∧ Open V ∧ x ∈ U ∧ y ∈ V ∧ U ∩ V = ∅ :=
  iff.intro
    (T2_space.T2)
    (assume H, obtain U V [OpU OpV xU yV UV], from H,
     suppose x = y,
     have ¬(x ∈ U ∩ V), from not.intro(
       assume xUV, absurd (UV ▸ xUV) !not_mem_empty),
     absurd (and.intro xU (`x = y`⁻¹ ▸ yV)) this)
end topology

structure perfect_space [class] (X : Type) extends topology X :=
  (perfect : ∀ x, '{x} ∉ opens)

/- topology generated by a set -/

namespace topology

inductive opens_generated_by {X : Type} (B : set (set X)) : set X → Prop :=
| generators_mem : ∀ ⦃s : set X⦄, s ∈ B → opens_generated_by B s
| univ_mem       : opens_generated_by B univ
| inter_mem      : ∀ ⦃s t⦄, opens_generated_by B s → opens_generated_by B t →
                    opens_generated_by B (s ∩ t)
| sUnion_mem     : ∀ ⦃S : set (set X)⦄, S ⊆ opens_generated_by B → opens_generated_by B (⋃₀ S)

attribute [instance]
protected definition generated_by {X : Type} (B : set (set X)) : topology X :=
⦃topology,
  opens            := opens_generated_by B,
  univ_mem_opens   := opens_generated_by.univ_mem B,
  inter_mem_opens  := λ s Hs t Ht, opens_generated_by.inter_mem Hs Ht,
  sUnion_mem_opens := opens_generated_by.sUnion_mem
⦄

theorem generators_mem_topology_generated_by {X : Type} (B : set (set X)) :
  let T := topology.generated_by B in
  ∀₀ s ∈ B, @Open _ T s :=
λ s H, opens_generated_by.generators_mem H

theorem opens_generated_by_initial {X : Type} {B : set (set X)} {T : topology X} (H : B ⊆ @opens _ T) :
  opens_generated_by B ⊆ @opens _ T :=
begin
  intro s Hs,
  induction Hs with s sB s t os ot soX toX S SB SOX,
    {exact H sB},
    {exact univ_mem_opens X},
    {exact inter_mem_opens X soX toX},
  exact sUnion_mem_opens SOX
end

theorem topology_generated_by_initial {X : Type} {B : set (set X)} {T : topology X}
    (H : ∀₀ s ∈ B, @Open _ T s) {s : set X} (H1 : @Open _ (topology.generated_by B) s) :
  @Open _ T s :=
opens_generated_by_initial H H1

section continuity

/- continuous mappings -/
/- continuity at a point -/

variables {M N : Type} [Tm : topology M] [Tn : topology N]
include Tm Tn

definition continuous_at (f : M → N) (x : M) :=
  ∀ U : set N, f x ∈ U → Open U → ∃ V : set M, x ∈ V ∧ Open V ∧ f 'V ⊆ U

definition continuous (f : M → N) :=
  ∀ x : M, continuous_at f x

end continuity

section boundary
variables {X : Type} [TX : topology X]
include TX

definition on_boundary (x : X) (u : set X) := ∀ v : set X, Open v → x ∈ v → u ∩ v ≠ ∅ ∧ ¬ v ⊆ u

theorem not_open_of_on_boundary {x : X} {u : set X} (Hxu : x ∈ u) (Hob : on_boundary x u) : ¬ Open u :=
  begin
    intro Hop,
    note Hbxu := Hob _ Hop Hxu,
    apply and.right Hbxu,
    apply subset.refl
  end

end boundary

end topology
