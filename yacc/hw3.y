%{
#include <stdio.h>
#include <string.h>
int yylex();
int yydebug=1;

int funcnt=0;
int opcnt=0;
int intcnt=0;
int charcnt=0;
int pocnt=0;
int arrcnt=0;
int selcnt=0;
int loopcnt=0;
int retcnt=0;

int inttmp=0;
int chartmp=0;
int potmp=0;
int arrtmp=0;

extern char*name;
char*typedef_li[100];
int typedef_cnt=0;

int is_typedef(char*s){
	for(int i=0;i<typedef_cnt;i++){
		if(strcmp(s,typedef_li[i])==0)return 1;
	}
	return 0;
}

char*define_li[100];
int define_cnt=0;
int is_define(char*s){
	for(int i=0;i<define_cnt;i++){
		if(strcmp(s,define_li[i])==0)return 1;
	}
	return 0;
}

%}

%token IDENTIFIER CONSTANT STRING_LITERAL SIZEOF
%token PTR_OP INC_OP DEC_OP LEFT_OP RIGHT_OP LE_OP GE_OP EQ_OP NE_OP
%token AND_OP OR_OP MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN ADD_ASSIGN
%token SUB_ASSIGN LEFT_ASSIGN RIGHT_ASSIGN AND_ASSIGN
%token XOR_ASSIGN OR_ASSIGN TYPE_NAME

%token TYPEDEF EXTERN STATIC AUTO REGISTER
%token CHAR SHORT INT LONG SIGNED UNSIGNED FLOAT DOUBLE CONST VOLATILE VOID
%token STRUCT UNION ENUM ELLIPSIS

%token CASE DEFAULT IF ELSE SWITCH WHILE DO FOR GOTO CONTINUE BREAK RETURN
%token DEFINE INCLUDE

%start translation_unit

%right "then" ELSE

%%

define_constant
	: '#' DEFINE IDENTIFIER CONSTANT {define_li[define_cnt++]=name;}
	;

preprocessor
	: define_constant
	| '#' INCLUDE 
	;

primary_expression
	: IDENTIFIER
	| CONSTANT
	| STRING_LITERAL
	| '(' expression ')'
	;

postfix_expression
	: primary_expression
	| postfix_expression '[' expression ']'
	| postfix_expression '(' ')' {funcnt++;}
	| postfix_expression '(' argument_expression_list ')' {funcnt++;}
	| postfix_expression '.' IDENTIFIER {opcnt++;}
	| postfix_expression PTR_OP IDENTIFIER {opcnt++;}
	| postfix_expression INC_OP {opcnt++;}
	| postfix_expression DEC_OP {opcnt++;}
	;

argument_expression_list
	: assignment_expression
	| argument_expression_list ',' assignment_expression
	;

unary_expression
	: postfix_expression
	| INC_OP unary_expression {opcnt++;}
	| DEC_OP unary_expression {opcnt++;}
	| unary_operator cast_expression
	| SIZEOF unary_expression
	| SIZEOF '(' type_name ')'
	;

unary_operator
	: '&'
	| '*'
	| '+'
	| '-'
	| '~'
	| '!'
	;

cast_expression
	: unary_expression
	| '(' type_name ')' cast_expression {opcnt++;}
	;

multiplicative_expression
	: cast_expression
	| multiplicative_expression '*' cast_expression {opcnt++;}
	| multiplicative_expression '/' cast_expression {opcnt++;}
	| multiplicative_expression '%' cast_expression {opcnt++;}
	;

additive_expression
	: multiplicative_expression
	| additive_expression '+' multiplicative_expression {opcnt++;}
	| additive_expression '-' multiplicative_expression {opcnt++;}
	;

shift_expression
	: additive_expression
	| shift_expression LEFT_OP additive_expression {opcnt++;}
	| shift_expression RIGHT_OP additive_expression {opcnt++;}
	;

relational_expression
	: shift_expression
	| relational_expression '<' shift_expression {opcnt++;}
	| relational_expression '>' shift_expression {opcnt++;}
	| relational_expression LE_OP shift_expression {opcnt++;}
	| relational_expression GE_OP shift_expression {opcnt++;}
	;

equality_expression
	: relational_expression
	| equality_expression EQ_OP relational_expression {opcnt++;}
	| equality_expression NE_OP relational_expression {opcnt++;}
	;

and_expression
	: equality_expression
	| and_expression '&' equality_expression {opcnt++;}
	;

exclusive_or_expression
	: and_expression
	| exclusive_or_expression '^' and_expression {opcnt++;}
	;

inclusive_or_expression
	: exclusive_or_expression
	| inclusive_or_expression '|' exclusive_or_expression {opcnt++;}
	;

logical_and_expression
	: inclusive_or_expression
	| logical_and_expression AND_OP inclusive_or_expression {opcnt++;}
	;

logical_or_expression
	: logical_and_expression
	| logical_or_expression OR_OP logical_and_expression {opcnt++;}
	;

conditional_expression
	: logical_or_expression
	| logical_or_expression '?' expression ':' conditional_expression
	;

