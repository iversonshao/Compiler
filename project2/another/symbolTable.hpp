#include <iostream>
#include <string.h>
#include <string>
#include <vector>
#include <sstream>
using namespace std;

enum DataType{
    iNT,
    rEAL,
    bOOL,
    sTRING,
    vOID,
    aRRAY
};

struct ID{
    int const_var_array_function_prod = 0; // 1: const, 2: var, 3: array 4: function 5: procedure
    string name;               // identifier's name
    int data_type;
    ID(){
        const_var_array_function_prod = 0;
        name = "";
        data_type = iNT;
    }
    ID(int vvaf, const char *s, int type){
        const_var_array_function_prod = vvaf;
        name = s;
        data_type = type;
    }
};

struct SymbolTable{
    int layer = 0; // layer of symbol table
    vector<ID> id; // identifier
    SymbolTable *previous = nullptr;
    SymbolTable *next = nullptr;
};

SymbolTable *head = nullptr;
SymbolTable *cur_table = nullptr;
SymbolTable *temp_table = nullptr;


void create(){
    SymbolTable *newSymbolTable = new SymbolTable();
    newSymbolTable->id.clear();

    if (head == nullptr){
        newSymbolTable->layer = 0; // 1st symbol table
        newSymbolTable->previous = nullptr;

        head = newSymbolTable;
        cur_table = head;
    }
    else{
        newSymbolTable->layer = cur_table->layer + 1;
        newSymbolTable->previous = cur_table;

        // set current table
        cur_table->next = newSymbolTable;
        cur_table = newSymbolTable;
    }
}

ID lookup(const char *s){
    SymbolTable *iter_table = head;
    while (iter_table != nullptr){
        for (int i = 0; i < iter_table->id.size(); i++){
            if (iter_table->id[i].name == s){
                return iter_table->id[i];
            }
        }
        iter_table = iter_table->next;
    }
    return ID(0, "", iNT);
}

void insert(int vvaf, const char *s, int type)
{
    ID newID = ID(vvaf, s, type);
    cur_table->id.push_back(newID);
}

void dump()
{
    cout << "-----Start to dump symbol table-----" << endl;
    SymbolTable *iter_table = head;
    while (iter_table != nullptr){
        cout << "number of symbol table: " << iter_table->layer << endl;
        for (int i = 0; i < iter_table->id.size(); i++){
            string temp_data_type = "";
            if (iter_table->id[i].data_type == iNT){
                temp_data_type = "INT";
            }
            else if (iter_table->id[i].data_type == rEAL)
            {
                temp_data_type = "REAL";
            }
            else if (iter_table->id[i].data_type == bOOL)
            {
                temp_data_type = "BOOL";
            }
            else if (iter_table->id[i].data_type == sTRING)
            {
                temp_data_type = "STRING";
            }
            else if (iter_table->id[i].data_type == vOID)
            {
                temp_data_type = "VOID";
            }
            else if (iter_table->id[i].data_type == aRRAY)
            {
                temp_data_type = "ARRAY";
            }

            if (iter_table->id[i].const_var_array_function_prod == 1)
            {
                cout << i << ": " << iter_table->id[i].name << " "
                     << "  constant  " << temp_data_type << endl;
            }
            else if (iter_table->id[i].const_var_array_function_prod == 2)
            {
                cout << i << ": " << iter_table->id[i].name << " "
                     << "  variable  " << temp_data_type << endl;
            }
            else if (iter_table->id[i].const_var_array_function_prod == 3)
            {
                cout << i << ": " << iter_table->id[i].name << " "
                     << "  array  " << temp_data_type << endl;
            }
            else if (iter_table->id[i].const_var_array_function_prod == 4)
            {
                cout << i << ": " << iter_table->id[i].name << " "
                     << "  function  " << temp_data_type << endl;
            }
            else if (iter_table->id[i].const_var_array_function_prod == 5)
            {
                cout << i << ": " << iter_table->id[i].name << " "
                     << "  procedure  " << temp_data_type << endl;
            }
        }
        iter_table = iter_table->next;
    }
    cout << "-----dump symbol table end-----" << endl;
}
