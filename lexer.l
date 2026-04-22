%option noyywrap

%{
#include "ast.h"
#include "parser.tab.h"
#include <stdlib.h>
#include <string.h>
#include <vector>
#include <string>

using namespace std;

vector<string> tokens;
%}

%%

"int"      { tokens.push_back("INT"); return INT; }
"if"       { tokens.push_back("IF"); return IF; }
"else"     { tokens.push_back("ELSE"); return ELSE; }
"while"    { tokens.push_back("WHILE"); return WHILE; }

"<"        { tokens.push_back("LT"); return LT; }

"{"        { tokens.push_back("LBRACE"); return LBRACE; }
"}"        { tokens.push_back("RBRACE"); return RBRACE; }

"("        { tokens.push_back("LPAREN"); return LPAREN; }
")"        { tokens.push_back("RPAREN"); return RPAREN; }

[0-9]+     { tokens.push_back(string("NUM(") + yytext + ")"); yylval.num = atoi(yytext); return NUMBER; }

[a-zA-Z_]+ { tokens.push_back(string("ID(") + yytext + ")"); yylval.str = strdup(yytext); return IDENTIFIER; }

"+"        { tokens.push_back("PLUS"); return PLUS; }
"="        { tokens.push_back("ASSIGN"); return ASSIGN; }
";"        { tokens.push_back("SEMICOLON"); return SEMICOLON; }

[ \t\n]    { }

.          { return yytext[0]; }

%%