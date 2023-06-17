%{

extern int yylex(void);
extern void yyerror(char *s);
extern int linenum;

#include <string>
#include <stdio.h>
#include <iostream>
#include <vector>
#define Trace(t)        printf(t)

#include"symbolTable.hpp"
using namespace std;
ID temp_id;
string temp_funtion_name = "";

string function_arguments_temp = "";
vector <vector<string>> 
function_arguments_type;

//data_value
int int_value = 0;
double real_value = 0;
string string_value = "";
bool bool_value = true;

%}
%union {
	int intVal;
	double realVal;
	bool boolVal;
	char* stringVal;
	int dataType;
}

/* union type */
%token <intVal> INT_VALUE INT
%token <realVal> REAL_VALUE REAL
%token <stringVal> STRING_VALUE //STRING_Dump
%token <boolVal> TRUE FALSE //BOOLEAN_Dump
%token <stringVal> ID
%token LP RP DOT COMMA COLON SEMICOLON LSB RSB LCB RCB ADDITION SUBTRACTION MULTIPLICATION DIVISION REMAINDER ASSIGNMENT LT LE GE GT EQ NOTE AND OR NOT
%token BOOL STRING VAR ARRAY CONST BEG GET CHAR DECREASING DEFAULT DO ELSE END EXIT FOR FUNCTION IF LOOP OF PUT PROCEDURE RESULT RETURN SKIP THEN WHEN


/* Operators */
%left OR
%left AND
%left NOT
%left LT LE EQ GE GT NOTE
%left ADDITION SUBTRACTION
%left MULTIPLICATION DIVISION
%nonassoc UMINUS

%type <dataType> type
%type <dataType> data_value //data
%type <dataType> expression boolean_expr

%start program
//%token SEMICOLON
%%
/*Program Units*/
//Start symbol
program: {
	create();
    }
    any_content
    ;

any_content: any_declaration | any_content any_declaration;
any_declaration: declaration | functions | procedures;

//Functions
functions: FUNCTION ID '(' {
        insert(4, $2, vOID, 0, true, ""); //predict function return type is vOID
        create();
        temp_funtion_name = $2;
    }
        function_contents{ 
            temp_id = lookup($2); 
            if (temp_id.data_type == vOID){// vOID 4
            	tab(cur_table -> layer +1);
            	fileJasm << "return" << endl;
            }
            tab(cur_table -> layer);
            fileJasm << "}" << endl;
            
            dump();
            cur_table = cur_table -> previous; //scope handling
    }
    ;
function_contents: {
	tab(cur_table -> layer);
	fileJasm << "method public static ";
	if(temp_funtion_name == "main"){
		fileJasm << "void " << temp_funtion_name << "(" << "java.lang.String[]";
	}
    } function_arguments_contents function_contents
    ;	
function_contents: ' '{ 
    tab(cur_table -> layer);
    fileJasm << " \n";
    } END ID
    | ' ' {
    tab(cur_table -> layer);
    fileJasm << " \n";
    } block_except_brace END ID
    ;
    
