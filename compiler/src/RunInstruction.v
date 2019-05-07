Require Import Coq.ZArith.BinInt.
Require Import coqutil.Z.Lia.
Require Import coqutil.Z.Lia.
Require Import Coq.Lists.List. Import ListNotations.
Require Import coqutil.Map.Interface coqutil.Map.Properties.
Require Import coqutil.Word.Interface coqutil.Word.Properties.
Require Import riscv.Utility.Monads.
Require Import riscv.Utility.Utility.
Require Import riscv.Spec.Decode.
Require Import riscv.Platform.Memory.
Require Import riscv.Spec.Machine.
Require Import riscv.Platform.RiscvMachine.
Require Import riscv.Platform.MetricRiscvMachine.
Require Import riscv.Spec.Primitives.
Require Import riscv.Spec.MetricPrimitives.
Require Import riscv.Platform.Run.
Require Import riscv.Spec.Execute.
Require Import riscv.Proofs.DecodeEncode.
Require Import coqutil.Tactics.Tactics.
Require Import compiler.SeparationLogic.
Require Import compiler.EmitsValid.
Require Import bedrock2.ptsto_bytes.
Require Import bedrock2.Scalars.
Require Import riscv.Utility.Encode.
Require Import riscv.Proofs.EncodeBound.
Require Import coqutil.Decidable.
Require Import compiler.GoFlatToRiscv.
Require Import riscv.Utility.InstructionCoercions. Local Open Scope ilist_scope.
Require Import compiler.SimplWordExpr.
Require Import compiler.DivisibleBy4.
Require Import compiler.ZLemmas.


