%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>

int yylex(void);
int yyerror(char *s);
extern FILE* yyin;
extern char* yytext;
extern int yylineno;
char buff[150];
char type[100] ;
int fd, fd1;
int nr_el; int nr_permis;

struct symbol 
{
        char tip[100];
        char name[100];
        int dim;
        int intv;
        char strv[100];
        float floatv;
        struct symbol *next;        
};

struct symbol *first_sym= NULL; //prima variabila
struct symbol *last_sym = NULL; //ultima variabila
struct symbol *first_fun = NULL; //prima functie
struct symbol *last_fun = NULL; //ultima functie

int find_var( char nume[])
{
        if(first_sym == NULL) return 0;
        else
        {
                struct symbol *current = first_sym;
                while(current != NULL)
                {
                        if(strcmp(current->name, nume)== 0) return 1;
                        else current = current->next;
                }
        }
        return 0;
}
void insert_var(char tip[], char nume[], int dim, int valoare, char strg[], float fval)
{
        if(find_var(nume)==1) {printf("Variabila deja existenta la linia %d\n", yylineno); exit(0);}
        else if(first_sym == NULL)
        {
                first_sym = (struct symbol*) malloc(sizeof(struct symbol));
                strcpy(first_sym->tip, tip);
                strcpy(first_sym->name, nume);
                first_sym->dim=dim;
                first_sym->intv = valoare;
                strcpy(first_sym->strv, strg);
                first_sym->floatv = fval;
                last_sym = first_sym;
                first_sym->next = last_sym;
                last_sym->next = NULL;
        }
        else
        {
                struct symbol* current = (struct symbol*) malloc(sizeof(struct symbol));
                strcpy(current->tip, tip);
                strcpy(current->name, nume);
                current->intv = valoare;
                current->dim=dim;
                strcpy(current->strv, strg);
                current->floatv = fval;
                last_sym->next = current;
                last_sym = current;
                current->next = NULL;
        }             
}
void printList() {
        struct symbol *ptr = first_sym;
        printf("\n[ ");

        //start from the beginning
        while(ptr != NULL) {
                printf("(%s) %s %d\n ",ptr->name, ptr->tip, ptr->dim);
                ptr = ptr->next;
        }

        printf(" ]\n");
}
int find_fun( char nume[])
{
        if(first_fun == NULL) return 0;
        else
        {
                struct symbol* current = first_fun;
                while(current != NULL)
                {
                        if(strcmp(current->name, nume)== 0) return 1;
                        else current = current->next;
                }
        }
        return 0;
}
void insert_fun(char tip[], char nume[],int dim, int valoare, char strg[], float fval)
{
        if(find_fun(nume)) {printf("Variabila existenta la linia %d", yylineno);exit(0);}
        else if(first_fun == NULL)
        {
                first_fun = (struct symbol*) malloc(sizeof(struct symbol));
                strcpy(first_fun->tip, tip);
                strcpy(first_fun->name, nume);
                first_fun->intv = valoare;
                strcpy(first_fun->strv, strg);
                first_fun->floatv = fval;
                first_fun->dim=dim;
                last_fun = first_fun;
                first_fun->next = last_fun;
                last_fun->next = NULL;
        }
        else
        {
                struct symbol* current = (struct symbol*) malloc(sizeof(struct symbol));
                strcpy(current->tip, tip);
                strcpy(current->name, nume);
                current->intv = valoare;
                current->dim=dim;
                strcpy(current->strv, strg);
                current->floatv = fval;
                last_fun->next = current;
                last_fun = current;
                current->next = NULL;
        }

}
%}
%union {
        int intval;
        char* strval;   
        float floatval;      
}
%type <strval> valstring
%type <floatval> valfloat
%type <intval> e
%type <strval> ef

