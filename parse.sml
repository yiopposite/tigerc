structure Parse : sig val parse : string -> Absyn.exp
		      val parse_str : string -> Absyn.exp
		  end =
struct 
  structure TigerLrVals = TigerLrValsFun(structure Token = LrParser.Token)
  structure Lex = TigerLexFun(structure Tokens = TigerLrVals.Tokens)
  structure TigerP = Join(structure ParserData = TigerLrVals.ParserData
			structure Lex=Lex
			structure LrParser = LrParser)
  exception SyntaxError of string
  fun parse filename =
      let val _ = (ErrorMsg.reset(); ErrorMsg.fileName := filename)
	  val file = TextIO.openIn filename
	  fun get _ = TextIO.input file
	  fun parseerror(s,p1,p2) = ErrorMsg.parseerror p1 s
	  val lexer = LrParser.Stream.streamify (Lex.makeLexer get)
	  val (absyn, _) = TigerP.parse(30,lexer,parseerror,())
       in TextIO.closeIn file;
	   absyn
      end handle LrParser.ParseError => raise ErrorMsg.Error

  fun parse_str str =
      let val _ = (ErrorMsg.reset(); ErrorMsg.fileName := "-")
	  val EOI = ref false
	  fun get _ = if !EOI then "" else (EOI := true; str)
	  fun parseerror(s,p1,p2) = ErrorMsg.parseerror p1 s
	  val lexer = LrParser.Stream.streamify (Lex.makeLexer get)
	  val (absyn, _) = TigerP.parse(30,lexer,parseerror,())
       in
	   absyn
      end handle LrParser.ParseError => raise ErrorMsg.Error

end



