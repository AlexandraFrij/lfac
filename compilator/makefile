all:
	rm -f lex.yy.c
	rm -f y.tab.c
	rm -f exec
	yacc -d compilator.y
	lex limbaj.l
	gcc lex.yy.c y.tab.c -o exec
	./exec input2.txt
rm:
	rm -f lex.yy.c
	rm -f y.tab.c
	rm -f exec
	rm y.tab.h