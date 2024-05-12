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
%token BEGINNING SEMICOLON BODY STRING PRINT MOVE TO INPUT ADD END
%%
sentence: BEGINNING declaration_section body_section END {printf("Parsed successfully!\n");}

declaration_section: declaration | declaration declaration_section

declaration: SPECIFIER IDENTIFIER {
	add_var_to_vars($2, $1);
}

body_section: body_keyword statements

body_keyword: BODY

statements: statement | statement statements

statement: assignment_id_to_id | assignment_int_to_int | addition | input | output

assignment_id_to_id: MOVE IDENTIFIER TO IDENTIFIER {
	Variable* var1 = lookup_var($2);
	Variable* var2 = lookup_var($4);
	if (var1 == NULL) {
		printf("Error | Use of undeclared variable on line %d: %s\n", yylineno, $2);
	}
	if (var2 == NULL) {
		printf("Error | Use of undeclared variable on line %d: %s\n", yylineno, $4);
	}
	if (var1 != NULL && var2 != NULL && var1->numOfDigits != var2->numOfDigits) {
		printf("Warning on line %d\n", yylineno);
		printf("Invalid value being assigned to variable %s!\n", $4);
		printf("You are trying to assign the value stored in variable %s to the variable %s, even though they were declared as different sizes (%d and %d).\n\n", $4, $2, var2->numOfDigits, var1->numOfDigits);
	}
}

assignment_int_to_int: MOVE INTEGER TO IDENTIFIER {
	Variable* var = lookup_var($4);
	if (var == NULL) {
		char error_string[256]; 
		int len = snprintf(error_string, sizeof(error_string), "Error | Use of undeclared variable on line %d: %s\n", yylineno, $4);
		if (len >= 0 && len < sizeof(error_string)) {
			yyerror(error_string);
		} else {
			printf("Error formatting string\n");
		}
	}
	if (var != NULL && var->numOfDigits != $2) {
		printf("Warning on line %d\n", yylineno);
		printf("Invalid value being assigned to variable %s!\n", $4);
		printf("You are trying to assign an integer of size %d to the variable %s, even though they were declared as a different size (%d).\n\n", $2, $4, var->numOfDigits);
	}
}

addition: addition_int_to_id | addition_id_to_id

addition_int_to_id: ADD INTEGER TO IDENTIFIER {
	Variable* var = lookup_var($4);
	if (var == NULL) {
		printf("Error | Use of undeclared variable on line %d: %s\n", yylineno, $4);
	}
}

addition_id_to_id: ADD IDENTIFIER TO IDENTIFIER {
	Variable* var1 = lookup_var($2);
	Variable* var2 = lookup_var($4);
	if (var1 == NULL) {
		printf("Error | Use of undeclared variable on line %d: %s\n", yylineno, $2);
	}
	if (var2 == NULL) {
		printf("Error | Use of undeclared variable on line %d: %s\n", yylineno, $4);
	}
}

input: INPUT identifiers 

identifiers: IDENTIFIER | IDENTIFIER SEMICOLON identifiers {
	Variable* var = lookup_var($1);
	if (var == NULL) {
		printf("Error | Use of undeclared variable on line %d: %s\n", yylineno, $1);
	}
}

output: PRINT prinputs

prinputs: STRING | IDENTIFIER | IDENTIFIER SEMICOLON prinputs | STRING SEMICOLON prinputs

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
	if (strcmp(s, "syntax error") == 0) {
		printf("A syntax error has been discovered on line %d\n", yylineno);
	} else {
    	printf("%s\n", s);
	}
	exit(1);
}