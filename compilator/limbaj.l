%{
#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h"
%}
%option noyywrap
%%
"int"|"float"|"bool"|"char"|"string" {yylval.strval=strdup(yytext);return TYPE;}   //predefined types
"const" {yylval.strval=strdup(yytext);return CONST;}
"array" {yylval.strval=strdup(yytext);return ARRAY;}
"struct" {yylval.strval=strdup(yytext);return STRUCTURE;}
"function" {yylval.strval=strdup(yytext);return FUNCTION;}
"begin_program" {return BGIN;}
"end_program" {return END;}
"Eval" {yylval.strval=strdup(yytext);return EVAL;}
"TypeOf" {yylval.strval=strdup(yytext);return TYPEOF;}
"if" {return IF;}//control statements
"else" {return ELSE;}
"for" {return FOR;}
"while" {return WHILE;}
"do" {return DO;}
":=" {yylval.strval=strdup(yytext);return ASSIGN;}//assignment statement
"==" {return EQ;}//boolean expressions 
">=" {return GRE;}
"<=" {return LWE;}
">" {return GR;}
"<" {return LW;}
"!" {return DIF;}
"&" {return AND;}
"||" {return OR;}
"+" {return PLUS;}//arithmetic expressions
"-" {return MINUS;}
"" {return MULTIPLY;}
"/" {return DIVIDE;}
"+1" {return INCR;} //++
"-1" {return DECR;} //--
_[A-Z][a-zA-Z0-9]+ {yylval.strval=strdup(yytext);return ID;} // id incepe cu _litera-mare urmata de macar inca o litera/un numar
0|[-]?[1-9]+[0-9]* {yylval.intval=atoi(yytext);return INTV;} //sa pot avea numere negative
(0|[-]?[1-9]+[0-9]*),[0-9]+ { yylval.floatval=atof(yytext);return FLOATV;} //o sa am obligatoriu macar 1 cifra dupa virgula/
[a-zA-Z] {yylval.intval=atoi(yytext);return CHARV;} // char = o singura litera
[a-zA-Z0-9]* {yylval.intval=atoi(yytext);return STRV;} 
[ \t] ;
\n {yylineno ++;}
. {return yytext[0];}


