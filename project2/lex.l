%{
/*Declarations*/
#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include "union.h"
#include "yacc.tab.h"

#define MAX_LINE_LENG 		256
#define LIST			strcat(buf,yytext)
#define token(s,t) 		{LIST; printf("<%s>\n", s); return(t);}
#define tokenId			{insert(yytext);LIST; printf("<%s:%s>\n","id",yytext);}
#define tokenInteger(s,t) 	{LIST; printf("<%s:%d>\n","int", yytext);}
#define tokenFloat(t)   	{LIST; printf("<%s:%d>\n","float" yytext)}
#define tokenReal		{LIST; printf("<%s:%s>\n","real", yytext);}
#define tokenBoolean		{LIST; printf("<%s:%s>\n","boolean",yytext);}
#define tokenString(s,t)	{LIST; printf("<%s:%s>\n","string",str);}
#define capitals(t) 		{ for(int i = 0; i < strlen(t); i++){t[i] = toupper(t[i]);};printf("<%s>\n", t); }
#define keyword(t)		{LIST; capitals(t)}

int 	line_num = 1;
char 	buf[MAX_LINE_LENG];
char 	str[1000];

int yywarp(void);
int yylex(void);


%}
/* states */
%x	STATE_string
%x 	COMMET_Cpp
%x	COMMET_C

/*Definitions*/
digs         [0-9]
integer      {digs}+
float        -?(([0-9]+)|([0-9]*\.[0-9]+)([eE][-+]?[0-9]+)?)
plainreal    {digs}"."{digs}
expreal      {digs}"."{digs}[Ee][+-]?{digs}		
real         {plainreal}|{expreal}
letter       [a-zA-Z]
identifier   {letter}+({digs}|{letter})*
string	     [0-9a-zA-Z]*
whitespace   [ \t]+
%%

 /*rules*/
 /* keyword */

"array"		{keyword(yytext); return ARRAY;}
"begin" 	{keyword(yytext); return BEGIN;}
"bool" 		{keyword(yytext); return BOOL;}
"char" 		{keyword(yytext); return CHAR;}
"const" 	{keyword(yytext); return CONST;}
"decreasing" 	{keyword(yytext); return DECREASING;}
"default" 	{keyword(yytext); return DEFAULT;}
"do" 		{keyword(yytext); return DO;}
"else" 		{keyword(yytext); return ELSE;}
"end" 		{keyword(yytext); return END;}
"exit" 		{keyword(yytext); return EXIT;}
"for" 		{keyword(yytext); return FOR;}
"function" 	{keyword(yytext); return FUNCUTION;}
"get" 		{keyword(yytext); return GET;}
"if"		{keyword(yytext); return IF;}
"int" 		{keyword(yytext); return INT;}
"loop" 		{keyword(yytext); return LOOP;}
"of" 		{keyword(yytext); return OF;}
"put" 		{keyword(yytext); return PUT;}
"procedure" 	{keyword(yytext); return PROCEDURE;}
"real" 		{keyword(yytext); return REAL;}
"result" 	{keyword(yytext); return RESULT;}
"return" 	{keyword(yytext); return RETURN;}
"skip" 		{keyword(yytext); return SKIP;}
"string"	{keyword(yytext); return STRING;}
"then" 		{keyword(yytext); return THEN;}
"var" 		{keyword(yytext); return VAR;}
"when" 		{keyword(yytext); return WHEN;}
"false" 	{tokenBoolean; yylval.m_nInt = 0; return FALSEVAL;}
"true"		{tokenBoolean; yylval.m_nInt = 1; return TUREVAL;}

"(" 		{token("("); return LP;}
")" 		{token(")"); return RP;}
"." 		{token("."); return DOT;}
"," 		{token(","); return COMMA;}
":" 		{token(":"); return COLON;}
";" 		{token(";"); return SEMICOLON;}
"[" 		{token("["); return LSB;}
"]" 		{token("]"); return RSB;}
"{" 		{token("{"); return LCB;}
"}" 		{token("}"); return RCB;}

"+" 		{token("+"); return ADDITION;}
"-" 		{token("-"); return SUBTRACTION;}
"*" 		{token("*"); return MULTIPLICATION;}
"/" 		{token("/"); return DIVISION;}
"mod" 		{token("mod"); return REMAINDER;}

":=" 		{token(":="); return ASSIGNMENT;}

"<"		{token("<"); return LT;}
"<="		{token("<="); return LE;}
">="		{token(">="); return GE;}
">"		{token(">"); return GT;}
"="		{token("="); return EQ;}
"not="		{token("not=");return NOTE;}
"and"		{token("and"); return AND;}
"or"		{token("or"); return OR;}
"not"		{token("not"); return NOT;}
{{identifier}  {
              strcpy(yylval.m_sId , yytext);
              tokenId(yylval.m_sId);
              return IDENTIFIER;
              }
{integer} 	{
              yylval.m_nInt=atoi(yytext);
              tokenInteger(yylval.m_nInt);
              
              return INTEGERVAL;
              }
{float}       {
              yylval.m_float=atof(yytext);
              tokenFloat(yylval.m_float);
              return FLOATVAL;
              }

\"		  {
                    LIST;
                    BEGIN STATE_string;
                  }

<STATE_string>\"  {
                      char c = input();
                      if(c=='\"')
                    {
                      LIST;
                      strcat(buf,"\"");
                      strcat(str,yytext);
                    }
                      else
                    {
                      tokenString("string",str);
                      unput(c);
                      str[0] = '\0';
                      BEGIN 0;
                      return STRINGVAL;
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
	puts("---the file is end---")
	return 1;
}