function_arguments_contents: ')' ':' type {
	if (temp_funtion_name != "main"){
		fileJasm << "void " << temp_funtion_name << "("; 
        }
        fileJasm << ")\n";
        tab(cur_table -> layer);
        fileJasm << "max_stack 15\n";
        tab(cur_table -> layer);
        fileJasm << "max_locals 15\n";
    }
    |   formal_arguments ')' { 
    	if(temp_funtion_name != "main"){
    		fileJasm << "void" << temp_funtion_name << "(";
    	}
    	fileJasm << function_arguments_temp;
    	vector<string> string_temp;
    	string_temp.push_back(temp_funtion_name);
    	string_temp.push_back(function_arguments_temp);
    	function_arguments_type.push_back(string_temp);
    	function_arguments_temp.clear();
        
        fileJasm << ")\n";
        tab(cur_table -> layer);
        fileJasm << "max_stack 15\n";
        tab(cur_table -> layer);
        fileJasm << "max_locals 15\n";
    }
    |   ')' ':' type {
        //correct fun return type
        SymbolTable* iter_table = head;
        while (iter_table != NULL) {
            for (int i = 0; i < iter_table -> id.size(); i++) {
                if (iter_table -> id[i].name == temp_funtion_name) {
                    cur_table -> id[i].data_type = $3;
                }
            }
            iter_table = iter_table -> next;
        }
        
        temp_id = find(temp_funtion_name);
        if (temp_id.name != ""){
        	if (temp_id.data_type == vOID){
        		fileJasm << "void ";
        	}
        	else if (temp_id.data_type == iNT){
        		fileJasm << "int ";
        	}
        	else if (temp_id.data_type == bOOL){
        		fileJasm << "boolean";
        	}
        	else{
        		yyerror((char*)"Function return type error.");
        	}
        }
        fileJasm << temp_funtion_name << "(";
        
        fileJasm << ")\n";
        tab(cur_table -> layer);
        fileJasm << "max_stack 15\n";
        tab(cur_table -> layer);
        fileJasm << "max_locals 15\n";    
    }
    |   formal_arguments ')' ':' type {
        //correct fun return type
        SymbolTable* iter_table = head;
        while (iter_table != NULL) {
            for (int i = 0; i < iter_table -> id.size(); i++) {
                if (iter_table -> id[i].name == temp_funtion_name) {
                    cur_table -> id[i].data_type = $4;
                }
            }
            iter_table = iter_table -> next;
        }
        
        temp_id = find (temp_funtion_name);
        if (temp_id.name != ""){
        	if (temp_id.data_type == vOID){
        		fileJasm << "void ";
        	}
        	else if (temp_id.data_type == iNT){
        		fileJasm << "int ";
        	}
        	else if (temp_id.data_type == bOOL){
        		fileJasm << "boolean";
        	}
        	else{
        		yyerror((char*)"Function return type error.");
        	}
        }   
        fileJasm << temp_funtion_name << "(";

        fileJasm << function_arguments_temp;
        vector<string> string_temp;
        string_temp.push_back(temp_funtion_name);
        string_temp.push_back(function_arguments_temp);
        function_arguments_type.push_back(string_temp);
        function_arguments_temp.clear();

        fileJasm << ")\n";
        tab(cur_table -> layer);
        fileJasm << "max_stack 15\n";
        tab(cur_table -> layer);
        fileJasm << "max_locals 15\n";             
    }
    ;
formal_arguments:  arguments
    |   formal_arguments ',' {
    	function_arguments_temp = function_arguments_temp + ", ";
    } arguments
    ;
    
arguments:  ID ':' type { 
	insert(2, $1, $3, 0, true, ""); 
	if ($3 == 0){
		function_arguments_temp = function_arguments_temp + "int";
	}
	else if ($3 == 2){
		function_arguments_temp = function_arguments_temp + "boolean";
	}
	else{
		yyerror((char*)"Function argument type error.");
	}	
    }
    ;
//procedures
procedures: PROCEDURE ID '(' {
        insert(5 , $2, vOID, 0, true, ""); //predict procedures return type is vOID
        create();
        temp_funtion_name = $2;
    }
        procedure_contents{ 
            dump(); 
            cur_table = cur_table -> previous; //scope handling
    }
    ;
procedure_contents: procedure_arguments_contents ' ' END ID
    |   procedure_arguments_contents ' ' block_except_brace END ID
    ;
    
procedure_arguments_contents: ')' { }
    |   formal_arguments ')' { }
formal_arguments:  ID ':' type { insert(2, $1, $3, 0, true, ""); } 
    |    formal_arguments ',' ID ':' type { insert(2, $3, $5, 0, true, ""); }	 
    ;
/*Block*/
//block
block_except_brace: block_content | block_content block_except_brace;

block_content: declaration 
    |	statements 
    |	expression
    |	RETURN expression {
        //expression & function type checking
        temp_id = find(temp_funtion_name);
        if(temp_id.data_type == vOID){
            yyerror((char*)"Function return type is void.");
        }
        if(temp_id.data_type != $2){
            yyerror((char*)"Function return type error.");
        }
        tab(cur_table -> layer + 1);
        fileJasm << "ireturn" << endl;
    }
    |   RETURN {
        temp_id = find(temp_funtion_name);
        if(temp_id.data_type != vOID){
            yyerror((char*)"Function return type is not void.");
        }
        tab(cur_table -> layer + 1);
        fileJasm << "return" << endl;
    }    
    ;

