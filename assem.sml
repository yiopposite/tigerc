structure Assem = struct

  type reg = string
  type temp = Temp.temp
  type label = Temp.label

  datatype instr = OPER of {asm: string,
			    dst: temp list,
			    src: temp list,
			    jmp: label list option}
                 | LABEL of {asm: string, lab: Temp.label}
                 | MOVE of {asm: string,
			    dst: temp,
			    src: temp}

  fun format saytemp =
    let 
	fun speak(asm,dst,src,jmp) =
	    let val saylab = Symbol.name    
		fun f(#"`":: #"s":: i::rest) = 
		    (explode(saytemp(List.nth(src,ord i - ord #"0"))) @ f rest)
		  | f( #"`":: #"d":: i:: rest) = 
		    (explode(saytemp(List.nth(dst,ord i - ord #"0"))) @ f rest)
		  | f( #"`":: #"j":: i:: rest) = 
		    (explode(saylab(List.nth(jmp,ord i - ord #"0"))) @ f rest)
		  | f( #"`":: #"`":: rest) = #"`" :: f rest
		  | f( #"`":: _ :: rest) = ErrorMsg.impossible "bad Assem format"
		  | f(c :: rest) = (c :: f rest)
		  | f nil = nil
	    in implode(f(explode asm))
	    end
      in fn OPER{asm,dst,src,jmp=NONE} => speak(asm,dst,src,nil)
          | OPER{asm,dst,src,jmp=SOME j} => speak(asm,dst,src,j)
	  | LABEL{asm,...} => asm
	  | MOVE{asm,dst,src} => speak(asm,[dst],[src],nil)
     end
end
