%{
#include<stdio.h>
extern int yylex();
extern int yylineno;
void yyerror(const char *s);
%}
%token BEGINNING SPECIFIER NEWLINE SEMICOLON IDENTIFIER INTEGER STRING BODY PRINT MOVE TO INPUT END
%%
sentence: BEGINNING newlines declaration_section newlines body_section newlines END {printf("VALID\n");}

declaration_section: declaration newlines | declaration newlines declaration_section

declaration: SPECIFIER IDENTIFIER

body_section: BODY newlines statements

statements: statement newlines | statement newlines statements

statement: assignment | addition | input | output

assignment: MOVE IDENTIFIER TO IDENTIFIER

addition: MOVE INTEGER TO IDENTIFIER

input: INPUT identifiers

identifiers: IDENTIFIER | IDENTIFIER SEMICOLON identifiers

output: PRINT prinputs

prinputs: IDENTIFIER | STRING | IDENTIFIER SEMICOLON prinputs | STRING SEMICOLON prinputs

newlines: NEWLINE | NEWLINE newlines

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
    fprintf(stderr, "%s\n%d", s, yylineno);
}