/*declaration*/
declaration:    const|var|array;
//Constants
const: CONST ID ':' type ASSIGNMENT expression {
        //cout << "-----TYPE: " << $4 << " EXPRESSION TYPE: " << $6 << endl;
        if($4 != $6){
            yyerror((char*)"Declaration data type error.");
        }
        else{    
            if($4 == 0){
                insert(1, $2, $4, int_value, true, "");
            }
            else if($4 == 2){
                insert(1, $2, $4, 0, bool_value, "");
            }
            else if($4 == 3){
                insert(1, $2, $4, 0, true, string_value);
            }
            else {
                yyerror((char*)"Declaration data type error.");
            }
        }
    }
    ;
//Variables
var: VAR ID {
        insert (2, $2, iNT, 0, true, "");
        if (cur_table == head){
            fileJasm << "\tfield static int " << $2 << endl;
        }
        else{
            tab (cur_table -> layer + 1);
		for (size_t i = 0; i < cur_table->id.size(); i++){
                	if (cur_table -> id[i].name == $2){
                    		fileJasm << "sipush " << 0 << endl;
                    		fileJasm << "istore " << i << endl;
                	}
            	}
        }
    }
    |	VAR ID ':' type {
        insert(2, $2, $4, 0, true, "");
        if (cur_table == head){
            fileJasm << "\tfield static ";
            if ($4 == 0){
            	fileJasm << "int ";
            }
            else if ($4 == 2){
        	fileJasm << "boolean ";
            }
            else {
            	yyerror((char*)"Declaration data type error.");
            }
            fileJasm << $2;
            if ($4 == 0){
            	fileJasm << endl;
            }
            else if ($4 == 2){
            	fileJasm << " = " << 1 << endl;
            }
        }	
        else{
            tab(cur_table->layer + 1);
		for (size_t i = 0; i < cur_table -> id.size(); i++){
                	if (cur_table -> id[i].name == $2){
                		if ($4 == 0){
                    			fileJasm << "sipush " << 0 << endl;
                    		}
                    		else if ($4 == 2){
                    		fileJasm << "iconst_1 " << endl;
                		}
                		else {
                			yyerror ((char*) "Declaration data type error.");
                		}
                		tab (cur_table -> layer + 1);
                		fileJasm << "istore " << i << endl;
            		}
        	}        
    	}
    }
    |   VAR ID ASSIGNMENT expression {
        if ($4 == 0){
            insert(2, $2, $4, int_value, true, "");
        }
        else if ($4 == 2){
            insert(2, $2, $4, 0, bool_value, "");
        }
        else {
            yyerror((char*)"Declaration data type error.");
        }
        if (cur_table == head){
            fileJasm << "\tfield static ";
            if ($4 == 0){
                fileJasm << "int ";
                fileJasm << $2 << " = " << int_value << endl;
            }
            else if ($4 == 2){
                fileJasm << "boolean ";
                fileJasm << $2 << " = " << bool_value << endl;
            }
            else{
                yyerror((char*)"Declaration data type error.");
            }
        }
        else{
            tab(cur_table -> layer + 1);
		for (size_t i = 0; i < cur_table -> id.size(); i++){
                	if (cur_table -> id[i].name == $2){
                    	fileJasm << "istore " << i << endl;
                }
            }
        }
    }
    |   VAR ID ':' type ASSIGNMENT expression {
        if ($4 == 0){
            insert(2, $2, $4, int_value, true, "");
        }
        else if ($4 == 2){
            insert(2, $2, $4, 0, bool_value, "");
        }
        else{
            yyerror((char*)"Declaration data type error.");
        }
  
        if ($4 != $6){
            yyerror((char*)"Declaration data type error.");
        }
        else{
            if (cur_table == head){
                fileJasm << "\tfield static ";
                if ($4 == 0){
                    fileJasm << "int ";
                    fileJasm << $2 << " = " << int_value << endl;
                }
                else if ($4 == 2){
                    fileJasm << "boolean ";
                    fileJasm << $2 << " = " << bool_value << endl;
                }
                else{
                    yyerror((char*)"Declaration data type error.");
        	}
            }
            else{
            	tab(cur_table -> layer + 1);
                for (size_t i = 0; i < cur_table -> id.size(); i++){
                    if (cur_table -> id[i].name == $2){
                        fileJasm << "istore " << i << endl;
                    }
                }
            }
        }	
    }
    ;
