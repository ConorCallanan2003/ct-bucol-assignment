%{
#include<stdio.h>
#include <string.h>
#include <stdlib.h>

extern int yylex();
extern int yylineno;
void yyerror(const char *s);

typedef struct {
    char* name;
	int numOfDigits;
} Variable;

Variable* variables[100];
int var_index = 0;

int beginning = 1;

void add_var_to_vars(char* name, int numOfDigits) {
    // Variable* new_var;
	Variable* new_var = malloc(sizeof(Variable));
	new_var->name = strdup(name);
    new_var->numOfDigits = numOfDigits;
    variables[var_index] = new_var;
    var_index++;
}

// // Function to lookup a symbol in the symbol table
Variable *lookup_var(char *name) {
    for (int i = 0; i < var_index; i++) {
        if (strcmp(variables[i]->name, name) == 0) {
            return variables[i];
        }
    }
    return NULL;
}
%}
%union {
    int ival;
    char *str;
}
%token <ival> SPECIFIER
%token <ival> INTEGER
%token <str> IDENTIFIER
%token BEGINNING SEMICOLON STRING BODY PRINT MOVE TO INPUT ADD END
%%
sentence: BEGINNING declaration_section body_section END {printf("VALID\n");}

declaration_section: declaration | declaration declaration_section

declaration: SPECIFIER IDENTIFIER {
	add_var_to_vars($2, $1);
}

body_section: BODY statements

statements: statement | statement statements

statement: assignment_id_to_id | assignment_int_to_int | addition | input | output

assignment_id_to_id: MOVE IDENTIFIER TO IDENTIFIER {
	Variable* var1 = lookup_var($2);
	Variable* var2 = lookup_var($4);
	if (var1 != NULL && var2 != NULL && var1->numOfDigits != var2->numOfDigits) {
		printf("Warning - bad programmer at work");
	}
}

assignment_int_to_int: MOVE INTEGER TO IDENTIFIER {
	Variable* var = lookup_var($4);
	if (var != NULL && var->numOfDigits != $2) {
		printf("Warning - bad programmer at work");
	}
}

addition: ADD INTEGER TO IDENTIFIER | ADD IDENTIFIER TO IDENTIFIER

input: INPUT identifiers

identifiers: IDENTIFIER | IDENTIFIER SEMICOLON identifiers

output: PRINT prinputs

prinputs: IDENTIFIER | STRING | IDENTIFIER SEMICOLON prinputs | STRING SEMICOLON prinputs


%%
extern FILE *yyin;
int main()
{
	do	{
		yyparse();
	}
	while(!feof(yyin));	
	return 0;
}

void yyerror(const char *s)
{
    fprintf(stderr, "%s\n", s);
}