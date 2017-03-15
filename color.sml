structure Color : COLOR =
struct

  structure Frame = X86Frame

  type allocation = Frame.register Temp.Table.table

  structure G = Graph
  structure S = IntListSet
  structure GT = G.Table
  structure GS = G.Set
  structure TT = Temp.Table
  structure FT = Frame.RegTable

  type NodeSet = GS.set
  type Color = int

  fun ICE msg = ErrorMsg.impossible ("COLOR: " ^ msg)
  fun assert(msg, cond) = ignore (cond orelse ICE msg)

  fun color {interference: Liveness.igraph,
	     initial: allocation,
	     spillCosts: Graph.node -> int,
	     registers: Frame.register list} =
      let val Liveness.IGRAPH {graph = igraph,
			       tnode = itnode,
			       gtemp = igtemp,
			       moves = imoves} = interference
	  (* constants w.r.t. Frame *)
	  val K = length registers
	  val allColors = S.fromList registers

	  (* precolored nodes *)
	  val allnodes = G.nodes igraph
	  val allnodes_set = GS.fromList allnodes
	  val (precolored, color) = foldl (fn (n, (s, m)) =>
					      (case TT.look(initial, igtemp(n)) of
						   SOME r => (GS.add(s, n),
							      GT.enter(m, n, r))
						 | NONE => (s, m)))
					  (GS.empty, GT.empty)
					  allnodes
	  val nonprecolored = GS.difference(allnodes_set, precolored)

	  fun n2t n = Temp.tempname(igtemp n)
	  fun showNodeSet(t, s) =
	      TextIO.output(TextIO.stdOut,
			    t ^ ": " ^
			    (String.concatWith
				 " "
				 (map (fn n => Temp.tempname(igtemp n))
				      (GS.listItems s)))
			    ^ "\n")
	  fun showNodeList(t, l) =
	      TextIO.output(TextIO.stdOut,
			    t ^ ": " ^
			    (String.concatWith
				 " "
				 (map (fn n => Temp.tempname(igtemp n)) l))
			    ^ "\n")
	  (*val _ = showNodeSet("allnotes", allnodes_set)
	  val _ = showNodeSet("precolored", precolored)
	  val _ = showNodeSet("nonprecolored", nonprecolored)*)

	  (* adjacency list and degree *)
	  val (adjList, degree) =
	      foldl (fn (n, (m, d)) =>
			let val l = GS.listItems(GS.fromList(G.adj n))
			in (GT.enter(m, n, l), GT.enter(d, n, length l))
			end)
		    (GT.empty, GT.empty)
		    (GS.listItems nonprecolored)
	  fun showAdjLists() =
	      app (fn n =>
		      let val nl = valOf(GT.look(adjList, n))
			  val d = valOf(GT.look(degree, n))
		      in TextIO.output(TextIO.stdOut,
				       Temp.tempname(igtemp n)
				       ^ " (" ^ Int.toString d ^ "): " ^
				       (String.concatWith
					    " "
					    (map (fn n => Temp.tempname(igtemp n)) nl))
				       ^ "\n")
		      end)
		  (GS.listItems nonprecolored)
	  (*val _ = showAdjLists()*)
	  (*val coloredNodes = S.fromList(G.nodes(igraph))*)

			      
	  (* Coalescing - TODO *)
	  fun nodeMoves n =
	      (*GS.intersection(GT.look(moveList, n),
			      GS.union(activeMoves, worklistMoves))*)
	      GS.empty
	  fun moveRelated n = not(GS.isEmpty(nodeMoves n))
	  val alias: (G.node GT.table) = GT.empty
	  val coalescedNodes = GS.empty
	  fun getAlias(n) = if GS.member(coalescedNodes, n)
			    then getAlias(valOf(GT.look(alias, n)))
			    else n

	  (* MakeWorklist *)
	  val (spillWorklist,
	       freezeWorklist,
	       simplifyWorklist) =
	      GS.foldl (fn (n, (spills, freezes, simplifies)) =>
			   let val d = valOf(GT.look(degree, n))
			   in if d >= K
			      then (GS.add(spills, n), freezes, simplifies)
			      else if moveRelated n
			      then (spills, GS.add(freezes, n), simplifies)
			      else (spills, freezes, GS.add(simplifies, n))
			   end)
		       (GS.empty, GS.empty, GS.empty)
		       nonprecolored

	  fun simpify(degree, selectStack, coalescedNodes,
		      spillWorklist,
		      freezeWorklist,
		      simplifyWorklist) =
	      let val n::_ = GS.listItems simplifyWorklist
		  val simplifyWorklist = GS.delete(simplifyWorklist, n)
		  val adjs = GS.difference(GS.fromList(valOf(GT.look(adjList, n))),
					   GS.union(GS.fromList selectStack, coalescedNodes))
		  val adjs = GS.filter (fn e => not(GS.member(precolored, e))) adjs
		  (*val _= showNodeSet("adjs", adjs)*)
		  val (degree, spillWorklist, freezeWorklist, simplifyWorklist) =
		      GS.foldl
			  (fn (m, (degree,
				   spillWorklist,
				   freezeWorklist,
				   simplifyWorklist)) =>
			      let val d = valOf(GT.look(degree, m))
			      in if d = K then
				     (GT.enter(degree, m, d - 1),
				      GS.subtract(spillWorklist, m),
				      freezeWorklist,
				      GS.add(simplifyWorklist, m))
				 else
				     (GT.enter(degree, m, d - 1),
				      spillWorklist,
				      freezeWorklist,
				      simplifyWorklist)
			      end)
			  (degree, spillWorklist, freezeWorklist, simplifyWorklist)
			  adjs
	      in
		  (degree, n::selectStack, spillWorklist, freezeWorklist, simplifyWorklist)
	      end

	  fun selectSpill(degree, spillWorklist) =
	      let
		  fun cost(n) = (Real.fromInt(spillCosts n)) /
				(Real.fromInt(valOf(GT.look(degree, n))))
		  fun select (h::nil) = h
		    | select(h::t) = let val c = cost h
					 and n = select t
					 val c' = cost n
				     in if c < c' then h else n end
		    | select nil = raise Empty
	      in
		  select(GS.listItems spillWorklist)
	      end

	  fun loop(simplifyWorklist, spillWorklist, worklistMoves, freezeWorklist,
		   degree, selectStack) =
	      (
		(*showNodeSet("simplifyWorklist", simplifyWorklist);
		showNodeSet("spillWorklist", spillWorklist);
		showNodeList("selectStack", selectStack);*)

  		if not(GS.isEmpty simplifyWorklist) then
  		    let val (degree, selectStack, spillWorklist,
  			     freezeWorklist, simplifyWorklist) =
  			    simpify(degree, selectStack, coalescedNodes,
  				    spillWorklist, freezeWorklist, simplifyWorklist)
  		    in
  			loop(simplifyWorklist, worklistMoves, freezeWorklist, spillWorklist,
  			     degree, selectStack)
  		    end
  		else if not(GS.isEmpty worklistMoves) then
  		    (* TODO - coalesce *)
  		    loop(simplifyWorklist, worklistMoves, freezeWorklist, spillWorklist,
  			 degree, selectStack)
  		else if not(GS.isEmpty freezeWorklist) then
  		    (* TODO - freeze *)
  		    loop(simplifyWorklist, worklistMoves, freezeWorklist, spillWorklist,
  			 degree, selectStack)
  		else if not(GS.isEmpty spillWorklist) then
  		    let val m = selectSpill(degree, spillWorklist)
  		    in
  			loop(GS.add(simplifyWorklist, m),
  			     worklistMoves, freezeWorklist,
  			     GS.delete(spillWorklist, m),
  			     degree, selectStack)
  		    end
  		else
  		    selectStack
	      )
		       
	  val selectStack = loop(simplifyWorklist, spillWorklist, GS.empty, GS.empty,
				 degree, [])

	  fun assignColors(selectStack as (n::rest),
			   color: Color GT.table,
			   spilledNodes,
			   coloredNodes) =
	      (
		(*showNodeList("selectStack", selectStack);
		showNodeSet("spilledNodes", spilledNodes);
		showNodeSet("coloredNodes", coloredNodes);*)
		(case S.listItems(foldl (fn (w, cs) =>
					    let val v = getAlias w
					    in if GS.member(coloredNodes, v) orelse GS.member(precolored, v)
					       then S.subtract(cs, valOf(GT.look(color, v)))
					       else cs
					    end)
					allColors
					(valOf(GT.look(adjList, n)))) of
		     [] => assignColors(rest, color,
					GS.add(spilledNodes, n),
					coloredNodes)
		   | (h::_) => assignColors(rest,
					    GT.enter(color, n, h), spilledNodes,
					    GS.add(coloredNodes, n)))
	      )
	    | assignColors([], color, spilledNodes, coloredNodes) =
	      (GS.foldl (fn (n, color) => GT.enter(color,
						   n,
						   valOf(GT.look(color, getAlias n))))
			color
			coalescedNodes,
	       spilledNodes,
	       coloredNodes)

	  val (color, spilledNodes, coloredNodes) = assignColors(
		  selectStack, color, GS.empty, GS.empty)

	  val _ = assert("INVARIRANT0", GS.isEmpty(GS.intersection(precolored, spilledNodes)))
	  val _ = assert("INVARIRANT0", GS.isEmpty(GS.intersection(precolored, coloredNodes)))
	  val _ = assert("INVARIRANT0", GS.isEmpty(GS.intersection(spilledNodes, coloredNodes)))
	  val _ = assert("INVARIRANT0", GS.equal(allnodes_set,
						 GS.union(precolored,
							  GS.union(spilledNodes, coloredNodes))))
	  val _ = if (GS.isEmpty spilledNodes) then
		      assert("RESULT", 
			 List.all (fn n => (case GT.look(color, n) of
						SOME c => true
					      | NONE => false))
				  allnodes)
		  else ()

      in
	  (foldl (fn (n, t) => case GT.look(color, n) of
				   SOME c => TT.enter(t, igtemp n, c)
				 | NONE => t)
		 TT.empty
		 allnodes,
	   map igtemp (GS.listItems spilledNodes))
      end