//Arrays
array: VAR ID ':' ARRAY INT '.''.' INT OF type{
        insert(3, $2, ARRAY, 0, true, "");
    }
    ;

/*Statements*/
//Simple
statements: ID ASSIGNMENT expression {
        putstatic_istore($1);
        temp_id = lookup($1);
        if(temp_id.name == ""){
            yyerror((char*)"Identify didn't declare yet.");
        }
        if(temp_id.const_var_array_function_prod == 1){
            yyerror((char*)"Constant can't be change.");
        }
    }
    |   ID ASSIGNMENT function_invocation_not_void {
    	putstatic_istore($1);
        temp_id = lookup($1);
        if(temp_id.name == ""){
            yyerror((char*)"Identify didn't declare yet.");
        }
        if(temp_id.const_var_array_function_prod == 1){
            yyerror((char*)"Constant can't be change.");
        }
    }
    |   PUT {
    	tab(cur_table -> layer + 1);
        fileJasm << "getstatic java.io.PrintStream java.lang.System.out" << endl;
        } 
        expression {
            tab(cur_table -> layer + 1);
            fileJasm << "invokevirtual void java.io.PrintStream.print";
            if($3 == 0){
                fileJasm << "(int)" << endl;
            }
            else if($3 == 2){
                fileJasm << "(boolean)" << endl;
            }
            else if($3 == 3){
                fileJasm << "(java.lang.String)" << endl;
            }
            else{
                yyerror((char*)"System out type error.");
            }
        }    
    |  	SKIP {
    	tab(cur_table -> layer + 1);
        fileJasm << "getstatic java.io.PrintStream java.lang.System.out" << endl;
        fileJasm << "invokevirtual void java.io.PrintStream.println";
    }
    /*
    |   EXIT
    |	EXIT WHEN boolean_expr
    |   RESULT expression {
        //expression & function type checking
        if (cur_table != nullptr){
            for(int i = 0; i < cur_table -> id.size(); i++){
                if(cur_table -> id[i].name == temp_funtion_name){
                    if(cur_table -> id[i].data_type != $2){
                        yyerror((char*)"Function return type error.");
                    }
                }
            }
	}
    }
    |   RETURN {
        if (cur_table != nullptr){
            for(int i = 0; i < cur_table -> id.size(); i++){
                if(cur_table -> id[i].name == temp_funtion_name){
                    if(cur_table -> id[i].data_type != vOID){
                        yyerror((char*)"Function return type is not void.");
                    }
                }
            }
	}
    }
    */
    |   loop
    |   conditional
    ;


//Conditional
conditional: IF '(' boolean_expr ')' THEN only_if  block_or_statement END IF {
        tab ( cur_table -> layer);
        fileJasm << "Lfalse" << if_else_counter << ":" << endl;
        if_else_counter = if_else_counter + 1;
    }
    |	IF '('boolean_expr')' THEN only_if  block_or_statement ELSE have_else block_or_statement END IF {
	tab(cur_table -> layer);
        fileJasm << "Lexit" << if_else_counter << ":" << endl;
        if_else_counter = if_else_counter + 1;

    }   
    ;
only_if: {
        tab ( cur_table -> layer + 1);
        fileJasm << "ifeq Lfalse" << if_else_counter << endl;
    }
    ;
have_else: {
        tab(cur_table -> layer + 1);
        fileJasm << "goto Lexit" << if_else_counter << endl;
        tab(cur_table -> layer);
        fileJasm << "Lfalse" << if_else_counter << ":" << endl;
    }
    ;
