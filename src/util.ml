(**************************************************************************)
(*                        Lem                                             *)
(*                                                                        *)
(*          Dominic Mulligan, University of Cambridge                     *)
(*          Francesco Zappa Nardelli, INRIA Paris-Rocquencourt            *)
(*          Gabriel Kerneis, University of Cambridge                      *)
(*          Kathy Gray, University of Cambridge                           *)
(*          Peter Boehm, University of Cambridge (while working on Lem)   *)
(*          Peter Sewell, University of Cambridge                         *)
(*          Scott Owens, University of Kent                               *)
(*          Thomas Tuerk, University of Cambridge                         *)
(*                                                                        *)
(*  The Lem sources are copyright 2010-2013                               *)
(*  by the UK authors above and Institut National de Recherche en         *)
(*  Informatique et en Automatique (INRIA).                               *)
(*                                                                        *)
(*  All files except ocaml-lib/pmap.{ml,mli} and ocaml-libpset.{ml,mli}   *)
(*  are distributed under the license below.  The former are distributed  *)
(*  under the LGPLv2, as in the LICENSE file.                             *)
(*                                                                        *)
(*                                                                        *)
(*  Redistribution and use in source and binary forms, with or without    *)
(*  modification, are permitted provided that the following conditions    *)
(*  are met:                                                              *)
(*  1. Redistributions of source code must retain the above copyright     *)
(*  notice, this list of conditions and the following disclaimer.         *)
(*  2. Redistributions in binary form must reproduce the above copyright  *)
(*  notice, this list of conditions and the following disclaimer in the   *)
(*  documentation and/or other materials provided with the distribution.  *)
(*  3. The names of the authors may not be used to endorse or promote     *)
(*  products derived from this software without specific prior written    *)
(*  permission.                                                           *)
(*                                                                        *)
(*  THIS SOFTWARE IS PROVIDED BY THE AUTHORS ``AS IS'' AND ANY EXPRESS    *)
(*  OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED     *)
(*  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE    *)
(*  ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY       *)
(*  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL    *)
(*  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE     *)
(*  GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS         *)
(*  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER  *)
(*  IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR       *)
(*  OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN   *)
(*  IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.                         *)
(**************************************************************************)

module Duplicate(S : Set.S) = struct

type dups = 
  | No_dups of S.t
  | Has_dups of S.elt

let duplicates (x : S.elt list) : dups =
  let rec f x acc = match x with
    | [] -> No_dups(acc)
    | s::rest ->
        if S.mem s acc then
          Has_dups(s)
        else
          f rest (S.add s acc)
  in
    f x S.empty
end

let remove_duplicates_gen p l =
  let rec aux acc l = match l with
      [] -> List.rev acc  
    | (x :: xs) -> if (List.exists (p x) acc) then (aux acc xs) else aux (x::acc) xs
  in
  aux [] l

let remove_duplicates l = remove_duplicates_gen (fun x y -> x = y) l

let get_duplicates_gen p l = 
  let rec aux acc l = match l with
      [] -> List.rev acc  
    | (x :: xs) -> if ((List.exists (p x) xs) && not (List.exists (p x) acc)) then (aux (x::acc) xs) else aux acc xs
  in
  aux [] l

let get_duplicates l = get_duplicates_gen (fun x y -> x = y) l

let rec compare_list f l1 l2 = 
  match (l1,l2) with
    | ([],[]) -> 0
    | (_,[]) -> 1
    | ([],_) -> -1
    | (x::l1,y::l2) ->
        let c = f x y in
          if c = 0 then
            compare_list f l1 l2
          else
            c
              
let map_changed_default d f l =
  let rec g = function
    | [] -> ([],false)
    | x::y ->
        let (r,c) = g y in
          match f x with
            | None -> ((d x)::r,c)
            | Some(x') -> (x'::r,true)
  in
  let (r,c) = g l in
    if c then
      Some(r)
    else
      None

let map_changed f l = map_changed_default (fun x -> x) f l

