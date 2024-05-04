%{
#include "minimal.tab.h"
%}
%%
[\t ]+	;
[\n ]   {printf("\nNEWLINE\n");return NEWLINE;}
"."     printf("\nDOT\n");
"BEGINNING" {printf("\nBEGINNING\n");return BEGINNING;}
"body"  return BODY;
"print" return PRINT;
"move"  return MOVE;
"to"    return TO;
"input" return INPUT;
"end"   return END;
";"     return SEMICOLON;
"x"+" "  {printf("\nSPECIFIER\n");return SPECIFIER;}
[a-z]+[a-z0-9\-]*   {printf("\nIDENTIFIER\n");return IDENTIFIER;}
[0-9]+  return INTEGER;
\"[a-z0-9]*\"   return STRING;
.	return(0);
%%

int yywrap() {
    return 1;
}
