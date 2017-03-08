structure Semant = struct

structure A = Absyn
structure S = Symbol
structure T = Types
structure E = Env
structure Tr = Translate

fun report(pos:int, msg:string): 'a = ErrorMsg.typeerror pos msg

val ICE = ErrorMsg.impossible

type expty = Tr.exp * T.ty

fun actualTy ty: T.ty =
    case ty of
	T.NAME(_, r) => (case !r of
			     SOME t => actualTy t
			   | NONE => ICE "actualTy meets NONE")
      | _ => ty

fun assignmentOK(T.RECORD _, T.NIL) = true
  | assignmentOK(T.RECORD(_, u), T.RECORD(_, u')) = u = u'
  | assignmentOK(T.INT, T.INT) = true
  | assignmentOK(T.STRING, T.STRING) = true
  | assignmentOK(T.ARRAY(_, u), T.ARRAY(_, u')) = u = u'
  | assignmentOK(_, _) = false
	
fun transExp(ve, te, lv: Tr.level, A.NilExp): expty = (Tr.mkNil(), T.NIL)
  | transExp(ve, te, lv, (A.IntExp i)) = (Tr.mkInt i, T.INT)
  | transExp(ve, te, lv, (A.StringExp (s, _))) = (Tr.mkStr s, T.STRING)
  | transExp(ve, te, lv, (A.VarExp v)) = transVar(ve, te, lv, v)

  | transExp(ve, te, lv, A.CallExp {func, args, pos}) =
    let
	fun check([], []) = ()
	  | check([], _) = report(pos, "formals are fewer than actuals")
	  | check(_, []) = report(pos, "actuals are fewer than formals")
	  | check(t::ts, (x:(Tr.exp * T.ty))::xs) =
	      if assignmentOK(t, #2(x)) then check(ts, xs)
	      else report(pos, "formals and actuals have incompatible types")
    in
	case S.look(ve, func) of
	    SOME ee => (
	     case ee of
		 E.FunEntry {formals, result, level, label} =>
		 let
		     val args' = map (fn a => transExp(ve, te, lv, a)) args
		     val _ = check (formals, args')
		 in
		     (Tr.mkCallExp(label, lv, level, map #1 args'), actualTy result)
		 end
	       | _ => report(pos, "'" ^ S.name(func) ^ "' is not a function"))
	  | NONE => report(pos, "undefined function '" ^ S.name(func) ^ "'")
    end

  | transExp(ve, te, lv, A.OpExp {left, oper=A.PlusOp,   right, pos}) =
    transArithExp(ve, te, lv, left, A.PlusOp, right, pos)
  | transExp(ve, te, lv, A.OpExp {left, oper=A.MinusOp,  right, pos}) =
    transArithExp(ve, te, lv, left, A.MinusOp, right, pos)
  | transExp(ve, te, lv, A.OpExp {left, oper=A.TimesOp,  right, pos}) =
    transArithExp(ve, te, lv, left, A.TimesOp, right, pos)
  | transExp(ve, te, lv, A.OpExp {left, oper=A.DivideOp, right, pos}) =
    transArithExp(ve, te, lv, left, A.DivideOp, right, pos)

  | transExp(ve, te, lv, A.OpExp {left, oper=A.LtOp,     right, pos}) =
    transCompExp(ve, te, lv, left, A.LtOp, right, pos)
  | transExp(ve, te, lv, A.OpExp {left, oper=A.LeOp,     right, pos}) =
    transCompExp(ve, te, lv, left, A.LeOp, right, pos)
  | transExp(ve, te, lv, A.OpExp {left, oper=A.GtOp,     right, pos}) =
    transCompExp(ve, te, lv, left, A.GtOp, right, pos)
  | transExp(ve, te, lv, A.OpExp {left, oper=A.GeOp,     right, pos}) =
    transCompExp(ve, te, lv, left, A.GeOp, right, pos)

  | transExp(ve, te, lv, A.OpExp {left, oper=A.EqOp,     right, pos}) =
    transEqExp(ve, te, lv, left, right, pos)
  | transExp(ve, te, lv, A.OpExp {left, oper=A.NeqOp,    right, pos}) =
    transNeqExp(ve, te, lv, left, right, pos)

  | transExp(ve, te, lv, A.SeqExp []) = (Tr.mkEmptyStm (), T.UNIT)
  | transExp(ve, te, lv, A.SeqExp es) =
    let
	val (last, rest) = case (rev es) of
			       (last::rest) => (#1(last), map #1 (rev rest))
			     | [] => ICE "SeqExp Empty"
	val es = map (fn e => #1(transExp(ve, te, lv, e))) rest
	val (e, t) = transExp(ve, te, lv, last)
    in
	(Tr.mkSeqExp(e, es), t)
    end

  | transExp(ve, te, lv, A.AssignExp {var, exp, pos}) =
    let
	val (e1, t1) = transVar(ve, te, lv, var)
	and (e2, t2) = transExp(ve, te, lv, exp)
	val _ = if (not (assignmentOK(t1, t2)))
		then report(pos, "assignment: type mismatch")
		else ()
    in
	(Tr.mkAssignment(e1, e2), T.UNIT)
    end

  | transExp(ve, te, lv, A.WhileExp {test, body, pos}) =
    let
	val (e1, t1) = transExp(ve, te, lv, test)
	val _ = Tr.enterLoop ()
	val (e2, t2) = transExp(ve, te, lv, body)
    in
	if t1 = T.INT then
	    if t2 = T.UNIT then
		(Tr.mkWhile (e1, e2), T.UNIT)
	    else report(pos, "body of while not unit")
	else report(pos, "test of while not int")
    end

  | transExp(ve, te, lv, A.ForExp {var, escape, lo, hi, body, pos}) =
    let
	val (e1, t1) = transExp(ve, te, lv, lo)
	and (e2, t2) = transExp(ve, te, lv, hi)
	val _ = (t1 = T.INT) orelse report(pos, "low index of for not int")
	and _ = (t2 = T.INT) orelse report(pos, "high index of for not int")
	val acc = Tr.allocLocal lv false
	val ve' = S.enter(ve, var, Env.VarEntry {access = acc, ty = T.INT})
	val _ = Tr.enterLoop ()
	val (e3, t3) = transExp(ve', te, lv, body)
	val _ = (t3 = T.UNIT) orelse report(pos, "body of for not unit")
    in
	(Tr.mkFor (acc, e1, e2, e3), T.UNIT)
    end

  | transExp(ve, te, lv, A.BreakExp pos) =
    ((Tr.mkBreak (), T.UNIT)
     handle Tr.BREAK => report(pos, "break outside for/while loop"))

  | transExp(ve, te, lv, A.IfExp {test, then', else'=NONE, pos}) =
    let
	val (e1, t1) = transExp(ve, te, lv, test)
	and (e2, t2) = transExp(ve, te, lv, then')
	val _ = (t1 = T.INT) orelse report(pos, "if-then test not int")
	val _ = (t2 = T.UNIT) orelse report(pos, "if-then body not unit")
    in
	(Tr.mkIfThen(e1, e2), T.UNIT)
    end

  | transExp(ve, te, lv, A.IfExp {test, then', else'=SOME else', pos}) =
    let
	val (e1, t1) = transExp(ve, te, lv, test)
	and (e2, t2) = transExp(ve, te, lv, then')
	and (e3, t3) = transExp(ve, te, lv, else')
	val _ = t1 = T.INT orelse report(pos, "test of if-else not int")
	and ty = case (t2, t3) of
		     (T.RECORD _, T.NIL) => t2
		   | (T.NIL, T.RECORD _) => t3
		   | (T.RECORD(_, u), T.RECORD(_, u')) =>
		     if u = u' then t2
		     else report(pos, "then-else of different record type")
		   | (T.INT, T.INT) => T.INT
		   | (T.UNIT, T.UNIT) => T.UNIT
		   | (T.NIL, T.NIL) => T.NIL
		   | (T.STRING, T.STRING) => T.STRING
		   | (T.ARRAY(_, u), T.ARRAY(_, u')) =>
		     if u = u' then t2
		     else report(pos, "then-else of different array type")
		   | (_, _) => report(pos, "types of then-else differ")
    in
	(Tr.mkIfThenElse(e1, e2, e3), ty)
    end
	
  | transExp(ve, te, lv, A.RecordExp {typ, fields, pos}) =
    let
	val ty = case S.look(te, typ) of
		     SOME ty => actualTy ty
		   | NONE => report(pos, "unknown record type " ^ S.name(typ))
	val members = case ty of
			  T.RECORD(fields, _) => fields
			| _ => report(pos, (S.name typ) ^ " is not a record type")
	fun lookField members (f, p) =
	    let
		fun look [] _ =
		    report(p, "record expression unknown field " ^ S.name(f))
		  | look ((s, t)::rest) i =
		    if s = f then (i, actualTy t) else look rest (i+1)
	    in
		look members 0
	    end

	val args: Tr.exp option Array.array = Array.array (length members, NONE)

	fun transField (fname, fexp, fpos) =
	    let
		val (i, ty) = lookField members (fname, fpos)
		val (e, ty') = transExp(ve, te, lv, fexp)
	    in
		if assignmentOK(ty, ty') then
		    case Array.sub (args, i) of
			NONE => Array.update (args, i, SOME e)
		      | _ => report(fpos, "record expression with duplicated field "
					 ^ S.name(fname))
		else (
		    (*print ((T.toString ty) ^ "\n"); print ((T.toString ty') ^ "\n");*)
		    report(fpos, "record expression with mismatched type of field "
				^ S.name(fname)))
	    end

	val _ = app transField fields

	val es = List.tabulate
		     ((length members),
		      (fn i =>
			  case Array.sub (args, i) of
			      NONE => report(pos,
					    "record expression with missing field "
					    ^ S.name(#1(List.nth(members, i))))
			    | SOME e => e))
    in
	(Tr.mkRecordExp es, ty)
    end

  | transExp(ve, te, lv, A.ArrayExp {typ, size, init, pos}) =
    let
	val t1 = case S.look(te, typ) of
		     SOME ty => actualTy ty
		   | NONE => report(pos, "unknown type " ^ S.name(typ))
	and (e2, t2) = transExp(ve, te, lv, size)
	and (e3, t3) = transExp(ve, te, lv, init)
    in
	case t1 of
	    T.ARRAY(ty, _) =>
	    if assignmentOK(actualTy ty, t3) then
		if t2 = T.INT then
		    (Tr.mkArrayExp(e2, e3), t1)
		else
		    report(pos, "index of array expression not int")
	    else
		report(pos, "initializing exp and array type differ")
	  | _ => report(pos, (S.name typ) ^ " is not an array type")
    end

  | transExp(ve, te, lv, A.LetExp {decs, body, pos}) =
    let
	val (ve', te', alist) = foldl
	      (fn (dec, (v, t, ss)) => case transDec(v, t, lv, dec) of
		  			   (v', t', NONE) => (v', t', ss)
					 | (v', t', SOME i) => (v', t', i::ss))
	      (ve, te, []) decs
	val (e, t) = transExp(ve', te', lv, body)
    in
	(Tr.mkLetExp(alist, e), t)
    end

and transEqExp(ve, te, lv, left, right, pos) =
    let
	val (le, lt) = transExp(ve, te, lv, left)
	and (re, rt) = transExp(ve, te, lv, right)
    in
	((case (lt, rt) of
	      (T.INT, T.INT) => Tr.mkIntEq (le, re)
	    | (T.STRING, T.STRING) => Tr.mkStrEq (le, re)
 	    | (T.RECORD r1, T.RECORD r2) => if r1 = r2
					    then Tr.mkRecEq(le, re)
					    else report(pos, "equality test of incompatible records")
	    | (T.RECORD _, T.NIL) => Tr.mkRecNilEq(le)
	    | (T.NIL, T.RECORD _) => Tr.mkRecNilEq(re)
	    | (T.NIL, T.NIL) => Tr.mkNilNilEq
 	    | (T.ARRAY a1, T.ARRAY a2) => if a1 = a2
					  then Tr.mkArrayEq(le, re)
					  else report(pos, "equality test of incompatible arrays")
	    | _ => report(pos, "equality test of incompatible types")),
	T.INT)
    end

and transNeqExp(ve, te, lv, left, right, pos) =
    let
	val (le, lt) = transExp(ve, te, lv, left)
	and (re, rt) = transExp(ve, te, lv, right)
    in
	((case (lt, rt) of
	      (T.INT, T.INT) => Tr.mkIntNeq (le, re)
	    | (T.STRING, T.STRING) => Tr.mkStrNeq (le, re)
 	    | (T.RECORD r1, T.RECORD r2) => if r1 = r2
					    then Tr.mkRecNeq(le, re)
					    else report(pos, "equality test of incompatible records")
	    | (T.RECORD _, T.NIL) => Tr.mkRecNilNeq(le)
	    | (T.NIL, T.RECORD _) => Tr.mkRecNilNeq(re)
	    | (T.NIL, T.NIL) => Tr.mkNilNilNeq
 	    | (T.ARRAY a1, T.ARRAY a2) => if a1 = a2
					  then Tr.mkArrayNeq(le, re)
					  else report(pos, "equality test of incompatible arrays")
	    | _ => report(pos, "equality test of incompatible types")),
	T.INT)
    end

and transCompExp(ve, te, lv, left, oper, right, pos) =
    let
	val (le, lt) = transExp(ve, te, lv, left)
	and (re, rt) = transExp(ve, te, lv, right)
    in
	case (lt, rt) of
	    (T.INT, T.INT) => (case oper of
				   A.LtOp => (Tr.mkIntLt (le, re), T.INT)
				 | A.LeOp => (Tr.mkIntLe (le, re), T.INT)
				 | A.GtOp => (Tr.mkIntGt (le, re), T.INT)
				 | A.GeOp => (Tr.mkIntGe (le, re), T.INT)
				 | _ => ICE "transCompExp int bad oper")
	  | (T.STRING, T.STRING) => (case oper of
				   A.LtOp => (Tr.mkStrLt (le, re), T.STRING)
				 | A.LeOp => (Tr.mkStrLe (le, re), T.STRING)
				 | A.GtOp => (Tr.mkStrGt (le, re), T.STRING)
				 | A.GeOp => (Tr.mkStrGe (le, re), T.STRING)
				 | _ => ICE "transCompExp string bad oper")
	  | (_, _) => report(pos, "comparison of incompatible types")
    end

and transArithExp(ve, te, lv, left, oper, right, pos) =
    let
	val (le, lt) = transExp(ve, te, lv, left)
	and (re, rt) = transExp(ve, te, lv, right)
	val _ =	 case (lt, rt) of
		     (T.INT, T.INT) => ()
		   | _ => report(pos, "integer required")
    in
	((case oper of
	    A.PlusOp => Tr.mkPlusExp (le, re)
	   | A.MinusOp => Tr.mkMinusExp (le, re)
	   | A.TimesOp => Tr.mkTimesExp (le, re)
	   | A.DivideOp => Tr.mkDivideExp (le, re)
	   | _ => ICE "transArithExp bad oper case"),
	 T.INT)
    end

and transVar(ve, te, lv, A.SimpleVar(v, pos)) =
    (case S.look(ve, v) of
	 SOME (E.VarEntry {access, ty}) => (Tr.mkVar(access, lv), actualTy ty)
       | SOME (E.FunEntry _) => report (pos, S.name(v) ^ " is a function, not a variable")
       | NONE => report(pos, "undeclared variable " ^ S.name(v)))

  | transVar(ve, te, lv, A.FieldVar(v, s, pos)) =
    let
	val (e, t) = transVar(ve, te, lv, v)
	fun lookField([], s: S.symbol, _) = NONE
	  | lookField((fs: S.symbol, ft: T.ty)::rest, s, i) =
	    if fs = s then SOME (ft, i) else lookField(rest, s, i+1)
    in
	case t of
	    T.RECORD(fs, _) => (case lookField(fs, s, 0) of
				    SOME (ft, i) => (Tr.mkFieldVar(e, i), actualTy ft)
				  | NONE => report(pos, "field '" ^ S.name(s) ^ "' not in record type"))
	  | _ => report(pos, "variable not record")
    end

  | transVar(ve, te, lv, A.SubscriptVar(v, e, pos)) =
    let
	val (e', t) = transVar(ve, te, lv, v)
    in
	case t of
	    T.ARRAY(t1, _) => (case transExp(ve, te, lv, e) of
				   (i, T.INT) => (Tr.mkSubscriptVar(e', i), actualTy t1)
				 | _ => report(pos, "subscript: index not an int"))
	  | _ => report(pos, "subscript: variable not array")
    end

(* Declarations *)

and transDec(ve, te, lv, A.VarDec {name, escape=ref esc, typ=NONE, init, pos}) =
    let
	val (exp, ty) = transExp(ve, te, lv, init)
	val _ = if ty = T.NIL
		then report(pos, "initializing nil expressions not constrained by record type")
		else ()
	val acc = Tr.allocLocal lv esc
    in
	(S.enter(ve, name, E.VarEntry {access = acc, ty = ty}),
	 te,
	 SOME (acc, exp))
    end

  | transDec(ve, te, lv, A.VarDec {name, escape=ref esc, typ=SOME (tyname, p), init, pos}) =
    let
	val (exp, ty') = transExp(ve, te, lv, init)
	and ty = case S.look(te, tyname) of
		     SOME ty => ty
		   | NONE => report(p, "vardecl: undeclared type " ^ S.name(tyname))
	val acc = Tr.allocLocal lv esc
    in
	if assignmentOK(ty, ty') then
	    (S.enter(ve, name, E.VarEntry {ty=ty, access=acc}),
	     te,
	     SOME (acc, exp))
	else
	    report(pos, "type constraint and init value differ")
    end

  | transDec(venv, tenv, lv, A.TypeDec decs) =
    let
	fun checkDup [] = NONE
	  | checkDup (s::ss) = if List.exists (fn x => s = x) ss
			       then SOME (S.name s) else checkDup ss

	val _ = case checkDup (map (fn t => #name(t)) decs) of
		    SOME name =>
		     (case List.find (fn t => S.name(#name(t)) = name) decs of
			  SOME t => report(#pos(t),
					  "two types with the same name ("
					  ^ name ^ ")"
					  ^ " in the same declaration block")
			| NONE => ICE "transTypeDec bad branch")
		  | NONE => ()

	fun transTy(tv, {name, ty=A.NameTy(sym, pos'), pos}) =
	    (case S.look(tv, sym) of
		 SOME ty => (name, ty)
		 (*SOME ty => T.NAME(name, ref(SOME(ty)))*)
	       | NONE => report(pos', "tydecl: undeclared type " ^ S.name(sym)))
	  | transTy(tv, {name, ty=A.ArrayTy(sym, pos'), pos}) =
	    (case S.look(tv, sym) of
		 SOME ty => (name, T.ARRAY(ty, ref ()))
	       | NONE => report(pos, "tydecl: undeclared type " ^ S.name(sym)))
	  | transTy(tv, {name, ty=A.RecordTy(fields), pos}) =
	    let
		fun tr({name, escape, typ, pos}: A.field) =
		    (name,
		     case S.look(tv, typ) of
			 SOME ty => ty
		       | NONE => report(pos, "undeclared type " ^ S.name(typ)))
		fun checkDup [] = NONE
		  | checkDup ((s:A.field)::ss) =
		    if List.exists (fn x => #name s = #name x) ss
		    then SOME (S.name (#name s), #pos s) else checkDup ss
	    in
		case checkDup fields of
		    SOME (nm, pos) => report(pos, "duplicated field name " ^ nm)
		  | NONE => (name, T.RECORD(map tr fields, ref ()))
	    end

	val names = map (fn dec => #name(dec)) decs

	val tenv' = foldl (fn (name, env) => S.enter(env, name, T.NAME(name, ref NONE)))
			  tenv names

	val tenv'' = foldl (fn ((name, ty), env) => S.enter(env, name, ty))
			   tenv (map (fn dec => transTy(tenv', dec)) decs)

	fun patch (tv, T.ARRAY(T.NAME(sym, r as (ref NONE)), _)) =
	    (case S.look(tv, sym) of
		SOME ty => r := SOME ty
	      | NONE => ICE ("tydecl patch array lookup " ^ S.name(sym)))
	  | patch (tv, T.NAME(sym, r as (ref NONE))) =
	    (case S.look(tv, sym) of
		 SOME ty => r := SOME ty
	       | NONE => ICE ("tydecl patch named lookup " ^ S.name(sym)))
	  | patch (tv, T.RECORD(fields, _)) =
	    let
		fun pat (fname, T.NAME(sym, r as (ref NONE))) =
		    (case S.look(tv, sym) of
			 SOME ty => r := SOME ty
		       | NONE => ICE ("tydecl patch record lookup "
				      ^ S.name(fname) ^ ":" ^ S.name(sym)))
		  | pat _ = ()
	    in
		app pat fields
	    end
	  | patch _ = ()

	val _ = app (fn nm => case S.look(tenv'', nm) of
				SOME ty => patch(tenv'', ty)
			      | NONE => ICE ("tydecl patch lookup " ^ S.name(nm)))
		    names

	val nuls: S.symbol list ref= ref []
	fun check (T.NAME(sym, ref (SOME ty)): T.ty, seen: S.symbol list) =
	    let
		val seen' = sym::seen
	    in
		if List.exists (fn s => s = sym) seen then
		    report(#pos(hd decs),
			  "cyclic types ("
			  ^ (String.concatWith " -> " (map (fn s => S.name s) (rev seen')))
			  ^ ")")
		else
		    check (ty, seen')
	    end
	  | check (T.NAME(sym, ref NONE), seen) = (nuls := sym::(!nuls))
	  | check _ = ()

	val _ = app (fn nm => case S.look(tenv'', nm) of
				  SOME ty => check(ty, [])
				| NONE => ICE "tydecl check")
		    names
	val _ = if not (null(!nuls)) then
		    ICE "tydecl cyclic check"
		else ()
    in
	(venv, tenv'', NONE)
    end

  | transDec(venv, tenv, lev, A.FunctionDec decs) =
    let
	fun checkDup [] = NONE
	  | checkDup (s::ss) = if List.exists (fn x => s = x) ss
			       then SOME (S.name s) else checkDup ss

	val _ = case checkDup (map (fn f: A.fundec => #name(f)) decs) of
		    SOME name =>
		     (case List.find (fn x => S.name(#name(x)) = name) decs of
			  SOME f => report(#pos(f),
					  "two functions with the same name ("
					  ^ name ^ ")"
					  ^ " in the same declaration block")
			| NONE => ICE "transFunctionDec bad branch")
		  | NONE => ()

	fun do_header(fdec as {name, params, result, body, pos}: A.fundec,
		      (ve:E.venv, protos)) =
	    let
		val _ = case checkDup(map (fn f:A.field => #name(f)) params) of
			    SOME nm => report(pos,
					     "duplicated formal parameter name '"
					     ^ nm ^ "'")
			  | NONE => ()
		val formals =
		    map
			(fn {name, typ, pos, ...} =>
			    case S.look(tenv, typ) of
				SOME ty => (name, ty)
			      | NONE => report(pos,
					      "unknown parameter type '"
					      ^ S.name(typ) ^ "'"))
			params
		and res =
		    case result of
			SOME (sym, pos) =>
			(case S.look(tenv, sym) of
			     SOME ty => ty
			   | NONE => report(pos,
					   "unknown return type '"
					   ^ S.name(sym) ^ "'"))
		      | NONE => T.UNIT
		and lbl = Temp.newlabel ()

		val lv = Tr.newLevel (lev, lbl, map ((op !) o #escape) params, SOME(Symbol.name(name)))
	    in
		(S.enter(ve, name,
			 E.FunEntry {
			     level = lv,
			     label = lbl,
			     formals = map #2 formals,
			     result = res}),
		 (formals, res, lv)::protos)
	    end

	val (venv', protos) = foldl do_header (venv, []) decs

	fun do_func(ve:E.venv, ((formals, res, lv),
				{name, params, result, body, pos})) =
	    let
		val ve' = foldl (fn (((s, t), a), v) => S.enter(v,
								s,
								E.VarEntry {access=a, ty=t}))
				ve
				(ListPair.zipEq(formals, tl(Tr.formals lv)))
		val _ = Tr.enterFunction lv
		val (body_exp, body_ty) = transExp(ve', tenv, lv, body)
		val _ = Tr.procEntryExit (lv, body_exp)
	    in
		case (res, body_ty) of
		    (T.UNIT, T.UNIT) => ()
		  | (T.UNIT, _) => report(pos, "procedure returns value")
		  | (_, T.UNIT) => report(pos, "no return values from function")
		  | (_, _) => if assignmentOK(res, body_ty)
			      then ()
			      else report(pos, "mismatched return type")
	    end

	val _ = app (fn f => do_func(venv', f)) (ListPair.zipEq(rev protos, decs))
    in
	
	(venv', tenv, NONE)
    end


(* main entry *)
fun transProg ast =
    let
	val _ = Tr.reset()
	val lev = Tr.newLevel (Tr.outermost,
			       Temp.namedlabel "_Tiger_main",
			       [], NONE)
	val _ = Tr.enterFunction(lev)
	val (e, t) = transExp(E.base_venv, E.base_tenv, lev, ast)
	val _ = Tr.procEntryExit(lev, e)
    in
	Tr.getResult ()
    end

	(* interactive test *)

fun test (prog: string) =
    let
	fun dump (Frame.PROC {body, frame}) = (
	    print("PROC: " ^ Temp.labelname (Frame.name frame)
		  ^ " (" ^ Frame.fname frame ^ ")");
	    app print ["[", String.concatWith ", " (map Frame.accessToString (Frame.formals frame)), "] "];
	    app print ["[", String.concatWith ", " (map Frame.accessToString (Frame.locals frame)), "]\n"];
	    Printtree.printtree (TextIO.stdOut, body))
	  | dump (Frame.STRING (lab, lit)) =
	    print("STRING: " ^ Temp.labelname lab ^ ": \"" ^ lit ^ "\"\n")
    in
	app dump (transProg (Parse.parse_str prog))
    end

end


(* regession *)

local
  fun isTigerFile s = 
      case rev (explode s) 
       of (#"g")::(#"i")::(#"t")::(#".")::nil => false
	| (#"g")::(#"i")::(#"t")::(#".")::_ => true
        | _ => false

  fun dirList (dir, isXFile) = 
      let val ds = OS.FileSys.openDir dir
	  fun loop () =
	      case OS.FileSys.readDir ds 
		of NONE => []
	         | SOME s => if isXFile s then s::(loop ()) else loop ()
      in loop () before OS.FileSys.closeDir ds end

  val test_dir = "./testcases"
  val files = ListMergeSort.sort (op >) (dirList (test_dir, isTigerFile))

  val type_check = Semant.transProg o Parse.parse

  fun test' file = (
     	   (type_check (test_dir ^ "/" ^ file);
     	   case List.find (fn x => x = file)
     		["test9.tig"   ,"test10.tig" ,"test11.tig" ,"test13.tig"
     		 ,"test14.tig" ,"test15.tig" ,"test16.tig" ,"test17.tig"
     		 ,"test18.tig" ,"test19.tig" ,"test20.tig" ,"test21.tig"
     		 ,"test22.tig" ,"test23.tig" ,"test24.tig" ,"test25.tig"
     		 ,"test26.tig" ,"test28.tig" ,"test29.tig" ,"test31.tig"
     		 ,"test32.tig" ,"test33.tig" ,"test34.tig" ,"test35.tig"
     		 ,"test36.tig" ,"test38.tig" ,"test39.tig" ,"test40.tig"
     		 ,"test43.tig" ,"test45.tig" ,"test49.tig"
     		 ,"testbreak1.tig", "testbreak2.tig"] of
     	       SOME f => (print ("UNCAUGHT ERROR in " ^ file ^ "\n"); true)
     	     | NONE => false)
     	    handle
     	    ErrorMsg.SyntaxError msg => not
     	    (case file of
     		"test9.tig" => String.isSubstring "types of then-else differ" msg
     	      | "test10.tig" => String.isSubstring "body of while not unit" msg
     	      | "test11.tig" => String.isSubstring "high index of for not int" msg
     	      | "test13.tig" => String.isSubstring "comparison of incompatible types" msg
     	      | "test14.tig" => String.isSubstring "equality test of incompatible types" msg
     	      | "test15.tig" => String.isSubstring "if-then body not unit" msg
     	      | "test16.tig" => String.isSubstring "cyclic types (c -> d -> a -> c)" msg
     	      | "test17.tig" => String.isSubstring "undeclared type treelist" msg
     	      | "test18.tig" => String.isSubstring "undefined function" msg
     	      | "test19.tig" => String.isSubstring "undeclared variable a" msg
     	      | "test20.tig" => String.isSubstring "undeclared variable i" msg
     	      | "test21.tig" => String.isSubstring "integer required" msg
     	      | "test22.tig" => String.isSubstring "field 'nam' not in record type" msg
     	      | "test23.tig" => String.isSubstring "type mismatch" msg
     	      | "test24.tig" => String.isSubstring "variable not array" msg
     	      | "test25.tig" => String.isSubstring "variable not record" msg
     	      | "test26.tig" => String.isSubstring "integer required" msg
     	      | "test28.tig" => String.isSubstring "type constraint and init value differ" msg
     	      | "test29.tig" => String.isSubstring "type constraint and init value differ" msg
     	      | "test31.tig" => String.isSubstring "type constraint and init value differ" msg
     	      | "test32.tig" => String.isSubstring "initializing exp and array type differ" msg
     	      | "test33.tig" => String.isSubstring "unknown record type rectype" msg
     	      | "test34.tig" => String.isSubstring "formals and actuals have incompatible types" msg
	      | "test35.tig" => String.isSubstring "formals and actuals have incompatible types" msg
     	      | "test36.tig" => String.isSubstring "formals are fewer than actuals" msg
     	      | "test38.tig" => String.isSubstring "two types with the same name" msg
     	      | "test39.tig" => String.isSubstring "two functions with the same name" msg
     	      | "test40.tig" => String.isSubstring "procedure returns value" msg
     	      | "test43.tig" => String.isSubstring "integer required" msg
     	      | "test45.tig" => String.isSubstring "initializing nil expressions not constrained by record" msg
     	      | "test49.tig" => String.isSubstring "syntax error" msg
     	      | "testbreak1.tig" => String.isSubstring "break outside for/while loop" msg
	      | "testbreak2.tig" => String.isSubstring "break outside for/while loop" msg
     	      | _ => (print(msg ^ "\n"); false))
     	    | ErrorMsg.Error => (print(file ^ " FAILED\n"); true))

  val result = ListPair.zipEq(files, map test' files)
  val total = length files
  val failed = length (List.filter (fn (f, failed) => failed) result)

  val ok = if failed = 0 then
	       print ("OK: typecheck " ^ Int.toString(total) ^ " tests\n")
	   else (
	       print ("FAILED: typecheck " ^ Int.toString(total) ^ " tests, "
		      ^ Int.toString(failed) ^ " failed\n");
	       raise Fail "type checker")
in
end
