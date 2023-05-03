TARGET = scanner
LEX = flex
CC = gcc

.PHONY: all clean

all: $(TARGET)

$(TARGET): lex.yy.c
	$(CC) lex.yy.c -lfl -o $@


clean:
	$(RM) $(TARGET) lex.yy.c