//Loop
loop: LOOP {
	tab(cur_table -> layer);
        fileJasm << "Lbegin_loop" << while_counter << ":" << endl;
    } EXIT WHEN '(' boolean_expr ')' {
	tab (cur_table -> layer + 1);
	fileJasm << "ifeq Lexit_loop" << while_counter << endl;
    } block_or_statement {
        tab(cur_table -> layer + 1);
        fileJasm << "goto Lbegin_loop" << while_counter << endl;
        tab(cur_table -> layer);
        fileJasm << "Lexit_loop" << while_counter << ":" << endl;
    } END LOOP
    |   FOR ID ':' INT_VALUE{
    	insert(2, $2, $4, 0, true, "");
    	//insert (2, $3, iNT, $5, true, "");
    	tab (cur_table -> layer + 1);
    	fileJasm << "sipush " << $4 << endl;
    	putstatic_istore($2);
    } '.' '.' INT_VALUE {
        tab (cur_table -> layer);
        fileJasm << "Lbegin_for" << for_counter << ":" << endl;
        getstatic_iload_sipush_iconst_ldc($2);
        tab (cur_table -> layer + 1);
        fileJasm << "sipush " << $8 << endl;
        if($8 > $4){
            boolean_expr_reduce("ifgt");
            tab(cur_table -> layer + 1);
            fileJasm << "ifne Lexit" << for_counter << endl;
        }
        else{
            boolean_expr_reduce("iflt");
            tab(cur_table -> layer + 1);
            fileJasm << "ifne Lexit" << for_counter << endl;
        }    	
    }block_or_statement {
    	getstatic_iload_sipush_iconst_ldc($2);
    	tab (cur_table -> layer + 1);
        fileJasm << "sipush 1" << endl;
        tab (cur_table -> layer + 1);
        if ($8 > $4){
        	fileJasm << "iadd" << endl;
        }
        else {
        	fileJasm << "isub" <<endl;
        }
        putstatic_istore($2);
        tab (cur_table -> layer +1);
        fileJasm << "goto Lbegin_for" << for_counter << endl;
        tab (cur_table -> layer);
        fileJasm << "Lexit" << for_counter << ":" << endl;
        for_counter = for_counter + 1;
        delete_ID($2);
    } END FOR
    ;

//expressions
expression: '[' expression ']' {$$ = $2;}
	/*
    |   expression OR expression {
    	boolean_expr_reduce ("ior")
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
    	*/
    |	expression '<' expression {
        boolean_expr_reduce("iflt");
        if($1 != $3){
            yyerror((char*)"Type error.");
        }
    }
    |   expression '>' expression {
        boolean_expr_reduce("ifgt");
        if($1 != $3){
            yyerror((char*)"Type error.");
        }
    }	
    |   expression '-' expression {
        if($1 != $3){
            yyerror((char*)"Type error.");
        }
	tab(cur_table->layer + 1);
        fileJasm << "isub" << endl;
    }
    |   expression '+' expression {
        if($1 != $3){
            yyerror((char*)"Type error.");
        }
        tab(cur_table->layer + 1);
        fileJasm << "iadd" << endl;
    }
    |   expression '/' expression {
        if($1 != $3){
            yyerror((char*)"Type error.");
        }
        tab(cur_table->layer + 1);
        fileJasm << "idiv" << endl;
    }
    |   expression '*' expression {
        if($1 != $3){
            yyerror((char*)"Type error.");
        }
        tab(cur_table->layer + 1);
        fileJasm << "imul" << endl;
    }
    |   expression REMAINDER expression {
        if($1 != $3){
            yyerror((char*)"Type error.");
        }
        tab(cur_table->layer + 1);
        fileJasm << "irem" << endl;
    }    
    |   '-' expression %prec UMINUS {
    	$$ = -$2;
    	tab(cur_table->layer + 1);
        fileJasm << "ineg" << endl;
    }
    /*
    |   STRING_Dump {$$ = sTRING;}
    |   BOOLEAN_Dump {$$ = bOOL;} 
    */
    |   data_value
    //|   const_expr
    |   ID {
        temp_id = lookup($1);
        if(temp_id.name == ""){
            yyerror((char*)"Identify didn't declare yet.");
        }
        else{
            if(cur_table != head){
                getstatic_iload_sipush_iconst_ldc($1);    
            }
            $$ = temp_id.data_type;
        }
    }
    //|	function_invocation
    ;

