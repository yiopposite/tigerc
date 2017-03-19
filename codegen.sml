signature CODEGEN =
sig
    structure Frame : FRAME
    val codegen: Frame.frame -> Tree.stm -> Assem.instr list
end

structure CodeGen : CODEGEN = struct

structure Frame = X86Frame

structure T = Tree
structure A = Assem
structure F = Frame

fun ICE msg = ErrorMsg.impossible ("CODEGEN: " ^ msg)

fun itoa i = if i < 0 then ("-" ^ (Int.toString(~i)))
	     else Int.toString i

fun codegen (frame: F.frame) (stm: T.stm) = let
    val ilist: A.instr list ref = ref []

    fun emit i = ilist := i :: !ilist

    fun relJ T.EQ = "je"
      | relJ T.NE = "jne"
      | relJ T.LT = "jl"
      | relJ T.GT = "jg"
      | relJ T.LE = "jle"
      | relJ T.GE =  "jge"
      | relJ T.ULT = "jb"
      | relJ T.UGT = "ja"
      | relJ T.ULE = "jbe"
      | relJ T.UGE = "jnb"

    and munchStm (T.SEQ (s1, s2)) = (munchStm s1; munchStm s2)
      (* STORE *)
      | munchStm (T.MOVE(T.MEM(T.BINOP(T.PLUS, e1, T.CONST i)), T.CONST j)) =
	emit (A.OPER {asm="\tmovq\t$" ^ itoa j ^ ", " ^ itoa i ^ "(`s0)\n",
		      src=[munchExp e1], dst=[], jmp=NONE})
      | munchStm (T.MOVE(T.MEM(T.BINOP(T.PLUS, T.CONST i, e1)), T.CONST j)) =
	emit (A.OPER {asm="\tmovq\t$" ^ itoa j ^ ", " ^ itoa i ^ "(`s0)\n",
		      src=[munchExp e1], dst=[], jmp=NONE})

      | munchStm (T.MOVE(T.MEM(T.BINOP(T.PLUS, e1, T.CONST i)), e2)) =
	emit (A.OPER {asm="\tmovq\t`s1, " ^ itoa i ^ "(`s0)\n",
		      src=[munchExp e1, munchExp e2], dst=[], jmp=NONE})
      | munchStm (T.MOVE(T.MEM(T.BINOP(T.PLUS, T.CONST i, e1)), e2)) =
	emit (A.OPER {asm="\tmovq\t`s1, " ^ itoa i ^ "(`s0)\n",
		      src=[munchExp e1, munchExp e2], dst=[], jmp=NONE})

      | munchStm (T.MOVE(T.MEM(e1), T.MEM(e2))) =
	ICE "munchStm MOVE MEM to MEM"

      | munchStm (T.MOVE(T.MEM(e1), e2)) =
	emit (A.OPER {asm="\tmovq\t`s1, (`s0)\n",
		      src=[munchExp e1, munchExp e2], dst=[], jmp=NONE})

      (* LOAD *)
      | munchStm (T.MOVE(e1, T.MEM(T.BINOP(T.PLUS, e2, T.CONST i)))) =
	emit (A.OPER {asm="\tmovq\t" ^ itoa i ^ "(`s0), `d0\n",
		      src=[munchExp e2], dst=[munchExp e1], jmp=NONE})
      | munchStm (T.MOVE(e1, T.MEM(T.BINOP(T.PLUS, T.CONST i, e2)))) =
	emit (A.OPER {asm="\tmovq\t" ^ itoa i ^ "(`s0), `d0\n",
		      src=[munchExp e2], dst=[munchExp e1], jmp=NONE})

      | munchStm (T.MOVE(e1, T.MEM(e2))) =
	emit (A.OPER {asm="\tmovq\t(`s0), `d0\n",
		      src=[munchExp e2], dst=[munchExp e1], jmp=NONE})

      (* MOVE *)
      | munchStm (T.MOVE(T.CONST i, T.CONST j)) =
	ICE "munchStm MOVE CONST to CONST"

      | munchStm (T.MOVE(e1, T.CONST i)) =
	emit (A.OPER {asm="\tmovq\t$" ^ itoa i ^ ", `d0\n",
		      src=[], dst=[munchExp(e1)], jmp=NONE})

      | munchStm (T.MOVE(T.TEMP d, T.BINOP(T.PLUS, T.TEMP s, T.CONST i))) = (
	if d <> s then
	    emit (A.MOVE {asm="\tmovq\t`s0, `d0\n", src=s, dst=d})
	else ();
	emit (A.OPER {asm="\taddq\t$" ^ itoa i ^ ", `d0\n",
			  src=[d], dst=[d], jmp=NONE}))
      (*| munchStm (T.MOVE(T.TEMP d, T.BINOP(T.PLUS, T.CONST i, T.TEMP s))) = (
	if d <> s then
	    emit (A.MOVE {asm="\tmovq\t`s0, `d0\n", src=s, dst=d})
	else ();
	emit (A.OPER {asm="\taddq\t$" ^ itoa i ^ ", `d0\n",
			  src=[d], dst=[d], jmp=NONE}))*)

      | munchStm (T.MOVE(e1, e2)) =
	emit (A.MOVE {asm="\tmovq\t`s0, `d0\n",
		      src=munchExp(e2),
		      dst=munchExp(e1)})

      | munchStm (T.EXP e) = (ignore (munchExp e))
      | munchStm (T.LABEL l) =
	emit (A.LABEL {asm=Temp.labelname l ^ ":\n", lab = l})
      | munchStm (T.JUMP (T.NAME lab, el)) =
	emit (A.OPER {asm="\tjmp\t" ^ Temp.labelname lab ^ "\n",
		      src=[], dst=[],
		      jmp=SOME el})
      | munchStm (T.JUMP _) = ICE "munchStm JUMP"
      | munchStm (T.CJUMP (p, T.CONST i, e, t, f)) = (
	  emit (A.OPER {asm="\tcmp\t$" ^ itoa i ^ ", `s0\n",
			src=[munchExp e], dst=[], jmp=NONE});
	  emit (A.OPER {asm="\t" ^ relJ p ^ "\t`j0\n",
			src=[], dst=[], jmp=SOME [t, f]}))
      | munchStm (T.CJUMP (p, e, T.CONST i, t, f)) = (
	  emit (A.OPER {asm="\tcmp\t$" ^ itoa i ^ ", `s0\n",
			src=[munchExp e], dst=[], jmp=NONE});
	  emit (A.OPER {asm="\t" ^ relJ p ^ "\t`j0\n",
			src=[], dst=[], jmp=SOME [t, f]}))
      | munchStm (T.CJUMP (p, e1, e2, t, f)) = (
	  emit (A.OPER {asm="\tcmp\t`s0, `s1\n",
			src=[munchExp e2, munchExp e1], dst=[], jmp=NONE});
	  emit (A.OPER {asm="\t" ^ relJ p ^ "\t`j0\n",
			src=[], dst=[], jmp=SOME [t, f]}))

    and result f = let val t = Temp.newtemp () in f t; t end

    and binP T.PLUS  = "addq"
      | binP T.MINUS = "subq"
      | binP T.MUL   = "imul"
      | binP T.DIV   = "idiv"
      | binP T.AND   = "jle"
      | binP T.OR    =  "jge "
      | binP T.LSHIFT = "salq"
      | binP T.RSHIFT = "shrq"
      | binP T.ARSHIFT= "sarq"
      | binP T.XOR    = "xor"

    and munchExp (T.MEM (T.BINOP(T.PLUS, e, T.CONST i))) =
	result (fn r => emit (A.OPER {asm="\tmovq\t" ^ itoa i ^ "(`s0)" ^ ", `d0\n",
				      src=[munchExp e], dst=[r], jmp=NONE}))
      | munchExp (T.MEM (T.BINOP(T.PLUS, T.CONST i, e))) =
	result (fn r => emit (A.OPER {asm="\tmovq\t" ^ itoa i ^ "(`s0)" ^ ", `d0\n",
				      src=[munchExp e], dst=[r], jmp=NONE}))
      | munchExp (T.MEM e) =
	result (fn r => emit (A.OPER {asm="\tmovq\t(`s0), `d0\n", src=[munchExp e], dst=[r], jmp=NONE}))
      (*| munchExp (T.BINOP(T.DIV, e1, T.CONST i)) =
	result (fn r => (emit (A.OPER {asm="\txor\t`d0, `d0\n",
				       src=[], dst=[F.RDX], jmp=NONE});
			 emit (A.MOVE {asm="\tmovq\t`s0, `d0\n", src=munchExp e1, dst=F.RAX});
			 emit (A.OPER {asm="\tidiv\t$" ^ itoa i ^ "\n",
				       src=[F.RDX, F.RAX], dst=[F.RAX, F.RDX], jmp=NONE});
			 emit (A.MOVE {asm="\tmovq\t`s0, `d0\n", src=F.RAX, dst=r})))*)
      | munchExp (T.BINOP(T.DIV, e1, e2)) =
	result (fn r => (emit (A.OPER {asm="\txor\t`d0, `d0\n",
				       src=[], dst=[F.RDX], jmp=NONE});
			 emit (A.MOVE {asm="\tmovq\t`s0, `d0\n", src=munchExp e1, dst=F.RAX});
			 emit (A.OPER {asm="\tidiv\t`s0\n",
				       src=[munchExp e2, F.RDX, F.RAX], dst=[F.RAX, F.RDX], jmp=NONE});
			 emit (A.MOVE {asm="\tmovq\t`s0, `d0\n", src=F.RAX, dst=r})))
      | munchExp (T.BINOP(opc, e1, T.CONST i)) =
	result (fn r => (emit (A.MOVE {asm="\tmovq\t`s0, `d0\n", src=munchExp e1, dst=r});
			 emit (A.OPER {asm="\t" ^ binP opc ^ "\t$" ^ itoa i ^ ", `d0\n",
				       src=[r], dst=[r], jmp=NONE})))
      | munchExp (T.BINOP(opc, e1, e2)) =
	result (fn r => (emit (A.MOVE {asm="\tmovq\t`s0, `d0\n", src=munchExp e1, dst=r});
			 emit (A.OPER {asm="\t" ^ binP opc ^ "\t`s0, `d0\n",
				       src=[munchExp e2, r], dst=[r], jmp=NONE})))
      | munchExp (T.CALL(T.NAME l, el)) =
	let val k = length el - length F.argregs
	    val args = map munchExp el
	    val _ = if k > 0 then
			app (fn t =>
				emit (A.OPER {asm="\tpushq\t`s0\n",
					      src=[t], dst=[F.SP], jmp=NONE}))
			    (List.take(rev args, k))
		    else ()
	    val _ = ListPair.map
			   (fn (t, r) => (
			       emit (A.MOVE {asm="\tmovq\t`s0, `d0\n",
					     src=t, dst=r});
			       r))
			   (if k > 0 then List.drop(args, k) else args,
			    F.argregs)
	in result (fn r => (emit (A.OPER {asm="\tcall\t" ^ Temp.labelname l ^ "\n",
					  src=[],
					  dst=F.callersaves,
					  jmp=NONE});
			    if k > 0 then
				emit (A.OPER {asm="\taddq\t$"
						  ^ itoa (k * F.wordSize)
						  ^ ", `d0\n",
					      src=[], dst=[F.SP], jmp=NONE})
			    else ();
			    emit (A.MOVE {asm="\tmovq\t`s0, `d0\n", src=F.RV, dst=r})))
	end
      | munchExp (T.CALL(_, el)) = ICE "munchExp CALL"
      | munchExp (T.NAME l) =
	result (fn r => emit (A.OPER {asm="\tmovq\t$" ^ Temp.labelname l ^ ", `d0\n",
				      src=[], dst=[r], jmp=NONE}))
      | munchExp (T.CONST i) =
	result (fn r => emit (A.OPER {asm="\tmovq\t$" ^ itoa i ^ ", `d0\n",
				      src=[], dst=[r], jmp=NONE}))
      | munchExp (T.TEMP r) = r
      | munchExp (T.ESEQ _) = ICE "munchExp ESEQ"
in
    munchStm stm;
    rev (!ilist)
end

end
