HOW TO RUN MINI COMPILER PROJECT

STEP 1: Open Terminal in Project Folder cd C:

STEP 2: Build the Compiler:-
bison -d parser.y
flex lexer.l
g++ -std=c++11 lex.yy.c parser.tab.c main.cpp utils.cpp -o compiler.exe

STEP 3: Verify Build dir Check if compiler.exe is present

STEP 4: Run Compiler Directly (Optional) compiler.exe Type code: int a;
a = 5; End input with Ctrl + Z + Enter

STEP 5: Start Backend (Flask) python server.py

STEP 6: Open UI Open browser and go to: http://127.0.0.1:5000

STEP 7: Use Compiler - Write code - Click Compile - View Tokens, Symbol
Table, AST, IR, Errors

FLOW: Frontend → Flask → compiler.exe → JSON → UI

COMMON ISSUES: - No output: Flask not running - Old output: rebuild and
restart Flask - compiler.exe missing: build failed

QUICK RUN: bison -d parser.y flex lexer.l g++ -std=c++11 lex.yy.c
parser.tab.c main.cpp utils.cpp -o compiler.exe python server.py

Sample Test Cases:-
Test Case 1:-
int a;
int b;
float c;

a = 5;

if (a < b) {
    c = a + b;
}

b = c;

Test Case 2:-
int a;
int b;

a = 1;
b = 5;

while (a < b) {
    if (a < 3) {
        a = a + 1;
    } else {
        b = b + a;
    }
}
Test Case 3:-
int a;
float b;
a = 5;
b = a + 10;
if (a < b) {
    a = a + b;
} else {
    b = b + a;
}

