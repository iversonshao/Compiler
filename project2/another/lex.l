%{
    extern int yylex(void);
    #include <stdio.h>
    #include <string.h>
    #include <math.h>
    #include <iostream>
    #include <sstream>
    #include <string>
    #include "y.tab.h"
    #define LIST     strcat(buf,yytext)
    #define token(t) {LIST; printf("<%s>\n",#t);}
    #define tokenInteger(t,i) {LIST; printf("<%s:%d>\n",t,i); yylval.intVal = i; return(INT);}
    #define tokenReal(t,r) {LIST; printf("<%s:%f>\n",t,r); yylval.realVal = r; return(REAL);}
    #define tokenBoolean(t,b) {LIST; printf("<%s:%s>\n",t,b); yylval.boolVal = yytext; return(BOOLEAN_Dump);}
    #define tokenString(t,s) {LIST; printf("<%s:%s>\n",t,s); yylval.stringVal = strdup(s); return (STRING_Dump);}
    #define tokenID(t,i) {LIST; printf("<%s:%s>\n",t,i); yylval.stringVal = strdup(i); return(ID);}
    #define MAX_LENGTH 256
    using namespace std;
    int linenum = 1;
    char buf[MAX_LENGTH];
    string str_temp;
    char stringBuf[MAX_LENGTH];
%}
/* states */
%x	STATE_string
%x 	COMMET_Cpp
%x	COMMET_C

digs         [0-9]
integer      {digs}+
plainreal    {digs}"."{digs}
expreal      {digs}"."{digs}[Ee][+-]?{digs}		
real         {plainreal}|{expreal}
letter       [a-zA-Z]
identifier   {letter}+({digs}|{letter})*
boolean       true|false
string	     [0-9a-zA-Z]*
whitespace   [ \t]+

/*delimiter   \,|\:|\;|\(|\)|\[|\]|\{|\}*/
/*Arithmetic, Relational, and Logical Operators*/
/*ARL  \+|\-|\*|\/|%|\<|<=|>=|\>|==|!=|&|\||!|\=|\+=|\-=|\*=|\/=*/
/*keyword bool|break|char|case|class|continue|declare|do|else|exit|float|for|fun|if|int|loop|print|println|return|string|val|var|while*/


%%

 /*delimiter*/
"." 		{token('.'); return(DOT);} 
"," 		{token(','); return(COMMA);}
":" 		{token(':'); return(COLON);}
";" 		{token(';'); return(SEMICOLON);}
"(" 		{token('('); return(LP);}
")" 		{token(')'); return(RP);}
"[" 		{token('['); return(LSB);}
"]" 		{token(']'); return(RSB);}
"{" 		{token('{'); return(LCB);}
"}" 		{token('}'); return(RCB);}
 /*ARL*/
"+" 		{token('+'); return(ADDITION);}
"-" 		{token('-'); return(SUBTRACTION);}
"*" 		{token('*'); return(MULTIPLICATION);}
"/" 		{token('/'); return(DIVISION);}
"mod" 		{token('mod'); return(REMAINDER);} 
":=" 		{token(':='); return(ASSIGNMENT);}
"<"		{token('<'); return(LT);}
"<="		{token('<='); return(LE);}
">="		{token('>='); return(GE);}
">"		{token('>'); return(GT);}
"="		{token('='); return(EQ);}
"not="		{token('not=');return(NOTE);}
"and"		{token('and'); return(AND);}
"or"		{token('or'); return(OR);}
"not"		{token('not'); return(NOT);}

 /* keyword */
"array"		{token(ARRAY); return(ARRAY);}
"begin" 	{token(BEGIN); return(BEGIN);} 
"bool" 		{token(BOOL); return BOOL;}
"char" 		{token(CHAR); return(CHAR);}
"const"	 	{token(CONST); return(CONST);}
"decreasing" 	{token(DECREASING); return(DECREASING);}
"default" 	{token(DEFAULT); return(DEFAULT);}
"do" 		{token(DO); return(DO);}
"else" 		{token(ELSE); return(ELSE);}
"end"		{token(END); return(END);}
"exit" 		{token(EXIT); return(EXIT);}
"for" 		{token(FOR); return(FOR);}//for loop
"function" 	{token(FUNCTION); return(FUNCTION);}
"if" 		{token(IF); return(IF);}
"int" 		{token(INT); return(INT);}
"loop" 		{token(LOOP); return(LOOP);}//while loop
"of" 		{token(OF); return(OF);}
"put" 		{token(PUT); return(PUT);}
"procedure" 	{token(PROCEDURE); return(PROCEDURE);}
"real" 		{token(REAL); return(REAL);}
"result" 	{token(RESULT); return(RESULT);}
"return" 	{token(RETURN); return(RETURN);}
"skip" 		{token(SKIP); return(SKIP);}
"string" 	{token(STRING); return(STRING);}
"then" 		{token(THEN); return(THEN);}
"var" 		{token(VAR); return(VAR);}
"when" 		{token(WHEN); return(WHEN);}

{integer} {tokenInteger("Integer",atoi(yytext));}
{real} {tokenReal("Real",atof(yytext));}
{boolean} {tokenBoolean("Boolen",yytext);}
{identifier} {tokenID("ID",yytext); }

\"		  {
                    LIST;
                    BEGIN STATE_string;
                  }

<STATE_string>\"  {
                      char c = input;
                      if (c == '\"') {
                      LIST;
                      strcat(buf,"\"");
                      strcat(str,yytext);
                    }
                      else{
                      tokenString("string",stringBuf);
                      unput(c);
                      stringBuf[0] = '\0';
                      BEGIN 0;
                      return STRING;
                    }
                    }
<STATE_string>.     {
                      LIST;
                      strcat(str,yytext);
                    }
"%"          		{
               		LIST;
                	BEGIN COMMET_Cpp;
            		}
<COMMET_Cpp>\n 	{
                      LIST;
                      printf("%d: %s", line_num++, buf);
                      buf[0] = '\0';
                      BEGIN 0;
                    }
<COMMET_Cpp>.    {
                      LIST;
                    }
"{%"               {
                      LIST;
                      BEGIN COMMET_C;
                    }
<COMMET_C>\n {
                      LIST;
                      printf("%d: %s", line_num++, buf);
                      buf[0] = '\0';
                     	}
<COMMET_C>"%}"	{
                      		LIST;
                      		BEGIN 0;
                    	}
<COMMET_C>.     {
                      		LIST;
                    	}
\n 			{
        		LIST;
        		printf("%d: %s", line_num++, buf);
        		buf[0] = '\0';
        		}
[ \t]*  		{LIST;}

%%
int yywrap(void){
	puts("---the file is end");
	return 1;
}
