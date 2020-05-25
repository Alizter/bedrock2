(*tag:test*)
Require Import Coq.Lists.List.
Import ListNotations.
Require bedrock2Examples.Demos.
Require Import coqutil.Decidable.
Require Import compiler.ExprImp.
Require Import compiler.NameGen.
Require Import compiler.PipelineWithRename.
Require Import riscv.Spec.Decode.
Require Import riscv.Utility.Words32Naive.
Require Import riscv.Utility.DefaultMemImpl32.
Require Import riscv.Utility.Monads.
Require Import compiler.util.Common.
Require Import coqutil.Decidable.
Require        riscv.Utility.InstructionNotations.
Require Import riscv.Platform.MinimalLogging.
Require Import bedrock2.MetricLogging.
Require Import riscv.Platform.MetricMinimal.
Require Import riscv.Utility.Utility.
Require Import riscv.Utility.Encode.
Require Import coqutil.Map.SortedList.
Require Import compiler.StringNameGen.
Require Import riscv.Utility.InstructionCoercions.
Require Import riscv.Platform.MetricRiscvMachine.
Require bedrock2.Hexdump.
Require Import bedrock2Examples.swap.

Open Scope Z_scope.
Open Scope string_scope.
Open Scope ilist_scope.

Definition var: Set := Z.
Definition Reg: Set := Z.


Existing Instance DefaultRiscvState.

Axiom TODO: forall {T: Type}, T.

Instance flatToRiscvDef_params: FlatToRiscvDef.FlatToRiscvDef.parameters := {
  funname_env T := TODO;
  FlatToRiscvDef.FlatToRiscvDef.compile_ext_call _ _ s :=
    match s with
    | FlatImp.SInteract _ fname _ =>
      if string_dec fname "nop" then
        [[Addi Register0 Register0 0]]
      else
        nil
    | _ => []
    end;
}.

Notation RiscvMachine := MetricRiscvMachine.

Existing Instance coqutil.Map.SortedListString.map.
Existing Instance coqutil.Map.SortedListString.ok.

Instance pipeline_params : Pipeline.parameters. simple refine {|
  Pipeline.string_keyed_map := _;
  Pipeline.Registers := _;
  Pipeline.ext_spec _ _ := TODO;
  Pipeline.PRParams := TODO;
|}; unshelve (try exact _); apply TODO. Defined.

Instance pipeline_assumptions: @Pipeline.assumptions pipeline_params. Admitted.

Definition allFuns: list swap.bedrock_func := [swap; swap_swap; main].

Definition e := map.putmany_of_list allFuns map.empty.

(* stack grows from high addreses to low addresses, first stack word will be written to
   (stack_pastend-8), next stack word to (stack_pastend-16) etc *)
Definition stack_pastend: Z := 2048.

Definition ml: MemoryLayout := {|
  MemoryLayout.code_start    := word.of_Z 0;
  MemoryLayout.code_pastend  := word.of_Z (4*2^10);
  MemoryLayout.heap_start    := word.of_Z (4*2^10);
  MemoryLayout.heap_pastend  := word.of_Z (8*2^10);
  MemoryLayout.stack_start   := word.of_Z (8*2^10);
  MemoryLayout.stack_pastend := word.of_Z (16*2^10);
|}.

Lemma f_equal2: forall {A B: Type} {f1 f2: A -> B} {a1 a2: A},
    f1 = f2 -> a1 = a2 -> f1 a1 = f2 a2.
Proof. intros. congruence. Qed.

Lemma f_equal3: forall {A B C: Type} {f1 f2: A -> B -> C} {a1 a2: A} {b1 b2: B},
    f1 = f2 -> a1 = a2 -> b1 = b2 -> f1 a1 b1 = f2 a2 b2.
Proof. intros. congruence. Qed.

Lemma f_equal3_dep: forall {A B C: Type} {f1 f2: A -> B -> C} {a1 a2: A} {b1 b2: B},
    f1 = f2 -> a1 = a2 -> b1 = b2 -> f1 a1 b1 = f2 a2 b2.
Proof. intros. congruence. Qed.

Definition swap_asm: list Instruction.
  let r := eval cbv in (compile ml e) in set (res := r).
  match goal with
  | res := Some (?x, _) |- _ => exact x
  end.
Defined.

Module PrintAssembly.
  Import riscv.Utility.InstructionNotations.
  Goal True. let r := eval unfold swap_asm in swap_asm in idtac (* r *). Abort.
  (* Annotated (was 64bit, now we print for 32bit):

  set_sp:
     lui     x2, -4096
     xori    x2, x2, -2048

  main:
     addi    x3, x0, 100   // load literals
     addi    x4, x0, 108
     sd      x2, x3, -16   // push args on stack
     sd      x2, x4, -8
     jal     x1, 64        // call swap_swap

  swap:
     addi    x2, x2, -40   // decrease sp
     sd      x2, x1, 16    // save ra
     sd      x2, x5, 0     // save registers modified by swap
     sd      x2, x6, 8
     ld      x3, x2, 24    // load args
     ld      x4, x2, 32    // body of swap
     ld      x5, x4, 0
     ld      x6, x3, 0
     sd      x4, x6, 0
     sd      x3, x5, 0
     ld      x5, x2, 0     // restore modified registers
     ld      x6, x2, 8
     ld      x1, x2, 16    // load ra
     addi    x2, x2, 40    // increase sp
     jalr    x0, x1, 0     // return

  swap_swap:
     addi    x2, x2, -24   // decrease sp
     sd      x2, x1, 0     // save ra
     ld      x3, x2, 8     // load args from stack
     ld      x4, x2, 16
     sd      x2, x3, -16
     sd      x2, x4, -8
     jal     x1, -84       // first call to swap
     sd      x2, x3, -16   // previous call had no ret vals to be loaded. push args onto stack
     sd      x2, x4, -8
     jal     x1, -96       // second call to swap
     ld      x1, x2, 0     // load ra
     addi    x2, x2, 24    // increase sp
     jalr    x0, x1, 0     // return

  *)
End PrintAssembly.

Definition swap_as_bytes: list Byte.byte := instrencode swap_asm.

Module PrintBytes.
  Import bedrock2.Hexdump.
  Local Open Scope hexdump_scope.
  Set Printing Width 100.
  Goal True. let x := eval cbv in swap_as_bytes in idtac (* x *). Abort.
End PrintBytes.
