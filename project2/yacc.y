%{
#include <stdio.h>
#include <string.h>
#include <stdbool.h>
#include "union.h"

int yylex(void);
void yyerror(const char *s);

struct content{
	char id[256];
	int ival;
	float rval;
	int bval;
	char sval[256];
	char type[256];
	char bigtype[256];
};

struct content symbolTable[256][256];
int id_total=0;
int scope = 0;
int isShouldAdd = 0;

int insert(struct content a){
	bool inSymbolTable = false ;
	for(int i = 0 ; i < id_total; i++){
		if(strcmp(a.id, symbolTable[scope][i].id)==0){
			inSymbolTable = true ;
		}
	}
	if (!inSymbolTable){
		if(strcmp("int",a.type)==0){
			if(strcmp("arrays",a.bigtype)==0){
			strcpy(symbolTable[scope][id_total].id,a.id);
			strcpy(symbolTable[scope][id_total].type,a.type);
			strcpy(symbolTable[scope][id_total].bigtype,a.bigtype);
			id_total++;
			}
			else{
			strcpy(symbolTable[scope][id_total].id,a.id);
			symbolTable[scope][id_total].ival = a.ival;
			strcpy(symbolTable[scope][id_total].type,a.type);
			strcpy(symbolTable[scope][id_total].bigtype,a.bigtype);
			id_total++;
			}
		}
		else if(strcmp("real",a.type)==0){
			if(strcmp("arrays",a.bigtype)==0){
			strcpy(symbolTable[scope][id_total].id,a.id);
			strcpy(symbolTable[scope][id_total].type,a.type);
			strcpy(symbolTable[scope][id_total].bigtype,a.bigtype);
			id_total++;
			}
			else{
			strcpy(symbolTable[scope][id_total].id,a.id);
			symbolTable[scope][id_total].fval = a.fval;
			strcpy(symbolTable[scope][id_total].type,a.type);
			strcpy(symbolTable[scope][id_total].bigtype,a.bigtype);
			id_total++;
			}
		}
		else if(strcmp("string",a.type)==0){
			if(strcmp("arrays",a.bigtype)==0){
			strcpy(symbolTable[scope][id_total].id,a.id);
			strcpy(symbolTable[scope][id_total].type,a.type);
			strcpy(symbolTable[scope][id_total].bigtype,a.bigtype);
			id_total++;
			}
			else{
			strcpy(symbolTable[scope][id_total].id,a.id);
			strcpy(symbolTable[scope][id_total].sval,a.sval);
			strcpy(symbolTable[scope][id_total].type,a.type);
			strcpy(symbolTable[scope][id_total].bigtype,a.bigtype);
			id_total++;
			}
		}
		else if(strcmp("bool",a.type)==0){
			if(strcmp("arrays",a.bigtype)==0){
			strcpy(symbolTable[scope][id_total].id,a.id);
			strcpy(symbolTable[scope][id_total].type,a.type);
			strcpy(symbolTable[scope][id_total].bigtype,a.bigtype);
			id_total++;
			}
			else{
			strcpy(symbolTable[scope][id_total].id,a.id);
			strcpy(symbolTable[scope][id_total].type,a.type);
			symbolTable[scope][id_total].bval = a.bval;
			strcpy(symbolTable[scope][id_total].bigtype,a.bigtype);
			id_total++;
			}
		}
		else{
			strcpy(symbolTable[scope][id_total].id,a.id);
			strcpy(symbolTable[scope][id_total].type,a.type);
			symbolTable[scope][id_total].ival = a.ival;
			strcpy(symbolTable[scope][id_total].bigtype,a.bigtype);

		}
	}
} 

int lookup(char *c){
	for (int i = 0; i <= scope; i++){
		for(int j=0;j<=id_total;j++){
			if (strcmp(c , symbolTable[i][j].id)==0){			
				if(strcmp(symbolTable[i][j].type,"int")==0){
					return symbolTable[i][j].ival;
				}
				else{
				
				}
			}
			else{
			}
		}
	}
}

int dump(){
	for (int i = 0; i <= scope; i++){
		for (int j=0; j <= id_total ;j++){
			if(strcmp("int",symbolTable[i][j].type)==0){
				if(strcmp("arrays",symbolTable[i][j].bigtype)==0){
					printf("%-*s\t%-*s\t%-*s\t%-*s\t%-*d\n",10,symbolTable[i][j].id,10,symbolTable[i][j].type,10,symbolTable[i][j].bigtype,10," ",10,i);
				}
				else{
					printf("%-*s\t%-*s\t%-*s\t%-*d\t%-*d\n",10,symbolTable[i][j].id,10,symbolTable[i][j].type,10,symbolTable[i][j].bigtype,10,symbolTable[i][j].ival,10,i);
				}
			}
			else if(strcmp("real",symbolTable[i][j].type)==0){
				if(strcmp("arrays",symbolTable[i][j].bigtype)==0){
					printf("%-*s\t%-*s\t%-*s\t%-*s\t%-*d\n",10,symbolTable[i][j].id,10,symbolTable[i][j].type,10,symbolTable[i][j].bigtype,10," ",10,i);
				}
				else{
					printf("%-*s\t%-*s\t%-*s\t%-*f\t%-*d\n",10,symbolTable[i][j].id,10,symbolTable[i][j].type,10,symbolTable[i][j].bigtype,10,symbolTable[i][j].fval,10,i);
				}
			}
			else if(strcmp("string",symbolTable[i][j].type)==0){
				if(strcmp("arrays",symbolTable[i][j].bigtype)==0){
					printf("%-*s\t%-*s\t%-*s\t%-*s\t%-*d\n",10,symbolTable[i][j].id,10,symbolTable[i][j].type,10,symbolTable[i][j].bigtype,10," ",10,i);
				}
				else{
					printf("%-*s\t%-*s\t%-*s\t%-*s\t%-*d\n",10,symbolTable[i][j].id,10,symbolTable[i][j].type,10,symbolTable[i][j].bigtype,10,symbolTable[i][j].sval,10,i);
				}
			}
			else if(strcmp("bool",symbolTable[i][j].type)==0){
				if(strcmp("arrays",symbolTable[i][j].bigtype)==0){
					printf("%-*s\t%-*s\t%-*s\t%-*s\t%-*d\n",10,symbolTable[i][j].id,10,symbolTable[i][j].type,10,symbolTable[i][j].bigtype,10," ",10,i);

				}
				else{
					if(symbolTable[i][j].bval==0){
						printf("%-*s\t%-*s\t%-*s\t%-*s\t%-*d\n",10,symbolTable[i][j].id,10,symbolTable[i][j].type,10,symbolTable[i][j].bigtype,10,"False",10,i);
					}
					else if(symbolTable[i][j].bval==1){
						printf("%-*s\t%-*s\t%-*s\t%-*s\t%-*d\n",10,symbolTable[i][j].id,10,symbolTable[i][j].type,10,symbolTable[i][j].bigtype,10,"True",10,i);
					}
				}
			}
			else if(strcmp("null",symbolTable[i][j].type)==0){
				printf("%-*s\t%-*s\t%-*s\t%-*s\t%-*d\n",10,symbolTable[i][j].id,10," ",10,symbolTable[i][j].bigtype,10," ",10,i);
			}
			else{

			}
		}
	}
}
%}
/*type*/
%union{
	char m_sId[256];
  	int m_nInt;
  	real m_real;
  	char m_str[256];
  	char type[256];
  	struct s sdec;
};


