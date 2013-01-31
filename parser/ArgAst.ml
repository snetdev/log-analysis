
exception Node_Mismatch
exception Compilation_Error

let trav_error s = 
  let _ = Printf.printf "\n%s\n" s
in raise Compilation_Error

(* - AST - *)

type boxnameorid = BoxName of string (* Box Name *) 
                 | ID      of int64  (* ID *)

type sn_ast = ExecTime of string (* Execution Option *)
                        * boxnameorid (*Box Name or ID*)
                        * sn_ast
            | ListTime of string (* List Time Option *)
                        * boxnameorid (*Box Name or ID*)
                        * sn_ast
            | Stream   of int64 (* Stream Id *)
                        * sn_ast        
            | Save     of string (* Filename *)
                        * sn_ast
            | Empty
 

(* ExecTime Parameters*)
let exectime_option = 
	function ExecTime (option, _, _) -> option | _ -> raise Node_Mismatch
let exectime_boxname = 
	function ExecTime (_, boxname, _) -> boxname | _ -> raise Node_Mismatch
let exectime_succs = 
	function ExecTime (_, _, succs) -> succs | _ -> raise Node_Mismatch

(* ListTime Parameters*)
let listtime_option = 
	function ListTime (option, _, _) -> option | _ -> raise Node_Mismatch
let listtime_boxname = 
	function ListTime (_, boxname, _) -> boxname | _ -> raise Node_Mismatch
let listtime_succs = 
	function ListTime (_, _, succs) -> succs | _ -> raise Node_Mismatch

(* Stream Parameters*)
let stream_streamid = 
	function Stream (streamid, _) -> streamid | _ -> raise Node_Mismatch
let stream_succs = 
	function Stream (_, succs) -> succs | _ -> raise Node_Mismatch

(* Stream Parameters*)
let svae_filename = 
	function Save (filename, _) -> filename | _ -> raise Node_Mismatch
let save_succs = 
	function Save (_, succs) -> succs | _ -> raise Node_Mismatch


(* Function for see all the ways*)
let read_arguments node = 
  let rec codegen_ ind node listarg =
    match node with
      | ExecTime(option,boxname, _) -> 
              let item = 
                match boxname with
                  | BoxName (name) -> ("exec%" ^ option ^ "%B%" ^ (name) )
                  | ID ( id )-> ("exec%" ^ option ^ "%I%" ^ (Int64.to_string id))  
              in (codegen_ (ind+1) (exectime_succs node) (item::listarg))
      | ListTime  ( option, boxname, _ ) -> 
              let item = 
                match boxname with
                  | BoxName (name) -> ("list%" ^ option ^ "%B%" ^ (name) )
                  | ID ( id )-> ("list%" ^ option  ^ "%I%" ^ (Int64.to_string id))  
                in (codegen_ (ind+1) (listtime_succs node)  (item::listarg))
      | Stream (streamid, _) -> codegen_ (ind+1) (stream_succs node)  (("stre%" ^ (Int64.to_string streamid))::listarg) 
      | Save (filename, _) -> codegen_ (ind+1) (save_succs node)  (("save%" ^ filename)::listarg)
      | Empty       _ ->  listarg
  in codegen_ 0 node []   

