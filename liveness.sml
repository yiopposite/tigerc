structure Liveness:
sig
    datatype igraph =
	     IGRAPH of {graph: Graph.graph,
			tnode: Temp.temp -> Graph.node,
			gtemp: Graph.node -> Temp.temp,
			moves: (Graph.node * Graph.node) list}
    (*val interferenceGraph :
	Flow.flowgraph -> igraph * (Graph.node -> Temp.temp list)*)
    val interferenceGraph :
	Flow.flowgraph * Graph.node list -> igraph
					    * (Flow.Graph.node -> Temp.temp list)
					    * (Graph.node -> int)

    val show : TextIO.outstream * igraph * (Graph.node -> int) -> unit
end =
struct

structure G = Graph
structure F = Flow
structure GT = G.Table
structure TT = Temp.Table
structure GS = G.Set
structure TS = Temp.Set
structure S = IntListSet

fun ICE msg = ErrorMsg.impossible ("LIVENESS: " ^ msg)

datatype igraph =
	 IGRAPH of {graph: Graph.graph,
		    tnode: Temp.temp -> Graph.node,
		    gtemp: Graph.node -> Temp.temp,
		    moves: (Graph.node * Graph.node) list}

fun interferenceGraph (Flow.FGRAPH{control, def, use, ismove}: Flow.flowgraph,
		       nlist: Graph.node list) =
    let val nvec = Vector.fromList nlist
	val ntoi = Vector.foldli (fn (i, n, t) => GT.enter(t, n, i)) GT.empty nvec
	val ins = Array.array (length nlist, S.empty)
	val outs = Array.array (length nlist, S.empty)
	val repeat = ref true

	fun dprint(n, s) = (
	    print(G.nodename n
		  ^ (if valOf(GT.look(ismove, n)) then "M" else "")
		  ^ "("
		  ^ String.concatWith " " (map Temp.tempname (valOf(GT.look(def, n))))
		  ^ "): ");
	    print(String.concatWith " " (map Int.toString (S.listItems(s))));
	    print "\n")
 
	val _ = (* algorithm 10.4 *)
	    while (!repeat) do (
		repeat := false;
		Vector.appi (fn (i, n) =>
				let val ins' =
					S.union(S.fromList(valOf(GT.look(use, n))),
						S.difference(
						    Array.sub(outs, i),
						    S.fromList(valOf(GT.look(def, n)))))
				    val outs' = foldr (fn (s, acc) => S.union(s, acc))
						      S.empty
						      (map (fn s => Array.sub(ins, valOf(GT.look(ntoi, s))))
							   (G.succ(n)))
				in
				    if not (S.equal(ins', Array.sub(ins, i)))
				    then (Array.update(ins, i, ins'); repeat := true)
				    else ();
				    if not (S.equal(outs', Array.sub(outs, i)))
				    then (Array.update(outs, i, outs'); repeat := true)
				    else ()
				end)
			    nvec)

	val (igraph: G.graph,
	     tmap: G.node TT.table,
	     nmap: Temp.temp GT.table,
	     weights: int ref GT.table) =
	    foldl (fn (n, (igraph, tmap, nmap, weights)) =>
		      let val defs = TS.fromList(valOf(GT.look(def, n)))
			  val uses = TS.fromList(valOf(GT.look(use, n)))
			  fun add(t, (gh, tm, nm, wm)) =
			      case TT.look(tm, t) of
				  NONE => let val n' = G.newNode gh
					  in (gh,
					      TT.enter(tm, t, n'),
					      GT.enter(nm, n', t),
					      GT.enter(wm, n', ref 0))
					  end
				| SOME _ => (gh, tm, nm, wm)
		      in TS.foldl add (igraph, tmap, nmap, weights) (TS.union(defs, uses)) end)
		  (G.newGraph(), TT.empty, GT.empty, GT.empty)
		  (G.nodes control)

       (*val _ = Vector.appi
		   (fn (i, n) => let val ts = Array.sub(outs, i)
				     (*val _ = dprint(n, ts)*)
				 in app (fn d => S.app (fn t => (if d <> t
								 then let val dn = valOf(TT.look(tmap, d))
									  val tn = valOf(TT.look(tmap, t))
								      in G.mk_edge{from=dn, to=tn} end
								 else ())) ts)
					(valOf(GT.look(def, n)))
				 end)
		   nvec*)
	val _ =
	    Vector.appi
		(fn (i, n) => let val ts = Array.sub(outs, i)
				  (*val _ = dprint(n, ts)*)
			      in app (fn d => S.app (fn t =>
							(if d <> t then
							     let val dn = valOf(TT.look(tmap, d))
								 val tn = valOf(TT.look(tmap, t))
							     in if valOf(GT.look(ismove, n))
								   andalso
								   hd(valOf(GT.look(use, n))) = t
								then ()
								else G.mk_edge{from=dn, to=tn}
							     end
							 else ())) ts)
				     (valOf(GT.look(def, n)))
			      end)
		nvec

	fun tnode t = valOf(TT.look(tmap, t))
	fun gtemp n = valOf(GT.look(nmap, n))

	fun live_ins (n: Flow.Graph.node) = S.foldr (op::) [] (Array.sub(ins, valOf(GT.look(ntoi, n))))
	fun live_outs (n: Flow.Graph.node) = S.foldr (op::) [] (Array.sub(outs, valOf(GT.look(ntoi, n))))

	val moves: (Graph.node * Graph.node) list =
	    map (fn n => let val [d] = valOf(GT.look(def, n))
			     val [u] = valOf(GT.look(use, n))
			 in (tnode d, tnode u) end)
		(List.filter (fn n => valOf(GT.look(ismove, n))) nlist)

	val _ = app (fn n =>
		      let val defs = valOf(GT.look(def, n))
			  val uses = valOf(GT.look(use, n))
			  fun add t =
			      let val n = tnode t
				  val w = valOf(GT.look(weights, n))
			      in w := !w + 1
			      end
		      in (app add defs;
			  app add uses)
		      end)
		    (G.nodes control)
	fun spillCosts n = !(valOf(GT.look(weights, n)))

    in
	(IGRAPH {graph=igraph, tnode=tnode, gtemp=gtemp, moves=moves}, live_outs, spillCosts)
    end

fun show(out, (IGRAPH {graph, tnode, gtemp, moves}), spillCosts) =
    let fun pr s = TextIO.output(out, s)
	fun prl s = (pr s; pr "\n")

	fun nm n = Temp.tempname(gtemp n)

	fun show_node n = (
	    pr (nm n);
	    pr ("(" ^ Int.toString(spillCosts(n)) ^ "):\t");
	    prl (String.concatWith " " (map nm (GS.listItems(GS.fromList((Graph.adj n)))))))
    in
	app show_node (Graph.nodes graph)
    end


end
