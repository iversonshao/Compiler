%{
/*Declarations*/
#define MAX_LINE_LENG 256
#define LIST strcat(buf,yytext)
#define token(t) {LIST; printf("<%s>\n","t");}
#define tokenId	{insert(yytext);LIST; printf("<%s:%s>\n","id",yytext);}
#define tokenInteger(t,i) {LIST; printf("<%s:%d>\n","t",i);}
#define tokenReal	{LIST; printf("<%s:%s>\n","real", yytext);}
#define tokenBoolean	{LIST; printf("<%s:%s>\n","boolean",yytext);}
#define tokenString(t,s) {LIST; printf("<%s:%s>\n","t",s);}
#define capital(t) { for(int i = 0; i < strlen(t); i++){t[i] = toupper(t[i]);};printf("<%s>\n", t); }
#define keyword(t)	{LIST; capitals(t)}


#include <stdio.h>
#include <string.h>

int linenum = 0;
char buf[MAX_LINE_LENG];
char 	str[1000];
char 	Symbol_Table[MAX_LENGTH][MAX_LENGTH];

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
digs         [0-9]+
integer      {digs}
plain_real   {digs}"."{digs}
expreal      {digs}"."{digs}[Ee][+-]?{digs}		
real         {plainreal}|{expreal}
letter       [a-zA-Z]
identifier   {letter}+
whitespace   [ \t]+
%%

 /*rules*/
 /* keyword */

"array"	{token(ARRAY);}
"begin" {token(BEGIN);}
"bool" {token(BOOL);}
"char" {token(CHAR);}
"const" {token(CONST);}
"decreasing" {token(DECREASING);}
"default" {token(DEFAULT);}
"do" {token(DO);}
"else" {token(ELSE);}
"end" {token(END);}
"exit" {token(EXIT);}
"false" {token(FALSE);}
"for" {token(FOR);}
"function" {token(FUNCTION);}
"get" {token(GET);}
"if"	{token(IF);}
"int" {token(INT);}
"loop" {token(LOOP);}
"of" {token(OF);}
"put" {token(PUT);}
"procedure" {token(PROCEDURE);}
"real" {token(REAL);}
"result" {token(RESULT);}
"return" {token(RETURN);}
"skip" {token(SKIP);}
"string" {token(STRING);}
"then" {token(THEN);}
"true"	{token(TRUE);}
"var" {token(VAR);}
"when" {token(WHEN);}


"(" {token('(');}
")" {token(')');}
"." {token('.');}
"," {token(',');}
":" {token(':');}
";" {token(';');}
"[" {token('[');}
"]" {token(']');}
"{" {token('{');}
"}" {token('}');}

"+" {token('+');}
"-" {token('-');}
"*" {token('*');}
"/" {token('/');}

"mod" {token('mod');}

":=" {token(':=');}

"<"	{token('<');}
"<="	{token('<=');}
">="	{token('>=');}
">"	{token('>');}
"="	{token('=');}
"not="	{token('not=');}
"and"	{token('and');}
"or"	{token('or');}
"not"	{token('not');}

{identifier}	{tokenId;}
{integer}	{tokenInteger;}
{real}		{tokenReal;}
\" {
	LIST;
	BEGIN STATE_string;
}
<STATE_string>\" {
	char c = input();
	if (c=='\"') {
		LIST;
		strcat(buf,"\"");
		strcat(str,yytext);
	}
	else {
		tokenString("string",str);
		unput(c);
		str[0] = '\0';
		BEGIN 0;
	}
}
<STATE_string>. {
	LIST;
	strcat(str,yytext);
}
"//" {
	LIST;
	BEGIN COMMET_Single;
}
<COMMET_Single>\n {
	LIST;
	printf("%d: %s", line_num++, buf);
	buf[0] = '\0';
	BEGIN 0;
}
<COMMET_Single>. {
	LIST;
}
"/*" {
	LIST;
	BEGIN COMMET_Multi;
}
<COMMET_Multi>\n {
	LIST;
	printf("%d: %s", line_num++, buf);
	buf[0] = '\0';
}
<COMMET_Multi>"*/" {
	LIST;
	BEGIN 0;
}
<COMMET_Multi>. {
	LIST;
}

\n {
	LIST;
	if (Opt_L)
		printf("%d: %s", linenum, buf);
		linenum++;
		buf[0] = ’\0’;
}
[ \t]* {LIST;}
. {
LIST;
printf("%d:%s\n", linenum+1, buf);
printf("bad character:’%s’\n",yytext);
exit(-1);
}
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
