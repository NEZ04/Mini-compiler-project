#include <string>
using namespace std;

int tempCount = 0;
int labelCount = 0;

string newTemp() {
    return "t" + to_string(++tempCount);
}

string newLabel() {
    return "L" + to_string(++labelCount);
}
