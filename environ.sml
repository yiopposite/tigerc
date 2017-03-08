signature ENV =
sig
  type access
  type level
  type label
  type ty

  datatype enventry = VarEntry of {access: access, ty: ty}
		    | FunEntry of {level: level,
				   label: label,
				   formals: ty list,
				   result: ty}

  type venv
  type tenv

  val base_tenv : tenv
  val base_venv : venv
end

structure Env: ENV =
struct

  type access = Translate.access
  type ty = Types.ty
  type level = Translate.level
  type label = Temp.label

  datatype enventry = VarEntry of {access: access, ty: ty}
		    | FunEntry of {level: level,
				   label: label,
				   formals: ty list,
				   result: ty}

  structure S = Symbol
  structure T = Types

  type venv = enventry S.table
  type tenv = Types.ty S.table
		 
  val base_tenv:tenv =
      foldl (fn ((s, e), env:tenv) => S.enter(env, s, e))
	    S.empty
	    [(S.symbol("int"), T.INT)
	    ,(S.symbol("string"), T.STRING)
	    ]

  val base_venv:venv =
      foldl (fn ((s, e), env:venv) => S.enter(env, s, e))
	    S.empty
	    [(S.symbol("print"), FunEntry {level = Translate.outermost,
					   label = Temp.namedlabel "print",
					   formals = [T.STRING],
					   result = T.UNIT})
	    ,(S.symbol("flush"), FunEntry {level = Translate.outermost,
					   label = Temp.namedlabel "flush",
					   formals = [],
					   result = T.UNIT})
	    ,(S.symbol("getchar"), FunEntry {level = Translate.outermost,
					     label = Temp.namedlabel "_Tiger_getchar",
					     formals = [],
					     result = T.STRING})
	    ,(S.symbol("ord"), FunEntry {level = Translate.outermost,
					 label = Temp.namedlabel "ord",
					 formals = [T.STRING],
					 result = T.INT})
	    ,(S.symbol("chr"), FunEntry {level = Translate.outermost,
					 label = Temp.namedlabel "chr",
					 formals = [T.INT],
					 result = T.STRING})
	    ,(S.symbol("size"), FunEntry {level = Translate.outermost,
					  label = Temp.namedlabel "size",
					  formals = [T.STRING],
					  result = T.INT})
	    ,(S.symbol("substring"), FunEntry {level = Translate.outermost,
					       label = Temp.namedlabel "substring",
					       formals = [T.STRING, T.INT, T.INT],
					       result = T.STRING})
	    ,(S.symbol("concat"), FunEntry {level = Translate.outermost,
					    label = Temp.namedlabel "concat",
					    formals = [T.STRING, T.STRING],
					    result = T.STRING})
	    ,(S.symbol("not"), FunEntry {level = Translate.outermost,
					 label = Temp.namedlabel "not",
					 formals = [T.INT],
					 result = T.INT})
	    ,(S.symbol("exit"), FunEntry {level = Translate.outermost,
					  label = Temp.namedlabel "exit",
					  formals = [T.INT],
					  result = T.UNIT})
	    ]

end

