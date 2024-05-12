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

void undeclared_id(char* id, int lineno) {
	char error_string[256]; 
	int len = snprintf(error_string, sizeof(error_string), "Error | Use of undeclared variable on line %d: %s\n", lineno, id);
	if (len >= 0 && len < sizeof(error_string)) {
		yyerror(error_string);
	} else {
		yyerror("syntax error");
	}
}

void missing_dot(int lineno) {
	char error_string[256]; 
	int len = snprintf(error_string, sizeof(error_string), "Error | Period missing on line %d", lineno-1);
	if (len >= 0 && len < sizeof(error_string)) {
		yyerror(error_string);
	} else {
		yyerror("syntax error");
	}
}


%}
%union {
    int ival;
    char *str;
}
%token <ival> SPECIFIER
%token <ival> INTEGER
%token <str> IDENTIFIER
%token BEGINNING SEMICOLON BODY STRING DOT PRINT MOVE TO INPUT ADD END
%%

program: beginning_section body_section END DOT {printf("Parsed successfully!\n");} | beginning_section body_section END {missing_dot(yylineno);}

beginning_section: BEGINNING DOT | BEGINNING DOT declaration_section | BEGINNING {missing_dot(yylineno);} | BEGINNING declaration_section {missing_dot(yylineno);}

declaration_section: declaration| declaration declaration_section

declaration: SPECIFIER IDENTIFIER {missing_dot(yylineno);} | SPECIFIER IDENTIFIER DOT {
	add_var_to_vars($2, $1);
}

body_section: BODY DOT | BODY DOT statements | BODY {missing_dot(yylineno);} | BODY statements {missing_dot(yylineno);}

statements: statement | statement statements

statement: assignment_id_to_id | assignment_int_to_int | addition | input | output

assignment_id_to_id: MOVE IDENTIFIER TO IDENTIFIER {missing_dot(yylineno);} | MOVE IDENTIFIER TO IDENTIFIER DOT {
	Variable* var1 = lookup_var($2);
	Variable* var2 = lookup_var($4);
	if (var1 == NULL) {
		undeclared_id($2, yylineno);
	}
	if (var2 == NULL) {
		undeclared_id($4, yylineno);
	}
	if (var1 != NULL && var2 != NULL && var1->numOfDigits > var2->numOfDigits) {
		printf("Warning on line %d\n", yylineno);
		printf("Potentially invalid value being assigned to variable %s!\n", $4);
		printf("You are trying to assign the value stored in variable %s to the variable %s, even though the first operand has been declared with a larger capacity than the second. (%d and %d).\n\n", $4, $2, var2->numOfDigits, var1->numOfDigits);
	}
}

assignment_int_to_int: MOVE INTEGER TO IDENTIFIER {missing_dot(yylineno);} | MOVE INTEGER TO IDENTIFIER DOT {
	Variable* var = lookup_var($4);
	if (var == NULL) {
		undeclared_id($4, yylineno);
	}
	if (var != NULL && var->numOfDigits < $2) {
		printf("Warning on line %d\n", yylineno);
		printf("Invalid value being assigned to variable %s!\n", $4);
		printf("You are trying to assign an integer of size %d to the variable %s, even though the number specified is too large for the variable's capacity (%d).\n\n", $2, $4, var->numOfDigits);
	}
}

addition: addition_int_to_id DOT | addition_id_to_id DOT | addition_int_to_id {missing_dot(yylineno);} | addition_id_to_id {missing_dot(yylineno);}

addition_int_to_id: ADD INTEGER TO IDENTIFIER {
	Variable* var = lookup_var($4);
	if (var == NULL) {
		undeclared_id($4, yylineno);
	}
	if (var != NULL && var->numOfDigits < $2) {
		printf("Warning on line %d\n", yylineno);
		printf("Invalid value being assigned to variable %s!\n", $4);
		printf("You are trying to add an integer of size %d to the variable %s, even though the number specified is too large for the variable's capacity (%d).\n\n", $2, $4, var->numOfDigits);
	}
}

addition_id_to_id: ADD IDENTIFIER TO IDENTIFIER {
	Variable* var1 = lookup_var($2);
	Variable* var2 = lookup_var($4);
	if (var1 == NULL) {
		undeclared_id($2, yylineno);
	}
	if (var2 == NULL) {
		undeclared_id($4, yylineno);
	}
	if (var1 != NULL && var2 != NULL && var2->numOfDigits < var1->numOfDigits) {
		printf("Warning on line %d\n", yylineno);
		printf("Invalid value potentially being assigned to variable %s!\n", $4);
		printf("You are trying to add the value stored in the variable %s to the variable %s, even though the first operand has a larger capacity than the second (%d vs %d).\n\n", $2, $4, var1->numOfDigits, var2->numOfDigits);
	}
}

input: INPUT identifiers DOT | INPUT identifiers {missing_dot(yylineno);} 

identifiers: IDENTIFIER | IDENTIFIER SEMICOLON identifiers {
	Variable* var = lookup_var($1);
	if (var == NULL) {
		undeclared_id($1, yylineno);
	}
}

output: PRINT prinputs DOT | PRINT prinputs {missing_dot(yylineno);} 

prinputs: STRING | IDENTIFIER {
	Variable* var = lookup_var($1);
	if (var == NULL) {
		undeclared_id($1, yylineno);
	}
} | IDENTIFIER SEMICOLON prinputs {
	Variable* var = lookup_var($1);
	if (var == NULL) {
		undeclared_id($1, yylineno);
	}
} | STRING SEMICOLON prinputs

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
		printf("A syntax error has been identified on line %d\n", yylineno);
	} else {
    	printf("%s\n", s);
	}
	exit(1);
}