Require Import Coq.ZArith.BinInt Coq.Lists.List.
Require Coq.Init.Byte Coq.Strings.Byte Coq.Strings.String.

Declare Scope bytedump_scope.
(* Usage: see etc/bytedump.sh and its invocation in bedrock2/Makefile *)

#[deprecated(note="Use Coq.Strings.String.list_byte_of_string")]
Notation byte_list_of_string := String.list_byte_of_string (only parsing).

(* Use a different scope for byte lists and bytes, otherwise nil and
   Byte.x20 have to share the same printing rule. *)
Declare Scope bytedumpchar_scope.
Delimit Scope bytedumpchar_scope with bytedumpchar.
Delimit Scope bytedump_scope with bytedump.
Notation "a b" :=
  (@cons Byte.byte a%bytedumpchar b%bytedump)
  (only printing, right associativity, at level 3, format "a b")
  : bytedump_scope.
Notation "" := (@nil _) (only printing, format "") : bytedump_scope.
Undelimit Scope bytedumpchar_scope.
Undelimit Scope bytedump_scope.

Notation "' '" := (Byte.x00) (only printing) : bytedumpchar_scope.
Notation "''" := (Byte.x01) (only printing) : bytedumpchar_scope.
Notation "''" := (Byte.x02) (only printing) : bytedumpchar_scope.
Notation "''" := (Byte.x03) (only printing) : bytedumpchar_scope.
Notation "''" := (Byte.x04) (only printing) : bytedumpchar_scope.
Notation "''" := (Byte.x05) (only printing) : bytedumpchar_scope.
Notation "''" := (Byte.x06) (only printing) : bytedumpchar_scope.
Notation "''" := (Byte.x07) (only printing) : bytedumpchar_scope.
Notation "''" := (Byte.x08) (only printing) : bytedumpchar_scope.
Notation "'	'" := (Byte.x09) (only printing) : bytedumpchar_scope.
Notation "'
'" := (Byte.x0a) (only printing) : bytedumpchar_scope.
Notation "''" := (Byte.x0b) (only printing) : bytedumpchar_scope.
Notation "''" := (Byte.x0c) (only printing) : bytedumpchar_scope.
Notation "''" := (Byte.x0d) (only printing) : bytedumpchar_scope.
Notation "''" := (Byte.x0e) (only printing) : bytedumpchar_scope.
Notation "''" := (Byte.x0f) (only printing) : bytedumpchar_scope.
Notation "''" := (Byte.x10) (only printing) : bytedumpchar_scope.
Notation "''" := (Byte.x11) (only printing) : bytedumpchar_scope.
Notation "''" := (Byte.x12) (only printing) : bytedumpchar_scope.
Notation "''" := (Byte.x13) (only printing) : bytedumpchar_scope.
Notation "''" := (Byte.x14) (only printing) : bytedumpchar_scope.
Notation "''" := (Byte.x15) (only printing) : bytedumpchar_scope.
Notation "''" := (Byte.x16) (only printing) : bytedumpchar_scope.
Notation "''" := (Byte.x17) (only printing) : bytedumpchar_scope.
Notation "''" := (Byte.x18) (only printing) : bytedumpchar_scope.
Notation "''" := (Byte.x19) (only printing) : bytedumpchar_scope.
Notation "''" := (Byte.x1a) (only printing) : bytedumpchar_scope.
Notation "''" := (Byte.x1b) (only printing) : bytedumpchar_scope.
Notation "''" := (Byte.x1c) (only printing) : bytedumpchar_scope.
Notation "''" := (Byte.x1d) (only printing) : bytedumpchar_scope.
Notation "''" := (Byte.x1e) (only printing) : bytedumpchar_scope.
Notation "''" := (Byte.x1f) (only printing) : bytedumpchar_scope.
Notation " " := (Byte.x20) (only printing, format " ") : bytedumpchar_scope.
Notation "'!'" := (Byte.x21) (only printing) : bytedumpchar_scope.
Notation "'""'" := (Byte.x22) (only printing) : bytedumpchar_scope.
Notation "'#'" := (Byte.x23) (only printing) : bytedumpchar_scope.
Notation "'$'" := (Byte.x24) (only printing) : bytedumpchar_scope.
Notation "'%'" := (Byte.x25) (only printing) : bytedumpchar_scope.
Notation "'&'" := (Byte.x26) (only printing) : bytedumpchar_scope.
Notation "'''" := (Byte.x27) (only printing) : bytedumpchar_scope.
Notation "'('" := (Byte.x28) (only printing) : bytedumpchar_scope.
Notation "')'" := (Byte.x29) (only printing) : bytedumpchar_scope.
Notation "'*'" := (Byte.x2a) (only printing) : bytedumpchar_scope.
Notation "'+'" := (Byte.x2b) (only printing) : bytedumpchar_scope.
Notation "','" := (Byte.x2c) (only printing) : bytedumpchar_scope.
Notation "'-'" := (Byte.x2d) (only printing) : bytedumpchar_scope.
Notation "'.'" := (Byte.x2e) (only printing) : bytedumpchar_scope.
Notation "'/'" := (Byte.x2f) (only printing) : bytedumpchar_scope.
Notation "'0'" := (Byte.x30) (only printing) : bytedumpchar_scope.
Notation "'1'" := (Byte.x31) (only printing) : bytedumpchar_scope.
Notation "'2'" := (Byte.x32) (only printing) : bytedumpchar_scope.
Notation "'3'" := (Byte.x33) (only printing) : bytedumpchar_scope.
Notation "'4'" := (Byte.x34) (only printing) : bytedumpchar_scope.
Notation "'5'" := (Byte.x35) (only printing) : bytedumpchar_scope.
Notation "'6'" := (Byte.x36) (only printing) : bytedumpchar_scope.
Notation "'7'" := (Byte.x37) (only printing) : bytedumpchar_scope.
Notation "'8'" := (Byte.x38) (only printing) : bytedumpchar_scope.
Notation "'9'" := (Byte.x39) (only printing) : bytedumpchar_scope.
Notation "':'" := (Byte.x3a) (only printing) : bytedumpchar_scope.
Notation "';'" := (Byte.x3b) (only printing) : bytedumpchar_scope.
Notation "'<'" := (Byte.x3c) (only printing) : bytedumpchar_scope.
Notation "'='" := (Byte.x3d) (only printing) : bytedumpchar_scope.
Notation "'>'" := (Byte.x3e) (only printing) : bytedumpchar_scope.
Notation "'?'" := (Byte.x3f) (only printing) : bytedumpchar_scope.
Notation "'@'" := (Byte.x40) (only printing) : bytedumpchar_scope.
Notation "'A'" := (Byte.x41) (only printing) : bytedumpchar_scope.
Notation "'B'" := (Byte.x42) (only printing) : bytedumpchar_scope.
Notation "'C'" := (Byte.x43) (only printing) : bytedumpchar_scope.
Notation "'D'" := (Byte.x44) (only printing) : bytedumpchar_scope.
Notation "'E'" := (Byte.x45) (only printing) : bytedumpchar_scope.
Notation "'F'" := (Byte.x46) (only printing) : bytedumpchar_scope.
Notation "'G'" := (Byte.x47) (only printing) : bytedumpchar_scope.
Notation "'H'" := (Byte.x48) (only printing) : bytedumpchar_scope.
Notation "'I'" := (Byte.x49) (only printing) : bytedumpchar_scope.
Notation "'J'" := (Byte.x4a) (only printing) : bytedumpchar_scope.
Notation "'K'" := (Byte.x4b) (only printing) : bytedumpchar_scope.
Notation "'L'" := (Byte.x4c) (only printing) : bytedumpchar_scope.
Notation "'M'" := (Byte.x4d) (only printing) : bytedumpchar_scope.
Notation "'N'" := (Byte.x4e) (only printing) : bytedumpchar_scope.
Notation "'O'" := (Byte.x4f) (only printing) : bytedumpchar_scope.
Notation "'P'" := (Byte.x50) (only printing) : bytedumpchar_scope.
Notation "'Q'" := (Byte.x51) (only printing) : bytedumpchar_scope.
Notation "'R'" := (Byte.x52) (only printing) : bytedumpchar_scope.
Notation "'S'" := (Byte.x53) (only printing) : bytedumpchar_scope.
Notation "'T'" := (Byte.x54) (only printing) : bytedumpchar_scope.
Notation "'U'" := (Byte.x55) (only printing) : bytedumpchar_scope.
Notation "'V'" := (Byte.x56) (only printing) : bytedumpchar_scope.
Notation "'W'" := (Byte.x57) (only printing) : bytedumpchar_scope.
Notation "'X'" := (Byte.x58) (only printing) : bytedumpchar_scope.
Notation "'Y'" := (Byte.x59) (only printing) : bytedumpchar_scope.
Notation "'Z'" := (Byte.x5a) (only printing) : bytedumpchar_scope.
Notation "'['" := (Byte.x5b) (only printing) : bytedumpchar_scope.
Notation "'\'" := (Byte.x5c) (only printing) : bytedumpchar_scope.
Notation "']'" := (Byte.x5d) (only printing) : bytedumpchar_scope.
Notation "'^'" := (Byte.x5e) (only printing) : bytedumpchar_scope.
Notation "'_'" := (Byte.x5f) (only printing) : bytedumpchar_scope.
Notation "'`'" := (Byte.x60) (only printing) : bytedumpchar_scope.
Notation "'a'" := (Byte.x61) (only printing) : bytedumpchar_scope.
Notation "'b'" := (Byte.x62) (only printing) : bytedumpchar_scope.
Notation "'c'" := (Byte.x63) (only printing) : bytedumpchar_scope.
Notation "'d'" := (Byte.x64) (only printing) : bytedumpchar_scope.
Notation "'e'" := (Byte.x65) (only printing) : bytedumpchar_scope.
Notation "'f'" := (Byte.x66) (only printing) : bytedumpchar_scope.
Notation "'g'" := (Byte.x67) (only printing) : bytedumpchar_scope.
Notation "'h'" := (Byte.x68) (only printing) : bytedumpchar_scope.
Notation "'i'" := (Byte.x69) (only printing) : bytedumpchar_scope.
Notation "'j'" := (Byte.x6a) (only printing) : bytedumpchar_scope.
Notation "'k'" := (Byte.x6b) (only printing) : bytedumpchar_scope.
Notation "'l'" := (Byte.x6c) (only printing) : bytedumpchar_scope.
Notation "'m'" := (Byte.x6d) (only printing) : bytedumpchar_scope.
Notation "'n'" := (Byte.x6e) (only printing) : bytedumpchar_scope.
Notation "'o'" := (Byte.x6f) (only printing) : bytedumpchar_scope.
Notation "'p'" := (Byte.x70) (only printing) : bytedumpchar_scope.
Notation "'q'" := (Byte.x71) (only printing) : bytedumpchar_scope.
Notation "'r'" := (Byte.x72) (only printing) : bytedumpchar_scope.
Notation "'s'" := (Byte.x73) (only printing) : bytedumpchar_scope.
Notation "'t'" := (Byte.x74) (only printing) : bytedumpchar_scope.
Notation "'u'" := (Byte.x75) (only printing) : bytedumpchar_scope.
Notation "'v'" := (Byte.x76) (only printing) : bytedumpchar_scope.
Notation "'w'" := (Byte.x77) (only printing) : bytedumpchar_scope.
Notation "'x'" := (Byte.x78) (only printing) : bytedumpchar_scope.
Notation "'y'" := (Byte.x79) (only printing) : bytedumpchar_scope.
Notation "'z'" := (Byte.x7a) (only printing) : bytedumpchar_scope.
Notation "'{'" := (Byte.x7b) (only printing) : bytedumpchar_scope.
Notation "'|'" := (Byte.x7c) (only printing) : bytedumpchar_scope.
Notation "'}'" := (Byte.x7d) (only printing) : bytedumpchar_scope.
Notation "'~'" := (Byte.x7e) (only printing) : bytedumpchar_scope.
Notation "''" := (Byte.x7f) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.x80) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.x81) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.x82) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.x83) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.x84) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.x85) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.x86) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.x87) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.x88) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.x89) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.x8a) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.x8b) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.x8c) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.x8d) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.x8e) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.x8f) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.x90) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.x91) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.x92) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.x93) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.x94) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.x95) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.x96) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.x97) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.x98) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.x99) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.x9a) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.x9b) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.x9c) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.x9d) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.x9e) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.x9f) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xa0) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xa1) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xa2) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xa3) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xa4) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xa5) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xa6) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xa7) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xa8) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xa9) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xaa) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xab) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xac) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xad) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xae) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xaf) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xb0) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xb1) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xb2) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xb3) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xb4) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xb5) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xb6) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xb7) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xb8) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xb9) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xba) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xbb) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xbc) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xbd) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xbe) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xbf) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xc0) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xc1) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xc2) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xc3) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xc4) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xc5) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xc6) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xc7) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xc8) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xc9) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xca) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xcb) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xcc) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xcd) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xce) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xcf) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xd0) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xd1) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xd2) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xd3) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xd4) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xd5) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xd6) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xd7) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xd8) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xd9) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xda) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xdb) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xdc) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xdd) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xde) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xdf) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xe0) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xe1) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xe2) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xe3) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xe4) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xe5) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xe6) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xe7) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xe8) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xe9) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xea) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xeb) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xec) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xed) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xee) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xef) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xf0) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xf1) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xf2) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xf3) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xf4) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xf5) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xf6) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xf7) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xf8) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xf9) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xfa) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xfb) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xfc) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xfd) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xfe) (only printing) : bytedumpchar_scope.
Notation "'�'" := (Byte.xff) (only printing) : bytedumpchar_scope.

Definition allBytes: list Byte.byte :=
  map (fun nn => match Byte.of_N (BinNat.N.of_nat nn) with
                 | Some b => b
                 | None => Byte.x00 (* won't happen *)
                 end)
      (seq 0 256).
