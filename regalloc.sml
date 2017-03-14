structure Regalloc : REG_ALLOC =
struct
  structure Frame = X86Frame
  type allocation = Frame.register Temp.Table.table

  structure TT = Temp.Table

  fun rewriteProgram(instrs, frame, temp) =
      (print (Temp.tempname temp);
       (instrs, frame))

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
    (*val prog = "let var i := 0 in while i < 5 do (i := i + 1); i end"*)
    (*val prog = "print(\"Hello, world!\")"*)
    (*val prog = "let function add(a:int,b:int,c:int): int=a+b+c in add(1,2,3) end"*)
    val prog="let function add(a: int, b: int, c:int) : int = a + b + c in print(chr(ord(\"0\")+add(1,2,3))) end"
    val absyn = Parse.parse_str prog
    val frags = (FindEscape.findEscape absyn; Semant.transProg absyn)

    fun comp (Frame.PROC{body, frame}) =
	let val stms = Canon.traceSchedule(Canon.basicBlocks(Canon.linearize body))
	    val _ = app (fn s => Printtree.printtree(TextIO.stdOut,s)) stms

	    val instrs = List.concat(map (CodeGen.codegen frame) stms)
	    val instrs = Frame.procEntryExit2(frame, instrs)
	    val _ = app (print o Assem.format Frame.tempName) instrs

	    val (instrs, frame, alloc) = Regalloc.alloc(instrs, frame)
	    fun t2r a t = case Temp.Table.look(a, t) of
			      SOME r => Frame.regName r
			    | NONE => raise FAILED "Not found TT"
	    val format = Assem.format (t2r alloc)
	    val printinstr = print o format
	    val _ = app printinstr instrs
	in ()
	end
      | comp _ = ()

    val _ = app comp frags
in
end
