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

  type nodeset = GS.set
  type adjset = G.AdjSet.set
  type color = int

  fun ICE msg = ErrorMsg.impossible ("COLOR: " ^ msg)
  fun assert(msg, cond) = ignore (cond orelse ICE msg)

  val K_r = ref 0

  type WL = {
      (* worklists *)
      simplifyWorklist: nodeset,
      freezeWorklist: nodeset,
      spillWorklist: nodeset,
      spilledNodes: nodeset,
      coalescedNodes: nodeset,
      coloredNodes: nodeset,
      selectStack: G.node list,
      (* move sets *)
      coalescedMoves: nodeset,
      constrainedMoves: nodeset,
      frozenMoves: nodeset,
      worklistMoves: nodeset,
      activeMoves: nodeset,
      (* others *)
      adjSet: adjset,
      adjList: nodeset GT.table,
      degree: int GT.table,
      moveList: nodeset GT.table,
      alias: G.node GT.table
  }
  fun withSWL(wl: WL, x): WL =
       {simplifyWorklist = x,
	freezeWorklist = #freezeWorklist wl,
	spillWorklist = #spillWorklist wl,
	spilledNodes = #spilledNodes wl,
	coalescedNodes = #coalescedNodes wl,
	coloredNodes = #coloredNodes wl,
	selectStack = #selectStack wl,
	coalescedMoves = #coalescedMoves wl,
	constrainedMoves = #constrainedMoves wl,
	frozenMoves = #frozenMoves wl,
	worklistMoves = #worklistMoves wl,
	activeMoves = #activeMoves wl,
	adjSet = #adjSet wl,
	adjList = #adjList wl,
	degree = #degree wl,
	moveList = #moveList wl,
	alias = #alias wl}
  fun withFWL(wl: WL, x): WL =
       {simplifyWorklist = #simplifyWorklist wl,
	freezeWorklist = x,
	spillWorklist = #spillWorklist wl,
	spilledNodes = #spilledNodes wl,
	coalescedNodes = #coalescedNodes wl,
	coloredNodes = #coloredNodes wl,
	selectStack = #selectStack wl,
	coalescedMoves = #coalescedMoves wl,
	constrainedMoves = #constrainedMoves wl,
	frozenMoves = #frozenMoves wl,
	worklistMoves = #worklistMoves wl,
	activeMoves = #activeMoves wl,
	adjSet = #adjSet wl,
	adjList = #adjList wl,
	degree = #degree wl,
	moveList = #moveList wl,
	alias = #alias wl}
  fun withPWL(wl: WL, x): WL =
       {simplifyWorklist = #simplifyWorklist wl,
	freezeWorklist = #freezeWorklist wl,
	spillWorklist = x,
	spilledNodes = #spilledNodes wl,
	coalescedNodes = #coalescedNodes wl,
	coloredNodes = #coloredNodes wl,
	selectStack = #selectStack wl,
	coalescedMoves = #coalescedMoves wl,
	constrainedMoves = #constrainedMoves wl,
	frozenMoves = #frozenMoves wl,
	worklistMoves = #worklistMoves wl,
	activeMoves = #activeMoves wl,
	adjSet = #adjSet wl,
	adjList = #adjList wl,
	degree = #degree wl,
	moveList = #moveList wl,
	alias = #alias wl}
  fun withPN(wl: WL, x): WL =
       {simplifyWorklist = #simplifyWorklist wl,
	freezeWorklist = #freezeWorklist wl,
	spillWorklist = #spillWorklist wl,
	spilledNodes = x,
	coalescedNodes = #coalescedNodes wl,
	coloredNodes = #coloredNodes wl,
	selectStack = #selectStack wl,
	coalescedMoves = #coalescedMoves wl,
	constrainedMoves = #constrainedMoves wl,
	frozenMoves = #frozenMoves wl,
	worklistMoves = #worklistMoves wl,
	activeMoves = #activeMoves wl,
	adjSet = #adjSet wl,
	adjList = #adjList wl,
	degree = #degree wl,
	moveList = #moveList wl,
	alias = #alias wl}
  fun withCN(wl: WL, x): WL =
       {simplifyWorklist = #simplifyWorklist wl,
	freezeWorklist = #freezeWorklist wl,
	spillWorklist = #spillWorklist wl,
	spilledNodes = #spilledNodes wl,
	coalescedNodes = x,
	coloredNodes = #coloredNodes wl,
	selectStack = #selectStack wl,
	coalescedMoves = #coalescedMoves wl,
	constrainedMoves = #constrainedMoves wl,
	frozenMoves = #frozenMoves wl,
	worklistMoves = #worklistMoves wl,
	activeMoves = #activeMoves wl,
	adjSet = #adjSet wl,
	adjList = #adjList wl,
	degree = #degree wl,
	moveList = #moveList wl,
	alias = #alias wl}
  fun withCoN(wl: WL, x): WL =
       {simplifyWorklist = #simplifyWorklist wl,
	freezeWorklist = #freezeWorklist wl,
	spillWorklist = #spillWorklist wl,
	spilledNodes = #spilledNodes wl,
	coalescedNodes = #coalescedNodes wl,
	coloredNodes = x,
	selectStack = #selectStack wl,
	coalescedMoves = #coalescedMoves wl,
	constrainedMoves = #constrainedMoves wl,
	frozenMoves = #frozenMoves wl,
	worklistMoves = #worklistMoves wl,
	activeMoves = #activeMoves wl,
	adjSet = #adjSet wl,
	adjList = #adjList wl,
	degree = #degree wl,
	moveList = #moveList wl,
	alias = #alias wl}
  fun withSS(wl: WL, x): WL =
       {simplifyWorklist = #simplifyWorklist wl,
	freezeWorklist = #freezeWorklist wl,
	spillWorklist = #spillWorklist wl,
	spilledNodes = #spilledNodes wl,
	coalescedNodes = #coalescedNodes wl,
	coloredNodes = #coloredNodes wl,
	selectStack = x,
	coalescedMoves = #coalescedMoves wl,
	constrainedMoves = #constrainedMoves wl,
	frozenMoves = #frozenMoves wl,
	worklistMoves = #worklistMoves wl,
	activeMoves = #activeMoves wl,
	adjSet = #adjSet wl,
	adjList = #adjList wl,
	degree = #degree wl,
	moveList = #moveList wl,
	alias = #alias wl}
  fun withDegree(wl: WL, x): WL =
       {simplifyWorklist = #simplifyWorklist wl,
	freezeWorklist = #freezeWorklist wl,
	spillWorklist = #spillWorklist wl,
	spilledNodes = #spilledNodes wl,
	coalescedNodes = #coalescedNodes wl,
	coloredNodes = #coloredNodes wl,
	selectStack = #selectStack wl,
	coalescedMoves = #coalescedMoves wl,
	constrainedMoves = #constrainedMoves wl,
	frozenMoves = #frozenMoves wl,
	worklistMoves = #worklistMoves wl,
	activeMoves = #activeMoves wl,
	adjSet = #adjSet wl,
	adjList = #adjList wl,
	degree = x,
	moveList = #moveList wl,
	alias = #alias wl}
  fun withAM(wl: WL, x): WL =
       {simplifyWorklist = #simplifyWorklist wl,
	freezeWorklist = #freezeWorklist wl,
	spillWorklist = #spillWorklist wl,
	spilledNodes = #spilledNodes wl,
	coalescedNodes = #coalescedNodes wl,
	coloredNodes = #coloredNodes wl,
	selectStack = #selectStack wl,
	coalescedMoves = #coalescedMoves wl,
	constrainedMoves = #constrainedMoves wl,
	frozenMoves = #frozenMoves wl,
	worklistMoves = #worklistMoves wl,
	activeMoves = x,
	adjSet = #adjSet wl,
	adjList = #adjList wl,
	degree = #degree wl,
	moveList = #moveList wl,
	alias = #alias wl}
  fun withWLM(wl: WL, x): WL =
       {simplifyWorklist = #simplifyWorklist wl,
	freezeWorklist = #freezeWorklist wl,
	spillWorklist = #spillWorklist wl,
	spilledNodes = #spilledNodes wl,
	coalescedNodes = #coalescedNodes wl,
	coloredNodes = #coloredNodes wl,
	selectStack = #selectStack wl,
	coalescedMoves = #coalescedMoves wl,
	constrainedMoves = #constrainedMoves wl,
	frozenMoves = #frozenMoves wl,
	worklistMoves = x,
	activeMoves = #activeMoves wl,
	adjSet = #adjSet wl,
	adjList = #adjList wl,
	degree = #degree wl,
	moveList = #moveList wl,
	alias = #alias wl}
  fun withOM(wl: WL, x): WL =
       {simplifyWorklist = #simplifyWorklist wl,
	freezeWorklist = #freezeWorklist wl,
	spillWorklist = #spillWorklist wl,
	spilledNodes = #spilledNodes wl,
	coalescedNodes = #coalescedNodes wl,
	coloredNodes = #coloredNodes wl,
	selectStack = #selectStack wl,
	coalescedMoves = #coalescedMoves wl,
	constrainedMoves = x,
	frozenMoves = #frozenMoves wl,
	worklistMoves = #worklistMoves wl,
	activeMoves = #activeMoves wl,
	adjSet = #adjSet wl,
	adjList = #adjList wl,
	degree = #degree wl,
	moveList = #moveList wl,
	alias = #alias wl}
  fun withCM(wl: WL, x): WL =
       {simplifyWorklist = #simplifyWorklist wl,
	freezeWorklist = #freezeWorklist wl,
	spillWorklist = #spillWorklist wl,
	spilledNodes = #spilledNodes wl,
	coalescedNodes = #coalescedNodes wl,
	coloredNodes = #coloredNodes wl,
	selectStack = #selectStack wl,
	coalescedMoves = x,
	constrainedMoves = #constrainedMoves wl,
	frozenMoves = #frozenMoves wl,
	worklistMoves = #worklistMoves wl,
	activeMoves = #activeMoves wl,
	adjSet = #adjSet wl,
	adjList = #adjList wl,
	degree = #degree wl,
	moveList = #moveList wl,
	alias = #alias wl}
  fun withML(wl: WL, x): WL =
       {simplifyWorklist = #simplifyWorklist wl,
	freezeWorklist = #freezeWorklist wl,
	spillWorklist = #spillWorklist wl,
	spilledNodes = #spilledNodes wl,
	coalescedNodes = #coalescedNodes wl,
	coloredNodes = #coloredNodes wl,
	selectStack = #selectStack wl,
	coalescedMoves = #coalescedMoves wl,
	constrainedMoves = #constrainedMoves wl,
	frozenMoves = #frozenMoves wl,
	worklistMoves = #worklistMoves wl,
	activeMoves = #activeMoves wl,
	adjSet = #adjSet wl,
	adjList = #adjList wl,
	degree = #degree wl,
	moveList = x,
	alias = #alias wl}
  fun withAlias(wl: WL, x): WL =
       {simplifyWorklist = #simplifyWorklist wl,
	freezeWorklist = #freezeWorklist wl,
	spillWorklist = #spillWorklist wl,
	spilledNodes = #spilledNodes wl,
	coalescedNodes = #coalescedNodes wl,
	coloredNodes = #coloredNodes wl,
	selectStack = #selectStack wl,
	coalescedMoves = #coalescedMoves wl,
	constrainedMoves = #constrainedMoves wl,
	frozenMoves = #frozenMoves wl,
	worklistMoves = #worklistMoves wl,
	activeMoves = #activeMoves wl,
	adjSet = #adjSet wl,
	adjList = #adjList wl,
	degree = #degree wl,
	moveList = #moveList wl,
	alias = x}
  fun withAdjSet(wl: WL, x): WL =
       {simplifyWorklist = #simplifyWorklist wl,
	freezeWorklist = #freezeWorklist wl,
	spillWorklist = #spillWorklist wl,
	spilledNodes = #spilledNodes wl,
	coalescedNodes = #coalescedNodes wl,
	coloredNodes = #coloredNodes wl,
	selectStack = #selectStack wl,
	coalescedMoves = #coalescedMoves wl,
	constrainedMoves = #constrainedMoves wl,
	frozenMoves = #frozenMoves wl,
	worklistMoves = #worklistMoves wl,
	activeMoves = #activeMoves wl,
	adjSet = x,
	adjList = #adjList wl,
	degree = #degree wl,
	moveList = #moveList wl,
	alias = #alias wl}
  fun withAdjList(wl: WL, x): WL =
       {simplifyWorklist = #simplifyWorklist wl,
	freezeWorklist = #freezeWorklist wl,
	spillWorklist = #spillWorklist wl,
	spilledNodes = #spilledNodes wl,
	coalescedNodes = #coalescedNodes wl,
	coloredNodes = #coloredNodes wl,
	selectStack = #selectStack wl,
	coalescedMoves = #coalescedMoves wl,
	constrainedMoves = #constrainedMoves wl,
	frozenMoves = #frozenMoves wl,
	worklistMoves = #worklistMoves wl,
	activeMoves = #activeMoves wl,
	adjSet = #adjSet wl,
	adjList = x,
	degree = #degree wl,
	moveList = #moveList wl,
	alias = #alias wl}
  fun withFM(wl: WL, x): WL =
       {simplifyWorklist = #simplifyWorklist wl,
	freezeWorklist = #freezeWorklist wl,
	spillWorklist = #spillWorklist wl,
	spilledNodes = #spilledNodes wl,
	coalescedNodes = #coalescedNodes wl,
	coloredNodes = #coloredNodes wl,
	selectStack = #selectStack wl,
	coalescedMoves = #coalescedMoves wl,
	constrainedMoves = #constrainedMoves wl,
	frozenMoves = x,
	worklistMoves = #worklistMoves wl,
	activeMoves = #activeMoves wl,
	adjSet = #adjSet wl,
	adjList = #adjList wl,
	degree = #degree wl,
	moveList = #moveList wl,
	alias = #alias wl}

  infix withSWL withFWL withPWL withPN withCoN withCN withSS withDegree
	withAM withWLM withCM withOM withML withAlias withAdjSet withAdjList
	withFM

val allnodes_r = ref (nil: G.node list)
val precolored_r = ref (GS.empty: GS.set)
val nonprecolored_r = ref (GS.empty: GS.set)
fun precolored n = GS.member(!precolored_r, n)
val nonprecolored = not o precolored

(* debug only *)
fun pr s = TextIO.output(TextIO.stdOut, s)
fun prl s = TextIO.output(TextIO.stdOut, s ^ "\n")
val n2t_r = ref (GT.empty: Temp.temp GT.table)
fun n2t n = Temp.tempname(valOf(GT.look(!n2t_r, n)))

fun getAlias(n, wl as {coalescedNodes, alias,...}:WL) =
    if GS.member(coalescedNodes, n)
    then getAlias(valOf(GT.look(alias, n)), wl)
    else n

fun adjacent(n, {adjList, coalescedNodes, selectStack,...}:WL) =
    GS.difference(valOf(GT.look(adjList, n)),
		  GS.union(GS.fromList selectStack, coalescedNodes))

fun nodeMoves(n, {activeMoves, worklistMoves, moveList,...}:WL) =
    case GT.look(moveList, n) of
	SOME s => GS.intersection(s, GS.union(activeMoves, worklistMoves))
      | NONE => GS.empty

fun moveRelated(n, wl:WL) = not(GS.isEmpty(nodeMoves(n, wl)))

fun enableMoves(nodes, wl as {activeMoves, worklistMoves, moveList,...}:WL) =
    let val activeMoves_r = ref activeMoves
	val worklistMoves_r = ref worklistMoves
    in (
	GS.app (fn n =>
		   GS.app (fn m =>
			   if GS.member(activeMoves, m) then
			       (activeMoves_r := GS.subtract(!activeMoves_r, m);
				worklistMoves_r := GS.add(!worklistMoves_r, m))
			   else ())
			  (nodeMoves(n, wl)))
	       nodes;
	wl withAM(!activeMoves_r) withWLM (!worklistMoves_r))
    end

fun addWorkList(u, wl) =
    if (nonprecolored u)
       andalso (not (moveRelated(u, wl)))
       andalso (valOf(GT.look(#degree wl, u)) < (!K_r))
    then
	wl withSWL (GS.add(#simplifyWorklist wl, u))
	   withFWL (GS.delete(#freezeWorklist wl, u))
    else
	wl

fun decrementDegree(m, wl) =
    if precolored m then wl
    else
	let val degree = #degree wl
	    val d = valOf(GT.look(degree, m))
	    val degree = GT.enter(degree, m, d - 1)
	    val wl = wl withDegree degree
	in if d <> (!K_r) then wl
	   else let
	       val {spillWorklist, freezeWorklist, simplifyWorklist,...}: WL = wl
	       val wl = enableMoves(GS.add(adjacent(m, wl), m), wl)
	       val spillWorklist = GS.subtract(spillWorklist, m)
	       val x = moveRelated(m, wl)
	       val freezeWorklist = if x then GS.add(freezeWorklist, m) else freezeWorklist
	       val simplifyWorklist = if x then GS.add(simplifyWorklist, m) else simplifyWorklist
	   in
	       wl withSWL spillWorklist
		  withFWL freezeWorklist
		  withSWL simplifyWorklist
	   end
	end

fun addEdge(u, v, wl as {adjSet, adjList, degree,...}: WL) =
    if not (G.AdjSet.member(adjSet, G.NodePair(u, v)))
       andalso not (G.eq(u, v)) then
    let
	val adjSet = G.AdjSet.add(G.AdjSet.add(adjSet, G.NodePair(u, v)),
				  G.NodePair(v, u))
	val wl = wl withAdjSet adjSet
	val wl = if nonprecolored u then
		     let val s = valOf(GT.look(adjList, u))
			 val adjList = GT.enter(adjList, u, GS.add(s, v))
			 val d = valOf(GT.look(degree, u)) + 1
			 val degree = GT.enter(degree, u, d)
		     in wl withAdjList adjList withDegree degree
		     end
		 else wl
	val wl = if nonprecolored v then
		     let val s = valOf(GT.look(adjList, v))
			 val adjList = GT.enter(adjList, v, GS.add(s, u))
			 val d = valOf(GT.look(degree, v)) + 1
			 val degree = GT.enter(degree, v, d)
		     in wl withAdjList adjList withDegree degree
		     end
		 else wl
    in
	wl
    end
    else wl

fun combine(u, v, wl as {freezeWorklist, spillWorklist,coalescedNodes,
			 alias, moveList,...}, K) =
    let
	val wl = if GS.member(freezeWorklist, v)
		 then wl withFWL (GS.delete(freezeWorklist, v))
		 else wl withSWL (GS.delete(spillWorklist, v))
	val wl = wl withCN (GS.add(coalescedNodes, v))
	val wl = wl withAlias (GT.enter(alias, v, u))
	val wl = wl withML (GT.enter(moveList, u,
				     GS.union(valOf(GT.look(moveList, u)),
					      valOf(GT.look(moveList, v)))))
	val wl = enableMoves(GS.singleton v, wl)
	val wl = GS.foldl (fn (t, wl) =>
			      decrementDegree(t, addEdge(t, u, wl)))
			  wl
			  (adjacent(v, wl))
	val degree = #degree wl
	val freezeWorklist = #freezeWorklist wl
    in
	if GS.member(freezeWorklist, u) andalso (valOf(GT.look(degree, u)) >= K) then
	    wl withFWL (GS.delete(freezeWorklist, u))
	       withSWL (GS.add(#spillWorklist wl, u))
	else wl
    end

fun coalesce(wl: WL, m_nodes, K) =
    let	val m::worklistMoves = GS.listItems (#worklistMoves wl)
	val (t1, t2) = m_nodes m
	val (x, y) = (getAlias(t1, wl), getAlias(t2, wl))
	val (u, v) = if precolored y then (y, x) else (x, y)
	val wl = wl withWLM (GS.fromList worklistMoves)

	fun OK(t, r, degree, adjSet) =
	    (precolored t
	     orelse valOf(GT.look(degree, t)) < K
	     orelse G.AdjSet.member(adjSet, G.NodePair(t, r)))

	fun conservative(nodes, degree) = (
	    (GS.foldl (fn (n,k) =>
			  if (precolored n) orelse (valOf(GT.look(degree, n)) >= K)
			  then k+1 else k)
		      0 nodes) < K
	)
    in
	if G.eq(u, v) then
	    let val wl = wl withCM (GS.add(#coalescedMoves wl, m))
	    in
		addWorkList(u, wl)
	    end
	else if precolored v
		orelse G.AdjSet.member(#adjSet wl, G.NodePair(u, v)) then
	    let val wl = wl withOM (GS.add(#constrainedMoves wl, m))
	    in
		addWorkList(v, addWorkList(u, wl))
	    end
	else if (precolored u
		 andalso (List.all
			      (fn t => OK(t, u, #degree wl, #adjSet wl))
			      (GS.listItems(adjacent(v, wl)))))
		orelse ((nonprecolored u)
			andalso
			(conservative(GS.union(adjacent(u, wl),
					       adjacent(v, wl)),
				      #degree wl)))
	then
	    let val wl = wl withCM (GS.add(#coalescedMoves wl, m))
	    in
		addWorkList(u, combine(u, v, wl, K))
	    end
	else (
	    wl withAM (GS.add(#activeMoves wl, m)))
    end

fun freezeMoves(u, wl, m_nodes, K) =
    GS.foldl
	(fn (m, wl) =>
	    let val (x, y) = m_nodes m
		val y' =  getAlias(y, wl)
		val v = if G.eq(y', getAlias(u, wl)) then getAlias(x, wl) else y'
		val wl = wl withAM (GS.delete(#activeMoves wl, m))
			    withFM (GS.add(#frozenMoves wl, m))
	    in
		if GS.isEmpty(nodeMoves(v, wl))
		   andalso (valOf(GT.look(#degree wl, v)) < K) then
		    wl withFWL (GS.delete(#freezeWorklist wl, v))
		       withSWL (GS.add(#spillWorklist wl, v))
		else wl
	    end
	)
	wl
	(nodeMoves(u, wl))

fun freeze(wl: WL, m_nodes, K) =
    let val u::freezeWorklist = GS.listItems (#freezeWorklist wl)
	val wl = wl withFWL (GS.fromList freezeWorklist)
		    withSWL (GS.add(#simplifyWorklist wl, u))
    in
	freezeMoves(u, wl, m_nodes, K)
    end

fun simpify(wl: WL) =
    let val n::_ = GS.listItems (#simplifyWorklist wl)
	val simplifyWorklist = GS.delete(#simplifyWorklist wl, n)
	val selectStack = n::(#selectStack wl)
	val wl = wl withSWL simplifyWorklist withSS selectStack
    in
	GS.foldl decrementDegree wl (adjacent(n, wl))
    end

fun loop(wl: WL, spillCosts, f_moves, tnode, K) =
    let
	fun selectSpill(degree, spillWorklist) =
	    let
		fun cost(n) = (Real.fromInt(spillCosts n)) /
			      (Real.fromInt(valOf(GT.look(degree, n))))
		fun select (h::nil) = h
		  | select(h::t) = let val c = cost h and n = select t
				       val c' = cost n
				   in if c < c' then h else n end
		  | select nil = raise Empty
	    in
		select(GS.listItems spillWorklist)
	    end

	fun m_nodes m = case GT.look(f_moves, m) of
			    SOME (from, to) => (tnode from, tnode to)
			  | NONE => ICE "m_nodes"

	fun loop'(wl: WL) = (
	    if not(GS.isEmpty (#simplifyWorklist wl)) then
		loop'(simpify wl)
	    else if not(GS.isEmpty (#worklistMoves wl)) then
		loop'(coalesce(wl, m_nodes, K))
	    else if not(GS.isEmpty (#freezeWorklist wl)) then
		loop'(freeze(wl, m_nodes, K))
	    else
		let val spillWorklist = #spillWorklist wl
		in if not(GS.isEmpty spillWorklist) then
		       let val m = selectSpill(#degree wl, spillWorklist)
		       in
			   loop'(wl
				 withSWL (GS.add(#simplifyWorklist wl, m))
				 withPWL (GS.delete(spillWorklist, m)))
		       end
		   else wl (* done *)
		end
	)
    in
	loop' wl
    end


fun assignColors(wl: WL,
		 result: color GT.table,
		 precolored: G.node -> bool,
		 allcolors: S.set) =
    case (#selectStack wl) of
	nil =>
	(wl,
	 GS.foldl (fn (n, result) =>
		      let val m = getAlias(n, wl)
		      in case GT.look(result, m) of
			     SOME c => GT.enter(result, n, c)
			   | NONE => (assert("ASSIGN", GS.member(#spilledNodes wl, m));
				      result)
		      end)
		  result
		  (#coalescedNodes wl))
      | (n::selectStack) =>
	let
	    val adjs = valOf(GT.look(#adjList wl, n))
	    val coloredNodes = #coloredNodes wl
	    val spilledNodes = #spilledNodes wl
	in
	    case S.listItems(
		     GS.foldl
			 (fn (w, cs) =>
			     let val v = getAlias(w, wl)
			     in if GS.member(coloredNodes, v) orelse (precolored v)
				then S.subtract(cs, valOf(GT.look(result, v)))
				else cs
			     end)
			 allcolors
			 adjs) of
		 [] => assignColors(
			  wl withSS selectStack
			     withPN (GS.add(spilledNodes, n)),
			  result,
			  precolored, allcolors)
	       | (c::_) => assignColors(
			      wl withSS selectStack
				 withCoN (GS.add(coloredNodes, n)),
			      GT.enter(result, n, c),
			      precolored, allcolors)
	end


fun color {interference: Liveness.igraph,
	   initial: allocation,
	   spillCosts: Graph.node -> int,
	   registers: Frame.register list,
	   flowgraph: Flow.flowgraph,
	   instrlist: Flow.Graph.node list} =
    let
	val Liveness.IGRAPH{graph, gtemp, tnode, ...}  = interference
	val allnodes = G.nodes graph
	val allnodes_set = GS.fromList allnodes

	(* for debugging *)
	val _ = (allnodes_r := allnodes)
	val _ = (n2t_r := (foldl (fn (n, m) => GT.enter(m, n, gtemp(n)))
				GT.empty
				allnodes))

	val Flow.FGRAPH {ismove = f_moves,...} = flowgraph

	val K = length registers
	val _ = (K_r := K)
	val allcolors = S.fromList registers
	val (precolored, color0) =
	    foldl (fn (n, (s, m)) =>
		      (case TT.look(initial, gtemp n) of
			   SOME r => (GS.add(s, n),
				      GT.enter(m, n, r))
			 | NONE => (s, m)))
		  (GS.empty, GT.empty)
		  allnodes
	val nonprecolored = GS.difference(allnodes_set, precolored)
	val _ = (precolored_r := precolored)
	val _ = (nonprecolored_r := nonprecolored)
	fun precolored_fn n = GS.member(precolored, n)

	(* build initial worklists, move lists, etc. *)
	val (adjSet0, adjList0, degree0) =
	    foldl (fn (n, (a, m, d)) =>
		      let val l = GS.listItems(GS.fromList(G.adj n))
			  val a' = foldl (fn (u, s) =>
					     G.AdjSet.add(
						 G.AdjSet.add(s, G.NodePair(n, u)),
						 G.NodePair(u, n)))
					 a l
		      in if GS.member(nonprecolored, n)
			 then (a', GT.enter(m, n, GS.fromList l), GT.enter(d, n, length l))
			 else (a', m, d)
		      end)
		  (G.AdjSet.empty, GT.empty, GT.empty)
		  allnodes

	val (moveList0, worklistMoves0) =
	    foldr (fn (n, (ml, wm)) =>
		      (case GT.look(f_moves, n) of
			   SOME (from, to) =>
			   let val nf = tnode from
			       and nt = tnode to
			       val sf = case GT.look(ml, nf) of
					    SOME s => GS.add(s, n)
					  | NONE => GS.singleton(n)
			       and st = case GT.look(ml, nt) of
					    SOME s => GS.add(s, n)
					  | NONE => GS.singleton(n)
			   in
			       (GT.enter(GT.enter(ml, nf, sf), nt, st),
				GS.add(wm, n))
			   end
			 | NONE => (ml, wm)))
		  (GT.empty, GS.empty)
		  instrlist

	(* no coalescing
	val (moveList0, worklistMoves0) = (GT.empty, GS.empty) *)

	val (spillWorklist0,
	     freezeWorklist0,
	     simplifyWorklist0) =
	    GS.foldl (fn (n, (spills, freezes, simplifies)) =>
			 let val d = valOf(GT.look(degree0, n))
			 in if d >= K then
				(GS.add(spills, n), freezes, simplifies)
			    else if isSome(GT.look(moveList0, n)) then
				(spills, GS.add(freezes, n), simplifies)
			    else
				(spills, freezes, GS.add(simplifies, n))
			 end)
		     (GS.empty, GS.empty, GS.empty)
		     nonprecolored

	val wl0: WL = {
	    simplifyWorklist = simplifyWorklist0,
	    freezeWorklist = freezeWorklist0,
	    spillWorklist = spillWorklist0,
	    spilledNodes = GS.empty,
	    coalescedNodes = GS.empty,
	    coloredNodes = GS.empty,
	    selectStack = nil,
	    coalescedMoves = GS.empty,
	    constrainedMoves = GS.empty,
	    frozenMoves = GS.empty,
	    worklistMoves = worklistMoves0,
	    activeMoves = GS.empty,
	    adjSet = adjSet0,
	    adjList = adjList0,
	    degree = degree0,
	    moveList = moveList0,
	    alias = GT.empty
	}

	val wl = loop(wl0, spillCosts, f_moves, tnode, K)
	val (wl, color) = assignColors(wl, color0, precolored_fn, allcolors)
    in
	(foldl (fn (n, t) => case GT.look(color, n) of
				 SOME c => TT.enter(t, gtemp n, c)
			       | NONE => t)
	       TT.empty
	       allnodes,
	 map gtemp (GS.listItems (#spilledNodes wl)))
    end

end
