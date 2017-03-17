signature TEMP = 
sig
  eqtype temp
  val newtemp : unit -> temp
  structure Table : TABLE sharing type Table.key = temp
  val makestring: temp -> string
  type label = Symbol.symbol
  val newlabel : unit -> label
  val namedlabel : string -> label

  structure Set : ORD_SET sharing type Set.Key.ord_key = temp

  val labelname: label -> string
  val tempname: temp -> string
  val reset: unit -> unit
end

