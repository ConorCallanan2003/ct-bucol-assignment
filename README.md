# Parser/Lexical Analyser for BUCOL (a non-existant syntactically limited language)
ISE 2nd Year Compiler Theory module

### How to compile & run

**Compile:**

`flex -i minimal.l && bison -d minimal.y && cc -c lex.yy.c minimal.tab.c && cc -o example lex.yy.o minimal.tab.o -ll`



**Run:**

`./example < <input file>`
