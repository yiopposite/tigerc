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
    val RV: Temp.temp
    val RAX: Temp.temp
    val RDX: Temp.temp

    eqtype register
    val tempMap: register Temp.Table.table
    val tempName: Temp.temp -> string
    val registerList: register list
    val regNum: register -> int
    val regName: register -> string
    structure RegTable : TABLE sharing type RegTable.key = register

    val wordSize: int
    val exp: access -> Tree.exp -> Tree.exp
    val fp: int -> Tree.exp

    datatype frag = PROC of {body: Tree.stm, frame: frame}
		  | STRING of Temp.label * string
    val getResult: unit -> frag list

    val addStringLiteral: Temp.label * string -> unit
    val addProc: frame * Tree.stm -> unit
    val procEntryExit: frame * Assem.instr list-> Assem.instr list

    (* test *)
    val fname: frame -> string
    val accessToString: access -> string
    val locals: frame -> access list
end

structure X86Frame : FRAME =
struct

datatype access = InFrame of int | InReg of Temp.temp
datatype frame = Frame of {name: Temp.label,
			   formals: access list,
			   locals: access list,
			   tos: int ref,
			   fname: string}

fun newFrame {name, formals, fname} =
    let
	val (formals', tos) =
	    foldl (fn (esc, (formals, offset))
		      => (*if esc then ((InFrame offset)::formals, offset + 4)
			   else ((InReg (Temp.newtemp ()))::formals, offset))*)
			(* 32-bit x86 *)
			((InFrame offset)::formals, offset + 4))
		  ([], 8) formals
    in
	Frame {name = name,
	       formals = rev formals',
	       locals = [],
	       tos = ref tos,
	       fname = fname}
    end

fun name (Frame {name, ...}) = name
fun fname (Frame {fname, ...}) = fname
fun formals (Frame {formals, ...}) = formals
fun locals (Frame {locals, ...}) = locals
fun allocLocal (Frame {tos, ...}) esc =
    if esc then (InFrame (!tos)) before tos := !tos + 4
    else InReg (Temp.newtemp())

(* rax, rbx, rcx, rdx, rbp, rsp, rsi, rdi, r8, r9, r10, r11, r12, r13, r14, r15 *)
val FP : Temp.temp = 4
val RV : Temp.temp = 0
val SP : Temp.temp = 5
val RAX : Temp.temp = 0
val RDX : Temp.temp = 3

datatype register = Rax | RBX | RCX | Rdx | RBP | RSP | RSI | RDI
		    | R8 | R9 | R10 | R11 | R12 | R13 | R14 | R15


fun regNum Rax = 0 | regNum RBX = 1 | regNum RCX = 2 | regNum Rdx = 3
    | regNum RBP = 4 | regNum RSP = 5 | regNum RSI = 6 | regNum RDI = 7
    | regNum R8 = 8 | regNum R9 = 9 | regNum R10 = 10 | regNum R11 = 11
    | regNum R12 = 12 | regNum R13 = 13 | regNum R14 = 14 | regNum R15 = 15

fun regName Rax = "%rax" | regName RBX = "%rbx"
    | regName RCX = "%rcx" | regName Rdx = "%rdx"
    | regName RBP = "%rbp" | regName RSP = "%rsp"
    | regName RSI = "%rsi" | regName RDI = "%rdi"
    | regName R8 = "%r8" | regName R9 = "%r9"
    | regName R10 = "%r10" | regName R11 = "%r11"
    | regName R12 = "%r12" | regName R13 = "%r13"
    | regName R14 = "%r14" | regName R15 = "%r15"

structure RegTable = IntMapTable(type key = register
				 fun getInt r = regNum r)

val registerList = [Rax, RBX, RCX, Rdx, RBP, RSP, RSI, RDI
		   , R8, R9, R10, R11, R12, R13, R14, R15]

val tempMap = foldl (fn (k, t) => Temp.Table.enter(t, k, List.nth(registerList, k)))
		    Temp.Table.empty
		    (List.tabulate(length registerList, fn i => i))

val specialregs = [FP, RV]
val argregs = []
val calleesaves = []
val callersaves = []

fun tempName t =
    case Temp.Table.look(tempMap, t) of
	SOME r => regName r
      | NONE => Temp.makestring t


val wordSize = 4

(* implicit first parameter, at offset +8 from FP *)
val staticLink = Tree.CONST 8

fun exp (InFrame offset) fp = Tree.MEM (Tree.BINOP (Tree.PLUS,
						    Tree.CONST offset,
						    fp))
  | exp (InReg reg) _ = Tree.TEMP reg

fun fp 0 = Tree.TEMP FP
  | fp nested_level = Tree.MEM (Tree.BINOP (Tree.PLUS,
					    fp (nested_level - 1),
					    staticLink))
			       
datatype frag = PROC of {body: Tree.stm, frame: frame}
	      | STRING of Temp.label * string

val result: frag list ref = ref []

fun reset () = (Temp.reset(); result := [])

fun addStringLiteral s = result := (STRING s) :: !result
fun addProc (frame, exp) = result := PROC {body=exp, frame=frame} :: !result

fun getResult () = !result

fun accessToString (InFrame i) = "m" ^ Int.toString i
  | accessToString (InReg t) = Temp.tempname t

structure A = Assem

fun procEntryExit(frame, body) =
    [A.OPER {asm="\tpushq\t`s0\n", src=[FP], dst=[], jmp=NONE},
     A.MOVE {asm="\tmovq\t`s0, `d0\n", src=SP, dst=FP}
    ]
    @ body
    @ [A.OPER {asm="\tleave\n", src=[FP], dst=[SP, FP], jmp=NONE},
       A.OPER {asm="\tret\n", src=[], dst=[], jmp=NONE}]

end

structure Frame : FRAME = X86Frame
