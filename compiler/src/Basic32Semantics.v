Require Import Coq.ZArith.ZArith.
Require Import bedrock2.Syntax bedrock2.Semantics.
Require Import coqutil.Map.SortedList.
Require Import bedrock2.ZNamesSyntax.
Require Import riscv.Words32Naive.
Require Import riscv.DefaultMemImpl32.
Require Import coqutil.Map.Empty_set_keyed_map.
Require Import coqutil.Map.Z_keyed_SortedListMap.


Definition TODO{T: Type}: T. Admitted.

Instance Basic32Syntax: bedrock2.Syntax.parameters := {|
  Syntax.varname := Z;
  Syntax.funname := Empty_set;
  Syntax.actname := Empty_set;
|}.

Instance Basic32Semantics: bedrock2.Semantics.parameters. unshelve refine {|
  Semantics.syntax := Basic32Syntax;
  Semantics.width := 32;
  Semantics.word := word32;
  Semantics.byte := word8;
  Semantics.locals := _;
  Semantics.env := Empty_set_keyed_map _;
  Semantics.mem := Mem;
|}.
Proof.
  all: apply TODO.
Defined.
