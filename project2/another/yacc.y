%{

extern int yylex(void);
extern void yyerror(char *s);
extern int linenum;

#include <string.h>
#include <stdio.h>
#include <iostream>
#define Trace(t)        printf(t)

#include"symbolTable.hpp"

using namespace std;

SymbolTable* head = nullptr;
SymbolTable* cur_table = nullptr;
ID temp_id;
string temp_funtion_name = "";

%}
%union {
	int intVal;
	double realVal;
	bool boolVal;
	string stringVal;
	int dataType;
}

/* union type */
%token <intVal> INT
%token <realVal> REAL
%token <stringVal> STRING_Dump
%token <boolVal> BOOLEAN_Dump
%token <stringVal> ID
%token LP RP DOT COMMA COLON SEMICOLON LSB RSB LCB RCB ADDITION SUBTRACTION MULTIPLICATION DIVISION REMAINDER ASSIGNMENT LT LE GE GT EQ NOTE AND OR NOT
%token BOOL STRING VAR ARRAY CONST BEGIN CHAR DECREASING DEFAULT DO ELSE END EXIT FOR FUNCTION GET IF LOOP OF PUT PROCEDURE RESULT RETURN SKIP THEN WHEN FALSE TRUE


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
any_declaration: declaration | functions ;

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
function_contents: function_arguments_contents ' ' END
    |   function_arguments_contents ' ' block_except_brace END
    ;
function_arguments_contents: ')' { }
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
                    cur_table->id[i].data_type = $5;
                }
            }
            iter_table = iter_table->next;
        }
    }
    ;
formal_arguments:  ID ':' type { insert(2, $1, $3); } 
    |    formal_arguments ',' ID ':' type { insert(2, $3, $5); } 
    ;


/*Block*/
//block
block_except_brace: block_content | block_content block_except_brace
    ;
block_content: declaration | statements | expression
    ;

