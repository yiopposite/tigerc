signature TRANSLATE =
sig
    type level
    type access
    type exp

    val outermost:  level
    val newLevel:   level * Temp.label * bool list * string option -> level
    val formals: level -> access list
    val allocLocal: level -> bool -> access

    exception BREAK

    val mkNil: unit -> exp
    val mkInt: int -> exp
    val mkStr: string -> exp

    val mkVar: access * level -> exp
    val mkFieldVar: exp * int -> exp
    val mkSubscriptVar: exp * exp -> exp

    val mkRecordExp: exp list * string -> exp
    val mkArrayExp: exp * exp -> exp

    val mkCallExp: Temp.label * level * level * exp list -> exp

    val mkEmptyStm: unit -> exp
    val mkAssignment: exp * exp -> exp

    val mkLetExp: (access * exp) list * exp -> exp

    val mkPlusExp: exp * exp -> exp
    val mkMinusExp: exp * exp -> exp
    val mkTimesExp: exp * exp -> exp
    val mkDivideExp: exp * exp -> exp

    val mkIntEq: exp * exp -> exp
    val mkIntNeq: exp * exp -> exp
    val mkIntLt: exp * exp -> exp
    val mkIntLe: exp * exp -> exp
    val mkIntGt: exp * exp -> exp
    val mkIntGe: exp * exp -> exp
    val mkStrEq: exp * exp -> exp
    val mkStrNeq: exp * exp -> exp
    val mkStrLt: exp * exp -> exp
    val mkStrLe: exp * exp -> exp
    val mkStrGt: exp * exp -> exp
    val mkStrGe: exp * exp -> exp
    val mkSeqExp: exp * exp list -> exp

    val mkRecEq: exp * exp -> exp
    val mkRecNeq: exp * exp -> exp
    val mkRecNilEq: exp -> exp
    val mkRecNilNeq: exp -> exp
    val mkNilNilEq: exp
    val mkNilNilNeq: exp
    val mkArrayEq: exp * exp -> exp
    val mkArrayNeq: exp * exp -> exp
				  
    val mkIfThen: exp * exp -> exp
    val mkIfThenElse: exp * exp * exp -> exp
				   
				   
    val enterLoop: unit -> unit
    val enterFunction: level -> unit
    val procEntryExit : level * exp -> unit

    val mkWhile: exp * exp -> exp
    val mkFor: access * exp * exp * exp -> exp
    val mkBreak: unit -> exp

    val getResult : unit -> Frame.frag list
    val reset: unit -> unit
end

structure Translate : TRANSLATE =
struct

fun ICE msg = ErrorMsg.impossible ("IR: " ^ msg)

val lp_stack: Temp.label list list ref = ref []

val frags: Frame.frag list ref = ref []

fun getResult () = !frags

structure D = BinaryMapFn(type ord_key=string val compare=String.compare)
val desctbl : Temp.label D.map ref = ref D.empty

fun reset () = (lp_stack := []; frags := []; desctbl := D.empty; Frame.reset ())

(* Frame *)

datatype level = Level of Frame.frame * level * unit ref * int * string option | TopLevel

type access = level * Frame.access

fun levelFrame TopLevel = ICE "levelFrame reaches TopLevel"
  | levelFrame (Level(frm, _, _, _, _)) = frm

fun levelParent TopLevel = ICE "levelParent reaches TopLevel"
  | levelParent (Level(_, parent, _, _, _)) = parent

fun levelID TopLevel = ICE "levelID reaches TopLevel"
  | levelID (Level(_, _, id, _, _)) = id

fun levelDepth TopLevel = ICE "levelDepth reaches TopLevel"
  | levelDepth (Level(_, _, _, depth, _)) = depth

fun levelFname TopLevel = ICE "levelFname reaches TopLevel"
  | levelFname (Level(_, _, _, _, name)) = name