/* tokens */
%start program

%token LP RP DOT COMMA COLON SEMICOLON LSB RSB LCB RCB ADDITION SUBTRACTION MULTIPLICATION DIVISION REMAINDER ASSIGNMENT LT LE GE GT EQ NOTE AND OR NOT
%token BEGIN DECREASING DEFAULT DO ELSE END EXIT FOR FUNCTION GET IF LOOP OF PUT PROCEDURE RESULT RETURN SKIP THEN WHEN FALSE TRUE

%token<type> BOOL REAL INT STRING CHAR VAR ARRAY CONST

%token<m_sId> 	IDENTIFIER
%token<m_nInt> 	INTEGERVAL
%token<m_str> 	STRINGVAL
%token<m_real>	REALVAL
%token<m_nInt>	TRUEVAL
%token<m_nInt>	FALSEVAL

%left OR
%left AND
%left NOT
%left LT LE EQ GE GT NOTE
%left ADDITION SUBTRACTION
%left MULTIPLICATION DIVISION

%nonassoc UMINUS UPLUS
/* type declare for non-terminal symbols */
%type<sdec> value_declaration
%type<type> type_specifier 
%type<m_nInt> additive_expression multiplicative_expression unary_expression primary_expression func_inv_list func_inv procedure_inv

%%
program:	external_declaration {printf("%s\n","Reducing to [program]");}
	| 	program external_declaration{printf("%s\n","Reducing to [program]");}
	;    

