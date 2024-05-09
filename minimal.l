%{
#include "minimal.tab.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
%}
%%
[\t ]+	;
[\n ]   {yylineno++;};
"."     ;
"beginning" {return BEGINNING;}
"body"  {return BODY;};
"print" {return PRINT;};
"move"  {return MOVE;};
"add"  {return ADD;};
"to"    {return TO;};
"input" {return INPUT;}
"end"   return END;
";"     return SEMICOLON;
"x"+" "  {
    yylval.ival = strlen(yytext) - 1; 
    return SPECIFIER;
}

\"[^"]*\"   {return STRING;};
[a-z]+[a-z0-9\-]*   {
    yylval.str = strdup(yytext);
    return IDENTIFIER;
}

[0-9]+  {
    yylval.ival = strlen(yytext); 
    return INTEGER;
} 
.	return(0);
%%

int yywrap() {
    return 1;
}
