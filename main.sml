structure Main = struct
local

fun compile(filename, outfilename) =
    let val absyn = Parse.parse filename
        val frags = (FindEscape.findEscape absyn; Semant.transProg absyn)

	fun comp out (Frame.PROC{body, frame}) =
	    let (* val _ = Printtree.printtree(out,body); *)
		val stms = Canon.linearize body
		(* val _ = app (fn s => Printtree.printtree(out,s)) stms; *)
		val stms' = Canon.traceSchedule(Canon.basicBlocks stms)
		(* val _ = app (fn s => Printtree.printtree(out,s)) stms'; *)
		val instrs = List.concat(map (CodeGen.codegen frame) stms')
		val instrs = Frame.procEntryExit2(frame, instrs)
		val (instrs, frame, alloc) = Regalloc.alloc(instrs, frame)
		val {prolog, body, epilog} = Frame.procEntryExit3(frame, instrs)
		val format = Assem.format(fn t => Frame.regName(valOf(Temp.Table.look(alloc, t))))
		fun pr s = TextIO.output (out, s)
	    in  pr prolog;
		app (fn i => TextIO.output(out,format i)) instrs;
		pr epilog
	    end
	  | comp out (Frame.STRING(l, s)) =
	    let	fun quote s = "\"" ^ concat (map Char.toCString (explode s)) ^ "\""
	    in TextIO.output(out, Temp.labelname l ^ ":\t.long " ^ Int.toString(size s) ^ "\n");
	       TextIO.output(out, "\t.ascii " ^ quote s ^ "\n")
	    end

	fun withOpenFile fname f =
	    let val out = TextIO.openOut fname
	    in (f out before TextIO.closeOut out)
	       handle e => (TextIO.closeOut out; raise e)
	    end
    in
        withOpenFile outfilename
		     (fn out =>
			 let fun pr s = TextIO.output(out, s)
			 in  pr ("\t.file \"" ^ (#file(OS.Path.splitDirFile filename)) ^ "\"\n");
			     pr "\t.text\n";
			     pr "\t.global _Tiger_main\n";
			     app (comp out) frags end)
    end

(* test *)
structure P = OS.Process
fun assert(msg, cond) = if cond then () else raise (Fail msg)

fun run(path, expected) =
    let
	val f = #base(OS.Path.splitBaseExt (#file(OS.Path.splitDirFile path)))
	val f' = OS.Path.joinBaseExt {base=f, ext=SOME "s"}
    in
	compile(path, f');
	assert("linking " ^ path, P.isSuccess(P.system("gcc runtime.c " ^ f')));
	if expected >= 0 then
	    assert("running " ^ path, (P.system "./a.out") = expected)
	else ();
	print("OK: " ^ path ^ "\n")
    end

val _ = run("./testcases/trivial.tig", 5)
val _ = run("./testcases/hello.tig", 14)
val _ = run("./testcases/callargs.tig", 6)
val _ = run("./testcases/callargs1.tig", 1)
val _ = run("./testcases/array.tig", 3)
val _ = run("./testcases/forloop.tig", 101)
val _ = run("./testcases/record.tig", 255)
val _ = run("./testcases/queens.tig", 92)
val _ = run("./testcases/fib.tig", 109)
val _ = run("./testcases/pi.tig", 0)
val _ = run("./testcases/merge.tig", ~1)

in

fun main(arg0, argv) =
    case argv of
	[path] =>
	let
	    val f = #base(OS.Path.splitBaseExt (#file(OS.Path.splitDirFile path)))
	    val f' = OS.Path.joinBaseExt {base=f, ext=SOME "s"}
	in (compile(path, f'); OS.Process.success)
	   handle
     	   ErrorMsg.SyntaxError msg =>
	    (print(msg ^ "\n"); OS.Process.failure)
	   | IO.Io {name, ...} =>
	     (print ("Cannot open file '" ^ name ^ "'\n"); OS.Process.failure)
	   | e =>
	     (print "INTERNAL ERROR!\n"; raise e)
	end
      | _ => (
	  print("Usage: " ^ arg0 ^ " <filename>\n");
	  OS.Process.failure)

val _ = SMLofNJ.exportFn("tigerc", main)

end
end