external_declaration:	function_definition{printf("%s\n","Reducing to [external_declaration]");}
	| 		declaration_list{printf("%s\n","Reducing to [external_declaration]");}
	| 		IDENTIFIER LP func_inv_list RP{printf("%s\n","Reducing to [external_declaration]");}
	| 		simple_statment{printf("%s\n","Reducing to [external_declaration]");}
	;
func_expression : FUNCTION{
			isShouldAdd = 0;
			scope++;
			printf("%s\n","Reducing to [func_expression]");}
		| PROCEDURE{
			isShouldAdd = 0;
			scope++;
			printf("%s\n","Reducing to [func_expression]");}
		;

function_definition: func_expression IDENTIFIER LP RP block_statement{
			struct content a;
			strcpy(a.id,$2);
			strcpy(a.bigtype,"function");
			strcpy(a.type,"null");
			strcpy(a.sval,"null");
			insert(a);
			scope++;
			printf("%s\n","Reducing to [function_definition]");}
	| 	     func_expression IDENTIFIER LP value_declaration COLON type_specifer RP COLON type_specifer block_statement{
			struct content a;
			strcpy(a.id,$2);
			strcpy(a.bigtype,"function");
			strcpy(a.type,$8);
			a.ival = 0;
			insert(a);
			scope++;
			printf("%s\n","Reducing to [function_definition]");}
	;

block_start : BEGIN{
			if (isShouldAdd == 1){		
				scope++;
			}
			else{
				isShouldAdd++;
			}
			printf("%s\n","Reducing to [block_start]");}
	    ;

block_end : END{
			scope--;
			printf("%s\n","Reducing to [block_end]");}
	  ;

block_statement: block_start statement_list block_end{printf("%s\n","Reducing to [block_statement]");}
	| 	 block_start declaration_list block_end{printf("%s\n","Reducing to [block_statement]");}
	| 	 block_start declaration_list statement_list block_end{printf("%s\n","Reducing to [block_statement]");}
	| 	 block_start block_end{printf("%s\n","Reducing to [block_statement]");}
	;

declaration_list: declaration{printf("%s\n","Reducing to [declaration_list]");}
	| 	  declaration_list declaration{printf("%s\n","Reducing to [declaration_list]");}
	;

declaration: 
	 CONST IDENTIFIER COLON type_specifier ASSIGNMENT value_declaration{
			struct content a;
			strcpy(a.id,$2);
			strcpy(a.bigtype,"conts");
			if($4.type == 0){
			strcpy(a.type,"int");
			a.ival = $4.uval.ival;
			}
			else if($4.type == 1){
			strcpy(a.type,"real");
			a.fval = $4.uval.rval;
			}
			else if($4.type == 2){
			strcpy(a.type,"string");
			strcpy(a.sval,$4.uval.sval);
			}
			else if($4.type == 3){
			strcpy(a.type,"bool");
			a.bval = $4.uval.bval;
			}
			else if($4.type == 4){
			strcpy(a.type,"bool");
			a.bval = $4.uval.bval;	
			}
			insert(a);
			printf("%s\n","Reducing to [declaration]");}
	| VAR IDENTIFIER COLON type_specifier  ASSIGNMENT value_declaration{
			struct content a;
			strcpy(a.id,$2);
			strcpy(a.bigtype,"conts");
			if($6.type == 0){
			strcpy(a.type,"int");
			a.ival = $6.uval.ival;
			}
			else if($6.type == 1){
			strcpy(a.type,"float");
			a.fval = $6.uval.fval;
			}
			else if($6.type == 2){
			strcpy(a.type,"str");
			strcpy(a.sval,$6.uval.sval);
			}
			else if($6.type == 3){
			strcpy(a.type,"bool");
			a.bval = $6.uval.bval;
			}
			else if($6.type == 4){
			strcpy(a.type,"bool");
			a.bval = $6.uval.bval;	
			}
			insert(a);
			printf("%s\n","Reducing to [declaration]");}
	| VAR IDENTIFIER COLON ARRAY INTEGERVAL DOT DOT INTEGERVAL OF type_specifier{
			struct content a;
			strcpy(a.id,$3);
			strcpy(a.bigtype,"var");
			if(strcmp("int",$5)==0){
			strcpy(a.type,"int");
			a.ival = $7.uval.ival;
			}
			else if(strcmp("float",$5)==0){
			strcpy(a.type,"float");
			a.fval = $7.uval.fval;
			}
			else if(strcmp("str",$5)==0){
			strcpy(a.type,"str");
			strcpy(a.sval,$7.uval.sval);
			}
			else if(strcmp("bool",$5)==0){
			strcpy(a.type,"bool");
			a.bval = $7.uval.bval;
			}
			else{
				printf("%s","ERROR!!!");
			}
			insert(a);
			printf("%s\n","Reducing to [declaration]");}
