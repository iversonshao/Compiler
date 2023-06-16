%{
    extern int yylex(void);
    #include <stdio.h>
    #include <string.h>
    #include <math.h>
    #include <iostream>
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
    char str_temp[MAX_LENGTH];
    char stringBuf[MAX_LENGTH];
    
%}
/* states */
%x	STR
%x 	COMMENT

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
/*ARL  \+|\-|\*|\/|%|\<|<=|>=|\>|=|&|\||
/*keyword bool|char|do|else|exit|for|function|if|int|loop|put|return|string|const|var|*/


%%
{integer} {tokenInteger("Integer",atoi(yytext));}
{real} {tokenReal("Real",atof(yytext));}

 /*delimiter*/
"." 		{token('.'); return yytext[0];} 
"," 		{token(','); return yytext[0];}
":" 		{token(':'); return yytext[0];}
";" 		{token(';'); return yytext[0];}
"(" 		{token('('); return yytext[0];}
")" 		{token(')'); return yytext[0];}
"[" 		{token('['); return yytext[0];}
"]" 		{token(']'); return yytext[0];}
"{" 		{token('{'); return yytext[0];}
"}" 		{token('}'); return yytext[0];}
 /*ARL*/
"+" 		{token('+'); return yytext[0];}
"-" 		{token('-'); return yytext[0];}
"*" 		{token('*'); return yytext[0];}
"/" 		{token('/'); return yytext[0];}
"mod" 		{token('mod'); return REMAINDER;} 
":=" 		{token(':='); return ASSIGNMENT;}
"<"		{token('<'); return LT;}
"<="		{token('<='); return LE;}
">="		{token('>='); return GE;}
">"		{token('>'); return GT;}
"="		{token('='); return EQ;}
"not="		{token('not=');return NOTE;}
"and"		{token('and'); return AND;}
"or"		{token('or'); return OR;}
"not"		{token('not'); return NOT;}

 /* keyword */
"array"		{token(ARRAY); return ARRAY;}
"begin" 	{token(BEG);  return BEG;} 
"bool" 		{token(BOOL); return BOOL;}
"char" 		{token(CHAR); return CHAR;}
"const"	 	{token(CONST); return CONST;}
"decreasing" 	{token(DECREASING); return DECREASING;}
"default" 	{token(DEFAULT); return DEFAULT;}
"do" 		{token(DO); return DO;}
"else" 		{token(ELSE); return ELSE;}
"end"		{token(END); return END;}
"exit" 		{token(EXIT); return EXIT;}
"for" 		{token(FOR); return FOR;}//for loop
"function" 	{token(FUNCTION); return FUNCTION;}
"if" 		{token(IF); return IF;}
"int" 		{token(INT); return INT;}
"loop" 		{token(LOOP); return LOOP;}//while loop
"of" 		{token(OF); return OF;}
"put" 		{token(PUT); return PUT;}
"procedure" 	{token(PROCEDURE); return PROCEDURE;}
"real" 		{token(REAL); return REAL;}
"result" 	{token(RESULT); return RESULT;}
"return" 	{token(RETURN); return RETURN;}
"bool" 		{token(BOOL); return BOOL;}
"skip" 		{token(SKIP); return SKIP;}
"string" 	{token(STRING); return STRING;}
"then" 		{token(THEN); return THEN;}
"var" 		{token(VAR); return VAR;}
"when" 		{token(WHEN); return WHEN;}



{boolean} {tokenBoolean("Boolean",yytext);}
{identifier} {tokenID("ID",yytext); }

\"  { 
    LIST;
    BEGIN(STR); 
    
}
<STR>\\n { 
    LIST; 
    strcat(stringBuf, "\n");
}
<STR>\\t { 
    LIST; 
    strcat(stringBuf, "\t");
}
<STR>\"\"    { 
    LIST; 
    strcat(stringBuf, "\"");
}
<STR>\"  { 
    BEGIN(INITIAL);
    strcat(stringBuf, "\0");
    for(int i = 0; i < MAX_LENGTH; i++){
    	//cout << stringBuf[i];
    	str_temp[i] = stringBuf[i];
    }
    tokenString("String",str_temp);
    stringBuf[0] = '\0';
}
<STR>\n  { 
    LIST; 
    printf("bad character:\\n\n"); 
    exit(-1); 
}
<STR>[^\"]* {
    LIST; 
    strcat(stringBuf, yytext);
}

"%".*    {LIST;}

"{%" {
    BEGIN(COMMENT);
    LIST;
}
<COMMENT>"%}"    {
    BEGIN(INITIAL);
    LIST;
}
<COMMENT>"\n"   {
    LIST;
    printf("%d: %s", linenum++, buf);
    buf[0] = '\0';
}
<COMMENT>[*]*   {LIST;}
<COMMENT>[^*/\n]* {LIST;}

\n      {
        LIST;
        printf("%d: %s", linenum++, buf);
        buf[0] = '\0';
        }

[ \t]*  {LIST;}

.       {
        LIST;
        printf("%d:%s\n", linenum+1, buf);
        printf("bad character:'%s'\n",yytext);
        exit(-1);
        }

%%
int yywrap(void){
	puts("---the file is end");
	return 1;
}
