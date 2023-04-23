%{
/*Declarations*/
#include <stdio.h>
#include <ctype.h>

#define MAX_LINE_LENG 	256
#define LIST		strcat(buf,yytext)
#define token(t) 	{LIST; printf("<'%s'>\n",t);}
#define tokenId		{insert(yytext);LIST; printf("<%s:%s>\n","id",yytext);}
#define tokenInteger 	{LIST; printf("<%s:%d>\n","integer", yytext);}
#define tokenReal	{LIST; printf("<%s:%s>\n","real", yytext);}
#define tokenBoolean	{LIST; printf("<%s:%s>\n","boolean",yytext);}
#define tokenString(t,s){LIST; printf("<%s:%s>\n","string",s);}
#define capital(t) 	{ for(int i = 0; i < strlen(t); i++){t[i] = toupper(t[i]);};printf("<%s>\n", t); }
#define keyword(t)	{LIST; capital(t)}

int 	line_num = 1;
char 	buf[MAX_LINE_LENG];
char 	str[1000];
char 	Symbol_Table[MAX_LINE_LENG][MAX_LINE_LENG];

int Symbol_index = -1;

int insert(char s[]){
	for (int i = 0; i <= Symbol_index; i++)
	{
		if (strcmp(Symbol_Table[i] , s) == 0)
			{
				return i;
			}
				}
				Symbol_index++;
				
				strcpy(Symbol_Table[Symbol_index],s);
				
	return Symbol_index ;
}

int lookup(char s[]){
	for (int i = 0; i <= Symbol_index; i++)
	{
		if (strcmp(Symbol_Table[i] , s)==0)
		{
			printf("%d\n", i);
			return i;
		}
	}
	printf("%s\n", "Null");
	return 0;
}

int dump(){
	for (int i = 0; i <= Symbol_index; i++)
	{
		if (Symbol_Table[i] != '\0')
		{
			printf("%s\n", Symbol_Table[i] );
		}
	}
	return 0 ;
}


%}
/* states */
%x	STATE_string
%x 	COMMET_Single
%x	COMMET_Multi

/*Definitions*/
digs         [0-9]
integer      {digs}+
plainreal    {digs}"."{digs}
expreal      {digs}"."{digs}[Ee][+-]?{digs}		
real         {plainreal}|{expreal}
letter       [a-zA-Z]
identifier   {letter}({digs}|{letter})*
whitespace   [ \t]+
%%

 /*rules*/
 /* keyword */

"array"		|
"begin" 	|
"bool" 		|
"char" 		|
"const" 	|
"decreasing" 	|
"default" 	|
"do" 		|
"else" 		|
"end" 		|
"exit" 		|
"for" 		|
"function" 	|
"get" 		|
"if"		|
"int" 		|
"loop" 		|
"of" 		|
"put" 		|
"procedure" 	|
"real" 		|
"result" 	|
"return" 	|
"skip" 		|
"string"	|
"then" 		|
"var" 		|
"when" 		{keyword(yytext);}
"false" 	{tokenBoolean;}
"true"		{tokenBoolean;}

"(" 		{token("(");}
")" 		{token(")");}
"." 		{token(".");}
"," 		{token(",");}
":" 		{token(":");}
";" 		{token(";");}
"[" 		{token("[");}
"]" 		{token("]");}
"{" 		{token("{");}
"}" 		{token("}");}

"+" 		{token("+");}
"-" 		{token("-");}
"*" 		{token("*");}
"/" 		{token("/");}
"mod" 		{token("mod");}

":=" 		{token(":=");}

"<"		{token("<");}
"<="		{token("<=");}
">="		{token(">=");}
">"		{token(">");}
"="		{token("=");}
"not="		{token("not=");}
"and"		{token("and");}
"or"		{token("or");}
"not"		{token("not");}
{identifier}  	{tokenId;}
{integer}     	{tokenInteger;}
{real}        	{tokenReal;}
\"		{
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
                    }
                    }
<STATE_string>.     {
                      LIST;
                      strcat(str,yytext);
                    }
"//"          		{
               		LIST;
                	BEGIN COMMET_Single;
            		}
<COMMET_Single>\n 	{
                      LIST;
                      printf("%d: %s", line_num++, buf);
                      buf[0] = '\0';
                      BEGIN 0;
                    }
<COMMET_Single>.    {
                      LIST;
                    }
"/*"               {
                      LIST;
                      BEGIN COMMET_Multi;
                    }
<COMMET_Multi>\n {
                      LIST;
                      printf("%d: %s", line_num++, buf);
                      buf[0] = '\0';
                     	}
<COMMET_Multi>"*/"	{
                      		LIST;
                      		BEGIN 0;
                    	}
<COMMET_Multi>.     {
                      		LIST;
                    	}
\n 			{
        		LIST;
        		printf("%d: %s", line_num++, buf);
        		buf[0] = '\0';
        		}
[ \t]*  		{LIST;}

%%
/*user code*/
int main(){
	yylex();
	if (buf[0] != '\0'){
		printf("%d: %s", line_num++, buf);
	}
	printf("\n%s\n", "Symbol Table:");
	dump();
	}
int yywrap(){
	return 1;
}
