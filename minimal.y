%{
#include<stdio.h>
extern int yylex();
extern int yylineno;
void yyerror(const char *s);
%}
%token BEGINNING SPECIFIER SEMICOLON IDENTIFIER INTEGER STRING BODY PRINT MOVE TO INPUT ADD END
%%
sentence: BEGINNING declaration_section body_section END {printf("VALID\n");}

declaration_section: declaration | declaration declaration_section

declaration: SPECIFIER IDENTIFIER

body_section: BODY statements

statements: statement | statement statements

statement: assignment | addition | input | output

assignment: MOVE IDENTIFIER TO IDENTIFIER | MOVE INTEGER TO IDENTIFIER

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