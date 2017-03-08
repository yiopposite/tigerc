structure Types =
struct

  type unique = unit ref

  datatype ty = 
            RECORD of (Symbol.symbol * ty) list * unique
          | NIL
          | INT
          | STRING
          | ARRAY of ty * unique
	  | NAME of Symbol.symbol * ty option ref
	  | UNIT

  fun toString NIL = "NIL"
    | toString INT = "INT"
    | toString STRING = "STRING"
    | toString UNIT = "UNIT"
    | toString (ARRAY(t, _)) = "ARRAY of (" ^ toString t ^ ")"
    | toString (RECORD(t, _)) =
      let
	  fun field(s, t) = Symbol.name(s) ^ ": " ^ toString t
	  fun cat [] = ""
	    | cat (s::nil) = s
	    | cat (s::ss) = s ^ "; " ^ cat ss
      in
	  "RECORD of (" ^ cat (map field t) ^ ")"
      end
    (*| toString (NAME(s, ref NONE)) = "NAME of (" ^ Symbol.name(s) ^ ": *NONE)"
    | toString (NAME(s, ref (SOME t))) = "NAME of (" ^ Symbol.name(s) ^ ": " ^ toString t ^ ")"*)
    | toString (NAME(s, ref NONE)) = "NAME of (" ^ Symbol.name(s) ^ ": *NONE*)"
    | toString (NAME(s, ref (SOME t))) = "NAME of (" ^ Symbol.name(s) ^ ")"
end

