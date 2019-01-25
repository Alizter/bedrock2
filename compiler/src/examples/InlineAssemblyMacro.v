Require Import Coq.ZArith.ZArith.
Require Import riscv.util.Word.
Require Import riscv.util.BitWidths.
Require Import compiler.util.Common.
Require Import riscv.util.BitWidth32.
Require Import riscv.util.Monads.
Require Import coqutil.Map.SortedList.
Require Import compiler.util.List_Set.
Require Import compiler.FlatImp.
Require Import riscv.util.ListLib.
Require Import riscv.Decode.
Require Import riscv.Utility.
Require Import riscv.PseudoInstructions.
Require Import riscv.InstructionCoercions.
Require Import riscv.Program.
Require Import compiler.FlatToRiscvDef.
Require Import compiler.FlatToRiscv.
Require Import compiler.FlatToRiscv32Specifics.
Require Import riscv.RiscvMachine.
Require Import riscv.MinimalMMIO. (* not really *)
Require Import riscv.Words32Naive.
Require Import riscv.DefaultMemImpl32.
Require Import coqutil.Map.Empty_set_keyed_map.
Require Import coqutil.Map.Z_keyed_SortedListMap.
Import ListNotations.

Open Scope ilist_scope.

Definition var: Set := Z.
Definition func: Set := Empty_set.
Inductive act: Set := Select. (* only one action (= "external call" = inline assembly snippet) *)

Instance act_dec: DecidableEq act. left. destruct x; destruct y. reflexivity. Defined.

Instance myparams: Syntax.parameters := {|
  Syntax.varname := var;
  Syntax.funname := func;
  Syntax.actname := act;
|}.

Instance annoying: DecidableEq (list Syntax.varname * list Syntax.varname * stmt). Admitted.


Inductive ext_spec: act -> list Empty_set -> list word32 ->
                    (list Empty_set -> list word32 -> Prop) -> Prop :=
| ext_select: forall i selector args,
    i = word.unsigned (word.sru selector (word.of_Z 2)) ->
    0 <= i < Zlength args ->
    ext_spec Select nil (selector :: args)
             (fun t' results =>
                t' = nil /\
                exists garbageWord,
                  results = [Znth args i (word.of_Z 0); garbageWord]).

(*
Instance myFlatImpParams: FlatImp.parameters := {|
  FlatImp.bopname_params := myparams;
  FlatImp.ext_spec := ext_spec;
|}.
*)

Definition map_with_index{A B: Type}(f: A -> Z -> B)(l: list A): list B :=
  fst (List.fold_right (fun elem '(acc, i) => (f elem i :: acc, i-1)) (nil, Zlength l - 1) l).


(* later, we'll modify the compiler to receive the absolute position of the code
   as an argument, which would allow us to use JALR here and get rid of the helpervar *)
Definition compile_ext_call(results: list var)(a: act)(args: list var): list Instruction :=
  match a with
  | Select =>
    match results, args with
    | resvar :: helpervar :: nil, selectorvar :: argvars => [[
        Auipc helpervar 0;
        Add helpervar helpervar selectorvar;
        Jalr Register0 helpervar 8
      ]] ++ concat
        (map_with_index
           (fun argvar i => [[ Addi resvar argvar 0; J ((Zlength argvars - i) * 8 - 4) ]])
           argvars)
    | _, _ => [[ ]] (* invalid *)
    end
  end.


(*
def test(addr, inp1, inp2):
    s = *addr // might take a long time to load
    // precompute possible operations while waiting for s
    a = inp1 * inp2
    b = inp1 + inp2
    c = inp1 - inp2
    (r, garbage) = select(s, a, b, c)
    return r
 *)

Definition _addr: Syntax.varname := 1.
Definition _inp1: Syntax.varname := 2.
Definition _inp2: Syntax.varname := 3.
Definition _a: Syntax.varname := 4.
Definition _b: Syntax.varname := 5.
Definition _c: Syntax.varname := 6.
Definition _r: Syntax.varname := 7.
Definition _garbage: Syntax.varname := 31.
Definition _s: Syntax.varname := 9.

Definition test: stmt :=
  (SSeq (SLoad Syntax.access_size.four _s _addr)
  (SSeq (SOp _a Syntax.bopname.mul _inp1 _inp2)
  (SSeq (SOp _b Syntax.bopname.add _inp1 _inp2)
  (SSeq (SOp _c Syntax.bopname.sub _inp1 _inp2)
        (SInteract [_r; _garbage] Select [_s; _a; _b; _c]))))).

Local Set Refine Instance Mode.

Instance compilation_params: FlatToRiscvDef.parameters := {|
  FlatToRiscvDef.actname := act;
  FlatToRiscvDef.compile_load := TODO;
  FlatToRiscvDef.compile_store := TODO;
  FlatToRiscvDef.compile_ext_call := compile_ext_call;
  FlatToRiscvDef.max_ext_call_code_size _ := 100;
|}. intros. apply TODO. Defined.

Definition compiled: list Instruction := Eval cbv in compile_stmt test.

Print compiled.