Section Run.

  Context {W: Words}.
  Context {Registers: map.map Register word}.
  Context {mem: map.map word byte}.
  Context {mem_ok: map.ok mem}.

  Local Notation RiscvMachineL := MetricRiscvMachine.

  Context {M: Type -> Type}.
  Context {MM: Monad M}.
  Context {RVM: RiscvProgram M word}.
  Context {PRParams: PrimitivesParams M MetricRiscvMachine}.
  Context {PR: MetricPrimitives PRParams}.

  Ltac simulate'_step :=
    first [ eapply go_loadByte_sep ; simpl; [sidecondition..|]
          | eapply go_storeByte_sep; simpl; [sidecondition..|intros]
          | eapply go_loadHalf_sep ; simpl; [sidecondition..|]
          | eapply go_storeHalf_sep; simpl; [sidecondition..|intros]
          | eapply go_loadWord_sep ; simpl; [sidecondition..|]
          | eapply go_storeWord_sep; simpl; [sidecondition..|intros]
          | eapply go_loadDouble_sep ; simpl; [sidecondition..|]
          | eapply go_storeDouble_sep; simpl; [sidecondition..|intros]
          | simpl_modu4_0
          | simulate_step ].

  Ltac simulate' := repeat simulate'_step.

  Definition run_Jalr0_spec :=
    forall (rs1: Register) (oimm12: MachineInt) (initialL: RiscvMachineL) (R: mem -> Prop)
           (dest: word),
      (* [verify] (and decode-encode-id) only enforces divisibility by 2 because there could be
         compressed instructions, but we don't support them so we require divisibility by 4: *)
      oimm12 mod 4 = 0 ->
      (word.unsigned dest) mod 4 = 0 ->
      (* valid_register almost follows from verify (or decode-encode-id) except for when
         the register is Register0 *)
      valid_register rs1 ->
      map.get initialL.(getRegs) rs1 = Some dest ->
      initialL.(getNextPc) = word.add initialL.(getPc) (word.of_Z 4) ->
      (program initialL.(getXAddrs) initialL.(getPc) [[Jalr RegisterNames.zero rs1 oimm12]] * R)
        %sep initialL.(getMem) ->
      mcomp_sat (run1 iset) initialL (fun finalL =>
        finalL.(getRegs) = initialL.(getRegs) /\
        finalL.(getLog) = initialL.(getLog) /\
        (program initialL.(getXAddrs) initialL.(getPc) [[Jalr RegisterNames.zero rs1 oimm12]] * R)
          %sep finalL.(getMem) /\
        finalL.(getXAddrs) = initialL.(getXAddrs) /\
        finalL.(getPc) = word.add dest (word.of_Z oimm12) /\
        finalL.(getNextPc) = word.add finalL.(getPc) (word.of_Z 4)).

  Definition run_Jal_spec :=
    forall (rd: Register) (jimm20: MachineInt) (initialL: RiscvMachineL) (R: mem -> Prop),
      jimm20 mod 4 = 0 ->
      valid_register rd ->
      initialL.(getNextPc) = word.add initialL.(getPc) (word.of_Z 4) ->
      (program initialL.(getXAddrs) initialL.(getPc) [[Jal rd jimm20]] * R)
        %sep initialL.(getMem) ->
      mcomp_sat (run1 iset) initialL (fun finalL =>
        finalL.(getRegs) = map.put initialL.(getRegs) rd initialL.(getNextPc) /\
        finalL.(getLog) = initialL.(getLog) /\
        (program initialL.(getXAddrs) initialL.(getPc) [[Jal rd jimm20]] * R)
          %sep finalL.(getMem) /\
        finalL.(getXAddrs) = initialL.(getXAddrs) /\
        finalL.(getPc) = word.add initialL.(getPc) (word.of_Z jimm20) /\
        finalL.(getNextPc) = word.add finalL.(getPc) (word.of_Z 4)).

  (* TOOD in the specs below we could remove divisibleBy4 and bounds because that's
     enforced by program *)

  Definition run_Jal0_spec :=
    forall (jimm20: MachineInt) (initialL: RiscvMachineL) (R: mem -> Prop),
      - 2^20 <= jimm20 < 2^20 ->
      jimm20 mod 4 = 0 ->
      divisibleBy4 initialL.(getPc) ->
      (program initialL.(getXAddrs) initialL.(getPc) [[Jal Register0 jimm20]] * R)
        %sep initialL.(getMem) ->
      mcomp_sat (run1 iset) initialL (fun finalL =>
        finalL.(getRegs) = initialL.(getRegs) /\
        finalL.(getLog) = initialL.(getLog) /\
        (* it would be nicer and more uniform wrt to memory-modifying instructions
           if we had this separation logic formula here instead of memory equality,
           but that doesn't work with the abstract goodReadyState predicate in EventLoop.v
        (program initialL.(getPc) [[Jal Register0 jimm20]] * R)%sep finalL.(getMem) /\ *)
        finalL.(getMem) = initialL.(getMem) /\
        finalL.(getXAddrs) = initialL.(getXAddrs) /\
        finalL.(getPc) = word.add initialL.(getPc) (word.of_Z jimm20) /\
        finalL.(getNextPc) = word.add finalL.(getPc) (word.of_Z 4)).

  Definition run_ImmReg_spec(Op: Register -> Register -> MachineInt -> Instruction)
                            (f: word -> word -> word): Prop :=
    forall (rd rs: Register) rs_val (imm: MachineInt) (initialL: RiscvMachineL) (R: mem -> Prop),
      verify (Op rd rs imm) iset ->
      (* valid_register almost follows from verify except for when the register is Register0 *)
      valid_register rd ->
      valid_register rs ->
      divisibleBy4 initialL.(getPc) ->
      initialL.(getNextPc) = word.add initialL.(getPc) (word.of_Z 4) ->
      map.get initialL.(getRegs) rs = Some rs_val ->
      (program initialL.(getXAddrs) initialL.(getPc) [[Op rd rs imm]] * R)%sep initialL.(getMem) ->
      mcomp_sat (run1 iset) initialL (fun finalL =>
        finalL.(getRegs) = map.put initialL.(getRegs) rd (f rs_val (word.of_Z imm)) /\
        finalL.(getLog) = initialL.(getLog) /\
        (program initialL.(getXAddrs) initialL.(getPc) [[Op rd rs imm]] * R)%sep finalL.(getMem) /\
        finalL.(getXAddrs) = initialL.(getXAddrs) /\
        finalL.(getPc) = initialL.(getNextPc) /\
        finalL.(getNextPc) = word.add finalL.(getPc) (word.of_Z 4)).

  Definition run_Load_spec(n: nat)(L: Register -> Register -> MachineInt -> Instruction)
             (opt_sign_extender: Z -> Z): Prop :=
    forall (base addr: word) (v: HList.tuple byte n) (rd rs: Register) (ofs: MachineInt)
           (initialL: RiscvMachineL) (R: mem -> Prop),
      verify (L rd rs ofs) iset ->
      (* valid_register almost follows from verify except for when the register is Register0 *)
      valid_register rd ->
      valid_register rs ->
      divisibleBy4 initialL.(getPc) ->
      initialL.(getNextPc) = word.add initialL.(getPc) (word.of_Z 4) ->
      map.get initialL.(getRegs) rs = Some base ->
      addr = word.add base (word.of_Z ofs) ->
      (program initialL.(getXAddrs) initialL.(getPc) [[L rd rs ofs]] * ptsto_bytes n addr v * R)
        %sep initialL.(getMem) ->
      mcomp_sat (run1 iset) initialL (fun finalL =>
        finalL.(getRegs) = map.put initialL.(getRegs) rd
                  (word.of_Z (opt_sign_extender (LittleEndian.combine n v))) /\
        finalL.(getLog) = initialL.(getLog) /\
        (program initialL.(getXAddrs)initialL.(getPc) [[L rd rs ofs]] * ptsto_bytes n addr v * R)
          %sep finalL.(getMem) /\
        finalL.(getXAddrs) = initialL.(getXAddrs) /\
        finalL.(getPc) = initialL.(getNextPc) /\
        finalL.(getNextPc) = word.add finalL.(getPc) (word.of_Z 4)).

  Definition run_Store_spec(n: nat)(S: Register -> Register -> MachineInt -> Instruction): Prop :=
    forall (base addr v_new: word) (v_old: HList.tuple byte n) (rs1 rs2: Register)
           (ofs: MachineInt) (initialL: RiscvMachineL) (R: mem -> Prop),
      verify (S rs1 rs2 ofs) iset ->
      (* valid_register almost follows from verify except for when the register is Register0 *)
      valid_register rs1 ->
      valid_register rs2 ->
      divisibleBy4 initialL.(getPc) ->
      initialL.(getNextPc) = word.add initialL.(getPc) (word.of_Z 4) ->
      map.get initialL.(getRegs) rs1 = Some base ->
      map.get initialL.(getRegs) rs2 = Some v_new ->
      addr = word.add base (word.of_Z ofs) ->
      (program initialL.(getXAddrs) initialL.(getPc) [[S rs1 rs2 ofs]] *
       ptsto_bytes n addr v_old * R)%sep initialL.(getMem) ->
      mcomp_sat (run1 iset) initialL (fun finalL =>
        finalL.(getRegs) = initialL.(getRegs) /\
        finalL.(getLog) = initialL.(getLog) /\
        (program finalL.(getXAddrs) initialL.(getPc) [[S rs1 rs2 ofs]] *
         ptsto_bytes n addr (LittleEndian.split n (word.unsigned v_new)) * R)%sep
            finalL.(getMem) /\
        finalL.(getXAddrs) = invalidateWrittenXAddrs n addr initialL.(getXAddrs) /\
        finalL.(getPc) = initialL.(getNextPc) /\
        finalL.(getNextPc) = word.add finalL.(getPc) (word.of_Z 4)).

  Ltac t :=
    repeat intro;
    match goal with
    | initialL: RiscvMachineL |- _ => destruct_RiscvMachine initialL
    end;
    simpl in *; subst;
    simulate';
    simpl;
    repeat match goal with
           | |- _ /\ _ => split
           | |- _ => solve [auto]
           | |- _ => ecancel_assumption
           end.

  Axiom decode_encode_to_verify: forall {instr},
      decode iset (encode instr) = instr -> verify instr iset.

  Lemma run_Jalr0: run_Jalr0_spec.
  Proof.
    repeat intro.
    destruct (invert_ptsto_program1 H4) as (DE & ? & ?).
    pose proof (decode_encode_to_verify DE).
    (* execution of Jalr clears lowest bit *)
    assert (word.and (word.add dest (word.of_Z oimm12))
                     (word.xor (word.of_Z 1) (word.of_Z (2 ^ width - 1))) =
            word.add dest (word.of_Z oimm12)) as A. {
      assert (word.unsigned (word.add dest (word.of_Z oimm12)) mod 4 = 0) as C by
            solve_divisibleBy4.
      generalize dependent (word.add dest (word.of_Z oimm12)). clear.
      intros.
      apply word.unsigned_inj.
      rewrite word.unsigned_and, word.unsigned_xor, !word.unsigned_of_Z. unfold word.wrap.
      assert (0 <= width) by (destruct width_cases as [E | E]; rewrite E; bomega).
      replace (2 ^ width - 1) with (Z.ones width); cycle 1. {
        rewrite Z.ones_equiv. reflexivity.
      }
      change 1 with (Z.ones 1).
      transitivity (word.unsigned r mod (2 ^ width)); cycle 1. {
        rewrite word.wrap_unsigned. reflexivity.
      }
      rewrite <-! Z.land_ones by assumption.
      change 4 with (2 ^ 2) in C.
      prove_Zeq_bitwise.Zbitwise.
    }
    assert (word.unsigned
              (word.and (word.add dest (word.of_Z oimm12))
                        (word.xor (word.of_Z 1) (word.of_Z (2 ^ width - 1)))) mod 4 = 0) as B. {
      rewrite A. solve_divisibleBy4.
    }
    t.
  Qed.

  Lemma run_Jal: run_Jal_spec.
  Proof.
    repeat intro.
    destruct (invert_ptsto_program1 H2) as (DE & ? & ?).
    t.
  Qed.

  Arguments Z.pow: simpl never.
  Arguments Z.opp: simpl never.

  Lemma run_Jal0: run_Jal0_spec.
  Proof. t. Qed.

  Lemma run_Addi: run_ImmReg_spec Addi word.add.
  Proof. t. Qed.

  Lemma run_Lb: run_Load_spec 1 Lb (signExtend 8).
  Proof. t. Qed.

  Lemma run_Lbu: run_Load_spec 1 Lbu id.
  Proof. t. Qed.

  Lemma run_Lh: run_Load_spec 2 Lh (signExtend 16).
  Proof. t. Qed.

  Lemma run_Lhu: run_Load_spec 2 Lhu id.
  Proof. t. Qed.

  Lemma run_Lw: run_Load_spec 4 Lw (signExtend 32).
  Proof. t. Qed.

  Lemma run_Lw_unsigned: width = 32 -> run_Load_spec 4 Lw id.
  Proof.
    t. rewrite sextend_width_nop; [reflexivity|symmetry;assumption].
  Qed.

  Lemma run_Lwu: run_Load_spec 4 Lwu id.
  Proof. t. Qed.

  Lemma run_Ld: run_Load_spec 8 Ld (signExtend 64).
  Proof. t. Qed.

  (* Note: there's no Ldu instruction, because Ld does the same *)
  Lemma run_Ld_unsigned: run_Load_spec 8 Ld id.
  Proof.
    t. rewrite sextend_width_nop; [reflexivity|]. unfold iset in *.
    clear -H. destruct H as [_ H]. unfold verify_iset in *.
    destruct width_cases as [E | E]; rewrite E in *; simpl in *; intuition congruence.
  Qed.

  Lemma iff1_emp: forall P Q,
      (P <-> Q) ->
      iff1 (emp P) (emp Q).
  Proof. unfold iff1, emp. clear. firstorder idtac. Qed.

  Lemma removeXAddr_diff: forall a1 a2 xaddrs,
      a1 <> a2 ->
      isXAddr a1 xaddrs ->
      isXAddr a1 (removeXAddr a2 xaddrs).
  Proof.
    unfold isXAddr, removeXAddr.
    intros.
    apply filter_In.
    split; [assumption|].
    rewrite word.eqb_ne by congruence.
    reflexivity.
  Qed.

  Lemma removeXAddr_bw: forall a1 a2 xaddrs,
      isXAddr a1 (removeXAddr a2 xaddrs) ->
      isXAddr a1 xaddrs.
  Proof.
    unfold isXAddr, removeXAddr.
    intros.
    eapply filter_In.
    eassumption.
  Qed.

  Lemma sep_ptsto_to_addr_neq: forall a1 v1 a2 v2 m R,
      (ptsto a1 v1 * ptsto a2 v2 * R)%sep m ->
      a1 <> a2.
  Proof.
    intros. intro E. subst a2. unfold ptsto in *.
    destruct H as (? & ? & ? & (? & ? & ? & ? & ?) & ?).
    subst.
    destruct H0 as [? D].
    unfold map.disjoint in D.
    eapply D; apply map.get_put_same.
  Qed.

  Lemma mod4_cases: forall x,
      x mod 4 = 0 \/ x mod 4 = 1 \/ x mod 4 = 2 \/ x mod 4 = 3.
  Abort.

  Lemma clear_lowest_two_bits_cases: forall a,
      clear_lowest_two_bits a = a \/
      clear_lowest_two_bits a = word.sub a (word.of_Z 1) \/
      clear_lowest_two_bits a = word.sub a (word.of_Z 2) \/
      clear_lowest_two_bits a = word.sub a (word.of_Z 3).
  Proof.
    intros. unfold clear_lowest_two_bits.
  Admitted.

  Add Ring wring : (word.ring_theory (word := word))
      (preprocess [autorewrite with rew_word_morphism],
       morphism (word.ring_morph (word := word)),
       constants [word_cst]).

  Lemma ptsto_instr_removeXAddr_disjoint: forall xaddrs addr pc instr v,
   iff1 (ptsto_instr xaddrs                                            pc instr * ptsto addr v)
        (ptsto_instr (removeXAddr (clear_lowest_two_bits addr) xaddrs) pc instr * ptsto addr v).
  Proof.
    intros. unfold ptsto_instr. intro m. split; intro A.
    - destruct (invert_ptsto_instr A) as (DE & D & IXA).
      assert (
          addr <> pc /\
          addr <> word.add pc (word.of_Z 1) /\
          addr <> word.add (word.add pc (word.of_Z 1)) (word.of_Z 1) /\
          addr <> word.add (word.add (word.add pc (word.of_Z 1)) (word.of_Z 1)) (word.of_Z 1)). {
        unfold truncated_scalar, littleendian, ptsto_bytes in A. simpl in A.
        repeat split; eapply sep_ptsto_to_addr_neq; ecancel_assumption.
      }
      use_sep_assumption.
      cancel.
      apply iff1_emp.
      split; intros; [|assumption].
      apply removeXAddr_diff; try assumption.
      intro C.
      subst pc.
      destruct H as (B0 & B1 & B2 & B3).
      destruct (clear_lowest_two_bits_cases addr) as [E | [E | [E | E] ] ];
        rewrite E in *.
      + apply B0. reflexivity.
      + apply B1. solve_word_eq word_ok.
      + apply B2. solve_word_eq word_ok.
      + apply B3. solve_word_eq word_ok.
    - destruct (invert_ptsto_instr A) as (DE & D & IXA).
      use_sep_assumption.
      cancel.
      apply iff1_emp.
      split; intros; [|assumption].
      eapply removeXAddr_bw; try eassumption.
  Qed.

  Lemma ptsto_instr_invalidate_disjoint: forall pc instr n xaddrs addr v,
      iff1 (ptsto_instr xaddrs                                  pc instr * ptsto_bytes n addr v)
           (ptsto_instr (invalidateWrittenXAddrs n addr xaddrs) pc instr * ptsto_bytes n addr v).
  Proof.
    induction n; intros.
    - simpl. reflexivity.
    - destruct v as [v vs]. unfold ptsto_bytes in *. simpl in *.
      specialize (IHn xaddrs (word.add addr (word.of_Z 1)) vs).
      match goal with
      | |- iff1 (?A * (?B * ?C))%sep _ => transitivity ((A * C) * B)%sep; [cancel|]
      end.
      rewrite IHn. clear IHn.
      reify_goal.
      cancel_seps_at_indices 1%nat 2%nat; [reflexivity|].
      remember (invalidateWrittenXAddrs n (word.add addr (word.of_Z 1)) xaddrs) as xaddrs'.
      simpl.
      apply ptsto_instr_removeXAddr_disjoint.
  Qed.

  Arguments invalidateWrittenXAddrs: simpl never.

  Lemma run_Sb: run_Store_spec 1 Sb.
  Proof.
    t.
    use_sep_assumption.
    reify_goal.
    cancel_seps_at_indices 2%nat 3%nat; [reflexivity|].
    cancel_emp_r.
    simpl.
    rewrite sep_comm.
    apply ptsto_instr_invalidate_disjoint.
  Qed.

  Lemma run_Sh: run_Store_spec 2 Sh.
  Proof.
    t.
    use_sep_assumption.
    reify_goal.
    cancel_seps_at_indices 2%nat 3%nat; [reflexivity|].
    cancel_emp_r.
    simpl.
    rewrite sep_comm.
    apply ptsto_instr_invalidate_disjoint.
  Qed.

  Lemma run_Sw: run_Store_spec 4 Sw.
  Proof.
    t.
    use_sep_assumption.
    reify_goal.
    cancel_seps_at_indices 2%nat 3%nat; [reflexivity|].
    cancel_emp_r.
    simpl.
    rewrite sep_comm.
    apply ptsto_instr_invalidate_disjoint.
  Qed.

  Lemma run_Sd: run_Store_spec 8 Sd.
  Proof.
    t.
    use_sep_assumption.
    reify_goal.
    cancel_seps_at_indices 2%nat 3%nat; [reflexivity|].
    cancel_emp_r.
    simpl.
    rewrite sep_comm.
    apply ptsto_instr_invalidate_disjoint.
  Qed.

End Run.
