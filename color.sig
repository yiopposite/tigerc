signature COLOR = 
sig
  structure Frame : FRAME

  type allocation = Frame.register Temp.Table.table

  val color: {interference: Liveness.igraph,
	      initial: allocation,
	      spillCosts: Graph.node -> int,
	      registers: Frame.register list,
	      flowgraph: Flow.flowgraph,
	      instrlist: Flow.Graph.node list}
	     -> allocation * Temp.temp list
end