// when function be called
func_inv_list: func_inv {printf("%s\n","Reducing to [func_inv_list]");}
	|      LP func_inv_list COMMA func_inv RP{$2 , $4 ;
			printf("%s\n","Reducing to [func_inv_list]");}
	;

func_inv: IDENTIFIER {
			$$ = lookup($1);
			struct content a ;
			strcpy(a.id,$1);
			a.ival = $$;
			insert(a);
			printf("%s\n","Reducing to [func_inv]");}
	| value_declaration{
			$$ = $1.uval.ival;
			printf("%s\n","Reducing to [func_inv]");}
	;

value_declaration: STRINGVAL {
  			$$.type = 2;
			strcpy($$.uval.sval,$1);
			printf("%s\n","Reducing to [value_declaration]");}
	| 	   TRUEVAL{
			$$.type = 3;
			$$.uval.bval = 1;
			printf("%s\n","Reducing to [value_declaration]");}
	| 	   FALSEVAL{
			$$.type = 4;
			$$.uval.bval = 0;
			printf("%s\n","Reducing to [value_declaration]");}
	| 	   INTEGERVAL{
			$$.type = 0;
			$$.uval.ival = $1;
			printf("%s\n","Reducing to [value_declaration]");}
	| 	   REALVAL{	
			$$.type = 1;
			$$.uval.rval = $1;
			printf("%s\n","Reducing to [value_declaration]");}
	;


primary_expression: func_inv_list {printf("%s\n","Reducing to [primary_expression]");}
	| 	    primary_expression func_inv_list{printf("%s\n","Reducing to [primary_expression]");}
	;

unary_expression: primary_expression{printf("%s\n","Reducing to [unary_expression]");}
	|  	  SUBTRACTION primary_expression %prec UMINUS{
			$$ = -$2;
			printf("%s\n","Reducing to [unary_expression]");
		  }
	;

multiplicative_expression: unary_expression{printf("%s\n","Reducing to [multiplicative_expression]");}
	| 		   multiplicative_expression MULTIPLY unary_expression
		{
			$$ = $1 * $3 ;
			printf("%s\n","Reducing to [multiplicative_expression]");
		}		
	| 		   multiplicative_expression DIVIDE unary_expression
		{
			$$ = $1 / $3 ;
			printf("%s\n","Reducing to [multiplicative_expression]");

		}
	| 		  multiplicative_expression MODULUS unary_expression
		{
			$$ = $1 mod $3;
			printf("%s\n","Reducing to [multiplicative_expression]");

		}
	;

additive_expression: multiplicative_expression
		{printf("%s\n","Reducing to [additive_expression]");}
	| additive_expression  ADDITION multiplicative_expression
		{
			$$ = $1 + $3 ;
			printf("%s\n","Reducing to [additive_expression]");
		}
	| additive_expression  SUBTRACTION multiplicative_expression
		{
			$$ = $1 - $3;
			printf("%s\n","Reducing to [additive_expression]");
		}
	;


relational_expression: additive_expression{printf("%s\n","Reducing to [relational_expression]");}
	|	       relational_expression LT primary_expression{printf("%s\n","Reducing to [relational_expression]");}
	|              relational_expression GT primary_expression{printf("%s\n","Reducing to [relational_expression]");}
	|              relational_expression LE primary_expression{printf("%s\n","Reducing to [relational_expression]");}
	|              relational_expression GE primary_expression{printf("%s\n","Reducing to [relational_expression]");}
	;

equality_expression: relational_expression{printf("%s\n","Reducing to [equality_expression]");}
	|              equality_expression EQ relational_expression{printf("%s\n","Reducing to [equality_expression]");}
	|              equality_expression NOTE relational_expression{printf("%s\n","Reducing to [equality_expression]");}
	;