//function invocation
function_invocation_not_void: ID '(' function_arguments ')' {
        temp_id = lookup($1);
        if(temp_id.name == ""){
            yyerror((char*)"Identify didn't declare yet.");
        }
        if (temp_id.data_type == vOID){
            yyerror((char*)"Function return type is void.");
        }
        
        tab (cur_table -> layer + 1);
        if (temp_id.data_type == 0){
            fileJasm << "invokestatic " << "int " << head -> id[0].name << "." << temp_id.name << "(";
        }
        else if(temp_id.data_type == 2){
            fileJasm << "invokestatic " << "boolean " << head -> id[0].name << "." << temp_id.name << "(";
        }
        for(int i = 0; i < function_arguments_type.size();i++){
            if(function_arguments_type[i][0] == temp_id.name){
                fileJasm << function_arguments_type[i][1] << ")" << endl;
            }
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
boolean_expr: expression '<' expression {
	boolean_expr_reduce("iflt");
    }
    |   expression '>' expression {
    	boolean_expr_reduce("ifgt");
    }	
    |   expression LE expression {
    	boolean_expr_reduce("ifle");
    }
    |   expression GE expression {
    	boolean_expr_reduce("ifge");
    }
    |   expression EQ expression {
    	boolean_expr_reduce("ifeq");
    }
    |   expression NOTE expression {
    	boolean_expr_reduce("ifne");
    }
    |   expression '|' expression {
        tab(cur_table->layer + 1);
        fileJasm << "ior" << endl;
    }
    |   expression '&' expression{
        tab(cur_table->layer + 1);
        fileJasm << "iand" << endl;
    }
    |   '!' expression {
        tab(cur_table -> layer + 1);
        fileJasm << "iconst_1" << endl;
        tab(cur_table -> layer + 1);
        fileJasm << "ixor" << endl;
    }
    ;

block_or_statement: BEG block_except_brace END | block_except_brace_only_one_line;
block_except_brace_only_one_line: block_content;

type:   INT     {$$ = iNT;}
    |   REAL   	{$$ = rEAL;}
    |   BOOL    {$$ = bOOL;}
    |   STRING  {$$ = sTRING;}
    ;
data_value:	INT_VALUE	{$$ = iNT; int_value = $1; if (cur_table != head){ tab (cur_table -> layer + 1); fileJasm << "sipush " << $1 << endl;}}
	|	REAL_VALUE	{$$ = rEAL; real_value = $1;}
	|	STRING_VALUE	{$$ = sTRING; string_value = $1; if (cur_table != head) {tab (cur_table -> layer + 1); fileJasm << "ldc \"" << $1 << "\"" << endl;}}
	|	TRUE		{$$ = bOOL; bool_value = true; if (cur_table != head){ tab (cur_table -> layer + 1); fileJasm << "iconst_1" << endl;}}
	|	FALSE		{$$ = bOOL; bool_value = false; if (cur_table != head){ tab (cur_table -> layer + 1); fileJasm << "iconst_0" << endl;}}
	;
	
%%
#include "lex.yy.c"

void yyerror(char *msg){
    fprintf(stderr, "line %d: %s\n", linenum, msg);
    exit(-1);
}

int main(int argc, char* argv[]){
    /* open the source program file */
    if (argc != 2) {
        printf ("Usage: sc filename\n");
        exit(1);
    }
    yyin = fopen(argv[1], "r");         /* open input file */
    
    string filename(argv[1]);
    	filename = filename.substr(0, strlen(argv[1]) - 3);
    	filename = filename + ".jasm";
    fileJasm.open(filename, ios::out | ios::trunc);
    /* perform parsing */
    if (yyparse() == 1)                 /* parsing */
        yyerror((char*)"Parsing error !");     /* syntax error */
}
