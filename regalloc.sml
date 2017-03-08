structure Regalloc : REG_ALLOC =
struct
  structure Frame = X86Frame
  type allocation = Frame.register Temp.Table.table

  structure TT = Temp.Table

  fun rewriteProgram(instrs, frame, temp) =
      (instrs, frame)

  fun alloc(instrs, frame) =
      let val (fgraph, nlist, imap) = Flow.instr2graph instrs
	  val (igraph, live_outs, spillCosts) = Liveness.interferenceGraph(fgraph, nlist)
      in case Color.color {interference = igraph,
			   initial = Frame.tempMap,
			   spillCosts = spillCosts,
			   registers = Frame.registerList} of
	     (allocation, nil) => (instrs, frame, allocation)
	   | (_, t::_) => alloc(rewriteProgram(instrs, frame, t))
      end
end

(* test *)
local
    exception FAILED of string
    val prog = "let var i := 0 in while i < 5 do (i := i + 1); i end"
    val absyn = Parse.parse_str prog
    val [Frame.PROC{body, frame}] = (FindEscape.findEscape absyn; Semant.transProg absyn)
    val stms = Canon.traceSchedule(Canon.basicBlocks(Canon.linearize body))
    (*val _ = app (fn s => Printtree.printtree(TextIO.stdOut,s)) stms*)

    val format = Assem.format Frame.tempName
    fun printinstr out instr = TextIO.output(out, format instr)
    val instrs = List.concat(map (CodeGen.codegen frame) stms)
    (*val _ = app (printinstr TextIO.stdOut) instrs*)
    val instrs = Frame.procEntryExit(frame, instrs)
    val _ = app (printinstr TextIO.stdOut) instrs

    val (instrs, frame, alloc) = Regalloc.alloc(instrs, frame)
    fun t2r a t = case Temp.Table.look(a, t) of
		      SOME r => Frame.regName r
		    | NONE => raise FAILED "Not found TT"
    val format = Assem.format (t2r alloc)
    fun printinstr instr = print(format instr)
    val _ = app printinstr instrs
in
end
