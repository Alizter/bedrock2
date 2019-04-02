Require Import bedrock2.Syntax bedrock2.StringNamesSyntax.
Require Import bedrock2.NotationsCustomEntry coqutil.Z.HexNotation.
Require Import bedrock2.FE310CSemantics.

Import Syntax BinInt String List.ListNotations.
Local Open Scope string_scope. Local Open Scope Z_scope. Local Open Scope list_scope.
Local Coercion literal (z : Z) : expr := expr.literal z.
Local Coercion var (x : String.string) : expr := expr.var x.
Local Definition bedrock_func : Type := funname * (list varname * list varname * cmd).
Local Coercion name_of_func (f : bedrock_func) := fst f.

Definition tf : bedrock_func := 
    let buf : varname := "buf" in
    let len : varname := "len" in
    let i : varname := "i" in
    let j : varname := "j" in
    let r : varname := "r" in
  ("tf", ([buf; len; i; j], [], bedrock_func_body:(
    require ( i < len ) else { /*skip*/ };
    store1(buf + i, constr:(0));
    require ( j < len ) else { r = (constr:(-1)) };
    r = (load1(buf + j))
  ))).

From bedrock2 Require Import BasicC64Semantics ProgramLogic.
From bedrock2 Require Import Array Scalars Separation.
From coqutil Require Import Word.Interface Map.Interface.

Local Instance spec_of_tf : spec_of "tf" := fun functions =>
  forall t m buf len bs i j R,
    (sep (array ptsto (word.of_Z 1) buf bs) R) m ->
    word.unsigned len = Z.of_nat (List.length bs) ->
    WeakestPrecondition.call functions "tf" t m [buf; len; i; j]
    (fun T M rets => True).

From coqutil.Tactics Require Import letexists.

Import SeparationLogic Lift1Prop.

Goal program_logic_goal_for_function! tf.
Proof.
  repeat straightline.

  letexists. split; [solve[repeat straightline] |].
  split; [|solve [repeat straightline]]; repeat straightline.
  assert (word.unsigned i < word.unsigned len) by admit.

  simple refine (store_one_of_sep _ _ _ _ _ _ (Lift1Prop.subrelation_iff1_impl1 _ _ _ _ _ H) _); shelve_unifiable.
  1: (etransitivity; [|etransitivity]); [ |  | ].
  2: eapply Proper_sep_iff1; [|reflexivity].
  2: eapply array_address_inbounds.
  5: ecancel.
  1: ecancel.

  all: change (word.unsigned (word.of_Z 1)) with 1 in *.
  all: rewrite ?Z.mul_1_l, ?Z.mod_1_r, ?Z.div_1_r; trivial.
  all: unshelve erewrite (_ : forall x y, word.sub (word.add x y) x = y) in *; [admit|].
  1: Omega.omega.

  intros.

  Import List.
  Local Infix "*" := sep : type_scope.
  Local Infix "*" := sep.
  Local Notation "a [ i ]" := (List.hd _ (List.skipn i a)) (at level 10, left associativity, format "a [ i ]").
  Local Notation "a [: i ]" := (List.firstn i a) (at level 10, left associativity, format "a [: i ]").
  Local Notation "a [ i :]" := (List.skipn i a) (at level 10, left associativity, format "a [ i :]").
  Local Notation bytes := (array ptsto (word.of_Z 1)).
  Local Notation n_o_w x := (Z.to_nat (word.unsigned x)).
  Local Infix "+" := word.add.

  From coqutil.Macros Require Import symmetry.
  seprewrite_in (symmetry! @array_cons) H3.
  replace (word.add buf i)
     with (buf +
             word.of_Z (word.unsigned (word.of_Z 1) * Z.of_nat (Datatypes.length (bs[:n_o_w i])))) in H3 by admit.
  seprewrite_in (symmetry! @array_append) H3.

  letexists. split.
  1: repeat straightline.
  split.
  2: repeat straightline.

  repeat straightline.

  letexists.
  split. {
    letexists.
    split; repeat straightline.
    letexists; split. {
      eapply load_one_of_sep.
      simple refine (Lift1Prop.subrelation_iff1_impl1 _ _ _ _ _ H3).
      1: (etransitivity; [|etransitivity]); [ |  | ].
      2: eapply Proper_sep_iff1; [|reflexivity].
      2: eapply array_address_inbounds.
      5: {
        reify_goal.
        let j := open_constr:(0%nat) in
        let i := open_constr:(1%nat) in
        simple refine (@cancel_seps_at_indices _ _ _ _ i j _ _ _ _);
          cbn[firstn skipn app hd tl].
        1: {
          let pf := open_constr:((@RelationClasses.reflexivity _ _ (@RelationClasses.Equivalence_Reflexive _ _ (@Equivalence_iff1 _)) _)) in
          (* exact pf. (* FAILS *) *)
          let G := match goal with |- ?G => G end in
          let T := type of pf in
          let __ := open_constr:(eq_refl : T = G) in
          exact pf. (* succeeds *)
          (* unify T G. *)
          (* pose proof (eq_refl : T = G). *)
        } 
        1: ecancel.
      } 
      1: ecancel.
  all: change (word.unsigned (word.of_Z 1)) with 1 in *.
  all: rewrite ?Z.mul_1_l, ?Z.mod_1_r, ?Z.div_1_r; trivial.
  all: unshelve erewrite (_ : forall x y, word.sub (word.add x y) x = y) in *; [admit|].
  1: admit. (* length_set_nth *)
  } 
  1: subst v2.
  refine eq_refl.
  exact (word.of_Z 0). }

  repeat straightline.

  Unshelve.
  exact (word.of_Z 0).
  
Abort.

  (* [eseptract] solves goals of the form [state == needle * ?r] by
    "subtracting" [needle] from [state] with the help of decomposition
    hints of the form [a = b * c * d * ...]. [?r] will be instantiated
    with the result of the subtraction "state - needle"; in terms of
    the magic wand operator this tactic simplifies [needle -* state].
    The process is directed by the syntactic form of [needle]:

    1. If [needle] appears syntactically in [state], the equation is
       solved by cancellation.
    2. If [needle] matches a part of a RHS of a decomposition lemma,
       the non-matched part of the RHS is into [r] and the LHS is
       subtracted from the state recursively.
    3. If [needle] is a separating conjunct of multiple clauses, they
       of them will be subtracted separately. *)

  (* TODO: should side conditions be solved before or after recursing?
     - before does not work for arrays -- need to know which array before checking bounds
     - after would mean all leaves of every struct would be explored -- uncontroled search *)

  (* better algorithm might use hints containing:
     - needle pattern
     - state pattern = hint lhs
     - condition when to apply this hint (is needle actually inside pattern?) this might be a judgementally trivial but syntactically informative precondition
     - hint rhs
     on match, only the hint rhs (plus original frame) would be searched for further matches *)