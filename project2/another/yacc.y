%{

extern int yylex(void);
extern void yyerror(char *s);
extern int linenum;

#include <string>
#include <stdio.h>
#include <iostream>
#define Trace(t)        printf(t)

#include"symbolTable.hpp"
using namespace std;
ID temp_id;
string temp_funtion_name = "";

%}
%union {
	int intVal;
	double realVal;
	bool boolVal;
	char* stringVal;
	int dataType;
}

/* union type */
%token <intVal> INT
%token <realVal> REAL
%token <stringVal> STRING_Dump
%token <boolVal> BOOLEAN_Dump
%token <stringVal> ID
%token LP RP DOT COMMA COLON SEMICOLON LSB RSB LCB RCB ADDITION SUBTRACTION MULTIPLICATION DIVISION REMAINDER ASSIGNMENT LT LE GE GT EQ NOTE AND OR NOT
%token BOOL STRING VAR ARRAY CONST BEG CHAR DECREASING DEFAULT DO ELSE END EXIT FOR FUNCTION GET IF LOOP OF PUT PROCEDURE RESULT RETURN SKIP THEN WHEN FALSE TRUE


/* Operators */
%left OR
%left AND
%left NOT
%left LT LE EQ GE GT NOTE
%left ADDITION SUBTRACTION
%left MULTIPLICATION DIVISION
%nonassoc UMINUS

%type <dataType> type
%type <dataType> data
%type <dataType> expression boolean_expr const_expr

%start program
//%token SEMICOLON
%%
/*Program Units*/
//Start symbol
program:{
	create();
    }
	any_content
    ;

any_content: any_declaration | any_content any_declaration;
any_declaration: declaration | functions | procedures;

//Functions
functions: FUNCTION ID '(' {
        insert(4,$2,vOID); //predict function return type is vOID
        create();
        temp_funtion_name = $2;
    }
        function_contents{ 
            dump(); 
            cur_table = cur_table->previous; //scope handling
    }
    ;
function_contents: function_arguments_contents ' ' END ID
    |   function_arguments_contents ' ' block_except_brace END ID
    ;
function_arguments_contents: ')' ':' type { }
    |   formal_arguments ')' { }
    |   ')' ':' type {
        //correct fun return type
        SymbolTable* iter_table = head;
        while (iter_table != NULL) {
            for (int i = 0; i < iter_table->id.size(); i++) {
                if (iter_table->id[i].name == temp_funtion_name) {
                    cur_table->id[i].data_type = $3;
                }
            }
            iter_table = iter_table->next;
        }
    }
    |   formal_arguments ')' ':' type {
        //correct fun return type
        SymbolTable* iter_table = head;
        while (iter_table != NULL) {
            for (int i = 0; i < iter_table->id.size(); i++) {
                if (iter_table->id[i].name == temp_funtion_name) {
                    cur_table->id[i].data_type = $4;
                }
            }
            iter_table = iter_table->next;
        }
    }
    ;
formal_arguments:  ID ':' type { insert(2, $1, $3); } 
    |    formal_arguments ',' ID ':' type { insert(2, $3, $5); }	 
    ;

//procedures
procedures: PROCEDURE ID '(' {
        insert(5,$2,vOID); //predict procedures return type is vOID
        create();
        temp_funtion_name = $2;
    }
        procedure_contents{ 
            dump(); 
            cur_table = cur_table->previous; //scope handling
    }
    ;
procedure_contents: procedure_arguments_contents ' ' END ID
    |   procedure_arguments_contents ' ' block_except_brace END ID
    ;
    
procedure_arguments_contents: ')' { }
    |   formal_arguments ')' { }
formal_arguments:  ID ':' type { insert(2, $1, $3); } 
    |    formal_arguments ',' ID ':' type { insert(2, $3, $5); }	 
    ;
/*Block*/
//block
block_except_brace: block_content | block_content block_except_brace;
block_content: declaration | statements | expression;

/*declaration*/
declaration:    const|var|array;
//Constants
const: CONST ID ASSIGNMENT expression {
        insert(1, $2, $4);
    }
    |   CONST ID ASSIGNMENT type ASSIGNMENT expression {
        //cout << "-----TYPE: " << $4 << " EXPRESSION TYPE: " << $6 << endl;
        if($4 != $6){
            yyerror((char*)"Declaration data type error.");
        }
        else{
            insert(1, $2, $4);
        }
    }
    ;
//Variables
var: VAR ID ':' type {
        //cout << "-------------TYPE: " << $4 << endl;
        insert(2, $2, $4);
    }
    |   VAR ID ASSIGNMENT const_expr {
        insert(2, $2, $4);
    }
    |   VAR ID ':' type ASSIGNMENT expression {
        //cout << "-----TYPE: " << $4 << " EXPRESSION TYPE: " << $6 << endl;
        if($4 != $6){
            yyerror((char*)"Declaration data type error.");
        }
        else{
            insert(2, $2, $4);
        }
    }
    ;
//Arrays
array: VAR ID ':' ARRAY INT '.''.' INT OF type{
        insert(3, $2, ARRAY);
    }
    ;

