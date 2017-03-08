signature FRAME =
sig
    type frame
    type access

    val reset: unit -> unit

    val newFrame:   {name: Temp.label, formals: bool list, fname: string} -> frame
    val name: frame -> Temp.label
    val formals: frame -> access list
    val allocLocal: frame -> bool -> access

    val FP: Temp.temp
    val SP: Temp.temp
    val RV: Temp.temp
    val RAX: Temp.temp
    val RDX: Temp.temp

    val argregs : Temp.temp list
    val calleesaves : Temp.temp list
    val callersaves : Temp.temp list

    eqtype register

    val tempMap: register Temp.Table.table
    val tempName: Temp.temp -> string
    val registerList: register list
    val regName: register -> string
    structure RegTable : TABLE sharing type RegTable.key = register

    val wordSize: int
    val exp: access -> Tree.exp -> Tree.exp
    val fp: int -> Tree.exp

    datatype frag = PROC of {body: Tree.stm, frame: frame}
		  | STRING of Temp.label * string

    val procEntryExit1: frame * Tree.stm -> Tree.stm
    val procEntryExit: frame * Assem.instr list-> Assem.instr list

    (* test *)
    val fname: frame -> string
    val accessToString: access -> string
    val locals: frame -> access list
end

structure X86Frame : FRAME =
struct

val wordSize = 8
val offsetParam = 16 (* offset of first parameter from FP *)

val registerNames = #[
	"%rax", "%rcx", "%rdx", "%rbx", "%rbp", "%rsp", "%rsi", "%rdi",
	"%r8", "%r9", "%r10", "%r11", "%r12", "%r13", "%r14", "%r15"]

val RV : Temp.temp = 0
val RAX : Temp.temp = 0
val RCX : Temp.temp = 1
val RDX : Temp.temp = 2
val RBX : Temp.temp = 3
val FP : Temp.temp = 4
val SP : Temp.temp = 5
val RSI : Temp.temp = 6
val RDI : Temp.temp = 7
val R8 : Temp.temp = 8
val R9 : Temp.temp = 9
val R10 : Temp.temp = 10
val R11: Temp.temp = 11
val R12 : Temp.temp = 12
val R13 : Temp.temp = 13
val R14 : Temp.temp = 14
val R15 : Temp.temp = 15

val registerList = List.tabulate(Vector.length registerNames, fn i => i)

fun regName r = Vector.sub(registerNames, r)

type register = int
			 
structure RegTable = IntMapTable(type key = register fun getInt r = r)

val tempMap = foldl (fn (k, t) => Temp.Table.enter(t, k, k))
		    Temp.Table.empty registerList

val specialregs = [FP, RV]
val argregs = [RDI,RSI,RDX,RCX,R8,R9]
val argregs' = [RSI,RDX,RCX,R8,R9]
val callersaves = [RV,RDI,RSI,RDX,RCX,R8,R9,R10,R11]
val calleesaves = [FP,SP,RBX,R12,R13,R14,R15]

datatype access = InFrame of int | InReg of Temp.temp
datatype frame = Frame of {name: Temp.label,
			   formals: access list,
			   locals: access list,
			   tos: int ref,
			   fname: string}

fun newFrame {name, formals, fname} =
    let
	val (formals', offset) =
	    foldl (fn (true, (formals, offset))
		      => ((InFrame (~offset))::formals, offset + wordSize)
		  | (false, (formals, offset))
		    => ((InReg (Temp.newtemp()))::formals, offset))
		  ([], 8) formals
    in
	Frame {name = name,
	       formals = rev formals',
	       locals = [],
	       tos = ref offset,
	       fname = fname}
    end

fun name (Frame {name, ...}) = name
fun fname (Frame {fname, ...}) = fname
fun formals (Frame {formals, ...}) = formals
fun locals (Frame {locals, ...}) = locals
fun allocLocal (Frame {tos, ...}) esc =
    if esc then (InFrame (~(!tos))) before tos := !tos + wordSize
    else InReg (Temp.newtemp())

fun tempName t =
    case Temp.Table.look(tempMap, t) of
	SOME r => regName r
      | NONE => Temp.makestring t

fun exp (InFrame offset) fp = Tree.MEM (Tree.BINOP (Tree.PLUS,
						    Tree.CONST offset,
						    fp))
  | exp (InReg reg) _ = Tree.TEMP reg


val staticLink = Tree.CONST offsetParam

fun fp 0 = Tree.TEMP FP
  | fp nested_level = Tree.MEM (Tree.BINOP (Tree.PLUS,
					    fp (nested_level - 1),
					    staticLink))

datatype frag = PROC of {body: Tree.stm, frame: frame}
	      | STRING of Temp.label * string

fun reset () = Temp.reset()

fun procEntryExit1(Frame {formals as (sl::rest),locals,...}, body) =
    let
	val (moves, n, _) = 
	    foldl (fn (f, (acc, i, r::rs)) =>
		      (Tree.SEQ(Tree.MOVE(exp f (fp 0), Tree.TEMP r), acc), i+1, rs)
		  | (f, (acc, i, nil)) =>
		    (Tree.SEQ(Tree.MOVE(exp f (fp 0),
					exp(InFrame (16+(i-6)*8)) (fp 0)),
			      acc),
		     i+1, nil))
		  (Tree.MOVE(exp sl (fp 0), Tree.TEMP RDI), 1, argregs')
		  rest
    in Tree.SEQ(moves, body)
    end
  (* top level *)
  | procEntryExit1(Frame {formals=nil,locals,...}, body) =
    body

fun accessToString (InFrame i) = "m" ^ Int.toString i
  | accessToString (InReg t) = Temp.tempname t

structure A = Assem

fun procEntryExit(frame, body) =
    [A.OPER {asm="\tpushq\t`s0\n", src=[FP], dst=[SP], jmp=NONE},
     A.MOVE {asm="\tmovq\t`s0, `d0\n", src=SP, dst=FP}
    ]
    @ body
    @ [A.OPER {asm="\tleave\n", src=[FP], dst=[SP, FP], jmp=NONE},
       A.OPER {asm="\tret\n", src=[], dst=[], jmp=NONE}]

end

structure Frame : FRAME = X86Frame
