#include <iostream>
#include "ast.h"
#include "json.hpp"
#include <vector>
#include <map>

using json = nlohmann::json;
using namespace std;

extern int yyparse();
extern ASTNode* root;

extern vector<string> tokens;
extern map<string, pair<string,int>> symbol_table;
extern vector<string> errors;

int main() {
    yyparse();

    json output;

    output["tokens"] = tokens;

    json symtab = json::array();
    for (auto &entry : symbol_table) {
        symtab.push_back({
            {"name", entry.first},
            {"type", entry.second.first},
            {"occurrences", entry.second.second}
        });

        if (entry.second.second == 0) {
            errors.push_back("Unused variable: " + entry.first);
        }
    }

    output["symbol_table"] = symtab;

    if (root) {
        output["ast"] = root->toJson();
    }

    vector<string> ir_code;
    if (root) {
        root->generateIR(ir_code);
    }
    output["ir"] = ir_code;

    output["errors"] = errors;

    cout << output.dump(4) << endl;

    return 0;
}