%token <strval>TYPE
%token <strval>ID BGIN END 
%token <intval>INTV <strval>CHARV <floatval>FLOATV <strval>STRV <strval>ARRAY <strval>CONST <intval>BOOLV
%token FOR WHILE DO IF ELSE <strval>STRUCTURE <strval>FUNCTION
%token <strval>ASSIGN PLUS MINUS MULTIPLY DIVIDE INCR DECR 
%token EQ LWE LW GR GRE DIF AND OR
%token EVAL TYPEOF
%start program
%right ASSIGN
%left OR
%left AND
%left DIF EQ
%left LWE LW GR GRE
%left PLUS MINUS
%left MULTIPLY DIVIDE
%left INCR DECR
%%
program: declaratii functii structuri bloc {printf("program corect sintactic\n");}
       ; 
/* declaratii */ 
declaratii: declaratie ';'
          | declaratii declaratie ';'
          ;
declaratie : lista_id // ex: int _A1, _A2; char _C1, _C2;
           | lista_const // ex: const int _Con1 = 23; const bool _B1 = 0;
           | lista_array //ex: int array _Ar1, _Ar2;
           ;
lista_id: TYPE ID {snprintf(buff, 150, "%s %s \n", $1, $2); write(fd, buff, strlen(buff)); insert_var($1,$2,0,0,"",0);}
        | TYPE ID {snprintf(buff, 150, "%s %s \n", $1, $2); write(fd, buff, strlen(buff));memset(type,'\0',strlen(type));
                 strcpy(type, $1);insert_var($1,$2,0,0,"",0);}',' multi_id
        ;
multi_id: ID {write(fd, type, strlen(type)); snprintf(buff, 150, " %s \n", $1); write(fd, buff, strlen(buff));
                insert_var(type,$1,0,0,"",0);}',' multi_id
        | ID {write(fd, type, strlen(type));snprintf(buff, 150, "%s\n", $1); write(fd, buff, strlen(buff));insert_var(type,$1,0,0,"",0);}
        ;
lista_const: CONST TYPE ID ASSIGN INTV { if(strstr($2,"int")==NULL){
                                                yyerror("Variabila este de alt tip! ");
                                        } else{
                                                snprintf(buff, 150, "%s %s %s %s %d\n", $1, $2, $3, $4, $5); write(fd, buff, strlen(buff)); 
                                                memset(type,'\0',strlen(type)); strcpy(type, $1); strcat(type," " ); strcat(type, $2);                                                                              
                                                insert_var(type,$3,0,atoi($4),"",0);
                                        }}
            | CONST TYPE ID ASSIGN BOOLV {if(strstr($2,"bool")==NULL || $5<0 || $5>1){
                                                yyerror("Variabila este de alt tip! ");
                                        }  else{
                                                snprintf(buff, 150, "%s %s %s %s %d\n", $1, $2, $3, $4, $5); write(fd, buff, strlen(buff)); 
                                                memset(type,'\0',strlen(type)); strcpy(type, $1); strcat(type," " ); strcat(type, $2);
                                                insert_var(type,$3,0,atoi($4),"",0);
                                        }}
            | CONST TYPE ID ASSIGN valstring {if(strstr($2,"string")==NULL){
                                                yyerror("Variabila este de alt tip! ");
                                        }  else{
                                                snprintf(buff, 150, "%s %s %s %s %s\n", $1, $2, $3, $4, $5); write(fd, buff, strlen(buff)); 
                                                memset(type,'\0',strlen(type)); strcpy(type, $1); strcat(type," " ); strcat(type, $2);
                                                insert_var(type,$3,0,0,$4,0);
                                        }}
            | CONST TYPE ID ASSIGN valfloat {if(strstr($2,"float")==NULL){
                                                yyerror("Variabila este de alt tip! ");
                                        }  else{
                                                snprintf(buff, 150, "%s %s %s %s %f\n", $1, $2, $3, $4, $5); write(fd, buff, strlen(buff)); 
                                                memset(type,'\0',strlen(type)); strcpy(type, $1); strcat(type," " ); strcat(type, $2);
                                                insert_var(type,$3,0,0,"",atof($4));
                                        }} 
           ;
