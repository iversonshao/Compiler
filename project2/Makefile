CC = gcc
LEX = flex
YACC = bison
LEX_FILENAME = lex.l
YACC_FILENAME = sT.y
OUTPUT_FILENAME = sT.out
TEST_FILENAME = example.st
OTHER_SOURCE = union.h

$(OUTPUT_FILENAME): clean lex.yy.o sT.tab.o
	$(CC) lex.yy.o sT.tab.o $(OTHER_SOURCE) -o $(OUTPUT_FILENAME)

lex.yy.o: lex.yy.c sT.tab.h
	$(CC) -c lex.yy.c

sT.tab.o: sT.tab.c
	$(CC) -c sT.tab.c

sT.tab.c sT.tab.h: $(YACC_FILENAME)
	$(YACC) -d $(YACC_FILENAME)

lex.yy.c: $(LEX_FILENAME)
	$(LEX) -o lex.yy.c $(LEX_FILENAME)

clean:
	rm -f lex.yy.c sT.tab.c sT.tab.h  *.o *.out 

run: 
	./$(OUTPUT_FILENAME) < $(TEST_FILENAME)
