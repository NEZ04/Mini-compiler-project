%{
#include <iostream>
#include "ast.h"
#include <map>
#include <vector>
#include <string>

using namespace std;

extern int yylex();
extern int yylineno;
void yyerror(const char *s);

ASTNode* root;

map<string, pair<string,int>> symbol_table;
vector<string> errors;

string getType(ASTNode* node) {
    if (dynamic_cast<NumberNode*>(node)) return "int";
    if (auto id = dynamic_cast<IdentifierNode*>(node)) {
        if (symbol_table.find(id->name) != symbol_table.end())
            return symbol_table[id->name].first;
    }
    if (auto bin = dynamic_cast<BinaryOpNode*>(node)) {
        string l = getType(bin->left);
        string r = getType(bin->right);
        if (l == r) return l;
        return "type_error";
    }
    return "unknown";
}
%}

%union {
    int num;
    char* str;
    ASTNode* node;
}

%token <num> NUMBER
%token <str> IDENTIFIER
%token INT FLOAT IF ELSE WHILE
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
        if (symbol_table.find($2) != symbol_table.end())
            errors.push_back("Line " + to_string(yylineno) + ": Redeclaration of " + string($2));
        else
            symbol_table[$2] = {"int",0};
        $$ = nullptr;
    }

    | FLOAT IDENTIFIER SEMICOLON
    {
        if (symbol_table.find($2) != symbol_table.end())
            errors.push_back("Line " + to_string(yylineno) + ": Redeclaration of " + string($2));
        else
            symbol_table[$2] = {"float",0};
        $$ = nullptr;
    }

    | IDENTIFIER ASSIGN expression SEMICOLON
    {
        if (symbol_table.find($1) == symbol_table.end()) {
            errors.push_back("Line " + to_string(yylineno) + ": Undeclared variable " + string($1));
        } else {
            symbol_table[$1].second++;
            string lhsType = symbol_table[$1].first;
            string rhsType = getType($3);

            if (lhsType != rhsType) {
                errors.push_back("Line " + to_string(yylineno) + ": Type mismatch");
            }
        }
        $$ = new AssignNode($1,$3);
    }

    | IF LPAREN condition RPAREN LBRACE statement_list RBRACE
    {
        $$ = new IfNode($3,$6);
    }

    | IF LPAREN condition RPAREN LBRACE statement_list RBRACE
      ELSE LBRACE statement_list RBRACE
    {
        $$ = new IfNode($3,$6,$10);
    }

    | WHILE LPAREN condition RPAREN LBRACE statement_list RBRACE
    {
        $$ = new WhileNode($3,$6);
    }
;

expression:
    NUMBER { $$ = new NumberNode($1); }

    | IDENTIFIER
    {
        if (symbol_table.find($1) == symbol_table.end())
            errors.push_back("Line " + to_string(yylineno) + ": Undeclared variable " + string($1));
        else
            symbol_table[$1].second++;

        $$ = new IdentifierNode($1);
    }

    | expression PLUS expression
    {
        $$ = new BinaryOpNode("+",$1,$3);
    }
;

condition:
    expression LT expression
    {
        $$ = new BinaryOpNode("<",$1,$3);
    }
;

%%

void yyerror(const char *s) {
    errors.push_back("Line " + to_string(yylineno) + ": Syntax Error");
}