lista_array: ARRAY TYPE ID '[' INTV ']' {snprintf(buff, 150, "%s %s %s[%d] \n", $1, $2, $3,$5); write(fd, buff, strlen(buff));                                        
                                        memset(type,'\0',strlen(type)); strcpy(type, $1); strcat(type," " ); strcat(type, $2);
                                        insert_var(type,$3,$5,0,"",0);}
           | ARRAY TYPE ID '[' INTV ']' {snprintf(buff, 150, "%s %s %s[%d] \n, ", $1, $2, $3,$5); write(fd, buff, strlen(buff));                                        
                                        memset(type,'\0',strlen(type)); strcpy(type, $1); strcat(type," " ); strcat(type, $2);
                                        insert_var(type,$3,$5,0,"",0);}',' multi_array 
           ; 
multi_array:  ID '[' INTV ']' {write(fd, type, strlen(type));snprintf(buff, 150, "%s %s[%d] \n", type, $1,$3); 
                                        write(fd, buff, strlen(buff));insert_var(type,$1,$3,0,"",0);}',' multi_array  
           |  ID '[' INTV ']' {write(fd, type, strlen(type));snprintf(buff, 150, "%s %s[%d] \n", type, $1, $3);
                                         write(fd, buff, strlen(buff));insert_var(type,$1,$3,0,"",0);}
           ;
valfloat: FLOATV { $$= $1; }
        ;
valstring: CHARV { $$= $1; } 
         | STRV { $$= $1; } 
         ;
/*functii*/
functii : functie ';'
        | functii functie ';'
        ;
functie : FUNCTION TYPE ID '(' {nr_el=0;}lista_parametri ')'  '{' instructiuni '}' {snprintf(buff, 150, "%s %s %s\n", $1, $2, $3);
                                                                        insert_fun($2,$3,nr_el,0,"",0);
                                                                         write(fd1, buff, strlen(buff));}
        | FUNCTION TYPE ID '(' ')' '{' instructiuni '}' {snprintf(buff, 150, "%s %s %s \n:  ", $1, $2, $3); insert_fun($2,$3,0,0,"",0);
                                                         write(fd1, buff, strlen(buff));}
        ;
us_functii: ID '(' ')'  {
                                struct symbol *id = first_fun; int ok=0;
                                while(id->next != NULL) {
                                        if(strcmp(id->name, $1)== 0){
                                                ok=1;
                                                if(id->dim!=0){
                                                        yyerror("Nu ati folosit toti parametrii \n");
                                                }
                                                break; 
                                        }
                                        else id = id->next;
                                }if(ok==0){
                                        yyerror("Functia nu este declarata\n");
                                }  
                        }
          | ID '(' lista_parametri ')'  {
                                struct symbol *id = first_fun; int ok=0;
                                while(id->next != NULL) {
                                        if(strcmp(id->name, $1)== 0){
                                                ok=1;
                                                if(id->dim!=nr_el){
                                                        yyerror("Nu ati folosit toti parametrii \n");
                                                }
                                                break; 
                                        }
                                        else id = id->next;
                                }if(ok==0){
                                        yyerror("Functia nu este declarata\n");
                                }  
                        }
          | EVAL '(' e ')'  
          | TYPEOF '(' ef ')'  
          ;
lista_parametri : lista_parametri ',' parametru {nr_el++;}
                | parametru {nr_el++;}
                ;
parametru : TYPE ID {snprintf(buff, 150, "%s %s \n", $1, $2); write(fd, buff, strlen(buff));}
          | CONST TYPE ID {snprintf(buff, 150, "%s %s %s\n ", $1, $2, $3); write(fd, buff, strlen(buff));}
          | ARRAY TYPE ID '[' INTV ']' {snprintf(buff, 150, "%s %s %s ", $1, $2, $3); write(fd, buff, strlen(buff));}
          | ID
          ;
/* structuri */
structuri: structura ';'
         | structuri structura ';'
         ;
structura: STRUCTURE ID '{' instructiuni '}'  {snprintf(buff, 150, "%s %s \n", $1, $2); write(fd1, buff, strlen(buff));}
        |  STRUCTURE ID '{' '}'   {snprintf(buff, 150, "%s %s \n", $1, $2); write(fd1, buff, strlen(buff));}
        ;
