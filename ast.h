#ifndef AST_H
#define AST_H

#include <string>
#include <vector>
#include "json.hpp"

using json = nlohmann::json;
using namespace std;

/* ?? FIX: extern (C++11 safe) */
extern int tempCount;

/* temp generator */
inline string newTemp() {
    return "t" + to_string(++tempCount);
}

/* Base */
class ASTNode {
public:
    virtual json toJson() = 0;
    virtual string generateIR(vector<string>& code) = 0;
};

/* Number */
class NumberNode : public ASTNode {
public:
    int value;

    NumberNode(int v) : value(v) {}

    json toJson() override {
        return {
            {"type", "number"},
            {"value", value}
        };
    }

    string generateIR(vector<string>& code) override {
        return to_string(value);
    }
};

/* Identifier */
class IdentifierNode : public ASTNode {
public:
    string name;

    IdentifierNode(char* n) : name(n) {}

    json toJson() override {
        return {
            {"type", "identifier"},
            {"name", name}
        };
    }

    string generateIR(vector<string>& code) override {
        return name;
    }
};

/* Binary Operation */
class BinaryOpNode : public ASTNode {
public:
    string op;
    ASTNode* left;
    ASTNode* right;

    BinaryOpNode(string o, ASTNode* l, ASTNode* r)
        : op(o), left(l), right(r) {}

    json toJson() override {
        return {
            {"type", "binary"},
            {"op", op},
            {"left", left->toJson()},
            {"right", right->toJson()}
        };
    }

    string generateIR(vector<string>& code) override {
        string leftVal = left->generateIR(code);
        string rightVal = right->generateIR(code);

        string temp = newTemp();
        code.push_back(temp + " = " + leftVal + " " + op + " " + rightVal);

        return temp;
    }
};

/* Assignment */
class AssignNode : public ASTNode {
public:
    string name;
    ASTNode* value;

    AssignNode(char* n, ASTNode* v)
        : name(n), value(v) {}

    json toJson() override {
        return {
            {"type", "assign"},
            {"name", name},
            {"value", value->toJson()}
        };
    }

    string generateIR(vector<string>& code) override {
        string val = value->generateIR(code);
        code.push_back(name + " = " + val);
        return name;
    }
};

#endif