/*declaration*/
declaration:    const|var|array
    ;
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
var: VAR ID {
        insert(2, $2, iNT);
    }
    |   VAR ID ':' type {
        //cout << "-------------TYPE: " << $4 << endl;
        insert(2, $2, $4);
    }
    |   VAR ID ASSIGNMENT expression {
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
array: VAR ID ':' ARRAY INT '.' '.' INT OF type{
        insert(3, $2, $4 ':' type);
    }
    ;

/*Statements*/
//Simple
/*statements: ID ASSIGNMENT expression {
        temp_id = lookup($1);
        if(temp_id.name == ""){
            yyerror((char*)"Identify didn't declare yet.");
        }
        if(temp_id.const_var_array_function == 1){
            yyerror((char*)"Constant can't be change.");
        }
    }
    |   ID function_invocation {
        temp_id = lookup($1);
        if(temp_id.name == ""){
            yyerror((char*)"Identify didn't declare yet.");
        }
        if(temp_id.const_var_array_function == 1){
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
        if(temp_id.const_var_array_function == 1){
            yyerror((char*)"Constant cannot be changed.");
        }
    }
    |   PUT expression{
        if($2 == sTRING){
            cout << $2 << endl;
        }
        else{
            cout << $2 << endl;
        }
    }
    |   GET ID{
        temp_id = lookup($2);
        if(temp_id.name == ""){
            yyerror((char*)"Identifier hasn't been declared yet.");
        }
    }
    |  	SKIP
    |   EXIT
    |	EXIT WHEN expression  
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
    ;

//Conditional
conditional: IF boolean_expr THEN block_or_statement ELSE block_or_statement
    |   IF boolean_expr THEN block_or_statement
    ;
//Loop
loop: LOOP block_or_statement
    |   FOR ID ':' const_expr '.' '.' const_expr block_or_statement
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

boolean_expr: expression '<' expression
    |   expression '>' expression
    |   expression LE expression
    |   expression GE expression
    |   expression '=' expression
    |   expression NOTE expression
    |   BOOLEAN_Dump {$$ = bOOL;}
    ;
const_expr:  INT {$$ = iNT;}
    | REAL{$$ = rEAL;}
    ; 
block_or_statement: BEGIN block_except_brace END | block_except_brace | statements;

type:   INT     {$$ = viNT;}
    |   REAL   	{$$ = vREAL;}
    |   BOOL    {$$ = vBOOL;}
    |   STRING  {$$ = vSTRING;}
    |   BOOLEAN_Dump {$$ = vBOOL;}
    |   STRING_Dump {$$ = vSTRING;}
    ;
data:	INT		{$$ = iNT;}
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
type: INT {
        $$ = vINT;
    }
    | REAL {
        $$ = vREAL;
    }
    | BOOLEAN_Dump {
        $$ = vBOOL;
    }
    | STRING_Dump {
        $$ = vSTRING;
    }
    ;

/* Statements */
statements: statement | statements statement
    ;

statement: assignment | conditional_statement | loop_statement | exit_statement | return_statement | put_statement | get_statement | skip_statement | procedure_call
    ;

assignment: ID ASSIGNMENT expression {
        temp_id = get_id($1);
        if (temp_id.data_type != $3) {
            cout << "Error: Incompatible data types in assignment statement" << endl;
        }
    }
    ;

conditional_statement: IF boolean_expr THEN block_except_brace END {
        if ($2 != vBOOL) {
            cout << "Error: Condition expression in IF statement must be of type boolean" << endl;
        }
    }
    | IF boolean_expr THEN block_except_brace ELSE block_except_brace END {
        if ($2 != vBOOL) {
            cout << "Error: Condition expression in IF statement must be of type boolean" << endl;
        }
    }
    ;

loop_statement: LOOP block_except_brace END
    ;

exit_statement: EXIT
    ;

return_statement: RETURN
    | RETURN expression {
        if (temp_function_name != "") {
            temp_id = get_id(temp_function_name);
            if ($2 != temp_id.data_type) {
                cout << "Error: Return type mismatch in function " << temp_function_name << endl;
            }
        }
    }
    ;

put_statement: PUT expression
    ;

get_statement: GET ID {
        temp_id = get_id($2);
    }
    ;

skip_statement: SKIP
    ;

procedure_call: ID '(' ')' {
        temp_id = get_id($1);
        if (temp_id.data_type != vOID) {
            cout << "Error: Procedure call must be of type void" << endl;
        }
    }
    | ID '(' expression_contents ')' {
        temp_id = get_id($1);
        if (temp_id.data_type != vOID) {
            cout << "Error: Procedure call must be of type void" << endl;
        }
    }
    ;

expression_contents: expression {
        if (temp_id.parameters.size() != 1) {
            cout << "Error: Invalid number of arguments in procedure call " << temp_id.name << endl;
        }
        if (temp_id.parameters[0] != $1) {
            cout << "Error: Argument type mismatch in procedure call " << temp_id.name << endl;
        }
    }
    | expression_contents ',' expression {
        if (temp_id.parameters.size() <= $1.size()) {
            cout << "Error: Invalid number of arguments in procedure call " << temp_id.name << endl;
        }
        if (temp_id.parameters[$1.size()] != $3) {
            cout << "Error: Argument type mismatch in procedure call " << temp_id.name << endl;
        }
    }
    ;

/* Expressions */
expression: arithmetic_expr {
        $$ = $1;
    }
    | boolean_expr {
        $$ = $1;
    }
    ;

arithmetic_expr: term {
        $$ = $1;
    }
    | arithmetic_expr '+' term {
        if ($1 != $3) {
            cout << "Error: Incompatible data types in addition" << endl;
        }
        $$ = $1;
    }
    | arithmetic_expr '-' term {
        if ($1 != $3) {
            cout << "Error: Incompatible data types in subtraction" << endl;
        }
        $$ = $1;
    }
    ;

term: factor {
        $$ = $1;
    }
    | term '*' factor {
        if ($1 != $3) {
            cout << "Error: Incompatible data types in multiplication" << endl;
        }
        $$ = $1;
    }
    | term '/' factor {
        if ($1 != $3) {
            cout << "Error: Incompatible data types in division" << endl;
        }
        $$ = $1;
    }
    ;

factor: '(' expression ')' {
        $$ = $2;
    }
    | constant {
        $$ = $1;
    }
    | ID {
        $$ = get_id($1).data_type;
    }
    ;

constant: INT {
        $$ = vINT;
    }
    | REAL {
        $$ = vREAL;
    }
    | BOOLEAN_Dump {
        $$ = vBOOL;
    }
    | STRING {
        $$ = vSTRING;
    }
    ;

boolean_expr: expression EQ expression {
        if ($1 != $3) {
            cout << "Error: Incompatible data types in equality comparison" << endl;
        }
        $$ = vBOOL;
    }
    | expression NOTE expression {
        if ($1 != $3) {
            cout << "Error: Incompatible data types in inequality comparison" << endl;
        }
        $$ = vBOOL;
    }
    | expression LT expression {
        if ($1 != vINT && $1 != vREAL) {
            cout << "Error: Incompatible data types in less than comparison" << endl;
        }
        if ($1 != $3) {
            cout << "Error: Incompatible data types in less than comparison" << endl;
        }
        $$ = vBOOL;
    }
    | expression GT expression {
        if ($1 != vINT && $1 != vREAL) {
            cout << "Error: Incompatible data types in greater than comparison" << endl;
        }
        if ($1 != $3) {
            cout << "Error: Incompatible data types in greater than comparison" << endl;
        }
        $$ = vBOOL;
    }
    | expression LE expression {
        if ($1 != vINT && $1 != vREAL) {
            cout << "Error: Incompatible data types in less than or equal to comparison" << endl;
        }
        if ($1 != $3) {
            cout << "Error: Incompatible data types in less than or equal to comparison" << endl;
        }
        $$ = vBOOL;
    }
    | expression GE expression {
        if ($1 != vINT && $1 != vREAL) {
            cout << "Error: Incompatible data types in greater than or equal to comparison" << endl;
        }
        if ($1 != $3) {
            cout << "Error: Incompatible data types in greater than or equal to comparison" << endl;
        }
        $$ = vBOOL;
    }
    | NOT expression {
        if ($2 != vBOOL) {
            cout << "Error: Operand in logical NOT expression must be of type boolean" << endl;
        }
        $$ = vBOOL;
    }
    | expression AND expression {
        if ($1 != vBOOL || $3 != vBOOL) {
            cout << "Error: Operands in logical AND expression must be of type boolean" << endl;
        }
        $$ = vBOOL;
    }
    | expression OR expression {
        if ($1 != vBOOL || $3 != vBOOL) {
            cout << "Error: Operands in logical OR expression must be of type boolean" << endl;
        }
        $$ = vBOOL;
    }
    ;
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
