CC = g++
TARGET = compiler
.PHONY: all clean

all: $(TARGET)

$(TARGET): lex.yy.c y.tab.c 
	$(CC) y.tab.c symbolTable.hpp -o parser -ll  -std=c++11
	
lex.yy.c: lex.l
	flex -o lex.yy.c lex.l

y.tab.c: yacc.y
	bison -dv yacc.y -o y.tab.c

clean:
	rm -f *.c parser *.h *.output *.jasm *.class
