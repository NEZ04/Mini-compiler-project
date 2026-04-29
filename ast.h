#pragma once
#include <string>
#include <vector>
#include <iostream>
#include "json.hpp"

using namespace std;
using json = nlohmann::json;

extern int tempCount;
extern int labelCount;

string newTemp();
string newLabel();

class ASTNode {
public:
    virtual json toJson() = 0;
    virtual string generateIR(vector<string>& code) = 0;
};

class NumberNode : public ASTNode {
public:
    int value;
    NumberNode(int v) : value(v) {}

    json toJson() {
        return {{"type","number"},{"value",value}};
    }

    string generateIR(vector<string>& code) {
        return to_string(value);
    }
};

class IdentifierNode : public ASTNode {
public:
    string name;
    IdentifierNode(string n) : name(n) {}

    json toJson() {
        return {{"type","identifier"},{"name",name}};
    }

    string generateIR(vector<string>& code) {
        return name;
    }
};

class BinaryOpNode : public ASTNode {
public:
    string op;
    ASTNode* left;
    ASTNode* right;

    BinaryOpNode(string o, ASTNode* l, ASTNode* r)
        : op(o), left(l), right(r) {}

    json toJson() {
        return {
            {"type","binary"},
            {"op",op},
            {"left",left->toJson()},
            {"right",right->toJson()}
        };
    }

    string generateIR(vector<string>& code) {
        string l = left->generateIR(code);
        string r = right->generateIR(code);
        string t = newTemp();
        code.push_back(t + " = " + l + " " + op + " " + r);
        return t;
    }
};

class AssignNode : public ASTNode {
public:
    string name;
    ASTNode* value;

    AssignNode(string n, ASTNode* v) : name(n), value(v) {}

    json toJson() {
        return {
            {"type","assign"},
            {"name",name},
            {"value",value->toJson()}
        };
    }

    string generateIR(vector<string>& code) {
        string v = value->generateIR(code);
        code.push_back(name + " = " + v);
        return name;
    }
};

class IfNode : public ASTNode {
public:
    ASTNode* condition;
    ASTNode* thenBranch;
    ASTNode* elseBranch;

    IfNode(ASTNode* c, ASTNode* t, ASTNode* e=nullptr)
        : condition(c), thenBranch(t), elseBranch(e) {}

    json toJson() {
        return {
            {"type","if"},
            {"condition",condition->toJson()},
            {"then",thenBranch ? thenBranch->toJson() : json()},
            {"else",elseBranch ? elseBranch->toJson() : json()}
        };
    }

    string generateIR(vector<string>& code) {
        string cond = condition->generateIR(code);
        string L1 = newLabel();
        string L2 = newLabel();

        code.push_back("if " + cond + " goto " + L1);
        code.push_back("goto " + L2);

        code.push_back(L1 + ":");
        if (thenBranch) thenBranch->generateIR(code);

        if (elseBranch) {
            string L3 = newLabel();
            code.push_back("goto " + L3);
            code.push_back(L2 + ":");
            elseBranch->generateIR(code);
            code.push_back(L3 + ":");
        } else {
            code.push_back(L2 + ":");
        }

        return "";
    }
};

class WhileNode : public ASTNode {
public:
    ASTNode* condition;
    ASTNode* body;

    WhileNode(ASTNode* c, ASTNode* b)
        : condition(c), body(b) {}

    json toJson() {
        return {
            {"type","while"},
            {"condition",condition->toJson()},
            {"body",body->toJson()}
        };
    }

    string generateIR(vector<string>& code) {
        string L1 = newLabel();
        string L2 = newLabel();

        code.push_back(L1 + ":");
        string cond = condition->generateIR(code);
        code.push_back("if " + cond + " goto " + L2);

        if (body) body->generateIR(code);

        code.push_back("goto " + L1);
        code.push_back(L2 + ":");

        return "";
    }
};
