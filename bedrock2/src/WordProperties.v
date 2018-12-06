Require Import Coq.ZArith.BinIntDef Coq.ZArith.BinInt.
Require Import Lia Btauto.
Require Coq.setoid_ring.Ring_theory.
Local Open Scope Z_scope.

(* NOTE: this stuff does not really belong here, but this way this file is self-contained. *)
Module Z.
  (* from https://github.com/coq/coq/pull/8062/files#diff-c73fff6c197eb53a5ca574b51e21bf82 *)
  Lemma mod_0_r_ext x y : y = 0 -> x mod y = 0.
  Proof. intro; subst; destruct x; reflexivity. Qed.
  Lemma div_0_r_ext x y : y = 0 -> x / y = 0.
  Proof. intro; subst; destruct x; reflexivity. Qed.

  Ltac div_mod_to_quot_rem_generalize x y :=
    pose proof (Z.div_mod x y);    pose proof (Z.mod_pos_bound x y);
    pose proof (Z.mod_neg_bound x y);    pose proof (div_0_r_ext x y);
    pose proof (mod_0_r_ext x y);    let q := fresh "q" in
    let r := fresh "r" in    set (q := x / y) in *;
    set (r := x mod y) in *;
    clearbody q r.  Ltac div_mod_to_quot_rem_step :=
    match goal with    | [ |- context[?x / ?y] ] => div_mod_to_quot_rem_generalize x y
    | [ |- context[?x mod ?y] ] => div_mod_to_quot_rem_generalize x y    | [ H : context[?x / ?y] |- _ ] => div_mod_to_quot_rem_generalize x y
    | [ H : context[?x mod ?y] |- _ ] => div_mod_to_quot_rem_generalize x y    end.
  Ltac div_mod_to_quot_rem := repeat div_mod_to_quot_rem_step.


  Lemma testbit_minus1 i (H:0<=i) : Z.testbit (-1) i = true.
  Proof. destruct i; try lia; exact eq_refl. Qed.
  Lemma testbit_mod_pow2 a n i (H:0<=n)
    : Z.testbit (a mod 2 ^ n) i = ((i <? n) && Z.testbit a i)%bool.
  Proof.
    destruct (Z.ltb_spec i n); rewrite
      ?Z.mod_pow2_bits_low, ?Z.mod_pow2_bits_high by auto; auto.
  Qed.
  Lemma testbit_ones n i (H : 0 <= n) : Z.testbit (Z.ones n) i = ((0 <=? i) && (i <? n))%bool.
  Proof.
    destruct (Z.leb_spec 0 i), (Z.ltb_spec i n); cbn;
      rewrite ?Z.testbit_neg_r, ?Z.ones_spec_low, ?Z.ones_spec_high by lia; trivial.
  Qed.
  Lemma testbit_ones_nonneg n i (Hn : 0 <= n) (Hi: 0 <= i) : Z.testbit (Z.ones n) i = (i <? n)%bool.
  Proof.
    rewrite testbit_ones by lia.
    destruct (Z.leb_spec 0 i); cbn; solve [trivial | lia].
  Qed.


  (* Create HintDb z_bitwise discriminated. *) (* DON'T do this, COQBUG(5381) *)
  Hint Rewrite
       Z.shiftl_spec_low Z.lxor_spec Z.lor_spec Z.land_spec Z.lnot_spec Z.ldiff_spec Z.shiftl_spec Z.shiftr_spec Z.ones_spec_high Z.shiftl_spec_alt Z.ones_spec_low Z.shiftr_spec_aux Z.shiftl_spec_high Z.ones_spec_iff Z.testbit_spec
       Z.div_pow2_bits Z.pow2_bits_eqb Z.bits_opp Z.testbit_0_l
       Z.testbit_mod_pow2 Z.testbit_ones_nonneg Z.testbit_minus1
       using solve [auto with zarith] : z_bitwise.
  Hint Rewrite <-Z.ones_equiv
       using solve [auto with zarith] : z_bitwise.
End Z.
Ltac mia := Z.div_mod_to_quot_rem; nia.

Require Import bedrock2.Word. Import word.

Ltac fix_V881 :=
  intros;
  repeat match goal with
         | H: _ |- _ => rewrite <- H; clear H
         end;
  try reflexivity.

Module word.
  (* Create HintDb word_laws discriminated. *) (* DON'T do this, COQBUG(5381) *)
  Hint Rewrite
       @unsigned_of_Z @signed_of_Z @of_Z_unsigned @unsigned_add @unsigned_sub @unsigned_opp @unsigned_or @unsigned_and @unsigned_xor @unsigned_not @unsigned_ndn @unsigned_mul @signed_mulhss @signed_mulhsu @unsigned_mulhuu @unsigned_divu @signed_divs @unsigned_modu @signed_mods @unsigned_slu @unsigned_sru @signed_srs @unsigned_eqb @unsigned_ltu @signed_lts
       using trivial
  : word_laws.
  Section WithWord.
    Context {width} {word : word width} {word_ok : word.ok word}.

    Lemma wrap_unsigned x : (unsigned x) mod (2^width) = unsigned x.
    Proof.
      pose proof unsigned_of_Z (unsigned x) as H.
      rewrite of_Z_unsigned in H; fix_V881.
    Qed.

    Lemma eq_unsigned x y (H : unsigned x = unsigned y) : x = y.
    Proof. rewrite <-(of_Z_unsigned x), <-(of_Z_unsigned y). apply f_equal, H. Qed.

    Lemma signed_eq_swrap_unsigned x : signed x = swrap (unsigned x).
    Proof. cbv [wrap]; rewrite <-signed_of_Z, of_Z_unsigned; trivial. Qed.

    Context (width_nonneg : 0 <= width).
    Let m_small : 0 < 2^width. apply Z.pow_pos_nonneg; firstorder idtac. Qed.

    Lemma unsigned_range x : 0 <= unsigned x < 2^width.
    Proof. rewrite <-wrap_unsigned. mia. Qed.

    Lemma ring_theory : Ring_theory.ring_theory (of_Z 0) (of_Z 1) add mul sub opp Logic.eq.
    Proof.
     split; intros; apply eq_unsigned; repeat rewrite ?wrap_unsigned,
         ?unsigned_add, ?unsigned_sub, ?unsigned_opp, ?unsigned_mul, ?unsigned_of_Z,
         ?Z.add_mod_idemp_l, ?Z.add_mod_idemp_r, ?Z.mul_mod_idemp_l, ?Z.mul_mod_idemp_r,
         ?Z.add_0_l, ?(Z.mod_small 1), ?Z.mul_1_l;
     f_equal; auto with zarith; fix_V881.
    Qed.

    Lemma ring_morph :
      Ring_theory.ring_morph (of_Z 0) (of_Z 1) add mul sub opp Logic.eq 0  1 Z.add Z.mul Z.sub Z.opp Z.eqb of_Z.
    Proof.
     split; intros; apply eq_unsigned; repeat rewrite  ?wrap_unsigned,
         ?unsigned_add, ?unsigned_sub, ?unsigned_opp, ?unsigned_mul, ?unsigned_of_Z,
         ?Z.add_mod_idemp_l, ?Z.add_mod_idemp_r, ?Z.mul_mod_idemp_l, ?Z.mul_mod_idemp_r,
         ?Zdiv.Zminus_mod_idemp_l, ?Zdiv.Zminus_mod_idemp_r,
         ?Z.sub_0_l, ?Z.add_0_l, ?(Z.mod_small 1), ?Z.mul_1_l by auto with zarith;
       try solve [f_equal; auto with zarith].
     { rewrite <-Z.sub_0_l; symmetry; rewrite <-Z.sub_0_l, Zdiv.Zminus_mod_idemp_r. auto. } (* COQBUG? *)
     { f_equal. eapply Z.eqb_eq. auto. } (* Z.eqb -> @eq z *)
    Qed.

    Ltac generalize_wrap_unsigned :=
      repeat match goal with
             | x : @word.rep ?a ?b |- _ =>
               rewrite <-(wrap_unsigned x);
               let x' := fresh in
               set (unsigned x) as x' in *; clearbody x'; clear x; rename x' into x
             end.

    Lemma unsigned_mulhuu_nowrap x y : unsigned (mulhuu x y) = Z.mul (unsigned x) (unsigned y) / 2^width.
    Proof. autorewrite with word_laws; generalize_wrap_unsigned; rewrite Z.mod_small; mia. Qed.
    Lemma unsigned_divu_nowrap x y (H:unsigned y <> 0) : unsigned (divu x y) = Z.div (unsigned x) (unsigned y).
    Proof. autorewrite with word_laws; generalize_wrap_unsigned; rewrite Z.mod_small; mia. Qed.
    Lemma unsigned_modu_nowrap x y (H:unsigned y <> 0) : unsigned (modu x y) = Z.modulo (unsigned x) (unsigned y).
    Proof. autorewrite with word_laws; generalize_wrap_unsigned; rewrite Z.mod_small; mia. Qed.

    Ltac bitwise :=
      autorewrite with word_laws;
      generalize_wrap_unsigned;
      eapply Z.bits_inj'; intros ?i ?Hi; autorewrite with z_bitwise; btauto.

    Lemma unsigned_or_nowrap x y : unsigned (or x y) = Z.lor (unsigned x) (unsigned y).
    Proof. bitwise. Qed.
    Lemma unsigned_and_nowrap x y : unsigned (and x y) = Z.land (unsigned x) (unsigned y).
    Proof. bitwise. Qed.
    Lemma unsigned_xor_nowrap x y : unsigned (xor x y) = Z.lxor (unsigned x) (unsigned y).
    Proof. bitwise. Qed.
    Lemma unsigned_ndn_nowrap x y : unsigned (ndn x y) = Z.ldiff (unsigned x) (unsigned y).
    Proof. bitwise. Qed.
    Lemma unsigned_sru_nowrap x y (H:unsigned y < width) : unsigned (sru x y) = Z.shiftr (unsigned x) (unsigned y).
    Proof.
      pose proof unsigned_range y.
      rewrite unsigned_sru by lia.
      rewrite <-(wrap_unsigned x).
      eapply Z.bits_inj'; intros ?i ?Hi; autorewrite with z_bitwise.
      repeat match goal with |- context [?a <? ?b] =>
        destruct (Z.ltb_spec a b); trivial; try lia
      end.
    Qed.

    Lemma testbit_wrap z i : Z.testbit (wrap z) i = ((i <? width) && Z.testbit z i)%bool.
    Proof. cbv [wrap]. autorewrite with z_bitwise; trivial. Qed.
  End WithWord.

  Section WithNontrivialWord.
    Context {width} {word : word width} {word_ok : word.ok word} (width_nonzero : 0 < width).
    Let halfm_small : 0 < 2^(width-1). apply Z.pow_pos_nonneg; auto with zarith. Qed.
    Let twice_halfm : 2^(width-1) * 2 = 2^width.
    Proof. rewrite Z.mul_comm, <-Z.pow_succ_r by lia; f_equal; lia. Qed.

    Lemma signed_range x : -2^(width-1) <= signed x < 2^(width-1).
    Proof.
      rewrite signed_eq_swrap_unsigned. cbv [swrap].
      rewrite <-twice_halfm. mia.
    Qed.

    Lemma swrap_inrange z (H : -2^(width-1) <= z < 2^(width-1)) : swrap z = z.
    Proof. cbv [swrap]; rewrite Z.mod_small; lia. Qed.

    Lemma swrap_as_div_mod z : swrap z = z mod 2^(width-1) - 2^(width-1) * (z / (2^(width - 1)) mod 2).
    Proof.
      symmetry; cbv [swrap wrap].
      replace (2^width) with ((2 ^ (width - 1) * 2))
        by (rewrite Z.mul_comm, <-Z.pow_succ_r by lia; f_equal; lia).
      replace (z + 2^(width-1)) with (z + 1*2^(width-1)) by lia.
      rewrite Z.rem_mul_r, ?Z.div_add, ?Z.mod_add, (Z.add_mod _ 1 2), Zdiv.Zmod_odd by lia.
      destruct (Z.odd _); cbn; lia.
    Qed.

    Lemma signed_add x y : signed (add x y) = swrap (Z.add (signed x) (signed y)).
    Proof.
      rewrite !signed_eq_swrap_unsigned; autorewrite with word_laws.
      cbv [wrap swrap]. rewrite <-(wrap_unsigned x), <-(wrap_unsigned y).
      replace (2 ^ width) with (2*2 ^ (width - 1)) by
        (rewrite <-Z.pow_succ_r, Z.sub_1_r, Z.succ_pred; lia).
      set (M := 2 ^ (width - 1)) in*; clearbody M.
      assert (0<2*M) by nia.
      rewrite <-!Z.add_opp_r.
      repeat rewrite ?Z.add_assoc, ?Z.add_mod_idemp_l, ?Z.add_mod_idemp_r, ?(Z.add_shuffle0 _ (_ mod _)) by lia.
      rewrite 4(Z.add_comm (_ mod _)).
      repeat rewrite ?Z.add_assoc, ?Z.add_mod_idemp_l, ?Z.add_mod_idemp_r, ?(Z.add_shuffle0 _ (_ mod _)) by lia.
      f_equal; f_equal; (lia || intros;
       repeat match goal with
              | H: _ |- _ => rewrite H
              end;
       try reflexivity).
    Qed.

    Lemma signed_sub x y : signed (sub x y) = swrap (Z.sub (signed x) (signed y)).
    Proof.
      rewrite !signed_eq_swrap_unsigned; autorewrite with word_laws.
      cbv [wrap swrap]; rewrite <-(wrap_unsigned x), <-(wrap_unsigned y).
      replace (2 ^ width) with (2*2 ^ (width - 1)) by
        (rewrite <-Z.pow_succ_r, Z.sub_1_r, Z.succ_pred; lia).
      set (M := 2 ^ (width - 1)) in*; clearbody M.
      assert (0<2*M) by nia.
      rewrite <-!Z.add_opp_r.
      repeat rewrite ?Z.add_assoc, ?Z.add_mod_idemp_l, ?Z.add_mod_idemp_r, ?(Z.add_shuffle0 _ (_ mod _)) by lia.
      rewrite !(Z.add_comm (_ mod _)).
      repeat rewrite ?Z.add_assoc, ?Z.add_mod_idemp_l, ?Z.add_mod_idemp_r, ?(Z.add_shuffle0 _ (_ mod _)) by lia.
      replace (-(unsigned y mod (2 * M))+M+unsigned x) with (M+unsigned x-(unsigned y mod(2*M))) by lia.
      replace (-M+-(-M+(unsigned y+M) mod (2*M))+M+unsigned x+M) with (-M+M+unsigned x+M+M-(unsigned y+M)mod(2*M)) by lia.
      rewrite 2Zdiv.Zminus_mod_idemp_r; f_equal; f_equal; lia || fix_V881.
    Qed.

    Lemma signed_opp x : signed (opp x) = swrap (Z.opp (signed x)).
    Proof.
      rewrite !signed_eq_swrap_unsigned; autorewrite with word_laws.
      cbv [wrap swrap]; rewrite <-(wrap_unsigned x).
      replace (2 ^ width) with (2*2 ^ (width - 1)) by
        (rewrite <-Z.pow_succ_r, Z.sub_1_r, Z.succ_pred; lia).
      set (M := 2 ^ (width - 1)) in*; clearbody M.
      rewrite <-!Z.add_opp_r.
      repeat rewrite ?Z.add_assoc, ?Z.add_mod_idemp_l, ?Z.add_mod_idemp_r, ?(Z.add_shuffle0 _ (_ mod _)) by lia.
      replace (- (unsigned x mod (2 * M)) + M) with (M - unsigned x mod (2 * M)) by lia.
      replace (- ((unsigned x + M) mod (2 * M) + - M) + M) with (M+M-(unsigned x+M) mod (2*M)) by lia.
      rewrite ?Zdiv.Zminus_mod_idemp_r; f_equal; f_equal; lia || fix_V881.
    Qed.

    Lemma signed_mul x y : signed (mul x y) = swrap (Z.mul (signed x) (signed y)).
    Proof.
      rewrite !signed_eq_swrap_unsigned; autorewrite with word_laws.
      cbv [wrap swrap]. rewrite <-(wrap_unsigned x), <-(wrap_unsigned y).
      replace (2 ^ width) with (2*2 ^ (width - 1)) by
        (rewrite <-Z.pow_succ_r, Z.sub_1_r, Z.succ_pred; lia).
      set (M := 2 ^ (width - 1)) in*; clearbody M.
      assert (0<2*M) by nia.
      f_equal; try fix_V881.
      symmetry.
      rewrite <-Z.add_mod_idemp_l by lia.
      rewrite Z.mul_mod by lia.
      rewrite <-!Z.add_opp_r.
      rewrite ?Z.add_mod_idemp_l, ?Z.add_mod_idemp_r by lia.
      rewrite !Z.add_opp_r.
      rewrite !Z.add_simpl_r.
      rewrite !Z.mod_mod by lia.
      trivial.
    Qed.

    Lemma testbit_swrap z i : Z.testbit (swrap z) i
                              = if i <? width
                                then Z.testbit (wrap z) i
                                else Z.testbit (wrap z) (width -1).
    Proof.
      destruct (ZArith_dec.Z_lt_le_dec i 0).
      { destruct (Z.ltb_spec i width); rewrite ?Z.testbit_neg_r by lia; trivial. }
      rewrite swrap_as_div_mod. cbv [wrap].
      rewrite <-Z.testbit_spec' by lia.
      rewrite <-Z.add_opp_r.
      rewrite Z.add_nocarry_lxor; cycle 1.
      { destruct (Z.testbit z (width - 1)) eqn:Hw1; cbn [Z.b2z];
          rewrite ?Z.mul_1_r, ?Z.mul_0_r, ?Z.opp_0, ?Z.add_0_r, ?Z.land_0_r;
          [|solve[trivial]].
        eapply Z.bits_inj'; intros j ?Hj; autorewrite with z_bitwise; btauto. }
      autorewrite with z_bitwise;
      destruct (Z.testbit z (width - 1)) eqn:Hw1; cbn [Z.b2z];
        rewrite ?Z.mul_1_r, ?Z.mul_0_r, ?Z.opp_0, ?Z.add_0_r, ?Z.land_0_r;
        autorewrite with z_bitwise; cbn [Z.pred];
        destruct (Z.ltb_spec i (width-1)), (Z.ltb_spec i width); cbn; lia || btauto || trivial.
      { assert (i = width-1) by lia; congruence. }
      { destruct (Z.ltb_spec (width-1) width); lia || btauto. }
      { assert (i = width-1) by lia; congruence. }
    Qed.

    Lemma testbit_signed x i : Z.testbit (signed x) i
                               = if i <? width
                                 then Z.testbit (unsigned x) i
                                 else Z.testbit (unsigned x) (width -1).
    Proof.
      rewrite <-wrap_unsigned, signed_eq_swrap_unsigned.
      eapply testbit_swrap; assumption.
    Qed.

    Hint Rewrite testbit_signed testbit_wrap testbit_swrap
         using solve [auto with zarith] : z_bitwise.

    Ltac sbitwise :=
      eapply Z.bits_inj'; intros ?i ?Hi;
      autorewrite with word_laws z_bitwise;
      repeat match goal with |- context [?a <? ?b] =>
        destruct (Z.ltb_spec a b); trivial; try lia
      end.

    Lemma swrap_signed x : swrap (signed x) = signed x.
    Proof. rewrite signed_eq_swrap_unsigned. sbitwise. Qed.

    Lemma signed_or x y (H : Z.lt (unsigned y) width) : signed (or x y) = swrap (Z.lor (signed x) (signed y)).
    Proof. sbitwise. Qed.
    Lemma signed_and x y : signed (and x y) = swrap (Z.land (signed x) (signed y)).
    Proof. sbitwise. Qed.
    Lemma signed_xor x y : signed (xor x y) = swrap (Z.lxor (signed x) (signed y)).
    Proof. sbitwise. Qed.
    Lemma signed_not x : signed (not x) = swrap (Z.lnot (signed x)).
    Proof. sbitwise. Qed.
    Lemma signed_ndn x y : signed (ndn x y) = swrap (Z.ldiff (signed x) (signed y)).
    Proof. sbitwise. Qed.

    Lemma signed_or_nowrap x y (H : Z.lt (unsigned y) width) : signed (or x y) = Z.lor (signed x) (signed y).
    Proof. sbitwise. Qed.
    Lemma signed_and_nowrap x y : signed (and x y) = Z.land (signed x) (signed y).
    Proof. sbitwise. Qed.
    Lemma signed_xor_nowrap x y : signed (xor x y) = Z.lxor (signed x) (signed y).
    Proof. sbitwise. Qed.
    Lemma signed_not_nowrap x : signed (not x) = Z.lnot (signed x).
    Proof. sbitwise. Qed.
    Lemma signed_ndn_nowrap x y : signed (ndn x y) = Z.ldiff (signed x) (signed y).
    Proof. sbitwise. Qed.

    Lemma signed_srs_nowrap x y (H:unsigned y < width) : signed (srs x y) = Z.shiftr (signed x) (unsigned y).
    Proof.
      pose proof @unsigned_range _ _ word_ok ltac:(lia) y; sbitwise.
      replace (unsigned y) with 0 by lia; rewrite Z.add_0_r; trivial.
    Qed.

    Lemma signed_mulhss_nowrap x y : signed (mulhss x y) = Z.mul (signed x) (signed y) / 2^width.
    Proof. rewrite signed_mulhss. apply swrap_inrange. pose (signed_range x); pose (signed_range y). mia. Qed.
    Lemma signed_mulhsu_nowrap x y : signed (mulhsu x y) = Z.mul (signed x) (unsigned y) / 2^width.
    Proof. rewrite signed_mulhsu. apply swrap_inrange. pose (signed_range x); pose (@unsigned_range _ _ word_ok ltac:(lia) y). mia. Qed.
    Lemma signed_divs_nowrap x y (H:signed y <> 0) (H0:signed x <> -2^(width-1) \/ signed y <> -1) : signed (divs x y) = Z.quot (signed x) (signed y).
    Proof.
      rewrite signed_divs by assumption. apply swrap_inrange.
      rewrite Z.quot_div by assumption. pose proof (signed_range x).
      destruct (Z.sgn_spec (signed x)) as [[? X]|[[? X]|[? X]]];
      destruct (Z.sgn_spec (signed y)) as [[? Y]|[[? Y]|[? Y]]];
      rewrite ?X, ?Y; rewrite ?Z.abs_eq, ?Z.abs_neq by lia; mia.
    Qed.
    Lemma signed_mods_nowrap x y (H:signed y <> 0) : signed (mods x y) = Z.rem (signed x) (signed y).
    Proof.
      rewrite signed_mods by assumption. apply swrap_inrange.
      rewrite Z.rem_mod by assumption.
      pose (signed_range x); pose (signed_range y).
      destruct (Z.sgn_spec (signed x)) as [[? X]|[[? X]|[? X]]];
      destruct (Z.sgn_spec (signed y)) as [[? Y]|[[? Y]|[? Y]]];
      rewrite ?X, ?Y; repeat rewrite ?Z.abs_eq, ?Z.abs_neq by lia; mia.
    Qed.

    Lemma eq_signed x y (H : signed x = signed y) : x = y.
    Proof.
      eapply eq_unsigned, Z.bits_inj'; intros i Hi.
      eapply (f_equal (fun z => Z.testbit z i)) in H.
      rewrite 2testbit_signed in H. rewrite <-(wrap_unsigned x), <-(wrap_unsigned y).
      autorewrite with word_laws z_bitwise.
      destruct (Z.ltb_spec i width); auto.
    Qed.

    Lemma signed_eqb x y : eqb x y = Z.eqb (signed x) (signed y).
    Proof.
      rewrite unsigned_eqb.
      destruct (Z.eqb_spec (unsigned x) (unsigned y)) as [?e|?];
        destruct (Z.eqb_spec (  signed x) (  signed y)) as [?e|?];
        try (apply eq_unsigned in e || apply eq_signed in e); subst; (reflexivity || contradiction).
    Qed.
  End WithNontrivialWord.
End word.
