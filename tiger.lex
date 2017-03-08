type pos = int
type svalue = Tokens.svalue
type ('a,'b) token = ('a,'b) Tokens.token
type lexresult = (svalue,pos) token

val lineNum = ErrorMsg.lineNum
val linePos = ErrorMsg.linePos
fun err(p1,p2) = ErrorMsg.error p1

val commentLevel = ref 0
val stringOpen = ref false
val stringPos = ref 0
val stringVal : char list ref = ref []

fun eof() =
    let
        val pos = hd(!linePos)
    in
        if (!commentLevel <> 0) then
  	    ErrorMsg.parseerror pos "EOF: unclosed comments"
        else if (!stringOpen) then
            ErrorMsg.parseerror pos "EOF: unclosed string"
	else
            ();
        Tokens.EOF(pos,pos)
    end

%%

alpha=[A-Za-z];
digit=[0-9];
blank=[ \t];

%s COMMENT STRINGL;

%header (functor TigerLexFun(structure Tokens: Tiger_TOKENS));

%%

<INITIAL>"/*"	=> (YYBEGIN COMMENT; commentLevel := 1; continue());
<COMMENT>"/*"	=> (commentLevel := !commentLevel + 1; continue());
<COMMENT>"\n"	=> (lineNum := !lineNum+1; linePos := yypos :: !linePos; continue());
<COMMENT>"*/"	=> (commentLevel := !commentLevel - 1;
                    if !commentLevel = 0 then YYBEGIN INITIAL else ();
                    continue());
<COMMENT>.      => (continue());

<INITIAL>\"	=> (YYBEGIN STRINGL;
		    stringOpen := true;
		    stringPos := yypos;
		    stringVal := [];
		    continue());
<STRINGL>\\\n[ \t]*\\ => (lineNum := !lineNum+1; linePos := yypos :: !linePos;
			  continue());
<STRINGL>\\\" => (stringVal := #"\"" :: !stringVal; continue());
<STRINGL>\\a  => (stringVal := #"\a" :: !stringVal; continue());
<STRINGL>\\b  => (stringVal := #"\b" :: !stringVal; continue());
<STRINGL>\\f  => (stringVal := #"\f" :: !stringVal; continue());
<STRINGL>\\n  => (stringVal := #"\n" :: !stringVal; continue());
<STRINGL>\\r  => (stringVal := #"\r" :: !stringVal; continue());
<STRINGL>\\t  => (stringVal := #"\t" :: !stringVal; continue());
<STRINGL>\\v  => (stringVal := #"\v" :: !stringVal; continue());
<STRINGL>\\\\ => (stringVal := #"\\" :: !stringVal; continue());
<STRINGL>\\[0-9]{3} => (case Int.fromString(substring(yytext, 1, 3)) of
			    (SOME n) => if n > 255 then
					    ErrorMsg.parseerror yypos ("illegal escape sequence " ^ yytext)
					else
					    stringVal := chr(n) :: !stringVal
			  | NONE => ErrorMsg.parseerror yypos ("illegal escape sequence " ^ yytext);
			continue());
<STRINGL>\\.  => (ErrorMsg.parseerror yypos ("illegal escape sequence " ^ yytext); continue());
<STRINGL>\"   => (YYBEGIN INITIAL;
		  stringOpen := false;
		  Tokens.STRING(implode(rev(!stringVal)), !stringPos, yypos));
<STRINGL>\n   => (lineNum := !lineNum+1; linePos := yypos :: !linePos;
		  stringVal := #"\n" :: !stringVal; continue());
<STRINGL>.    => (stringVal := String.sub(yytext, 0) :: !stringVal; continue());

<INITIAL>"\n"	=> (lineNum := !lineNum+1; linePos := yypos :: !linePos; continue());
<INITIAL>","	=> (Tokens.COMMA(yypos,yypos+1));
<INITIAL>":"	=> (Tokens.COLON(yypos,yypos+1));
<INITIAL>";"	=> (Tokens.SEMICOLON(yypos,yypos+1));
<INITIAL>"("	=> (Tokens.LPAREN(yypos,yypos+1));
<INITIAL>")"	=> (Tokens.RPAREN(yypos,yypos+1));
<INITIAL>"["	=> (Tokens.LBRACK(yypos,yypos+1));
<INITIAL>"]"	=> (Tokens.RBRACK(yypos,yypos+1));
<INITIAL>"{"	=> (Tokens.LBRACE(yypos,yypos+1));
<INITIAL>"}"	=> (Tokens.RBRACE(yypos,yypos+1));
<INITIAL>"."	=> (Tokens.DOT(yypos,yypos+1));
<INITIAL>"+"	=> (Tokens.PLUS(yypos,yypos+1));
<INITIAL>"-"	=> (Tokens.MINUS(yypos,yypos+1));
<INITIAL>"*"	=> (Tokens.TIMES(yypos,yypos+1));
<INITIAL>"/"	=> (Tokens.DIVIDE(yypos,yypos+1));
<INITIAL>"="	=> (Tokens.EQ(yypos,yypos+1));
<INITIAL>"<>"	=> (Tokens.NEQ(yypos,yypos+2));
<INITIAL>"<"	=> (Tokens.LT(yypos,yypos+1));
<INITIAL>"<="	=> (Tokens.LE(yypos,yypos+1));
<INITIAL>">"	=> (Tokens.GT(yypos,yypos+1));
<INITIAL>">="	=> (Tokens.GE(yypos,yypos+1));
<INITIAL>"&"	=> (Tokens.AND(yypos,yypos+1));
<INITIAL>"|"	=> (Tokens.OR(yypos,yypos+1));
<INITIAL>":="	=> (Tokens.ASSIGN(yypos,yypos+2));

<INITIAL>array 	=> (Tokens.ARRAY(yypos,yypos+5));
<INITIAL>break 	=> (Tokens.BREAK(yypos,yypos+5));
<INITIAL>do  	=> (Tokens.DO(yypos,yypos+2));
<INITIAL>else  	=> (Tokens.ELSE(yypos,yypos+4));
<INITIAL>end  	=> (Tokens.END(yypos,yypos+3));
<INITIAL>for  	=> (Tokens.FOR(yypos,yypos+3));
<INITIAL>function  => (Tokens.FUNCTION(yypos,yypos+8));
<INITIAL>if  	=> (Tokens.IF(yypos,yypos+2));
<INITIAL>in  	=> (Tokens.IN(yypos,yypos+2));
<INITIAL>let  	=> (Tokens.LET(yypos,yypos+3));
<INITIAL>nil  	=> (Tokens.NIL(yypos,yypos+3));
<INITIAL>of  	=> (Tokens.OF(yypos,yypos+2));
<INITIAL>then  	=> (Tokens.THEN(yypos,yypos+4));
<INITIAL>to  	=> (Tokens.TO(yypos,yypos+2));
<INITIAL>type  	=> (Tokens.TYPE(yypos,yypos+4));
<INITIAL>while	=> (Tokens.WHILE(yypos,yypos+5));
<INITIAL>var	=> (Tokens.VAR(yypos,yypos+3));

<INITIAL>[a-zA-Z][a-zA-Z0-9_]*	=> (Tokens.ID(yytext,yypos,yypos+size yytext));
<INITIAL>[0-9]+	=> (Tokens.INT(valOf(Int.fromString(yytext)),yypos,yypos+size yytext));

<INITIAL>[ \t]+	=> (continue());
<INITIAL>.      => (ErrorMsg.parseerror yypos ("illegal character " ^ yytext); continue());