/*Statements*/
//Simple
statements: ID ASSIGNMENT expression {
        temp_id = lookup($1);
        if(temp_id.name == ""){
            yyerror((char*)"Identify didn't declare yet.");
        }
        if(temp_id.const_var_array_function_prod == 1){
            yyerror((char*)"Constant can't be change.");
        }
    }
    |   ID function_invocation {
        temp_id = lookup($1);
        if(temp_id.name == ""){
            yyerror((char*)"Identify didn't declare yet.");
        }
        if(temp_id.const_var_array_function_prod == 1){
            yyerror((char*)"Constant can't be change.");
        }
    }
    |   ID '[' expression ']' '=' expression {
        temp_id = lookup($1);
        if(temp_id.name == ""){
            yyerror((char*)"Identify didn't declare yet.");
        }
        if(temp_id.data_type != $6){
            yyerror((char*)"Declaration data type error.");
        }
    }
    |   ID '[' expression ']' '=' expression {
        temp_id = lookup($1);
        if(temp_id.name == ""){
            yyerror((char*)"Identifier hasn't been declared yet.");
        }
        if(temp_id.const_var_array_function_prod == 1){
            yyerror((char*)"Constant cannot be changed.");
        }
    }
    |   PUT expression
    |   GET ID
    |  	SKIP
    |   EXIT
    |	EXIT WHEN boolean_expr
    |   RESULT expression {
        //expression & function type checking
        if (cur_table != nullptr){
            for(int i = 0;i<cur_table->id.size();i++){
                if(cur_table->id[i].name == temp_funtion_name){
                    if(cur_table->id[i].data_type != $2){
                        yyerror((char*)"Function return type error.");
                    }
                }
            }
		}
    }
    |   RETURN {
        if (cur_table != nullptr){
            for(int i = 0;i<cur_table->id.size();i++){
                if(cur_table->id[i].name == temp_funtion_name){
                    if(cur_table->id[i].data_type != vOID){
                        yyerror((char*)"Function return type is not void.");
                    }
                }
            }
	}
    }
    |   loop
    |   conditional
    |	blocks
    ;

//blocks
blocks: BEG block_or_statement END;
//Conditional
conditional: IF boolean_expr THEN block_or_statement ELSE block_or_statement END IF
    |   IF boolean_expr THEN block_or_statement END IF
    ;
//Loop
loop: LOOP block_or_statement END LOOP
    |   FOR ID ':' const_expr '.' '.' const_expr block_or_statement END FOR
    ;

//expressions
expression: '[' expression ']' {$$ = $2;}
    |   expression OR expression {
        //type checking
        if($1 != bOOL && $3 != bOOL){
            yyerror((char*)"Type error.");
        }
    } 
    |   expression AND expression {
        if($1 != bOOL && $3 != bOOL){
            yyerror((char*)"Type error.");
        }
    } 
    |   NOT expression {$$ = $2;}
    |   expression '-' expression {
        if($1 != $3){
            yyerror((char*)"Type error.");
        }
        else{
            $$ = $1 - $3;
        }
    }
    |   expression '+' expression {
        if($1 != $3){
            yyerror((char*)"Type error.");
        }
        else{
            $$ = $1 + $3;
        }
    }
    |   expression '/' expression {
        if($1 != $3){
            yyerror((char*)"Type error.");
        }
        else{
            $$ = $1 / $3;
        }
    }
    |   expression '*' expression {
        if($1 != $3){
            yyerror((char*)"Type error.");
        }
        else{
            $$ = $1 * $3;
        }
    }
    |   expression REMAINDER expression {
        if($1 != $3){
            yyerror((char*)"Type error.");
        }
        else{
            $$ = $1 % $3;
        }
    }    

    |   '-' expression %prec UMINUS {$$ = -$2;}
    |   STRING_Dump {$$ = sTRING;}
    |   BOOLEAN_Dump {$$ = bOOL;}
    |   data
    |   ID {
        temp_id = lookup($1);
        if(temp_id.name == ""){
            yyerror((char*)"Identify didn't declare yet.");
        }
        else{
            $$ = temp_id.data_type;
        }
    }
    |	function_invocation
    ;

//function invocation
function_invocation: ID '(' function_arguments ')' {
        temp_id = lookup($1);
        if(temp_id.name == ""){
            yyerror((char*)"Identify didn't declare yet.");
        }
    }
    ;
function_arguments: expression
    |   function_arguments ',' expression
    ;
procedure_invocation: ID '(' procedure_arguments ')' {
        temp_id = lookup($1);
        if(temp_id.name == ""){
            yyerror((char*)"Identify didn't declare yet.");
        }
    }
    ;
procedure_arguments: expression
    |   procedure_arguments ',' expression
    ;
boolean_expr: expression '<' expression
    |   expression '>' expression
    |   expression LE expression
    |   expression GE expression
    |   expression EQ expression
    |   expression NOTE expression
    |   BOOLEAN_Dump {$$ = bOOL;}
    ;
const_expr:  INT {$$ = iNT;}
    | REAL{$$ = rEAL;}
    ; 

block_or_statement: block_except_brace | statements;

type:   INT     {$$ = iNT;}
    |   REAL   	{$$ = rEAL;}
    |   BOOL    {$$ = bOOL;}
    |   STRING  {$$ = sTRING;}
    |   BOOLEAN_Dump {$$ = bOOL;}
    |   STRING_Dump {$$ = sTRING;}
    ;
data:		INT	{$$ = iNT;}
	|	REAL	{$$ = rEAL;}
	|	STRING	{$$ = sTRING;}
	|	TRUE	{$$ = bOOL;}
	|	FALSE	{$$ = bOOL;}
	;
/*program:        ID semi
                {
                Trace("Reducing to program\n");
                }
                ;

semi:           SEMICOLON
                {
                Trace("Reducing to semi\n");
                }
                ;*/

%%
#include "lex.yy.c"

void yyerror(char *msg)
{
    fprintf(stderr, "line %d: %s\n", linenum, msg);
    exit(-1);
}

int main(int argc, char* argv[])
{
    /* open the source program file */
    if (argc != 2) {
        printf ("Usage: sc filename\n");
        exit(1);
    }
    yyin = fopen(argv[1], "r");         /* open input file */

    /* perform parsing */
    if (yyparse() == 1)                 /* parsing */
        yyerror((char*)"Parsing error !");     /* syntax error */
}
