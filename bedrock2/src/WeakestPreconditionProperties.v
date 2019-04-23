Require Import  coqutil.Macros.subst coqutil.Macros.unique coqutil.Map.Interface coqutil.Word.Properties.
Require bedrock2.WeakestPrecondition.

Require Import Coq.Classes.Morphisms.

Section WeakestPrecondition.
  Context {p : unique! Semantics.parameters}.

  Ltac ind_on X :=
    intros;
    repeat match goal with x : ?T |- _ => first [ constr_eq T X; move x at top | revert x ] end;
    match goal with x : X |- _ => induction x end;
    intros.

  Global Instance Proper_literal : Proper (pointwise_relation _ ((pointwise_relation _ Basics.impl) ==> Basics.impl)) WeakestPrecondition.literal.
  Proof. cbv [WeakestPrecondition.literal]; cbv [Proper respectful pointwise_relation Basics.impl]; firstorder idtac. Qed.

  Global Instance Proper_get : Proper (pointwise_relation _ (pointwise_relation _ ((pointwise_relation _ Basics.impl) ==> Basics.impl))) WeakestPrecondition.get.
  Proof. cbv [WeakestPrecondition.get]; cbv [Proper respectful pointwise_relation Basics.impl]; firstorder idtac. Qed.

  Global Instance Proper_load : Proper (pointwise_relation _ (pointwise_relation _ (pointwise_relation _ ((pointwise_relation _ Basics.impl) ==> Basics.impl)))) WeakestPrecondition.load.
  Proof. cbv [WeakestPrecondition.load]; cbv [Proper respectful pointwise_relation Basics.impl]; firstorder idtac. Qed.

  Global Instance Proper_store : Proper (pointwise_relation _ (pointwise_relation _ (pointwise_relation _ (pointwise_relation _ ((pointwise_relation _ Basics.impl) ==> Basics.impl))))) WeakestPrecondition.store.
  Proof. cbv [WeakestPrecondition.load]; cbv [Proper respectful pointwise_relation Basics.impl]; firstorder idtac. Qed.

  Global Instance Proper_expr : Proper (pointwise_relation _ (pointwise_relation _ (pointwise_relation _ ((pointwise_relation _ Basics.impl) ==> Basics.impl)))) WeakestPrecondition.expr.
  Proof.
    cbv [Proper respectful pointwise_relation Basics.impl]; ind_on Syntax.expr.expr;
      cbn in *; intuition (try typeclasses eauto with core).
    { eapply Proper_literal; eauto. }
    { eapply Proper_get; eauto. }
    { eapply IHa1; eauto; intuition idtac. eapply Proper_load; eauto using Proper_load. }
  Qed.

  Global Instance Proper_list_map {A B} :
    Proper ((pointwise_relation _ (pointwise_relation _ Basics.impl ==> Basics.impl)) ==> pointwise_relation _ (pointwise_relation _ Basics.impl ==> Basics.impl)) (WeakestPrecondition.list_map (A:=A) (B:=B)).
  Proof.
    cbv [Proper respectful pointwise_relation Basics.impl]; ind_on (list A);
      cbn in *; intuition (try typeclasses eauto with core).
  Qed.

  Context {Proper_ext_spec : forall trace m act args, Proper ((pointwise_relation _ (pointwise_relation _ Basics.impl)) ==> Basics.impl) (Semantics.ext_spec trace m act args)}.
  Global Instance Proper_cmd :
    Proper (
     (pointwise_relation _ (pointwise_relation _ (pointwise_relation _ (pointwise_relation _ (pointwise_relation _ ((pointwise_relation _ (pointwise_relation _ Basics.impl))) ==> Basics.impl)))) ==>
     pointwise_relation _ (
     pointwise_relation _ (
     pointwise_relation _ (
     pointwise_relation _ (
     (pointwise_relation _ (pointwise_relation _ (pointwise_relation _ Basics.impl))) ==>
     Basics.impl)))))) WeakestPrecondition.cmd.
  Proof.
    cbv [Proper respectful pointwise_relation Basics.flip Basics.impl]; ind_on Syntax.cmd.cmd;
      cbn in *; cbv [dlet.dlet] in *; intuition (try typeclasses eauto with core).
    { destruct H1 as (?&?&?). eexists. split.
      1: eapply Proper_expr.
      1: cbv [pointwise_relation Basics.impl]; intuition eauto 2.
      all: eauto. }
    { destruct H1 as (?&?&?). eexists. split.
      { eapply Proper_expr.
        { cbv [pointwise_relation Basics.impl]; intuition eauto 2. }
        { eauto. } }
      { destruct H2 as (?&?&?). eexists. split.
        { eapply Proper_expr.
          { cbv [pointwise_relation Basics.impl]; intuition eauto 2. }
          { eauto. } }
        { eapply Proper_store; eauto; cbv [pointwise_relation Basics.impl]; eauto. } } }
    { destruct H1 as (?&?&?). eexists. split.
      { eapply Proper_expr.
        { cbv [pointwise_relation Basics.impl]; intuition eauto 2. }
        { eauto. } }
      { intuition eauto 6. } }
    { destruct H1 as (?&?&?&?&?&HH).
      eassumption || eexists.
      eassumption || eexists.
      eassumption || eexists.
      eassumption || eexists. { eassumption || eexists. }
      eassumption || eexists. { eassumption || eexists. }
      intros X Y Z T W.
      specialize (HH X Y Z T W).
      destruct HH as (?&?&?). eexists. split.
      1: eapply Proper_expr.
      1: cbv [pointwise_relation Basics.impl].
      all:intuition eauto 2.
      - eapply H2; eauto; cbn; intros.
        match goal with H:_ |- _ => destruct H as (?&?&?); solve[eauto] end.
      - intuition eauto. }
    { destruct H1 as (?&?&?). eexists. split.
      { eapply Proper_list_map; eauto; try exact H4; cbv [respectful pointwise_relation Basics.impl]; intuition eauto 2.
        eapply Proper_expr; eauto. }
      { eapply H; eauto; firstorder eauto. } }
    { destruct H1 as (?&?&?). eexists. split.
      { eapply Proper_list_map; eauto; try exact H4; cbv [respectful pointwise_relation Basics.impl].
        { eapply Proper_expr; eauto. }
        { eauto. } }
      { destruct H2 as (mKeep & mGive & ? & ?).
        exists mKeep. exists mGive.
        split; [assumption|].
        eapply Proper_ext_spec; [|solve[eassumption]]; firstorder eauto. } }
  Qed.

  Global Instance Proper_func :
    Proper (
     (pointwise_relation _ (pointwise_relation _ (pointwise_relation _ (pointwise_relation _ (pointwise_relation _ ((pointwise_relation _ (pointwise_relation _ Basics.impl))) ==> Basics.impl)))) ==>
     pointwise_relation _ (
     pointwise_relation _ (
     pointwise_relation _ (
     pointwise_relation _ (
     (pointwise_relation _ (pointwise_relation _ (pointwise_relation _ Basics.impl))) ==>
     Basics.impl)))))) WeakestPrecondition.func.
  Proof.
    cbv [Proper respectful pointwise_relation Basics.flip Basics.impl  WeakestPrecondition.func]; intros.
    destruct a. destruct p0.
    destruct H1; intuition idtac.
    eexists.
    split; [eauto|].
    eapply Proper_cmd;
      cbv [Proper respectful pointwise_relation Basics.flip Basics.impl  WeakestPrecondition.func];
      try solve [typeclasses eauto with core].
    intros.
    eapply Proper_list_map;
      cbv [Proper respectful pointwise_relation Basics.flip Basics.impl  WeakestPrecondition.func];
      try solve [typeclasses eauto with core].
    - intros.
      eapply Proper_get;
        cbv [Proper respectful pointwise_relation Basics.flip Basics.impl  WeakestPrecondition.func];
        eauto.
    - eauto.
  Qed.

  Global Instance Proper_call :
    Proper (
     (pointwise_relation _ (
     (pointwise_relation _ (
     pointwise_relation _ (
     pointwise_relation _ (
     pointwise_relation _ (
     (pointwise_relation _ (pointwise_relation _ (pointwise_relation _ Basics.impl))) ==>
     Basics.impl)))))))) WeakestPrecondition.call.
  Proof.
    cbv [Proper respectful pointwise_relation Basics.impl]; ind_on (list (Syntax.funname * (list Syntax.varname * list Syntax.varname * Syntax.cmd.cmd)));
      cbn in *; intuition (try typeclasses eauto with core).
    destruct a.
    destruct (Semantics.funname_eqb f a1); eauto.
    eapply Proper_func;
      cbv [Proper respectful pointwise_relation Basics.flip Basics.impl  WeakestPrecondition.func];
      eauto.
  Qed.

  Global Instance Proper_program :
    Proper (
     pointwise_relation _ (
     pointwise_relation _ (
     pointwise_relation _ (
     pointwise_relation _ (
     pointwise_relation _ (
     (pointwise_relation _ (pointwise_relation _ (pointwise_relation _ Basics.impl))) ==>
     Basics.impl)))))) WeakestPrecondition.program.
  Proof.
    cbv [Proper respectful pointwise_relation Basics.impl  WeakestPrecondition.program]; intros.
    eapply Proper_cmd;
    cbv [Proper respectful pointwise_relation Basics.flip Basics.impl  WeakestPrecondition.func];
    try solve [typeclasses eauto with core].
    intros.
    eapply Proper_call;
    cbv [Proper respectful pointwise_relation Basics.flip Basics.impl  WeakestPrecondition.func];
    solve [typeclasses eauto with core].
  Qed.

  Ltac t :=
      repeat match goal with
             | |- forall _, _ => progress intros
             | H: exists _, _ |- _ => destruct H
             | H: and _ _ |- _ => destruct H
             | H: eq _ ?y |- _ => subst y
             | H: False |- _ => destruct H
             | _ => progress cbn in *
             | _ => progress cbv [dlet.dlet WeakestPrecondition.dexpr WeakestPrecondition.dexprs WeakestPrecondition.store] in *
             end; eauto.

  Lemma expr_sound m l e post (H : WeakestPrecondition.expr m l e post)
    : exists v, Semantics.eval_expr m l e = Some v /\ post v.
  Proof.
    ind_on Syntax.expr; t.
    { eapply IHe in H; eauto. destruct H. destruct H. setoid_rewrite H. eauto. }
    { eapply IHe1 in H; t. eapply IHe2 in H0; t. rewrite H, H0; eauto. }
  Qed.
    
  Lemma sound_args : forall m l args P,
      WeakestPrecondition.list_map (WeakestPrecondition.expr m l) args P ->
      exists x, List.option_all (List.map (Semantics.eval_expr m l) args) = Some x /\ P x.
  Proof.
    induction args; cbn; repeat (subst; t).
    eapply expr_sound in H; t; rewrite H.
    eapply IHargs in H0; t; rewrite H0.
    eauto.
  Qed.
  
  Local Hint Constructors Semantics.exec.
  Lemma sound_nil c t m l mc post
        (H:WeakestPrecondition.cmd (fun _ _ _ _ _ => False) c t m l post)
    : Semantics.exec map.empty c t m l mc (fun t' m' l' mc' => post t' m' l').
   Proof.
    ind_on Syntax.cmd; repeat (t; try match reverse goal with H : WeakestPrecondition.expr _ _ _ _ |- _ => eapply expr_sound in H end).
    { destruct (BinInt.Z.eq_dec (Interface.word.unsigned x) (BinNums.Z0)) as [Hb|Hb]; cycle 1.
      { econstructor; t. }
      { eapply Semantics.exec.if_false; t. } }
    { revert dependent l; revert dependent m; revert dependent t; revert dependent mc; pattern x2.
      eapply (well_founded_ind H); t.
      pose proof (H1 _ _ _ _ ltac:(eassumption));
        repeat (t; try match goal with H : WeakestPrecondition.expr _ _ _ _ |- _ => eapply expr_sound in H end).
      { destruct (BinInt.Z.eq_dec (Interface.word.unsigned x4) (BinNums.Z0)) as [Hb|Hb].
        { eapply Semantics.exec.while_false; t. }
        { eapply Semantics.exec.while_true; t. t. } } }
    { eapply sound_args in H; t. }
  Qed.

End WeakestPrecondition.
