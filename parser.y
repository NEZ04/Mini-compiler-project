%{
#include <iostream>
#include <cstdio>
#include <cstdlib>
#include "ast.h"
#include <map>
#include <string>
#include <vector>

using namespace std;

extern int yylex();
void yyerror(const char *s);

ASTNode* root;
map<string, pair<string,int>> symbol_table;
vector<string> errors;
%}

%union {
    int num;
    char* str;
    ASTNode* node;
}

%token <num> NUMBER
%token <str> IDENTIFIER
%token INT IF ELSE WHILE
%token PLUS ASSIGN SEMICOLON
%token LT
%token LBRACE RBRACE LPAREN RPAREN

%left PLUS

%type <node> program statement_list statement expression condition

%%

program:
    statement_list { root = $1; }
;

statement_list:
    statement { $$ = $1; }
    | statement_list statement { $$ = $2; }
;

statement:
    INT IDENTIFIER SEMICOLON
    {
        if (symbol_table.find($2) != symbol_table.end()) {
            errors.push_back(string("Redeclaration of variable: ") + $2);
        } else {
            symbol_table[$2] = {"int", 0};
        }
        $$ = nullptr;
    }
    | IDENTIFIER ASSIGN expression SEMICOLON
    {
        if (symbol_table.find($1) == symbol_table.end()) {
            errors.push_back(string("Undeclared variable: ") + $1);
        } else {
            symbol_table[$1].second++;
        }
        $$ = new AssignNode($1, $3);
    }
    | IF LPAREN condition RPAREN LBRACE statement_list RBRACE
    {
        $$ = $6;
    }
    | IF LPAREN condition RPAREN LBRACE statement_list RBRACE
      ELSE LBRACE statement_list RBRACE
    {
        $$ = $6;
    }
    | WHILE LPAREN condition RPAREN LBRACE statement_list RBRACE
    {
        $$ = $6;
    }
;

expression:
    NUMBER { $$ = new NumberNode($1); }
    | IDENTIFIER
    {
        if (symbol_table.find($1) == symbol_table.end()) {
            errors.push_back(string("Undeclared variable used: ") + $1);
        } else {
            symbol_table[$1].second++;
        }
        $$ = new IdentifierNode($1);
    }
    | expression PLUS expression
    {
        $$ = new BinaryOpNode("+", $1, $3);
    }
;

condition:
    expression LT expression
    {
        $$ = new BinaryOpNode("<", $1, $3);
    }
;

%%

void yyerror(const char *s) {
    errors.push_back(string("Syntax Error: ") + s);
}