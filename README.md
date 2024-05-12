# Parser/Lexical Analyser for BUCOL (a non-existant syntactically limited language)
ISE 2nd Year Compiler Theory module

### How to compile & run

**Compile:**

`flex -i bucol.l && bison -d bucol.y && cc -c lex.yy.c bucol.tab.c && cc -o example lex.yy.o bucol.tab.o -ll`



**Run:**

`./example < <input file>`