assignment_expression
	: conditional_expression
	| unary_expression assignment_operator assignment_expression {opcnt++;}
	;

assignment_operator
	: '='
	| MUL_ASSIGN
	| DIV_ASSIGN
	| MOD_ASSIGN
	| ADD_ASSIGN
	| SUB_ASSIGN
	| LEFT_ASSIGN
	| RIGHT_ASSIGN
	| AND_ASSIGN
	| XOR_ASSIGN
	| OR_ASSIGN
	;

expression
	: assignment_expression
	| expression ',' assignment_expression
	;

constant_expression
	: conditional_expression
	;

declaration
	: declaration_specifiers ';'
	| declaration_specifiers init_declarator_list ';' {if($1==4)intcnt+=$2; if($1==2)charcnt+=$2;}
	| TYPEDEF declaration_specifiers init_declarator_list ';' 
		{
		if($2==4)intcnt+=$3; if($2==2)charcnt+=$3;
		typedef_li[typedef_cnt++]=name;
		}
	;

declaration_specifiers
	: storage_class_specifier				{$$=0;}
	| storage_class_specifier declaration_specifiers	{$$=$2;}
	| type_specifier					{$$=$1;}
	| type_specifier declaration_specifiers			{$$=$1;}
	| type_qualifier					{$$=0;}
	| type_qualifier declaration_specifiers			{$$=$2;}
	;

init_declarator_list
	: init_declarator				{$$=$1;}	
	| init_declarator_list ',' init_declarator	{$$=$1+$3;} 
	;

init_declarator
	: declarator 			
	{
	chartmp=0; inttmp=0; arrtmp=0; potmp=0;
	$$=0;
	if($1%5==4) funcnt++; 
	if($1!=0&&$1!=2&&$1%5!=3) pocnt++;
	if($1==0||$1==1||$1==2||$1==5||$1==7) $$=1;
	if($1%5==2) arrcnt++;
	}
	| declarator '=' initializer	
	{opcnt++; 
	chartmp=0; inttmp=0; arrtmp=0; potmp=0;
	$$=0;
	if($1%5==4) funcnt++;
	if($1!=0&&$1!=2&&$1%5!=3) pocnt++;
	if($1==0||$1==1||$1==2||$1==5||$1==7) $$=1;
	if($1%5==2) arrcnt++;
	} 
	;

storage_class_specifier
	: EXTERN
	| STATIC
	| AUTO
	| REGISTER
	;

type_specifier
	: VOID		{$$=1;}
	| CHAR		{$$=2;}
	| SHORT		{$$=3;}
	| INT		{$$=4;}
	| LONG		{$$=5;}
	| FLOAT		{$$=6;}
	| DOUBLE	{$$=7;}
	| SIGNED	{$$=8;}
	| UNSIGNED	{$$=9;}
	| struct_or_union_specifier	{$$=10;}
	| enum_specifier	{$$=11;}
	| TYPE_NAME	{$$=12;}
	;

struct_or_union_specifier
	: struct_or_union IDENTIFIER '{' struct_declaration_list '}'
	| struct_or_union '{' struct_declaration_list '}'
	| struct_or_union IDENTIFIER
	;

struct_or_union
	: STRUCT
	| UNION
	;

struct_declaration_list
	: struct_declaration
	| struct_declaration_list struct_declaration
	;

struct_declaration
	: specifier_qualifier_list struct_declarator_list ';' {if($1==4)intcnt+=$2; if($1==2)charcnt+=$2;}
	;

specifier_qualifier_list
	: type_specifier specifier_qualifier_list	{$$=$1;}
	| type_specifier				{$$=$1;}
	| type_qualifier specifier_qualifier_list	{$$=$2;}
	| type_qualifier				{$$=0;}
	;

struct_declarator_list
	: struct_declarator				{$$=$1;}
	| struct_declarator_list ',' struct_declarator	{$$=$1+$3;}
	;

struct_declarator
	: declarator
        	{
        	chartmp=0; inttmp=0; arrtmp=0; potmp=0;
        	$$=0;
        	if($1%5==4) funcnt++;
        	if($1!=0&&$1!=2&&$1%5!=3) pocnt++;
        	if($1==0||$1==1||$1==2||$1==5||$1==7) $$=1;
        	if($1%5==2) arrcnt++;
        	}
	| ':' constant_expression		{$$=-1;}
	| declarator ':' constant_expression
       	        {
        	chartmp=0; inttmp=0; arrtmp=0; potmp=0;
        	$$=0;
        	if($1%5==4) funcnt++;
        	if($1!=0&&$1!=2&&$1%5!=3) pocnt++;
        	if($1==0||$1==1||$1==2||$1==5||$1==7) $$=1;
        	if($1%5==2) arrcnt++;
        	}		
	;

enum_specifier
	: ENUM '{' enumerator_list '}'
	| ENUM IDENTIFIER '{' enumerator_list '}'
	| ENUM IDENTIFIER
	;

enumerator_list
	: enumerator
	| enumerator_list ',' enumerator
	;

enumerator
	: IDENTIFIER
	| IDENTIFIER '=' constant_expression
	;

type_qualifier
	: CONST
	| VOLATILE
	;