fun newLevel (TopLevel, name, formals, NONE) =
    Level (Frame.newFrame {name=name, formals=formals, fname=""},
	   TopLevel, ref (), 0, NONE)
  | newLevel (parent, name, formals, SOME fname) =
    let val fname' = case (levelFname parent) of
			 SOME s => s ^ "::" ^ fname
		       | NONE => fname
    in Level (Frame.newFrame {name=name, formals=true::formals, fname=fname'},
	      parent, ref (), (levelDepth parent) + 1, SOME fname')
    end
  | newLevel _ = ICE "newlevel bad arguments"

fun formals (lev as Level (frm, _, _, _, _)) =
    map (fn a => (lev, a)) (Frame.formals frm)
  | formals TopLevel = []

fun allocLocal (lev as (Level (frm, _, _, _, _)))  (esc: bool) =
    (lev, (Frame.allocLocal frm esc))
  | allocLocal TopLevel _ = ICE "allocLocal reaches TopLevel"

val outermost = TopLevel

(* IR *)

structure T = Tree

datatype exp = Ex of T.exp
	     | Nx of T.stm
	     | Cx of Temp.label * Temp.label -> T.stm

fun seq [] = ICE "seq empty list"
  | seq [_] = ICE "seq singlar list"
  | seq [s1: T.stm, s2: T.stm] = T.SEQ (s1, s2)
  | seq (s::ss) = T.SEQ (s, seq ss)

fun unEx (Ex e) = e
  | unEx (Nx s) = T.ESEQ (s, T.CONST 0)
  | unEx (Cx genstm) =
    let val r = Temp.newtemp()
	val t = Temp.newlabel() and f = Temp.newlabel()
    in
	T.ESEQ (seq [T.MOVE ((T.TEMP r), (T.CONST 1)),
		     genstm(t, f),
		     T.LABEL f,
		     T.MOVE ((T.TEMP r), (T.CONST 0)),
		     T.LABEL t],
		T.TEMP r)
    end

fun unNx (Nx s) = s
  | unNx (Ex e) = T.EXP e
  | unNx (Cx genstm) =
    let val out = Temp.newlabel ()
    in
	T.SEQ (genstm (out, out),
	       T.LABEL out)
    end

fun unCx (Cx c) = c
  | unCx (Nx _) = ICE "unCx meets Nx"
  | unCx (Ex (T.CONST 0)) = (fn (t: Temp.label, f: Temp.label) => T.JUMP (T.NAME f, [f]))
  | unCx (Ex (T.CONST _)) = (fn (t: Temp.label, f: Temp.label) => T.JUMP (T.NAME t, [t]))
  | unCx (Ex e) = (fn (t, f) => T.CJUMP (T.NE, T.CONST 0, e, t, f))

fun mkNil () = Ex (T.CONST 0)
fun mkInt i = Ex (T.CONST i)

fun mkStr lit =
    let val lbl = Temp.newlabel ()
    in frags := (Frame.STRING(lbl, lit)) :: !frags;
       Ex (T.NAME lbl)
    end

fun mkVar (((Level (_, _, id, _, _)), acc), lv_acc) =
    let
	fun diff (Level(_, parent, id', _, _)) =
	    if id = id' then 0 else 1 + diff parent
	  | diff TopLevel = ICE "mkVar diff reach toplevel"
    in
	Ex (Frame.exp acc (Frame.fp (diff lv_acc)))
    end
  | mkVar (_, _) = ICE "mkVar bad level"

fun mkFieldVar (var, offset) =
    (* TODO: code for nil check *)
    Ex (T.MEM (T.BINOP (T.PLUS, unEx var,
			T.CONST (offset * Frame.wordSize))))
	
fun mkSubscriptVar(var, index) =
    (* TODO: code for boundary check *)
    Ex (T.MEM (T.BINOP (T.PLUS, unEx var,
			T.BINOP (T.MUL, unEx index, T.CONST Frame.wordSize))))

fun externalCall(label: Tree.label, args: T.exp list) =
    (* TODO: name conventions for C? *)
    T.CALL (T.NAME label, args)

fun mkCallExp(label,
	      Level(caller_frm, _, _, caller_depth, _),
	      Level(callee_frm, _, _, callee_depth, _),
	      args) =
    let
	val dis = caller_depth - callee_depth + 1
	val sl = if dis >= 0
		 then Frame.fp dis
		 else ICE "mkCallExp: calling deep nested function"
    in
	Ex (T.CALL (T.NAME label, sl :: map unEx args))
    end
  | mkCallExp(label, Level lv, TopLevel, args) =
     Ex (externalCall (label, map unEx args))
  | mkCallExp(label, TopLevel, _, _) =
    ICE "mkCallExp: TopLevel caller"

fun mkRecordExp (elist, desc) =
    let val n = length elist
	val b = Temp.newtemp()
	val l = case D.find(!desctbl, desc) of
		    SOME l => l
		  | NONE => let val l = Temp.newlabel();
			    in desctbl := D.insert(!desctbl, desc, l); l end
	val s0 = T.MOVE(T.TEMP b,
			T.CALL (T.NAME (Temp.namedlabel "malloc"),
				[T.CONST (n * Frame.wordSize)]))
    in
	if n = 0 then
	    Ex (T.ESEQ (s0, T.TEMP b))
	else
	    Ex (T.ESEQ (T.SEQ(s0, #2(
			      let val sn = T.MOVE(T.MEM(
						   T.BINOP(T.PLUS,
							   T.TEMP b,
							   T.CONST ((n-1) * Frame.wordSize))),
					      unEx (List.last elist))
			      in
				  foldr (fn (e, (i, acc)) =>
					    (i - 1,
					     T.SEQ(T.MOVE(
							T.MEM(T.BINOP(T.PLUS,
								      T.TEMP b,
								      T.CONST (i * Frame.wordSize))),
							unEx e),
						   acc)))
					(n - 2, sn)
					(List.take(elist, n-1))
			      end)),
			T.TEMP b))
    end		      

fun mkArrayExp (size, init) =
    let val b = Temp.newtemp()
	and s = Temp.newtemp()
	and i = Temp.newtemp()
	and loop_lbl = Temp.newlabel ()
	and body_lbl = Temp.newlabel ()
	and exit_lbl = Temp.newlabel ()
    in
	Ex (T.ESEQ(seq [T.MOVE(T.TEMP s, unEx size),
			T.MOVE(T.TEMP b,
			       T.CALL (T.NAME (Temp.namedlabel "malloc"),
				       [T.BINOP(T.MUL,
						T.TEMP s,
						T.CONST Frame.wordSize)])),

			T.MOVE(T.TEMP i, T.CONST 0),
			T.LABEL loop_lbl,
			T.CJUMP(T.GE, T.TEMP i, T.TEMP s, exit_lbl, body_lbl),
			T.LABEL body_lbl,
			T.MOVE(T.MEM(T.BINOP(T.PLUS,
					     T.TEMP b,
					     T.BINOP(T.MUL,
						     T.TEMP i,
						     T.CONST Frame.wordSize))),
			       unEx init),
			T.MOVE(T.TEMP i,
			       T.BINOP(T.PLUS, T.TEMP i, T.CONST 1)),
			T.JUMP (T.NAME loop_lbl, [loop_lbl]),
			T.LABEL exit_lbl],
		   T.TEMP b))
    end


fun mkEmptyStm () = Nx (T.EXP (T.CONST 0))

fun mkSeqExp (e, es) =
    case es of
	[] => ICE "mkSeqExp empty"
      | [e'] => Ex (T.ESEQ (unNx e', unEx e))
      | _ => Ex (T.ESEQ (seq (map unNx es), unEx e))

fun mkAssignment (lh, rh) = Nx (T.MOVE (unEx lh, unEx rh))

fun mkLetExp ([], body) = body
  | mkLetExp (((_, acc), e)::rest, body) =
    mkLetExp (rest,
	      Ex(T.ESEQ(T.MOVE (Frame.exp acc (T.TEMP Frame.FP), unEx e), unEx body)))

fun mkPlusExp (lh, rh) = Ex (T.BINOP (T.PLUS, unEx lh, unEx rh))
fun mkMinusExp (lh, rh) = Ex (T.BINOP (T.MINUS, unEx lh, unEx rh))
fun mkTimesExp (lh, rh) = Ex (T.BINOP (T.MUL, unEx lh, unEx rh))
fun mkDivideExp (lh, rh) = Ex (T.BINOP (T.DIV, unEx lh, unEx rh))

fun mkIntLt (lh, rh) = Cx (fn (t, f) => T.CJUMP (T.LT, unEx lh, unEx rh, t, f))
fun mkIntLe (lh, rh) = Cx (fn (t, f) => T.CJUMP (T.LE, unEx lh, unEx rh, t, f))
fun mkIntGt (lh, rh) = Cx (fn (t, f) => T.CJUMP (T.GT, unEx lh, unEx rh, t, f))
fun mkIntGe (lh, rh) = Cx (fn (t, f) => T.CJUMP (T.GE, unEx lh, unEx rh, t, f))

val strcmp = Temp.namedlabel "_Tiger_strcmp"

fun mkStrLt (lh, rh) =
    Cx (fn (t, f) => T.CJUMP (T.LT,
			      externalCall(strcmp, [unEx lh, unEx rh]),
			      T.CONST 0,
			      t, f))
fun mkStrLe (lh, rh) =
    Cx (fn (t, f) => T.CJUMP (T.LE,
			      externalCall(strcmp, [unEx lh, unEx rh]),
			      T.CONST 0,
			      t, f))
fun mkStrGt (lh, rh) =
    Cx (fn (t, f) => T.CJUMP (T.GT,
			      externalCall(strcmp, [unEx lh, unEx rh]),
			      T.CONST 0,
			      t, f))
fun mkStrGe (lh, rh) =
    Cx (fn (t, f) => T.CJUMP (T.GE,
			      externalCall(strcmp, [unEx lh, unEx rh]),
			      T.CONST 0,
			      t, f))

fun mkStrEq (lh, rh) =
    Cx (fn (t, f) => T.CJUMP (T.EQ,
			      externalCall(strcmp, [unEx lh, unEx rh]),
			      T.CONST 0,
			      t, f))
fun mkStrNeq (lh, rh) =
    Cx (fn (t, f) => T.CJUMP (T.NE,
			      externalCall(strcmp, [unEx lh, unEx rh]),
			      T.CONST 0,
			      t, f))

fun mkIntEq (lh, rh) = Cx (fn (t, f) => T.CJUMP (T.EQ, unEx lh, unEx rh, t, f))
fun mkIntNeq (lh, rh) = Cx (fn (t, f) => T.CJUMP (T.NE, unEx lh, unEx rh, t, f))

			   
fun mkRecEq (lh, rh) = Cx (fn (t, f) => T.CJUMP (T.EQ, unEx lh, unEx rh, t, f))
fun mkRecNeq (lh, rh) = Cx (fn (t, f) => T.CJUMP (T.NE, unEx lh, unEx rh, t, f))
fun mkRecNilEq (e) = Cx (fn (t, f) => T.CJUMP (T.EQ, unEx e, (T.CONST 0), t, f))
fun mkRecNilNeq (e) = Cx (fn (t, f) => T.CJUMP (T.NE, unEx e, (T.CONST 0), t, f))
val mkNilNilEq = Ex (T.CONST 1)
val mkNilNilNeq = Ex (T.CONST 0)

fun mkArrayEq (lh, rh) = Cx (fn (t, f) => T.CJUMP (T.EQ, unEx lh, unEx rh, t, f))
fun mkArrayNeq (lh, rh) = Cx (fn (t, f) => T.CJUMP (T.NE, unEx lh, unEx rh, t, f))

fun mkIfThen (test, then') =
    let val then_lbl = Temp.newlabel ()
	and exit_lbl = Temp.newlabel ()
    in
	Nx (seq [T.CJUMP(T.EQ, T.CONST 0, unEx test, exit_lbl, then_lbl),
		 T.LABEL then_lbl,
		 unNx then',
		 T.LABEL exit_lbl])
    end

fun mkIfThenElse (test, then', else') =
    let val then_lbl = Temp.newlabel ()
	and else_lbl = Temp.newlabel ()
	and exit_lbl = Temp.newlabel ()
	and ans = Temp.newtemp ()
    in
	Ex (T.ESEQ (seq [T.CJUMP(T.NE, T.CONST 0, unEx test, then_lbl, else_lbl),
			 T.LABEL then_lbl,
			 T.MOVE (T.TEMP ans, unEx then'),
			 T.JUMP (T.NAME exit_lbl, [exit_lbl]),
			 T.LABEL else_lbl,
			 T.MOVE (T.TEMP ans, unEx else'),
			 T.LABEL exit_lbl],
		    T.TEMP ans))
    end

exception BREAK

fun enterLoop () =
    let val exit_lbl = Temp.newlabel ()
    in
	lp_stack := (exit_lbl::(hd(!lp_stack)))::(tl(!lp_stack))
    end

fun leaveLoop () = lp_stack := (tl(hd(!lp_stack)))::(tl(!lp_stack))

fun lookLoop () = hd(hd(!lp_stack))

fun enterFunction (lev: level) = lp_stack := []::(!lp_stack)

fun procEntryExit (lev as Level(frm, parent, _, depth, _), body: exp) =
    let val _ = case lp_stack of
		    ref (x::xs) => (if not (null x)
				    then ICE "exitFunction: lp stack dirty"
				    else lp_stack := xs)
		  | ref [] => ICE "exitFunction: lp stack empty";
        val body = Frame.procEntryExit1(frm, T.MOVE (T.TEMP Frame.RV, unEx body))
    in
        frags := Frame.PROC {body=body, frame=frm} :: (!frags)
    end
  | procEntryExit _ = ICE "procEntryExit: Top level"


fun mkWhile (test, body) =
    let val loop_lbl = Temp.newlabel ()
	and body_lbl = Temp.newlabel ()
	and exit_lbl = lookLoop ()
    in
	leaveLoop ();
	Nx (seq [T.LABEL loop_lbl,
		 T.CJUMP(T.EQ, T.CONST 0, unEx test, exit_lbl, body_lbl),
		 T.LABEL body_lbl,
		 unNx body,
		 T.JUMP (T.NAME loop_lbl, [loop_lbl]),
		 T.LABEL exit_lbl])
    end

fun mkFor (acc: access, lo, hi, body) =
    let val loop_lbl = Temp.newlabel ()
	and exit_lbl = lookLoop ()
	and body_lbl = Temp.newlabel ()
	val var = Frame.exp (#2(acc)) (T.TEMP Frame.FP)
    in
	leaveLoop ();
	Nx (seq [T.MOVE (var, unEx lo),
		 T.LABEL loop_lbl,
		 T.CJUMP(T.GT, var, unEx hi, exit_lbl, body_lbl),
		 T.LABEL body_lbl,
		 unNx body,
		 T.MOVE (var, T.BINOP(T.PLUS, var, T.CONST 1)),
		 T.JUMP (T.NAME loop_lbl, [loop_lbl]),
		 T.LABEL exit_lbl])
    end

fun mkBreak () =
    let val lbl = lookLoop () handle Empty => raise BREAK
    in
	Nx (T.JUMP ((T.NAME lbl), [lbl]))
    end

end