end


(* test
local
    exception ASSERT of string
    fun assert msg cond = ignore (cond orelse raise ASSERT msg)

    val prog = "let var i := 0 in while i < 5 do (i := i + 1) end"
    val prog="let function add(a: int, b: int, c:int) : int = a + b + c in print(chr(ord(\"0\")+add(1,2,3))) end"
    val absyn = Parse.parse_str prog
    val (Frame.PROC{body, frame})::_ = (FindEscape.findEscape absyn; Semant.transProg absyn)
    val stms = Canon.traceSchedule(Canon.basicBlocks(Canon.linearize body))
    val _ = app (fn s => Printtree.printtree(TextIO.stdOut,s)) stms

    val format = Assem.format Frame.tempName
    fun printinstr out instr = TextIO.output(out, format instr)

    val instrs = List.concat(map (CodeGen.codegen frame) stms)
    val instrs = Frame.procEntryExit2(frame, instrs)
    val _ = app (printinstr TextIO.stdOut) instrs

    val (fgraph as Flow.FGRAPH{control,def,use,ismove}, nlist, imap) = Flow.instr2graph instrs

    fun show_fnode out n =
	let fun p g n = String.concatWith " " (map (fn i => Graph.nodename i) (g n))
	    val nname = Graph.nodename n
	    val succs = "[" ^ p Graph.succ n ^ "]"
	    val preds = "[" ^ p Graph.pred n ^ "]"
	    val instr = format(valOf(Graph.Table.look(imap, n)))
	    val defs = "<" ^ String.concatWith
				 " " (map Temp.tempname (valOf(Flow.Graph.Table.look(def, n)))) ^ ">"
	    val uses = "<" ^ String.concatWith
				 " " (map Temp.tempname (valOf(Flow.Graph.Table.look(use, n)))) ^ ">"
	    val move = if valOf(Flow.Graph.Table.look(ismove, n)) then "M" else ""
	in
	    TextIO.output(out, nname ^ ": "
			       ^ String.concatWith " " [succs, preds, defs, uses, move]
			       ^ "\t\t" ^ instr)
	end
    val _ = app (show_fnode TextIO.stdOut) nlist

    val (igraph as Liveness.IGRAPH {graph, tnode, gtemp, moves}, live_outs, spillCosts) =
	Liveness.interferenceGraph(fgraph, nlist)
    (*val _ = Liveness.show(TextIO.stdOut, igraph, spillCosts)*)

    val (alloc, spills) = Color.color {
	    interference = igraph,
	    initial = Frame.tempMap,
	    spillCosts = spillCosts,
	    registers = Frame.registerList}

    val _ = (TextIO.output(TextIO.stdOut, "Allocation:\n");
	     app (fn n => let val t = gtemp n
			      val s = Temp.tempname(t) ^ ":\t" ^
				      (case Temp.Table.look(alloc, t) of
					   SOME r => Frame.regName r
					 | NONE => "*") ^ "\n"
			  in
			      TextIO.output(TextIO.stdOut, s)
			  end)
		 (Graph.nodes graph);
	     TextIO.output(TextIO.stdOut,
			   "Spills: "
			   ^ (String.concatWith " " (map Temp.tempname spills))
			   ^ "\n"))

in
end
 *)