declarator
	: pointer direct_declarator 	{if($1==1)$$=$2+5;else $$=$2+10;}
	| direct_declarator		{$$=$1;}
	;

direct_declarator
	: IDENTIFIER					{$$=0;}
	| '(' declarator ')'				{if($2>=5)$$=1;else $$=$2;}
	| direct_declarator '[' constant_expression ']'	{$$=2;}
	| direct_declarator '[' ']'			{$$=2;}
	| direct_declarator '(' parameter_type_list ')' {if($1==1)$$=4;else $$=3;}
	| direct_declarator '(' identifier_list ')'	{$$=0;}
	| direct_declarator '(' ')'			{if($1==1)$$=4;else $$=3;}
	;

pointer
	: '*'					{$$=1;}
	| '*' type_qualifier_list		{$$=1;}
	| '*' pointer				{$$=$2+1;}
	| '*' type_qualifier_list pointer	{$$=$3+1;}
	;

type_qualifier_list
	: type_qualifier
	| type_qualifier_list type_qualifier
	;


parameter_type_list
	: parameter_list
	| parameter_list ',' ELLIPSIS
	;

parameter_list
	: parameter_declaration
	| parameter_list ',' parameter_declaration
	;

parameter_declaration
	: declaration_specifiers declarator 	
	{
	if($2==0||$2==1||$2==2||$2==5||$2==7)
		{
		if($1==2)chartmp++;if($1==4)inttmp++;
		}
	if($2==1||$2==5||$2==6||$2==7||$2==10||$2==11||$2==12) potmp++;
	if($2==2||$2==7||$2==12) arrtmp++;
	}
	| declaration_specifiers abstract_declarator
	| declaration_specifiers
	;

identifier_list
	: IDENTIFIER
	| identifier_list ',' IDENTIFIER
	;

type_name
	: specifier_qualifier_list
	| specifier_qualifier_list abstract_declarator
	;

abstract_declarator
	: pointer
	| direct_abstract_declarator
	| pointer direct_abstract_declarator
	;

direct_abstract_declarator
	: '(' abstract_declarator ')'
	| '[' ']'
	| '[' constant_expression ']'
	| direct_abstract_declarator '[' ']'
	| direct_abstract_declarator '[' constant_expression ']'
	| '(' ')'
	| '(' parameter_type_list ')'	{chartmp=inttmp=potmp=arrtmp=0;}
	| direct_abstract_declarator '(' ')'
	| direct_abstract_declarator '(' parameter_type_list ')' {chartmp=inttmp=potmp=arrtmp=0;}
	;

initializer
	: assignment_expression
	| '{' initializer_list '}'
	| '{' initializer_list ',' '}'
	;

initializer_list
	: initializer
	| initializer_list ',' initializer
	;

statement
	: labeled_statement
	| compound_statement
	| expression_statement
	| selection_statement	{selcnt++;}
	| iteration_statement	{loopcnt++;}
	| jump_statement
	;

labeled_statement
	: IDENTIFIER ':' statement
	| CASE constant_expression ':' statement
	| DEFAULT ':' statement
	;

compound_statement
	: '{' '}'
	| '{' declaration_statement_list '}'
	;

declaration_statement_list
	: declaration
	| declaration declaration_statement_list
	| statement
	| statement declaration_statement_list
	;

expression_statement
	: ';'
	| expression ';'
	;

selection_statement
	: IF '(' expression ')' statement	%prec "then"
	| IF '(' expression ')' statement ELSE statement
	| SWITCH '(' expression ')' statement
	;

iteration_statement
	: WHILE '(' expression ')' statement
	| DO statement WHILE '(' expression ')' ';'
	| FOR '(' expression_statement expression_statement ')' statement
	| FOR '(' expression_statement expression_statement expression ')' statement
	| FOR '(' declaration expression_statement ')' statement
	| FOR '(' declaration expression_statement expression ')' statement
	;

jump_statement
	: GOTO IDENTIFIER ';'
	| CONTINUE ';'
	| BREAK ';'
	| RETURN ';'		{retcnt++;}
	| RETURN expression ';'	{retcnt++;}
	;

translation_unit
	: external_declaration
	| translation_unit external_declaration
	;

external_declaration
	: function_definition {funcnt++; intcnt+=inttmp; charcnt+=chartmp; pocnt+=potmp; arrcnt+=arrtmp; inttmp=chartmp=potmp=arrtmp=0;}
	| declaration
	| preprocessor
	;

function_definition
	: declaration_specifiers declarator compound_statement 
	| declarator compound_statement 
	;

%%

int main(void){
	yyparse();
	printf("fuction = %d\n", funcnt);	
	printf("operator = %d\n", opcnt);
	printf("int = %d\n", intcnt);
	printf("char = %d\n", charcnt);
	printf("pointer = %d\n", pocnt);
	printf("array = %d\n", arrcnt);
	printf("selection = %d\n", selcnt);
	printf("loop = %d\n", loopcnt);
	printf("return = %d\n", retcnt);

	return 0;
}
void yyerror(const char *str)
{
	fprintf(stderr,"error : %s\n",str);
}
