structure Flow : sig
    structure Graph : GRAPH
    datatype flowgraph = FGRAPH of {control: Graph.graph,
				    def: Temp.temp list Graph.Table.table,
				    use: Temp.temp list Graph.Table.table,
				    ismove: bool Graph.Table.table}

  (* Note:  any "use" within the block is assumed to be BEFORE a "def" 
        of the same variable.  If there is a def(x) followed by use(x)
       in the same block, do not mention the use in this data structure,
       mention only the def.

     More generally:
       If there are any nonzero number of defs, mention def(x).
       If there are any nonzero number of uses BEFORE THE FIRST DEF,
           mention use(x).

     For any node in the graph,  
           Graph.Table.look(def,node) = SOME(def-list)
           Graph.Table.look(use,node) = SOME(use-list)
   *)

    (* structure MakeGraph *)
    (*val instr2graph: Assem.instr list -> Flow.flowgraph * Graph.node list*)
    val instr2graph: Assem.instr list -> flowgraph * Graph.node list * Assem.instr Graph.Table.table

    (* for debugging *)
    val show : TextIO.outstream * flowgraph -> unit
end =
struct
structure Graph = Graph
datatype flowgraph = FGRAPH of {control: Graph.graph,
				def: Temp.temp list Graph.Table.table,
				use: Temp.temp list Graph.Table.table,
				ismove: bool Graph.Table.table}

structure A = Assem
structure G = Graph
structure T = G.Table

fun ICE msg = ErrorMsg.impossible ("FLOW: " ^ msg)

fun instr2graph instrs =
    let
	fun proc (i as A.OPER {asm, dst, src, jmp},
		  (gph: G.graph,
		   def: Temp.temp list T.table,
 		   use: Temp.temp list T.table,
		   ismove: bool G.Table.table,
		   labs: (G.node option * G.node list) Symbol.table,
		   last_jmp: bool,
		   n::ns: G.node list, imap: A.instr T.table)) =
	    let val n' = G.newNode gph
		val _ = if last_jmp then () else G.mk_edge{from = n, to = n'}
		val (labs', is_jmp) = case jmp of
				NONE => (labs, false)
			      | SOME js =>
				(foldl (fn (j, acc) =>
					  (case Symbol.look(acc, j) of
					       NONE => Symbol.enter(acc, j, (NONE, [n']))
					     | SOME (NONE, x::xs) =>
					       Symbol.enter(acc, j, (NONE, n'::x::xs))
					     | SOME (SOME n'', []) =>
					       acc before G.mk_edge{from=n', to=n''}
					     | _ => ICE "bad oper case"))
				      labs js, not(List.null js))
	    in (gph,
		T.enter(def, n', dst),
		T.enter(use, n', src),
		T.enter(ismove, n', false),
		labs', is_jmp, n'::n::ns, T.enter(imap, n', i))
	    end
	  | proc (i as A.OPER {asm, dst, src, jmp},
		  (gph, def, use, ismove, labs, false, [], imap)) =
	    let val n = G.newNode gph
		val (labs', is_jmp) = case jmp of
				NONE => (labs, false)
			      | SOME js => (foldl (fn (j, acc) => Symbol.enter(acc, j, (NONE, [n])))
						  labs js, not(List.null js))
	    in (gph,
		T.enter(def, n, dst),
		T.enter(use, n, src),
		T.enter(ismove, n, false),
		labs, is_jmp, [n], T.enter(imap, n, i))
	    end

	  | proc (i as A.LABEL {asm, lab}, (gph, def, use, ismove, labs, last_jmp, n::ns, imap)) =
	    let val n' = G.newNode gph
		val _ = if last_jmp then () else G.mk_edge{from = n, to = n'}
		val labs' = case Symbol.look(labs, lab) of
				NONE => Symbol.enter(labs, lab, (SOME n', []))
			      | SOME (NONE, x::xs) =>
				Symbol.enter(labs, lab, (SOME n', []))
				before app (fn x => G.mk_edge{from=x, to=n'}) (x::xs)
			      | _ => ICE "bad label case"
	    in
		(gph,
		 T.enter(def, n', []), (* empty list *)
		 T.enter(use, n', []), (* empty list *)
		 T.enter(ismove, n', false),
		 labs', false, n'::n::ns, T.enter(imap, n', i))
	    end
	  | proc (i as A.LABEL {asm, lab}, (gph, def, use, ismove, labs, false, [], imap)) =
	    let val n = G.newNode gph
		val labs' = Symbol.enter(labs, lab, (SOME n, []))
	    in
		(gph,
		 T.enter(def, n, []), (* empty list *)
		 T.enter(use, n, []), (* empty list *)
		 T.enter(ismove, n, false),
		 labs', false, [n], T.enter(imap, n, i))
	    end

	  | proc (i as A.MOVE {asm, dst, src}, (gph, def, use, ismove, labs, last_jmp, n::ns, imap)) =
	    let val n' = G.newNode gph
		val _ = if last_jmp then () else G.mk_edge{from = n, to = n'}
	    in
		(gph,
		 T.enter(def, n', [dst]),
		 T.enter(use, n', [src]),
		 T.enter(ismove, n', true),
		 labs, false, n'::n::ns, T.enter(imap, n', i))
	    end
	  | proc (i as A.MOVE {asm, dst, src}, (gph, def, use, ismove, labs, false, [], imap)) =
	    let val n = G.newNode gph
	    in
		(gph,
		 T.enter(def, n, [dst]),
		 T.enter(use, n, [src]),
		 T.enter(ismove, n, true),
		 labs, false, [n], T.enter(imap, n, i))
	    end

	    | proc _ = ICE "bad proc input"

	val (gph, def, use, ismove, _, _, nlist, imap) =
	    foldl proc (G.newGraph(),
			G.Table.empty, G.Table.empty, G.Table.empty, Symbol.empty, false, [], G.Table.empty)
		  instrs
    in
	(FGRAPH {control=gph, def=def, use=use, ismove=ismove}, rev nlist, imap)
    end

fun show(out, (FGRAPH {control, def, use, ismove})) =
    let
	fun show' n =
	    let fun p g n = String.concatWith " " (map (fn i => G.nodename i) (g n))
		val nname = G.nodename n
		val succs = "[" ^ p G.succ n ^ "]"
		(*val preds = "[" ^ p G.pred n ^ "]"*)
		val defs = "<" ^ String.concatWith " " (map Temp.tempname (valOf(T.look(def, n)))) ^ ">"
		val uses = "<" ^ String.concatWith " " (map Temp.tempname (valOf(T.look(use, n)))) ^ ">"
		val move = if valOf(T.look(ismove, n)) then "M" else "m"
	    in
		TextIO.output(out,
			      String.concatWith "\t"
						[nname ^ ": ", succs, (*preds,*) defs, uses, move, "\n"])
	    end
    in
	app show' (Graph.nodes control)
    end

end
