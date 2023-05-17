CC = g++
TARGET = p2
.PHONY: all clean

all: $(TARGET)

$(TARGET): lex.yy.c y.tab.c 
	$(CC) y.tab.c -ll -ly -std=c++11 -p $(TARGET)
	#mv a.out parser
lex.yy.c: lex.l
	flex -o lex.yy.c lex.l

y.tab.c: yacc.y
	bison -dv yacc.y -o y.tab.c

clean:
	rm -f lex.yy.c y.tab.c y.tab.h a.output $(TARGET)