let rec map_filter (f : 'a -> 'b option) (l : 'a list) : 'b list =
  match l with [] -> []
    | x :: xs ->
      let xs' = map_filter f xs in
      match (f x) with None -> xs' 
        | Some x' -> x' :: xs'

let list_index p l =
  let rec aux i l =
    match l with [] -> None
        | (x :: xs) -> if p x then Some i else aux (i+1) xs
  in
  aux 0 l

let list_subset l1 l2 = List.for_all (fun e -> List.mem e l2) l1
let list_diff l1 l2 = List.filter (fun e -> not (List.mem e l2)) l1

let rec list_longer n l = match (l, n) with
  | ([],_) -> false
  | (_::_, 0) -> true
  | (_::l', n) -> list_longer (n-1) l'

let rec list_null l = match l with
  | [] -> true
  | _ -> false

let list_dest_snoc l =  
  match l with
    | [] -> raise (Failure "list_dest_snoc")
    | _ -> begin
      let l_rev = List.rev l in
      (List.rev (List.tl l_rev), List.hd l_rev)
    end 

let list_pick p l = begin
  let rec aux acc l = begin
    match l with
      | [] -> None
      | x :: xs -> if p x then Some (x, List.rev acc @ xs) else
                   aux (x::acc) xs
  end in
    aux [] l
end

let option_get_exn e = function
  | Some(o) -> o
  | None -> raise e

let option_default d = function
  | None -> d
  | Some(o) -> o

let option_default_map op d f =
  match op with 
    | None -> d
    | Some(o) -> f o

let option_cases op f1 f2 = match op with
  | Some(o) -> f1 o
  | None -> f2 ()

let option_map f = function
  | None -> None
  | Some(o) -> Some(f o)

let option_bind f = function
  | None -> None
  | Some(o) -> f o

let changed2 f g x h y =
  match (g x, h y) with
    | (None,None) -> None
    | (Some(x'),None) -> Some(f x' y)
    | (None,Some(y')) -> Some(f x y')
    | (Some(x'),Some(y')) -> Some(f x' y')

let rec map_all (f : 'a -> 'b option) (l : 'a list) : 'b list option =
  match l with [] -> Some []
    | x :: xs ->
      match (f x) with None -> None
        | Some x' -> option_map (fun xs' -> x' :: xs') (map_all f xs)

let rec option_first f xL =
  match xL with
      [] -> None
    | (x :: xs) -> match f x with None -> option_first f xs | Some s -> Some s

let list_to_front n l =
  if n <= 0 then l else 
  let rec aux acc n l =
    match (n, l) with
        (0, x::xs) -> (x :: (List.rev_append acc xs))
      | (n, x::xs) -> aux (x :: acc) (n-1) xs
      | (_, []) -> (* should not happen *) raise (Failure "list_to_front")
  in aux [] n l

let undo_list_to_front n l =
  if n <= 0 then l else 
  let rec aux acc n y l =
    match (n, l) with
        (0, xs) -> List.rev_append acc (y::xs)
      | (n, x::xs) -> aux (x :: acc) (n-1) y xs
      | (_, []) -> List.rev_append acc [y]
  in match l with [] -> l | y::xs -> aux [] n y xs

let split_after n l =
  if n < 0 then raise (Failure "negative argument to split_after") else
  let rec aux acc n ll = match (n, ll) with
      (0, _)       -> (List.rev acc, ll)
    | (n, x :: xs) -> aux (x :: acc) (n-1) xs
    | _            -> raise (Failure "index too large")
  in aux [] n l

let list_firstn n l = fst (split_after n l)
let list_dropn n l = snd (split_after n l)

(* Available in OCaml since 4.00.0 - copied from list.ml *)
let rec mapi i f = function
    [] -> []
  | a::l -> let r = f i a in r :: mapi (i + 1) f l
;;
let list_mapi f l = mapi 0 f l ;;

let rec intercalate sep =
  function
    | [] -> []
    | [x] -> [x]
    | x::xs -> x::sep::intercalate sep xs
;;

let rec replicate n e =
  match n with
    | 0 -> []
    | n -> e :: replicate (n - 1) e
;;

let rec list_iter_sep (sf : unit -> unit) (f : 'a -> unit) l : unit =
  match l with
    | []   -> ()
    | [x0] -> f x0
    | (x0 :: x1 :: xs) -> (f x0; sf(); list_iter_sep sf f (x1 :: xs))

let string_to_list s =
  let rec aux i acc =
    if i < 0 then acc
    else aux (i-1) (s.[i] :: acc)
  in aux (String.length s - 1) []

let string_split c s =
  let rec aux acc start = try
     let next = String.index_from s start c in
     let acc' = (String.sub s start (next - start))::acc in
     aux acc' (next+1)
  with Not_found -> (List.rev acc, String.sub s start (String.length s - start)) 
  in aux [] 0

module IntSet = Set.Make( 
  struct
    let compare = Pervasives.compare
    type t = int
  end )

module IntIntSet = Set.Make( 
  struct
    let compare = Pervasives.compare
    type t = int * int
  end )


module ExtraSet = functor (S : Set.S) ->
  struct 
    let add_list s l = List.fold_left (fun s x -> S.add x s) s l
    let remove_list s l = List.fold_left (fun s x -> S.remove x s) s l
    let from_list l = add_list S.empty l
    let list_union l = List.fold_left S.union S.empty l
    let list_inter = function s :: l -> List.fold_left S.inter s l
       | [] -> raise (Failure "ExtraSet.list_inter")
  end;;


let copy_file src dst = 
  let len = 5096 in
  let b = String.make len ' ' in
  let read_len = ref 0 in
  let i = open_in_bin src in
  let o = open_out_bin dst  in
  while (read_len := input i b 0 len; !read_len <> 0) do
    output o b 0 !read_len
  done;
  close_in i;
  close_out o

let move_file src dst =
   if (Sys.file_exists dst) then Sys.remove dst;
   try
     (* try efficient version *)
     Sys.rename src dst
   with Sys_error _ -> 
   begin
     (* OK, do it the the hard way *)
     copy_file src dst;
     Sys.remove src
   end

let same_content_files file1 file2 : bool =
  (Sys.file_exists file1) && (Sys.file_exists file2) && 
  begin
    let s1 = Stream.of_channel (open_in_bin file1) in
    let s2 = Stream.of_channel (open_in_bin file2) in
    let stream_is_empty s = (try Stream.empty s; true with Stream.Failure -> false) in
    try 
      while ((Stream.next s1) = (Stream.next s2)) do () done;
      false
    with Stream.Failure -> stream_is_empty s1 && stream_is_empty s2
  end


let string_for_all p s = List.for_all p (string_to_list s)

let is_letter_char x = 
  let c = Char.code x in 
  begin
    (c <= 90  && c >= 65) (* A-Z *) || 
    (c <= 122 && c >= 97) (* a-z *)
  end

let is_digit_char x = 
  let c = Char.code x in 
  begin
    (c <= 57  && c >= 48) (* 0-9 *)
  end

let is_simple_ident_char x = 
  is_letter_char x ||
  is_digit_char x ||
  (x = '_')  

let is_simple_ident_string s =
  match (string_to_list s) with
    | [] -> false (* no empty idents *)
    | c::cs -> is_letter_char c && List.for_all is_simple_ident_char cs

let message_singular_plural (s, p) = function
  | []  -> s
  | [_] -> s
  | _   -> p

