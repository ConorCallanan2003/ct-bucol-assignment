# Parser/Lexical Analyser for BUCOL (a non-existant syntactically limited language)
ISE 2nd Year Compiler Theory - Conor Callanan

#### Features:
1. Reports that it has been presented with a well formed/not well formed program.
2. Returns an error if the program attempts to assign a value to a variable that is not declared.
3. Flags a warning if the program attempts to assign a value to a variable which is bigger than its declared capacity.
4. Flags a warning if the program attempts to move a value from an identifier 1 to an identifier 2 when identifier 1 is declared to be larger than identifier 2.
5. Reports an accurate line number and helpful description for common errors.

## Compile & Run How-To  (non-unix-based systems may differ)

### Compile

`flex -i bucol.l && bison -d bucol.y && cc -c lex.yy.c bucol.tab.c && cc -o example lex.yy.o bucol.tab.o -ll`

> ensure to include `-i` in compilation step or the resulting executable will be case sensitive


### Run

`./example < <input file>`