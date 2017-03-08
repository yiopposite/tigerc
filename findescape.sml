structure FindEscape :
	  sig val findEscape: Absyn.exp -> unit end =
struct
local
    structure A = Absyn
    structure S = Symbol
		      
    type env = (bool ref * int) Symbol.table
				
fun doExp(env: env, i: int, A.NilExp) = ()
  | doExp(env, i, A.IntExp _) = ()
  | doExp(env, i, A.StringExp _) = ()
  | doExp(env, i, A.CallExp {args, ...}) =
    app (fn a => doExp (env, i, a)) args
  | doExp(env, i, A.OpExp {left, right, ...}) =
    (doExp(env, i, left); doExp(env, i, right)) 
  | doExp(env, i, A.SeqExp es) = app (fn (e, _) => doExp (env, i, e)) es
  | doExp(env, i, A.VarExp v) = doVar(env, i, v)
  | doExp(env, i, A.AssignExp {var, exp, pos}) = (doVar(env, i, var); doExp(env, i, exp))
  | doExp(env, i, A.WhileExp {test, body, ...}) = (doExp(env, i, test); doExp(env, i, body))
  | doExp(env, i, A.BreakExp pos) = ()
  | doExp(env, i, A.ForExp {var, escape, lo, hi, body, pos}) =
    (doExp(env, i, lo);
     doExp(env, i, hi);
     doExp(S.enter(env, var, (escape, i)), i, body))
  | doExp(env, i, A.IfExp {test, then', else'=NONE, pos}) =
    (doExp(env, i, test);
     doExp(env, i, then'))
  | doExp(env, i, A.IfExp {test, then', else'=SOME else', pos}) =
    (doExp(env, i, test);
     doExp(env, i, then');
     doExp(env, i, else'))
  | doExp(env, i, A.RecordExp {fields, ...}) =
    app (fn (_, e, _) => doExp(env, i, e)) fields
  | doExp(env, i, A.ArrayExp {size, init, ...}) =
    (doExp(env, i, size);
     doExp(env, i, init))
  | doExp(env, i, A.LetExp {decs, body, pos}) =
    let
	val env' = foldl (fn (dec, v) => doDec(v, i, dec)) env decs
    in
	doExp(env', i, body)
    end

and doVar(env: env, i, A.SimpleVar(v, pos)) =
    (case S.look(env, v) of
	 SOME (escape, i') => (
	  if i > i' then escape := i' < i else ())
       | NONE => () (* will be caught later in type checker *))
  | doVar(env, i, A.FieldVar(v, _, _)) = doVar(env, i, v)
  | doVar(env, i, A.SubscriptVar(v, e, _)) = (doVar(env, i, v); doExp(env, i, e))

and doDec(env, i, A.VarDec {name, escape, typ, init, pos}) =
    (doExp(env, i, init);
     S.enter(env, name, (escape, i)))
  | doDec(env, i, A.TypeDec decs) = env
  | doDec(env, i, A.FunctionDec decs) =
    let
      fun doFun ({params, body, ...}: A.fundec) =
	  let
	      val env' = foldl
			     (fn ({name, escape, ...}, v) =>
				 S.enter(v, name, (escape, i + 1)))
			     env params
	  in
	      doExp(env', i + 1, body)
	  end
    in
	(app doFun decs; env)
    end
in

fun findEscape prog = doExp (Symbol.empty, 0, prog)

end
end

(* test *)
local
exception ASSERT of string

fun assert msg cond = ignore (cond orelse raise ASSERT msg)

val ok = let
    val ast = Parse.parse_str "\
	\let var t0 := 0 \
	\    var t1 := 1 \
	\    function f(fp0: int, fp1: int) : int = \
	\    let var fv0 := 0 \
	\        var fv1 := 1 \
	\        function g(gp0: int, gp1: int) = \
	\        let var gv0 := 0 \
	\            var gv1 := 1 \
	\        in \
	\            fp1 := 2; fv1 := 3; gp1 := 4; gv1 := 5 \
	\     end \
	\     in \
	\       t1 + fp0 + fp1 + fv0 + fv1 \
	\    end \
	\in  t0 + t1 \
	\end"
    val _ = FindEscape.findEscape ast
    val Absyn.LetExp {
      decs = [
      Absyn.VarDec { escape = ref t0, ... },
      Absyn.VarDec { escape = ref t1, ... },
      Absyn.FunctionDec([
	{params =  [{escape = ref fp0, ...}, {escape = ref fp1, ...}],
	 body = Absyn.LetExp {
	     decs = [
		Absyn.VarDec { escape = ref fv0, ... },
		Absyn.VarDec { escape = ref fv1, ... },
		Absyn.FunctionDec([
		  {params =  [{escape = ref gp0, ...}, {escape = ref gp1, ...}],
		   body = Absyn.LetExp {
		       decs = [
		       Absyn.VarDec { escape = ref gv0, ... },
		       Absyn.VarDec { escape = ref gv1, ... }
		   ], ...}, ...}]
	     )], ...}, ...}]
      )],
      ...
    } = ast
in
  (* PrintAbsyn.print (TextIO.stdOut, ast) *)
  assert "t0 should not escape" (not t0);
  assert "t1 should escape" t1;
  assert "fp0 should not escape" (not fp0);
  assert "fp1 should escape" fp1;
  assert "fv0 should not escape" (not fv0);
  assert "fv1 should escape" fv1;
  assert "gp0 should not escape" (not gp0);
  assert "gp1 should not escape" (not gp1);
  assert "gv0 should not escape" (not gv0);
  assert "gv1 should not escape" (not gv1)
end
before print ("OK: findescape\n")
handle
ASSERT msg => raise Fail ("findescape: " ^ msg)
in
end