/* bloc */
bloc : BGIN '{' instructiuni '}' END 
     ;
instructiuni: instructiune ';'
            | instructiuni instructiune ';'
            ;
/* instructiune */
instructiune: asignari
            | if_st
            | while_loop
            | do_while
            | for_loop
            | us_functii
            | declaratie
            ;
asignari: asignare
        | asignari asignare
        ;
arg : valfloat { nr_el++;
        if(strstr(type,"float")==NULL){
                yyerror("Variabila este de alt tip! \n");
                nr_el--;
        }
        else if(nr_permis<nr_el){
                yyerror("Prea multe elemente!\n ");
        }
    }',' arg
    | valstring{ nr_el++;
        if(strstr(type,"string")==NULL){
                yyerror("Variabila este de alt tip! \n");
                nr_el--;
        }
        else if(nr_permis<nr_el){
                yyerror("Prea multe elemente!\n ");
        }
    } ',' arg
    | INTV{ nr_el++;
        if(strstr(type,"int")==NULL){
                yyerror("Variabila este de alt tip! \n");
                nr_el--;
        }
        else if(nr_permis<nr_el){
                yyerror("Prea multe elemente!\n ");
        }
    } ',' arg
    | valfloat{ nr_el++;
        if(strstr(type,"float")==NULL){
                yyerror("Variabila este de alt tip! \n");
                nr_el--;
        }
        else if(nr_permis<nr_el){
                yyerror("Prea multe elemente!\n ");
        }
    }
    | valstring{ nr_el++;
        if(strstr(type,"string")==NULL){
                yyerror("Variabila este de alt tip! \n");
                nr_el--;
        }
        else if(nr_permis<nr_el){
                yyerror("Prea multe elemente!\n ");
        }
    }
    | INTV { nr_el++; 
        if(strstr(type,"int")==NULL){
                yyerror("Variabila este de alt tip! \n");
                nr_el--;
        }
        else if(nr_permis<nr_el){
                yyerror("Prea multe elemente!\n ");
        }
    }
    ;
asignare: ID ASSIGN FLOATV{
                        struct symbol *id = first_sym; int ok=0;
                        while(id->next != NULL) {
                                if(strcmp(id->name, $1)== 0){
                                        ok=1;
                                        if(strstr(id->tip,"const")!=NULL){
                                                yyerror("Variabila este constanta! \n");
                                        }
                                        if(strstr(id->tip,"float")==NULL){
                                                yyerror("Variabila este de alt tip! \n");
                                        }
                                        break; 
                                }
                                else id = id->next;
                        }if(ok==0){
                                yyerror("Variabila nu este declarata\n");
                        }
        }
        | ID ASSIGN '{'{
                        struct symbol *id = first_sym; int ok=0;
                        while(id->next != NULL) {
                                if(strcmp(id->name, $1)== 0){
                                        ok=1;
                                        nr_permis=id->dim;
                                        nr_el=0;
                                        memset(type,'\0',strlen(type));
                                        strcpy(type,id->tip);
                                        break; 
                                }
                                else id = id->next;
                        }if(ok==0){
                                yyerror("Variabila nu este declarata\n");
                        }} arg '}'
        | ID ASSIGN CHARV {
                        struct symbol *id = first_sym; int ok=0;
                        while(id->next != NULL){
                                if(strcmp(id->name, $1)== 0){
                                        ok=1;
                                        if(strstr(id->tip,"const")!=NULL){
                                                yyerror("Variabila este constanta! \n");
                                        }
                                        if(strstr(id->tip,"char")==NULL){
                                                yyerror("Variabila este de alt tip! \n");
                                        }
                                        break;
                                }
                                else id = id->next;
                        }if(ok==0){
                                yyerror("Variabila nu este declarata \n");
                        }
        }
        | ID ASSIGN e {
                struct symbol *id = first_sym; int ok=0;
                        while(id->next != NULL){
                                if(strcmp(id->name, $1)== 0){
                                        ok=1;               
                                        if(strstr(id->tip,"const")!=NULL){
                                                yyerror("Variabila este constanta! \n");
                                        }                         
                                        if(strstr(id->tip,"int")==NULL){
                                                yyerror("Variabila este de alt tip! \n");
                                        }                                        
                                        break;
                                }
                                else id = id->next;
                        }if(ok==0){
                                yyerror("Variabila nu este declarata \n");
                        }
        }
        | ID ASSIGN conditie {
                struct symbol *id = first_sym; int ok=0;
                        while(id->next != NULL){
                                if(strcmp(id->name, $1)== 0){
                                        ok=1;
                                        if(strstr(id->tip,"const")!=NULL){
                                                yyerror("Variabila este constanta! \n");
                                        }
                                        if(strstr(id->tip,"bool")==NULL){
                                                yyerror("Variabila este de alt tip!\n ");
                                        } break;
                                }
                                else id = id->next;
                        }if(ok==0){
                                yyerror("Variabila nu este declarata \n");
                        }
        }
        ;
