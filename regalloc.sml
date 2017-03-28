structure Regalloc : REG_ALLOC =
struct
  structure Frame = X86Frame
  type allocation = Frame.register Temp.Table.table

  structure A = Assem
  structure T = Temp
  structure F = Frame
  structure TT = Temp.Table

  val itoa = Int.toString

  fun rewriteProgram(instrs, frame, spills) = let
      fun find(t, ts) = List.exists (fn x => x=t) ts
      fun update(t, t', ts) = foldr (fn (x, acc) => if x=t then t'::acc else x::acc) [] ts
      (*val _ = print("***SPILLING " ^
		    String.concatWith " " (map Temp.tempname spills) ^ "\n")*)
      fun rewrite1(spill, (instrs, frame)) =
	  let val _ = F.allocLocal frame true
	      val tos = F.frameSize frame
	  in (foldr
		  (fn (i as A.OPER{asm, dst, src, jmp}, acc) =>
		      if find(spill, dst) then
			  if find(spill, src) then
			      let val t1 = T.newtemp()
				  val t2 = T.newtemp()
			      in
				  (* load & store *)
				  A.OPER{asm="\tmovq\t-" ^ itoa tos ^ "(`s0), `d0\n",
					 src=[F.FP], dst=[t1], jmp=NONE} ::
				  A.OPER{asm=asm, jmp=jmp,
					 dst=update(spill, t2, dst),
					 src=update(spill, t1, src)} ::
				  A.OPER{asm="\tmovq\t`s0, -" ^ itoa tos ^ "(`s1)\n",
					 src=[t2, F.FP], dst=[], jmp=NONE}
				  :: acc
			      end
			  else
			      let val t = T.newtemp() in
				  A.OPER{asm=asm,src=src,dst=update(spill, t, dst),jmp=jmp} ::
				  (* store *)
				  A.OPER{asm="\tmovq\t`s0, -" ^ itoa tos ^ "(`s1)\n",
					 src=[t, F.FP], dst=[], jmp=NONE}
				  :: acc
			      end
		      else if find(spill, src) then
			  let val t = T.newtemp() in
			      (* load *)
			      A.OPER{asm="\tmovq\t-" ^ itoa tos ^ "(`s0), `d0\n",
				     src=[F.FP], dst=[t], jmp=NONE} ::
			      A.OPER{asm=asm,dst=dst,src=update(spill, t, src),jmp=jmp}
			      :: acc
			  end
		      else
			  i::acc
		  | (i as A.MOVE{asm, dst, src}, acc) =>
		    if dst = src then acc
		    else if dst = spill then
			let val t = T.newtemp()
			in A.MOVE{asm=asm,dst=t,src=src} ::
			   A.OPER{asm="\tmovq\t`s0, -" ^ itoa tos ^ "(`s1)\n",
				  src=[t, F.FP], dst=[], jmp=NONE}
			   :: acc
			end
		    else if src = spill then
			let val t = T.newtemp()
			in
			    A.OPER{asm="\tmovq\t-" ^ itoa tos ^ "(`s0), `d0\n",
				   src=[F.FP], dst=[t], jmp=NONE} ::
			    A.MOVE{asm=asm,dst=dst,src=t}
			    :: acc
			end
		    else i::acc
		  | (i as A.LABEL{...}, acc) => i::acc)
		  [] instrs,
	      frame)
	  end
  in
      foldl rewrite1 (instrs, frame) spills
  end

  fun alloc(instrs, frame) =
      let fun alloc'(instrs, frame) =
	      let val (fgraph, nlist, imap) = Flow.instr2graph instrs
		  val (igraph, live_outs, spillCosts) = Liveness.interferenceGraph(fgraph, nlist)
	      in case Color.color {interference = igraph,
				   initial = Frame.tempMap,
				   spillCosts = spillCosts,
				   registers = Frame.registerList,
				   flowgraph = fgraph,
				   instrlist = nlist} of
		     (allocation, nil) => (instrs, frame, allocation)
		   | (_, spills) => alloc'(rewriteProgram(instrs, frame, spills))
	      end
	  val (instrs', frame', allocation) = alloc'(instrs, frame)
      in
	  (foldr (fn (i as A.MOVE{dst,src,...}, acc) =>
		     if Temp.Table.look(allocation, dst) = Temp.Table.look(allocation, src)
		     then acc else i::acc
		 | (i, acc) => i::acc) [] instrs',
	   frame',
	   allocation)
      end
end
