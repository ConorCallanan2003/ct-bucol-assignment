%{
#include "minimal.tab.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

extern YYSTYPE yylval;

// Structure to represent a symbol
typedef struct {
    char name[256];
} Variable;

// Symbol table
Variable* variables[100];
int var_index = 0;

int beginning = 1;

void add_var_to_vars(char* name) {
    Variable* new_var = (Variable *)malloc(sizeof(Variable));
    strcpy(new_var->name, name);
    variables[var_index] = new_var;
    var_index++;
}

// Function to lookup a symbol in the symbol table
Variable *lookup_var(char *name) {
    for (int i = 0; i < var_index; i++) {
        if (strcmp(variables[i]->name, name) == 0) {
            return variables[i];
        }
    }
    return NULL;
}
%}
%%
[\t ]+	;
[\n ]   {yylineno++;};
"."     ;
"beginning" {return BEGINNING;}
"body"  {beginning = 0; return BODY;};
"print" {return PRINT;};
"move"  {return MOVE;};
"add"  {return ADD;};
"to"    {return TO;};
"input" {return INPUT;}
"end"   return END;
";"     return SEMICOLON;
"x"+" "  {return SPECIFIER;}
\"[^"]*\"   {return STRING;};
[a-z]+[a-z0-9\-]*   {
    if (beginning) {
        add_var_to_vars(yytext);
        return IDENTIFIER;
    } else {
        if (lookup_var(yytext) != NULL) {
            return IDENTIFIER;
        } else {
            printf("\nUndeclared identifier on line %d\n", yylineno);
        }
    }
}
[0-9]+  return INTEGER;
.	return(0);
%%

int yywrap() {
    return 1;
}