ef: ef PLUS ef { if(strcmp($1, $3))  {
        yyerror("Variabile de tip diferit");}
        $$ = $1; }
    | ef MINUS ef   { if(strcmp($1, $3))  {
        yyerror("Variabile de tip diferit");}
        $$ = $1;}
    | ef DIVIDE ef     { if(strcmp($1, $3))  {
        yyerror("Variabile de tip diferit");}
        $$=$1;}
    | ef MULTIPLY ef   { if(strcmp($1, $3))  {
        yyerror("Variabile de tip diferit");}
        $$=$1;}
    | '(' ef ')' { $$ = $2;}
    | ID   {
        struct symbol *id = first_sym; int ok=0; char t[100] = " ";
        while(id!= NULL){
                if(strcmp(id->name, $1)== 0){
                        ok = 1;
                        strcpy(t, id->tip);
                }
                else id = id->next;
        }if(ok==0){
                yyerror("Variabila nu este declarata ");
        }
        $$ = t;
    }
    | INTV {$$= "int";}
    | FLOATV {$$= "float";}
    ;
e: e PLUS e {$$ = $1 + $3;}
 | e MINUS e {$$ = $1 - $3;}
 | e MULTIPLY e {$$ = $1 * $3;}
 | e DIVIDE e { $$ = $1 / $3;}
 | INCR e{$$ = $2 + 1;}
 | DECR e {$$ = $2 - 1;}
 | '(' e ')' {$$ = $2;}
 | ID {
        struct symbol *id = first_sym; int ok=0;
        while(id->next != NULL){
                if(strcmp(id->name, $1)== 0){
                        ok=1;
                        if(strstr(id->tip,"int")==NULL){
                                yyerror("Variabila este de alt tip! ");
                        } break;
                }
                else id = id->next;
        }if(ok==0){
                yyerror("Variabila nu este declarata ");
        }
}
 
 | INTV {$$ = $1;}
 ;
 conditie: '(' conditie ')'
         | conditie AND conditie
         | conditie OR conditie
         | e expresie_bo e
         | BOOLV
expresie_bo : EQ 
            | GRE 
            | GR 
            | LWE
            | LW 
            | DIF 
            ;
if_st : IF '(' conditie ')' '{' instructiuni '}'
      | IF '(' conditie ')' '{' instructiuni '}' ELSE '{' instructiuni '}'
      ;
while_loop : WHILE '(' conditie ')' '{' instructiuni '}' 
           ;
do_while : DO '{' instructiuni '}' WHILE '(' conditie ')'
         ;
for_loop : FOR '(' ID ';' conditie ';' e ')' '{' instructiuni '}'
         ;
%%

int yyerror(char * s){
        printf("eroare: %s la linia:%d\n",s,yylineno);
        exit(0);
}
int main(int argc, char** argv){
        fd = open("symbol_table.txt", O_RDWR);
        fd1 = open("symbol_table_functions.txt", O_RDWR);
        yyin=fopen(argv[1],"r");
        yyparse();
}