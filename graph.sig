signature GRAPH =
sig
    type graph
    type node

    val nodes: graph -> node list
    val succ: node -> node list
    val pred: node -> node list
    val adj: node -> node list   (* succ+pred *)
    val eq: node*node -> bool

    val newGraph: unit -> graph
    val newNode : graph -> node
    exception GraphEdge
    val mk_edge: {from: node, to: node} -> unit
    val rm_edge: {from: node, to: node} -> unit

    structure Table : TABLE 
    sharing type Table.key = node

    structure Set : ORD_SET
    sharing type Set.Key.ord_key = node

    datatype nodepair = NodePair of node * node
    structure AdjSet : ORD_SET sharing type AdjSet.Key.ord_key = nodepair

    val nodename: node->string  (* for debugging only *)

end