and_expression: equality_expression{printf("%s\n","Reducing to [and_expression]");}
	| 	and_expression AND equality_expression{printf("%s\n","Reducing to [and_expression]");}
	;

inclusive_or_expression: and_expression{printf("%s\n","Reducing to [inclusive_expression]");}
	| 		 inclusive_or_expression OR and_expression{printf("%s\n","Reducing to [inclusive_expression]");}
	;

assignment_expression: inclusive_or_expression{printf("%s\n","Reducing to [assignment_expression]");}
	| 	       inclusive_or_expression EQUALS assignment_expression{printf("%s\n","Reducing to [assignment_expression]");}
	;
	
expression: assignment_expression{printf("%s\n","Reducing to [expression]");}
	|   expression assignment_expression{printf("%s\n","Reducing to [expression]");}
	|   LP expression RP{printf("%s\n","Reducing to [expression]");}
	|   '\"' expression '\"'
		{printf("%s\n","Reducing to [expression]");}
	;


type_specifier: BOOL{
			strcpy($$,"bool");
			printf("%s\n","Reducing to [type_specifier]");
		}
	| 	STRING{
			strcpy($$,"str");
			printf("%s\n","Reducing to [type_specifier]");
		}
	| 	REAL{
			strcpy($$,"float");
			printf("%s\n","Reducing to [type_specifier]");
		}
	| 	INT{
			strcpy($$,"int");
			printf("%s\n","Reducing to [type_specifier]");
		}
	;

// when funtion be defined
parameter_list: parameter_declaration{printf("%s\n","Reducing to [parameter_list]");}
	| 	parameter_list COMMA parameter_declaration{printf("%s\n","Reducing to [parameter_list]");}
	;

parameter_declaration: IDENTIFIER COLON type_specifier{
			struct content a;	
			strcpy(a.id,$1);
			strcpy(a.type,$3);
			strcpy(a.bigtype,"func");
			a.ival = 0;
			insert(a);
			printf("%s\n","Reducing to [parameter_declaration]");
		}
	;

simple_statment: IDENTIFIER ASSIGNMENT expression{printf("%s\n","Reducing to [simple_statment]");}
	| PUT expression{printf("%s\n","Reducing to [simple_statment]");}
	| GET IDENTIFIER{printf("%s\n","Reducing to [simple_statment]");}
	| RETURN{printf("%s\n","Reducing to [simple_statment]");}
	| RESULT expression{printf("%s\n","Reducing to [simple_statment]");}
	| RESULT expression{printf("%s\n","Reducing to [simple_statment]");}
	| exit{printf("%s\n","Reducing to [simple_statment]");}
	| slip{printf("%s\n","Reducing to [simple_statment]");}
	;


expression_statement:expression{printf("%s\n","Reducing to [expression_statement]");}
	;

selection_statement: IF expression THEN statement ELSE statement END IF{printf("%s\n","Reducing to [selection_statment]");}
	| 	     IF expression THEN statement END IF{printf("%s\n","Reducing to [selection_statment]");}
	;

iteration_statement: LOOP statement END LOOP{printf("%s\n","Reducing to [iteration_statment]");}
	|	     FOR IDENTIFIER COLON expression DOT DOT expression END FOR{printf("%s\n","Reducing to [iteration_statment]");}	
	;

statement_list
	: statement
		{printf("%s\n","Reducing to [statment_list]");}
	| statement_list statement
		{printf("%s\n","Reducing to [statment_list]");}
	;

statement
	: simple_statment
		{printf("%s\n","Reducing to [statment]");}
	| block_statement
		{printf("%s\n","Reducing to [statment]");}
	| expression_statement
		{printf("%s\n","Reducing to [statment]");}
	| selection_statement 
		{printf("%s\n","Reducing to [statment]");}
	| iteration_statement
		{printf("%s\n","Reducing to [statment]");}
	;

%%
void yyerror(const char *s)
{
	printf("%s\n",s);
}

int main()
{
	isShouldAdd = 0;
	scope = 0;
	yyparse();
	printf("\n\n%s\n", "-----------------------------Symbol Table:-----------------------------");
    	printf("%-*s\t%-*s\t%-*s\t%-*s\t%-*s\n",10,"Identifier",10,"Type",10,"Belong",10,"Value",10,"Scope");
	dump();
	return 0 ;
}

