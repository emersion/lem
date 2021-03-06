(* Generated by Lem from string.lem. *)

Require Import Arith.
Require Import Bool.
Require Import List.
Require Import String.
Require Import Program.Wf.

Require Import coqharness.

Open Scope nat_scope.
Open Scope string_scope.



Require Import lem_bool.
Require Export lem_bool.
Require Import lem_basic_classes.
Require Export lem_basic_classes.
Require Import lem_list.
Require Export lem_list.



Require Import Coq.Strings.Ascii.
Require Export Coq.Strings.Ascii.
Require Import Coq.Strings.String.
Require Export Coq.Strings.String.

(* [?]: removed value specification. *)

(* [?]: removed value specification. *)

(* [?]: removed value specification. *)

(* 
Definition makeString  (len : nat ) (c : ascii )  : string :=  string_from_char_list (replicate len c). *)
(* [?]: removed value specification. *)

(* [?]: removed value specification. *)

(* [?]: removed top-level value definition. *)
(* [?]: removed value specification. *)


Definition string_case {a : Type}  (s : string ) (c_empty : a) (c_cons : ascii  -> string  -> a)  : a:= 
  match ( (string_to_char_list s)) with 
    | [] => c_empty
    | c :: cs => c_cons c (string_from_char_list cs)
  end.
(* [?]: removed value specification. *)

(* [?]: removed top-level value definition. *)
(* [?]: removed value specification. *)

(* [?]: removed top-level value definition. *)
(* [?]: removed value specification. *)

Program Fixpoint concat0  (sep : string ) (ss : list (string ))  : string := 
  match ( ss) with 
    | [] => ""
    | s :: ss' =>
      match ( ss') with 
      | [] => s
      | _ =>  String.append s  (String.append sep (concat0 sep ss'))
      end
  end.
